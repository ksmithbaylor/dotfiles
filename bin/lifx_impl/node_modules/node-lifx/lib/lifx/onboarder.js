'use strict';

var EventEmitter = require('eventemitter3');
var tls = require('tls');
var fs = require('fs');
var util = require('util');
var _ = require('lodash');
var constants = require('../lifx').constants;
var Packet = require('../lifx').packet;

function Onboarder() {
  EventEmitter.call(this);

  this.socket = null;
  this.isSocketOpen = false;
}
util.inherits(Onboarder, EventEmitter);

Onboarder.prototype.init = function() {
  this.socket = tls.connect({
    host: '172.16.0.1',
    port: constants.LIFX_DEFAULT_PORT,
    cert: fs.readFileSync(process.cwd() + '/assets/cert_lcm.pem'),
    rejectUnauthorized: false
  }, function() {
    this.isSocketOpen = true;
    this.emit('connected');
  }.bind(this));

  this.socket.on('close', function(hadError) {
    this.isSocketOpen = false;
    if (hadError) {
      console.error('LIFX Onboard Client TCP connection closed due to a transmission error');
    } else {
      console.log('LIFX Onboard Client TCP connection closed');
    }
  }.bind(this));

  this.socket.on('data', function(msg) {
    console.log('DEBUG - ' + msg.toString('hex'));

    // Parse packet to object
    var parsedMsg = Packet.toObject(msg);

    // Check if packet is read successfully
    if (parsedMsg instanceof Error) {
      console.error('LIFX Client invalid packet header error');
      console.error('Packet: ', msg.toString('hex'));
      console.trace(parsedMsg);
    } else {
      // Convert type before emitting
      var messageTypeName = _.result(_.find(Packet.typeList, {id: parsedMsg.type}), 'name');
      if (messageTypeName !== undefined) {
        parsedMsg.type = messageTypeName;
      }
      this.emit('message', parsedMsg);
    }
  }.bind(this));

  this.socket.on('error', function(err) {
    console.error('LIFX Onboard Client TCP error');
    console.trace(err);
    this.socket.destroy();
    this.emit('error', err);
  }.bind(this));
};

exports.Onboarder = Onboarder;
