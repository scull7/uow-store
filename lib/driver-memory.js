var bluebird      = require('bluebird');
var inherits      = require('util').inherits;
var EventEmitter  = require('events').EventEmitter;

function MemoryDriver() {
  this.store  = {};
}

inherits(MemoryDriver, EventEmitter);

/**
 * Store the given task object.
 * ----------------------------
 * @param {Task} task
 * @return {Promise::Task}
 * @throws {TypeError}
 */
MemoryDriver.prototype.create   = function(task) {

  var id          = task.id;

  if (!id) {
    return bluebird.reject(new TypeError('TaskIdNotPresent'));
  }

  if (this.store[id]) {
    return bluebird.reject(new TypeError('TaskIdExists'));
  }

  this.store[id]  = task;

  return bluebird.resolve(task);
};

/**
 * Replace the stored task object with the given object.
 * -----------------------------------------------------
 * @param {Task} task
 * @return {Promise::Task}
 * @throws {TypeError}
 */
MemoryDriver.prototype.update   = function(task) {
  var id  = task.id;

  if (!id) {
    return bluebird.reject(new TypeError('TaskIdNotPresent'));
  }

  if (!this.taskExists(id)) {
    return bluebird.reject(new RangeError('TaskNotFound'));
  }

  this.store[id]  = task;

  return bluebird.resolve(task);
};

/**
 * Does a task exist at the given identifier.
 * ------------------------------------------
 * @param {string} id
 * @return {boolean}
 */
MemoryDriver.prototype.exists   = function(id) {
  try {

    this.getById(id);

  } catch (e) {

    if (e instanceof RangeError) {
      return false;
    }

    throw e;
  }

  return true;
};

/**
 * Retrieve a task by it's identifier.
 * -----------------------------------
 * @param {string} id
 * @return {Promise::Task}
 * @throws {RangeError}
 */
MemoryDriver.prototype.getById  = function(id) {
  var task  = this.store[id];

  if (!task) {
    throw new RangeError('TaskNotFound');
  }

  return bluebird.resolve(task);
};

module.exports  = MemoryDriver;
