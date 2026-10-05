const mongoose = require('mongoose');

const packageSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    location: { type: String, required: true },
    price: { type: String, required: true },
    rating: { type: String, required: true },
    duration: { type: String, required: true },
    image: { type: String, required: true },
    isTrending: { type: Boolean, default: false },
    departureDates: [{ type: String }],
    categories: { type: mongoose.Schema.Types.Mixed },
    itinerary: [{ type: mongoose.Schema.Types.Mixed }],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Package', packageSchema);
