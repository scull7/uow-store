
MemoryDriver        = require '../../lib/driver-memory.js'

describe 'Memory Driver', ->
  driver  = null

  before -> driver = new MemoryDriver()

  describe '::create', ->

    it 'should be a function with an arity of one', ->
      expect(driver.create).to.be.a 'function'
      expect(driver.create.length).to.eql 1

  describe '::update', ->

    it 'should be a function with an arity of one', ->
      expect(driver.update).to.be.a 'function'
      expect(driver.update.length).to.eql 1

  describe '::exits', ->

    it 'should be a function with an arity of one', ->
      expect(driver.exists).to.be.a 'function'
      expect(driver.exists.length).to.eql 1

  describe '::getById', ->

    it 'should be a function with an arity of one', ->
      expect(driver.exists).to.be.a 'function'
      expect(driver.exists.length).to.eql 1
