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

  return this.getById(id)

  .then(function() {

    this.store[id]  = task;

    return task;

  }.bind(this));

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
    return bluebird.reject(new RangeError('TaskNotFound'));
  }

  return bluebird.resolve(task);
};

module.exports  = MemoryDriver;
