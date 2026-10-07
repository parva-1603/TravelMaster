const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    bookingReference: { type: String, required: true, unique: true },
    packageName: { type: String, required: true },
    customerName: { type: String, default: 'Valued Traveler' },
    customerEmail: { type: String, default: 'customer@travelmaster.com' },
    customerPhone: { type: String, default: '+91 9876543210' },
    travelDate: { type: String, default: '15 Nov 2026' },
    category: { type: String, default: 'Standard' },
    amount: { type: Number, required: true, default: 25000 },
    paymentStatus: { type: String, enum: ['CONFIRMED', 'PENDING', 'CANCELLED'], default: 'CONFIRMED' },
    transactionId: { type: String },
    utrNumber: { type: String },
    startingCity: { type: String, default: '' },
    customDetails: { type: String, default: '' },
    // Structured transport selection from customize sheet
    selectedTransport: {
      name: { type: String, default: '' },
      mode: { type: String, default: '' },      // 'flight' or 'train'
      classType: { type: String, default: '' },
      departure: { type: String, default: '' },
      arrival: { type: String, default: '' },
      price: { type: Number, default: 0 },
    },
    // Structured hotel/resort selection from customize sheet
    selectedHotel: {
      name: { type: String, default: '' },
      type: { type: String, default: '' },      // 'Hotel' or 'Resort'
      rating: { type: String, default: '' },
      price: { type: Number, default: 0 },
      contact: { type: String, default: '' },
    },
    // Category-level train/flight selection (Economy/Standard/Luxury tier)
    selectedTrainCategory: { type: String, default: '' },
    // Connecting train details (if applicable)
    connectingTrain: {
      trainNumber: { type: String, default: '' },
      trainName: { type: String, default: '' },
      fromJunction: { type: String, default: '' },
      toJunction: { type: String, default: '' },
      departureTime: { type: String, default: '' },
      arrivalTime: { type: String, default: '' },
      price: { type: Number, default: 0 },
    },
    travelers: [
      {
        name: { type: String, default: '' },
        age: { type: String, default: '' },
        gender: { type: String, default: '' },
        aadharNo: { type: String, default: '' },
        aadharFile: { type: String, default: '' },
      }
    ]
  },
  { timestamps: true }
);

module.exports = mongoose.model('Booking', bookingSchema);
