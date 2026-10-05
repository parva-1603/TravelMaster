require('dotenv').config();
const mongoose = require('mongoose');
const Package = require('./models/Package');

async function main() {
  const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/travelmaster';
  await mongoose.connect(MONGODB_URI);
  
  const packages = await Package.find();
  console.log("Total packages in MongoDB:", packages.length);
  console.log(packages);
}

main()
  .catch(console.error)
  .finally(() => mongoose.disconnect());
