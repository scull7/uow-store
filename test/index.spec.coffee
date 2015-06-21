
MemoryDriver  = require '../lib/driver-memory.js'
LibStore      = require '../lib/store.js'
Store         = require '../index.js'

describe 'Store', ->

  it 'should provide access to the memory driver.', ->
    expect(Store.MemoryDriver).to.eql MemoryDriver

  it 'should return the lib/Store', ->
    expect(Store).to.eql LibStore
