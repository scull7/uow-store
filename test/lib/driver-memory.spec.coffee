
MemoryDriver        = require '../../lib/driver-memory.js'

describe 'Memory Driver', ->
  driver  = null

  before -> driver = new MemoryDriver()

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
