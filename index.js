var Store           = require('./lib/store.js');
var MemoryDriver    = require('./lib/driver-memory.js');

Store.MemoryDriver  = MemoryDriver;

module.exports      = Store;
