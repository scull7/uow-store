var Store           = require('./lib/store.js');
var MemoryDriver    = require('./lib/driver-memory.js');

Store.MemoryDriver  = MemoryDriver;

/**
 * Memory based storage example of using the Store object.
 * -------------------------------------------------------
 * @return {Store}
 */
Store.MemoryStore   = function() {
  var memoryDriver = new MemoryDriver();

  return new Store({ driver: memoryDriver });
};

module.exports      = Store;
