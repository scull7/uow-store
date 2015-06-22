var R             = require('ramda');
var bluebird      = require('bluebird');
var inherits      = require('util').inherits;
var EventEmitter  = require('events').EventEmitter;

// Default search delay is 500ms
var DEFAULT_SEARCH_DELAY  = 500;

function MemoryDriver(options) {
  options             = options || {};
  this.store          = {};

  this.isTaskReady    = options.isTaskReady || function(task) {
    return task.status === 'ready';
  };

  this.taskReadyDelay = options.taskReadySearchDelay || DEFAULT_SEARCH_DELAY;

  // Task search is off by default, Memory driver is intended for testing only.
  this.runTaskSearch  = options.runTaskSearch || false;

  if (this.runTaskSearch) {
    this.findReady(this.taskReadyDelay);
  }

}

inherits(MemoryDriver, EventEmitter);

/**
 * Search through the stored tasks to find any `ready` to process tasks.
 * ---------------------------------------------------------------------
 */
MemoryDriver.prototype.findReady  = function(delay) {

  if (delay) {
    return setTimeout(this.findReady.bind(this), delay);
  }

  var isReady   = R.filter(this.isTaskReady);
  var getReady  = R.pipe(R.values, isReady);

  R.map(function(task) {

    this.emit('task::ready', task.id);

  }.bind(this), getReady(this.store));

  if (this.runTaskSearch) {
    this.findReady(this.taskReadyDelay);
  }

};

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
