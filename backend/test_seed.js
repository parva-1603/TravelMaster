require('dotenv').config();
const mongoose = require('mongoose');
const Package = require('./models/Package');
const Location = require('./models/Location');

async function seed() {
  const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/travelmaster';
  await mongoose.connect(MONGODB_URI);

  try {
    await Package.deleteMany({});
    
    const dummyPackages = [
      {
        title: 'Kerala Backwaters',
        location: 'Kerala',
        price: 'Rs. 25,000',
        rating: '4.9',
        duration: '5 Days',
        image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
        isTrending: true,
        departureDates: ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'],
        categories: {
          Economy: { price: 'Rs. 18,000', facilities: ['Standard Hotel', 'Non-AC Bus Transport', 'Breakfast Included'] },
          Standard: { price: 'Rs. 25,000', facilities: ['3 Star Hotel', 'AC Volvo Transport', 'All Meals Included'] },
          Luxury: { price: 'Rs. 40,000', facilities: ['5 Star Resort', 'Private Luxury SUV', 'All Meals + Houseboat Cruise'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival & Fort Kochi Heritage Tour', description: 'Arrive in Kochi. Transfer to hotel, check-in, and visit historic Fort Kochi, Mattancherry Palace, and iconic Chinese Fishing Nets.' },
          { day: 2, title: 'Munnar Hill Station & Tea Gardens', description: 'Scenic drive through Cheeyappara waterfalls to Munnar. Tour sprawling tea plantations, Tea Museum, and Eravikulam National Park.' },
          { day: 3, title: 'Alleppey Houseboat Backwater Cruise', description: 'Drive to Alleppey and board a traditional luxury houseboat. Cruise through calm backwaters and Vembanad Lake with local Keralite meals.' },
          { day: 4, title: 'Kovalam Beach & Coastal Relaxation', description: 'Proceed to Kovalam. Relax at Lighthouse Beach and visit Samudra Beach and local seafood cafes.' },
          { day: 5, title: 'Souvenir Shopping & Farewell', description: 'Morning breakfast, shop for authentic spices and tea, and transfer to Ernakulam station/airport.' }
        ]
      },
      {
        title: 'Royal Rajasthan',
        location: 'Jaipur',
        price: 'Rs. 32,000',
        rating: '4.8',
        duration: '7 Days',
        image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
        isTrending: true,
        departureDates: ['10 Oct 2026', '25 Oct 2026', '12 Nov 2026'],
        categories: {
          Economy: { price: 'Rs. 24,000', facilities: ['Heritage Haveli Stay', 'Shared Bus Transport', 'Breakfast'] },
          Standard: { price: 'Rs. 32,000', facilities: ['4 Star Palace Hotel', 'Private AC Sedan', 'Breakfast & Dinner'] },
          Luxury: { price: 'Rs. 55,000', facilities: ['Grand Heritage Palace', 'Chauffeur Luxury Car', 'All Inclusive Royal Meals'] }
        },
        itinerary: [
          { day: 1, title: 'Welcome to Pink City Jaipur', description: 'Arrival in Jaipur, check-in, and evening visit to Chokhi Dhani for authentic Rajasthani culture and dinner.' },
          { day: 2, title: 'Amber Fort & Nahargarh Exploration', description: 'Explore grand Amber Fort, Sheesh Mahal, Jaigarh Fort, and catch sunset over Jaipur from Nahargarh Fort.' },
          { day: 3, title: 'Hawa Mahal, City Palace & Markets', description: 'Visit Hawa Mahal, City Palace Museum, Jantar Mantar, and shop in Johari Bazaar.' },
          { day: 4, title: 'Jodhpur Blue City & Mehrangarh Fort', description: 'Drive to Jodhpur. Visit towering Mehrangarh Fort and Jaswant Thada royal cenotaph.' },
          { day: 5, title: 'Thar Desert Camp in Jaisalmer', description: 'Travel to Jaisalmer. Enjoy desert camp stay, camel safari, and folk dance performance.' },
          { day: 6, title: 'Golden Fort & Patwon Ki Haveli', description: 'Explore living Jaisalmer Fort, intricately carved havelis, and Gadisar Lake.' },
          { day: 7, title: 'Departure with Royal Memories', description: 'Breakfast and transfer to airport/railway station.' }
        ]
      },
      {
        title: 'Majestic Himalayas',
        location: 'Ladakh',
        price: 'Rs. 45,000',
        rating: '5.0',
        duration: '8 Days',
        image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1400&q=85',
        isTrending: true,
        departureDates: ['01 May 2027', '15 May 2027', '05 Jun 2027'],
        categories: {
          Economy: { price: 'Rs. 35,000', facilities: ['Guest House Stay', 'Tempo Traveller', 'Breakfast & Dinner'] },
          Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Hotel & Tents', 'Private SUV (Scorpio/Innova)', 'All Meals'] },
          Luxury: { price: 'Rs. 70,000', facilities: ['Luxury Glamping Tents', '4x4 Luxury Vehicle', 'All Meals + Oxygen Support'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival in Leh & High Altitude Acclimatization', description: 'Arrive at Leh Kushok Bakula Airport. Rest for full day for acclimatization.' },
          { day: 2, title: 'Leh Monasteries & Shanti Stupa', description: 'Visit Shanti Stupa, Leh Palace, Hall of Fame, and Thiksey Monastery.' },
          { day: 3, title: 'Leh to Nubra Valley via Khardung La', description: 'Drive over Khardung La Pass (18,380 ft). Arrive in Hunder, Nubra Valley.' },
          { day: 4, title: 'Hunder Sand Dunes & Camel Safari', description: 'Experience double-humped Bactrian camel ride and visit Diskit Monastery.' },
          { day: 5, title: 'Nubra to Pangong Tso Lake', description: 'Drive along Shyok River to scenic Pangong Tso color-changing lake.' },
          { day: 6, title: 'Pangong Sunrise & Return to Leh', description: 'Witness breathtaking sunrise over Pangong Lake, drive back to Leh via Chang La.' },
          { day: 7, title: 'Magnetic Hill & Sangam Confluence', description: 'Visit Sangam (Indus & Zanskar river confluence), Magnetic Hill, and Gurudwara Pathar Sahib.' },
          { day: 8, title: 'Departure from Leh', description: 'Transfer to airport for return flight.' }
        ]
      },
      {
        title: 'Goa Beach Escape',
        location: 'Goa',
        price: 'Rs. 18,000',
        rating: '4.7',
        duration: '4 Days',
        image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
        isTrending: true,
        departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026'],
        categories: {
          Economy: { price: 'Rs. 12,000', facilities: ['2 Star Hotel near Beach', 'Self-drive Scooter', 'Breakfast'] },
          Standard: { price: 'Rs. 18,000', facilities: ['4 Star Beach Resort', 'Private AC Car', 'Breakfast & Dinner'] },
          Luxury: { price: 'Rs. 32,000', facilities: ['5 Star Beach Villa', 'Private Chauffeur Car', 'All Meals + Yacht Cruise'] }
        },
        itinerary: [
          { day: 1, title: 'Welcome to Sunny Goa', description: 'Arrive in Goa, check-in at resort, and relax at Calangute Beach.' },
          { day: 2, title: 'North Goa Beaches & Fort Aguada', description: 'Visit historic 17th-century Fort Aguada, Baga Beach, and enjoy watersports.' },
          { day: 3, title: 'Old Goa Churches & Mandovi Cruise', description: 'Explore Basilica of Bom Jesus, Se Cathedral, Panjim market, and evening sunset river cruise.' },
          { day: 4, title: 'Leisure & Farewell', description: 'Relax by pool/beach, shop for Goan cashew nuts and spices, and transfer to airport/station.' }
        ]
      }
    ];

    await Package.insertMany(dummyPackages);

    await Location.deleteMany({});
    const dummyLocations = [
      { name: 'Delhi', state: 'Delhi' },
      { name: 'Mumbai', state: 'Maharashtra' },
      { name: 'Bangalore', state: 'Karnataka' },
      { name: 'Kerala', state: 'Kerala' },
      { name: 'Goa', state: 'Goa' },
      { name: 'Jaipur', state: 'Rajasthan' },
      { name: 'Ladakh', state: 'Ladakh' }
    ];
    await Location.insertMany(dummyLocations);

    console.log('Successfully seeded MongoDB database with full itineraries and departure dates!');
  } catch (err) {
    console.error('Seed error:', err);
  } finally {
    await mongoose.disconnect();
  }
}

seed();
