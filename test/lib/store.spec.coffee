MemoryDriver    = require '../../lib/driver-memory.js'
Store           = require '../../lib/store.js'

describe 'Store', ->
  driver  = null
  store   = null

  before ->
    driver  = new MemoryDriver()
    store   = new Store(driver)

  describe '::createTask', ->

    it 'should be a function with an arity of one', ->
      expect(store.createTask).to.be.a 'function'
      expect(store.createTask.length).to.eql 1

  describe '::updateTask', ->

    it 'should be a function with an arity of two', ->
      expect(store.updateTask).to.be.a 'function'
      expect(store.updateTask.length).to.eql 2

  describe '::getTaskById', ->

    it 'should be a function with an arity of one', ->
      expect(store.getTaskById).to.be.a 'function'
      expect(store.getTaskById.length).to.eql 1

  describe '::lockTask', ->

    it 'should be a function with an arity of three', ->
      expect(store.lockTask).to.be.a 'function'
      expect(store.lockTask.length).to.eql 3

  describe '::unlockTask', ->

    it 'should be a function with an arity of two', ->
      expect(store.unlockTask).to.be.a 'function'
      expect(store.unlockTask.length).to.eql 2
