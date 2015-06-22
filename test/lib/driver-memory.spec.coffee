bluebird            = require 'bluebird'
MemoryDriver        = require '../../lib/driver-memory.js'
TaskLock            = require 'uow-lock'

describe 'Memory Driver', ->
  driver  = null

  before -> driver = new MemoryDriver()

  describe '::findReady', ->

    beforeEach ->
      @clock       = sinon.useFakeTimers()
      driver       = new MemoryDriver()

      t1  = driver.create {
        id      : 'ready-1'
        name    : 'ready-task-one'
        status  : 'ready'
      }

      t2  = driver.create {
        id      : 'not-ready-1'
        name    : 'not-ready-task-one'
        status  : 'new'
      }

      t3  = driver.create {
        id      : 'ready-2'
        name    : 'ready-task-two'
        status  : 'ready'
      }

      t4  = driver.create {
        id      : 'not-ready-2'
        name    : 'not-ready-task-two'
        status  : 'new'
      }

      bluebird.join t1, t2, t3, t4

    afterEach -> @clock.restore()

    it 'should start the ready search if the option is set.', (done) ->
      tick        = @clock.tick.bind(@)
      initDriver  = new MemoryDriver({ runTaskSearch: true })

      initDriver.on 'task::ready', (taskId) ->
        expect(taskId).to.eql 'ready-on-start'
        done()

      t1  = initDriver.create {
        id      : 'ready-on-start'
        name    : 'ready-on-start'
        status  : 'ready'
      }

      .then -> tick 501

    it 'should emit ready events for all ready, unlocked tasks.', (done) ->
      readyTasks  = []

      driver.on 'task::ready', (taskId) ->
        readyTasks.push taskId

        if readyTasks.length >= 2
          setTimeout ->
            expect(readyTasks.length).to.eql 2
            expect(readyTasks.indexOf('not-ready-1')).to.eql -1
            expect(readyTasks.indexOf('not-ready-2')).to.eql -1
            done()

          , 5

      driver.findReady()
      @clock.tick(10)

    it 'should call the task after the set delay if search is turned on',
    (done) ->
      driver.runTaskSearch  = true
      driver.taskReadyDelay = 100
      readyTasks            = []
      tick                  = @clock.tick.bind(@)

      driver.on 'task::ready', (taskId) ->
        readyTasks.push taskId

        if readyTasks.length >= 3
          setTimeout ->
            expect(readyTasks.length).to.eql 3
            expect(readyTasks.indexOf('not-ready-1')).to.eql -1
            expect(readyTasks.indexOf('not-ready-2')).to.eql -1
            done()

          , 5

          tick 10

      driver.findReady()
      driver.getById 'ready-2'

      .then (task) ->

        task.status = 'success'
        driver.update task

      .then -> tick 101

  describe '::create', ->

    it 'should be a function with an arity of one', ->
      expect(driver.create).to.be.a 'function'
      expect(driver.create.length).to.eql 1

    it 'should throw an exception if the task object has an ID', ->
      task  = { name : 'bad' }

      driver.create task

      .then -> throw new Error('UnexpectedSuccess')

      .catch TypeError, (e) -> expect(e.message).to.eql 'TaskIdNotPresent'

    it 'should throw an exception if the task object already exists', ->
      task  = { id  : 'duplicate-id' }

      driver.create task

      .then (task) -> driver.create task

      .then -> throw new Error('UnexpectedSuccess')

      .catch TypeError, (e) -> expect(e.message).to.eql 'TaskIdExists'

    it 'should store the new task', ->

      task  = {
        id    : 'my-test-id'
        name  : 'my-test-name'
      }

      driver.create task

      .then (task) ->
        expect(task.id).to.eql 'my-test-id'
        expect(task.name).to.eql 'my-test-name'

        expect(driver.store['my-test-id']).to.eql task

  describe '::update', ->

    it 'should be a function with an arity of one', ->
      expect(driver.update).to.be.a 'function'
      expect(driver.update.length).to.eql 1

    it 'should throw a TypeError if the task doesn\'t have an ID', ->
      task  = { name : 'not-saved' }

      driver.update task

      .then -> throw new Error('UnexpectedSuccess')

      .catch TypeError, (e) -> expect(e.message).to.eql 'TaskIdNotPresent'

    it 'should throw a RangeError if the task is not found', ->

      task  =
        id    : 'not-found'
        name  : 'not-found-name'

      driver.update task

      .then -> throw new Error('UnexpectedSuccess')

      .catch RangeError, (e) -> expect(e.message).to.eql 'TaskNotFound'

    it 'should update the stored task', ->

      task  =
        id    : 'update-test'
        name  : 'update-test-name'

      driver.create task

      .then (task) ->
        task.updated  = 1
        driver.update task

      .then (task) ->
        expect(task.id).to.eql 'update-test'
        expect(task.name).to.eql 'update-test-name'
        expect(task.updated).to.eql 1

  describe '::getById', ->

    it 'should be a function with an arity of one', ->
      expect(driver.getById).to.be.a 'function'
      expect(driver.getById.length).to.eql 1

    it 'should throw a RangeError when the task is not found', ->
      task  =
        id    : 'not-found-id'
        name  : 'not-found-name'

      driver.getById(task.id)

      .then -> throw new Error('UnexpectedSuccess')

      .catch RangeError, (e) -> expect(e.message).to.eql 'TaskNotFound'

    it 'should return the saved task object', ->

      task  =
        id    : 'found-id'
        name  : 'found-name'

      driver.create task

      .then -> driver.getById 'found-id'

      .then (task) ->
        expect(task.id).to.eql 'found-id'
        expect(task.name).to.eql 'found-name'
