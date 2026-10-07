const mongoose = require('mongoose');
const Package = require('./models/Package');
const Location = require('./models/Location');
const Booking = require('./models/Booking');

const MONGODB_URI = "mongodb+srv://Vercel-Admin-TravelMaster:BjwhReHVZBr8VYRo@travelmaster.jtqamic.mongodb.net/?retryWrites=true&w=majority";

const packagesData = [
  {
    title: 'Kerala Backwaters & Houseboat Escape',
    location: 'Kerala',
    price: 'Rs. 25,000',
    rating: '4.9',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
    images: [
      'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1616190419596-e2839e7380d7?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1506461883276-594a12b11ea3?auto=format&fit=crop&w=1400&q=85'
    ],
    isTrending: true,
    departureDates: ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'],
    categories: {
      Economy: { price: 'Rs. 18,000', facilities: ['Standard Room', 'Breakfast Only', 'Shared Coach Transfers'] },
      Standard: { price: 'Rs. 25,000', facilities: ['3-Star Hotel', 'Breakfast & Dinner', 'Private Cab Transfers'] },
      Luxury: { price: 'Rs. 45,000', facilities: ['5-Star Premium Houseboat', 'All Meals Included', 'Private SUV', 'Ayurvedic Spa'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Kochi & Heritage Walk', description: 'Upon arrival at Kochi International Airport, check in and explore Fort Kochi, Chinese Fishing Nets, and Santa Cruz Basilica.' },
      { day: 2, title: 'Munnar Tea Gardens & Waterfalls', description: 'Scenic drive to Munnar. Visit Cheeyappara Waterfalls, Tea Museum, and Mattupetty Dam.' },
      { day: 3, title: 'Alleppey Luxury Houseboat Cruise', description: 'Check into a traditional wooden houseboat in Alleppey. Enjoy a serene backwater cruise with authentic Keralite meals.' },
      { day: 4, title: 'Kovalam Beach Sunset', description: 'Drive down to Kovalam. Relax on Lighthouse Beach and witness a breathtaking sunset over the Arabian Sea.' },
      { day: 5, title: 'Trivandrum Sightseeing & Departure', description: 'Visit Padmanabhaswamy Temple before your transfer to the airport or railway station.' }
    ]
  },
  {
    title: 'Royal Rajasthan & Desert Safari',
    location: 'Jaipur',
    price: 'Rs. 32,000',
    rating: '4.8',
    duration: '7 Days',
    image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
    images: [
      'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1572445271230-a78b5944a659?auto=format&fit=crop&w=1400&q=85'
    ],
    isTrending: true,
    departureDates: ['10 Oct 2026', '25 Oct 2026', '12 Nov 2026'],
    categories: {
      Economy: { price: 'Rs. 20,000', facilities: ['Standard Room', 'Breakfast', 'Bus Transfers'] },
      Standard: { price: 'Rs. 32,000', facilities: ['Heritage Hotel', 'Breakfast & Dinner', 'Private Sedan'] },
      Luxury: { price: 'Rs. 55,000', facilities: ['5-Star Palace Hotel', 'All Meals', 'Luxury SUV', 'Desert Safari'] }
    },
    itinerary: [
      { day: 1, title: 'Welcome to Pink City Jaipur', description: 'Arrive in Jaipur and check into your heritage hotel. Visit Hawa Mahal and Johari Bazaar.' },
      { day: 2, title: 'Amber Fort & Jal Mahal', description: 'Elephant ride up to Amber Fort, explore City Palace and Jantar Mantar observatory.' },
      { day: 3, title: 'Drive to Blue City Jodhpur', description: 'Travel to Jodhpur. Visit the imposing Mehrangarh Fort and Jaswant Thada.' },
      { day: 4, title: 'Jaisalmer Golden Fort', description: 'Drive across the Thar desert to Jaisalmer. Explore the living sandstone fort.' },
      { day: 5, title: 'Sam Sand Dunes Camel Safari', description: 'Evening camel safari across Sam Sand Dunes with folk dance and dinner under the stars.' },
      { day: 6, title: 'Udaipur City of Lakes', description: 'Drive to Udaipur, stop at Ranakpur Jain Temple. Enjoy Lake Pichola boat ride.' },
      { day: 7, title: 'Udaipur Departure', description: 'Visit Saheliyon-ki-Bari before airport departure.' }
    ]
  },
  {
    title: 'Majestic Himalayas & Pangong Lake',
    location: 'Ladakh',
    price: 'Rs. 45,000',
    rating: '5.0',
    duration: '8 Days',
    image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1400&q=85',
    images: [
      'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1581793745862-99fde7fa73d2?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1506197603052-3cc9c3a201bd?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1619716012197-2a62886f481c?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1597074866923-dc0589150358?auto=format&fit=crop&w=1400&q=85'
    ],
    isTrending: true,
    departureDates: ['01 May 2027', '15 May 2027', '05 Jun 2027'],
    categories: {
      Economy: { price: 'Rs. 35,000', facilities: ['Standard Camps', 'Breakfast', 'Shared Tempo Traveller'] },
      Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Camps/Hotels', 'Breakfast & Dinner', 'Private Innova'] },
      Luxury: { price: 'Rs. 75,000', facilities: ['Premium Glamping', 'All Meals', 'Luxury SUV 4x4'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Leh & Acclimatization', description: 'Arrive at Kushok Bakula Rimpochee Airport. Rest for complete high-altitude acclimatization.' },
      { day: 2, title: 'Leh Local Monasteries & Shanti Stupa', description: 'Visit Hemis Monastery, Thiksey Monastery, and sunset at Shanti Stupa.' },
      { day: 3, title: 'Khardung La Pass to Nubra Valley', description: 'Cross Khardung La (17,582 ft) to Hunder. Enjoy double-humped camel rides on sand dunes.' },
      { day: 4, title: 'Diskit Monastery & Turtuk Village', description: 'Explore Diskit Monastery and India-Pakistan border village Turtuk.' },
      { day: 5, title: 'Pangong Tso Lake Camping', description: 'Drive along Shyok River to Pangong Tso. Overnight glamping by the turquoise lake.' },
      { day: 6, title: 'Pangong to Leh via Chang La', description: 'Witness sunrise over Pangong Lake and return to Leh via Chang La Pass.' },
      { day: 7, title: 'Magnetic Hill & Sangam Confluence', description: 'Visit Magnetic Hill, Gurudwara Pathar Sahib, and Indus-Zanskar confluence.' },
      { day: 8, title: 'Departure from Leh', description: 'Transfer to Leh Airport with unlosable Himalayan memories.' }
    ]
  },
  {
    title: 'Goa Beach Escape & Party Nights',
    location: 'Goa',
    price: 'Rs. 18,000',
    rating: '4.7',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
    images: [
      'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1614082242765-7c98ca0f3df3?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1587922546307-776227941871?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1400&q=85'
    ],
    isTrending: true,
    departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 12,000', facilities: ['Budget Hotel', 'Breakfast'] },
      Standard: { price: 'Rs. 18,000', facilities: ['3-Star Resort', 'Breakfast', 'Airport Transfers'] },
      Luxury: { price: 'Rs. 35,000', facilities: ['5-Star Beach Resort', 'All Meals', 'Yacht Ride'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in North Goa', description: 'Arrive in Goa, check in to beach resort. Relax at Baga Beach shacks.' },
      { day: 2, title: 'Water Sports & Fort Aguada', description: 'Parasailing, jet-skiing at Calangute Beach and sunset at Fort Aguada.' },
      { day: 3, title: 'Old Goa Churches & Mandovi Cruise', description: 'Visit Basilica of Bom Jesus and evening sunset cruise on Mandovi river.' },
      { day: 4, title: 'South Goa Beaches & Departure', description: 'Relax at Palolem Beach before departure.' }
    ]
  },
  {
    title: 'Statue of Unity & Gujarat Heritage',
    location: 'Gujarat',
    price: 'Rs. 19,500',
    rating: '4.9',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1609946850027-e431f4961556?auto=format&fit=crop&w=1400&q=85',
    images: [
      'https://images.unsplash.com/photo-1609946850027-e431f4961556?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?auto=format&fit=crop&w=1400&q=85'
    ],
    isTrending: true,
    departureDates: ['18 Oct 2026', '01 Nov 2026', '15 Nov 2026'],
    categories: {
      Economy: { price: 'Rs. 14,000', facilities: ['Standard Room', 'Breakfast'] },
      Standard: { price: 'Rs. 19,500', facilities: ['3-Star Tent City', 'Breakfast & Dinner', 'Private Cab'] },
      Luxury: { price: 'Rs. 32,000', facilities: ['Premium Tent City Resort', 'All Meals', 'Viewing Gallery Pass'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Kevadia & Tent City Check-in', description: 'Arrive at Ekta Nagar (Kevadia). Check in at Tent City and watch the Laser Show.' },
      { day: 2, title: 'Statue of Unity Viewing Gallery', description: 'Visit world\'s tallest statue, 153m Viewing Gallery, Valley of Flowers, and Glow Garden.' },
      { day: 3, title: 'Jungle Safari & Narmada River Cruise', description: 'Explore State-of-the-Art Zoological Park and evening river cruise.' },
      { day: 4, title: 'Ahmedabad Sabarmati Ashram Departure', description: 'Visit Sabarmati Ashram before departure.' }
    ]
  },
  {
    title: 'Misty Manali & Solang Valley Snow',
    location: 'Manali',
    price: 'Rs. 22,000',
    rating: '4.8',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?auto=format&fit=crop&w=1400&q=85',
    images: [
      'https://images.unsplash.com/photo-1605649487212-47bdab064df7?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1626714424814-72216447ec1f?auto=format&fit=crop&w=1400&q=85',
      'https://images.unsplash.com/photo-1562670652-e5947bddb335?auto=format&fit=crop&w=1400&q=85'
    ],
    isTrending: true,
    departureDates: ['05 Nov 2026', '20 Nov 2026', '01 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 15,000', facilities: ['Standard Room', 'Breakfast'] },
      Standard: { price: 'Rs. 22,000', facilities: ['3-Star Resort', 'Breakfast & Dinner'] },
      Luxury: { price: 'Rs. 38,000', facilities: ['Luxury Cottage', 'All Meals', 'Solang Snow Passes'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Manali & Mall Road', description: 'Arrive in Manali, check in and stroll Mall Road.' },
      { day: 2, title: 'Solang Valley Adventure', description: 'Ziplining, paragliding, and cable car rides in Solang.' },
      { day: 3, title: 'Atal Tunnel & Sissu Valley', description: 'Drive through Atal Tunnel (9.02 km) to Sissu in Lahaul Valley.' }
    ]
  }
];

const locationsData = [
  { name: 'Kerala', state: 'Kerala' },
  { name: 'Jaipur', state: 'Rajasthan' },
  { name: 'Ladakh', state: 'Jammu & Kashmir' },
  { name: 'Goa', state: 'Goa' },
  { name: 'Kevadia', state: 'Gujarat' },
  { name: 'Manali', state: 'Himachal Pradesh' },
  { name: 'Srinagar', state: 'Jammu & Kashmir' },
  { name: 'Varanasi', state: 'Uttar Pradesh' }
];

const sampleBookingsData = [
  {
    bookingReference: 'BK-TM-2026-8821',
    packageName: 'Kerala Backwaters & Houseboat Escape',
    customerName: 'Aarav Sharma',
    customerEmail: 'aarav.sharma@gmail.com',
    customerPhone: '+91 9876543210',
    travelDate: '15 Nov 2026',
    category: 'Customized',
    amount: 54000,
    paymentStatus: 'CONFIRMED',
    transactionId: 'TXN-TM-918273',
    utrNumber: 'UTR-98127491823',
    startingCity: 'Ahmedabad',
    customDetails: 'Requested 5-Star Lake View Villa + Candlelight Dinner in Houseboat',
    selectedTransport: {
      name: 'IndiGo Express Flight',
      mode: 'flight',
      classType: 'Economy',
      departure: '08:30 AM',
      arrival: '10:45 AM',
      price: 6500
    },
    selectedHotel: {
      name: 'Kumarakom Lake Resort',
      type: 'Resort',
      rating: '5-Star',
      price: 12500,
      contact: '+91 481 2524300'
    },
    travelers: [
      {
        name: 'Aarav Sharma',
        age: '28',
        gender: 'Male',
        aadharNo: '4829 1049 9012',
        aadharFile: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
        aadharFileName: 'aarav_aadhar.jpg',
        aadharVerified: 'VERIFIED ✓'
      },
      {
        name: 'Ananya Sharma',
        age: '26',
        gender: 'Female',
        aadharNo: '4829 1049 9013',
        aadharFile: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
        aadharFileName: 'ananya_aadhar.jpg',
        aadharVerified: 'VERIFIED ✓'
      }
    ]
  },
  {
    bookingReference: 'BK-TM-2026-4192',
    packageName: 'Royal Rajasthan & Desert Safari',
    customerName: 'Priya Patel',
    customerEmail: 'priya.patel@gmail.com',
    customerPhone: '+91 9825012345',
    travelDate: '10 Nov 2026',
    category: 'Standard',
    amount: 64000,
    paymentStatus: 'CONFIRMED',
    transactionId: 'TXN-TM-401928',
    utrNumber: 'UTR-1092837419',
    startingCity: 'Ahmedabad',
    customDetails: '',
    selectedTrainCategory: 'Train (2-Tier AC)',
    travelers: [
      {
        name: 'Priya Patel',
        age: '31',
        gender: 'Female',
        aadharNo: '5819 2019 1192',
        aadharFile: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
        aadharFileName: 'priya_aadhar.jpg',
        aadharVerified: 'VERIFIED ✓'
      },
      {
        name: 'Rajesh Patel',
        age: '34',
        gender: 'Male',
        aadharNo: '5819 2019 1193',
        aadharFile: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
        aadharFileName: 'rajesh_aadhar.jpg',
        aadharVerified: 'VERIFIED ✓'
      }
    ]
  }
];

async function seedDatabase() {
  try {
    console.log('Connecting to MongoDB Atlas Cluster...');
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB Atlas Successfully!');

    console.log('Clearing existing records...');
    await Package.deleteMany({});
    await Location.deleteMany({});
    await Booking.deleteMany({});

    console.log('Inserting Packages into MongoDB Atlas...');
    const createdPackages = await Package.insertMany(packagesData);
    console.log(`✅ Successfully seeded ${createdPackages.length} Packages!`);

    console.log('Inserting Locations into MongoDB Atlas...');
    const createdLocations = await Location.insertMany(locationsData);
    console.log(`✅ Successfully seeded ${createdLocations.length} Locations!`);

    console.log('Inserting Sample Bookings into MongoDB Atlas...');
    const createdBookings = await Booking.insertMany(sampleBookingsData);
    console.log(`✅ Successfully seeded ${createdBookings.length} Sample Bookings!`);

    console.log('\n🎉 ALL DATA SEEDED SUCCESSFULLY TO MONGODB ATLAS!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error Seeding MongoDB Atlas:', err);
    process.exit(1);
  }
}

seedDatabase();
