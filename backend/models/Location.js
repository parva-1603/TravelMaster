const mongoose = require('mongoose');

const LocationSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  state: {
    type: String
  },
  country: {
    type: String,
    default: 'India'
  }
});

module.exports = mongoose.model('Location', LocationSchema);
