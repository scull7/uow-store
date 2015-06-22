
MemoryDriver  = require '../lib/driver-memory.js'
LibStore      = require '../lib/store.js'
Store         = require '../index.js'

describe 'Store', ->

  it 'should provide access to the memory driver.', ->
    expect(Store.MemoryDriver).to.eql MemoryDriver

  it 'should return the lib/Store', ->
    expect(Store).to.eql LibStore

  describe 'MemoryStore', ->

    it 'should return a new store using a MemoryDriver', ->
      store = Store.MemoryStore()

      expect(store).to.be.an.instanceOf LibStore
      expect(store.driver).to.be.an.instanceOf MemoryDriver
