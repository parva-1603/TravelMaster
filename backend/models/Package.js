const mongoose = require('mongoose');

const PackageSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  location: {
    type: String,
    required: true
  },
  price: {
    type: String,
    required: true
  },
  rating: {
    type: String,
    default: '0.0'
  },
  duration: {
    type: String,
    required: true
  },
  image: {
    type: String,
    required: true
  },
  isTrending: {
    type: Boolean,
    default: false
  },
  category: {
    type: String,
    default: 'General' // e.g. Honeymoon, Family, Adventure
  }
}, { timestamps: true });

module.exports = mongoose.model('Package', PackageSchema);
