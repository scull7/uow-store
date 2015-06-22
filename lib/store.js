var bluebird          = require('bluebird');
var uuid              = require('uuid');
var inherits          = require('util').inherits;
var EventEmitter      = require('events').EventEmitter;
var TaskLock          = require('uow-lock');
var LockError         = TaskLock.LockError;

/**
 * Is the given task ready to process?
 * -----------------------------------
 * @param {Task} task
 * @return {boolean}
 */
function isTaskReady(task) {
  var after       = task.after || new Date().getTime();
  var delay       = task.delay || 0;

  return task.status === 'ready' &&
  ((after + delay) <= new Date().getTime()) &&
  !TaskLock.isTaskLocked(task);
}

function Store(options) {

  if (!options || !options.driver) {
    throw new TypeError('DriverNotPresent');
  }

  this.driver = options.driver;

  this.driver.on('task::ready', this.handleReadyTask.bind(this));
}

inherits(Store, EventEmitter);

/**
 * Handle a task ready event.
 * --------------------------
 * @param {string} taskId
 */
Store.prototype.handleReadyTask = function(taskId) {

  return this.getTaskById(taskId)

  .then(function(task) {

    if (isTaskReady(task)) {

      this.emit('ready', task);

    }

  }.bind(this));

};

/**
 * Persist the given task object.
 * ------------------------------
 * @param {Task} task
 * @return {Promise::Task}
 * @throws {TypeError}
 */
Store.prototype.createTask  = function(task) {
  if (task.id) {
    return bluebird.reject(new TypeError('InvalidTaskObject'));
  }

  task.id       = uuid.v4();

  if (typeof task.pickle === 'function') {
    task        = task.pickle();
  }

  return this.driver.create(task);
};

/**
 * Update the stored version of a task.
 * ------------------------------------
 * @param {string} workerId
 * @param {string} task
 * @return {Promise::Task}
 * @throws {TypeError}
 */
Store.prototype.updateTask    = function(workerId, task) {
  if (!task.id) {
    return bluebird.reject(new TypeError('InvalidTaskObject'));
  }

  return this.getTaskById(task.id)

  .then(function(storedTask) {

    if (
      TaskLock.isTaskLocked(storedTask) &&
      !TaskLock.isLockHolder(storedTask, workerId)
    ) {
      throw new LockError('TaskLocked');
    }

    return this.driver.update(task);

  }.bind(this));
};

/**
 * Retrieve a task by its assigned identifier.
 * -------------------------------------------
 * @param {string} id
 * @return {Promise::Task}
 * @throws {TypeError}
 * @throws {RangeError}
 */
Store.prototype.getTaskById   = function(id) {
  if (!id) {
    return bluebird.reject(new TypeError('TaskIdNotProvided'));
  }

  return this.driver.getById(id);
};

/**
 * Attempt to acquire a lock for the given task identifier.
 * --------------------------------------------------------
 * @param {string} workerId
 * @param {string} taskId
 * @param {Promise::Task}
 * @throws {TypeError}
 * @throws {RangeError}
 * @throws {LockError}
 */
Store.prototype.lockTask      = function(workerId, taskId, timeToLive) {
  if (!workerId) {
    return bluebird.reject(new TypeError('WorkerIdNotProvided'));
  }

  if (!taskId) {
    return bluebird.reject(new TypeError('TaskIdNotProvided'));
  }

  return this.getTaskById(taskId)

  .then(TaskLock.acquire.bind(null, timeToLive, workerId))

  .then(this.updateTask.bind(this, workerId));

};

/**
 * Release a lock from a task.
 * ---------------------------
 * @param {string} workerId
 * @param {string} taskId
 * @param {Promise::Task}
 * @param {TypeError}
 * @param {LockError}
 */
Store.prototype.unlockTask    = function(workerId, taskId) {
  if (!workerId) {
    return bluebird.reject(new TypeError('WorkerIdNotProvided'));
  }

  if (!taskId) {
    return bluebird.reject(new TypeError('TaskIdNotProvided'));
  }

  return this.getTaskById(taskId)

  .then(TaskLock.release.bind(null, workerId))

  .then(this.updateTask.bind(this, workerId));
};

module.exports  = Store;
