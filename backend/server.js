require('dotenv').config();
const express = require('express');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Prisma will auto-connect, but we can verify connection here
prisma.$connect()
  .then(() => console.log('Connected to Microsoft SQL Server Successfully via Prisma'))
  .catch((err) => console.error('Prisma connection error:', err));

// =======================
// SEED DATABASE ROUTE
// =======================
app.post('/api/seed', async (req, res) => {
  try {
    await prisma.package.deleteMany({});
    
    const dummyPackages = [
      {
        title: 'Kerala Backwaters',
        location: 'Kerala',
        price: 'Rs. 25,000',
        rating: '4.9',
        duration: '5 Days',
        image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
        isTrending: true
      },
      {
        title: 'Royal Rajasthan',
        location: 'Jaipur',
        price: 'Rs. 32,000',
        rating: '4.8',
        duration: '7 Days',
        image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
        isTrending: true
      },
      {
        title: 'Majestic Himalayas',
        location: 'Ladakh',
        price: 'Rs. 45,000',
        rating: '5.0',
        duration: '8 Days',
        image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1400&q=85',
        isTrending: true
      },
      {
        title: 'Goa Beach Escape',
        location: 'Goa',
        price: 'Rs. 18,000',
        rating: '4.7',
        duration: '4 Days',
        image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
        isTrending: true
      }
    ];

    await prisma.package.createMany({ data: dummyPackages });

    await prisma.location.deleteMany({});
    const dummyLocations = [
      { name: 'Delhi', state: 'Delhi' },
      { name: 'Mumbai', state: 'Maharashtra' },
      { name: 'Bangalore', state: 'Karnataka' },
      { name: 'Kerala', state: 'Kerala' },
      { name: 'Goa', state: 'Goa' },
      { name: 'Jaipur', state: 'Rajasthan' },
      { name: 'Ladakh', state: 'Ladakh' }
    ];
    await prisma.location.createMany({ data: dummyLocations });

    res.json({ message: 'Database seeded successfully with dummy data!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to seed database' });
  }
});

// =======================
// APIs
// =======================

// All Comprehensive Packages (including iconic Invincible NGO adventure camps and treks)
const allPackages = [
  {
    id: 1,
    title: 'Kerala Backwaters',
    location: 'Kerala',
    price: 'Rs. 25,000',
    rating: '4.9',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'],
    categories: {
      Economy: { price: 'Rs. 18,000', facilities: ['Standard Room', 'Breakfast Only', 'Shared Coach Transfers'] },
      Standard: { price: 'Rs. 25,000', facilities: ['3-Star Hotel', 'Breakfast & Dinner', 'Private Cab Transfers'] },
      Luxury: { price: 'Rs. 45,000', facilities: ['5-Star Premium Houseboat', 'All Meals Included', 'Private SUV', 'Ayurvedic Spa'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Kochi & Heritage Walk', description: 'Upon arrival at the Kochi International Airport, our representative will greet you and transfer you to your hotel. After a refreshing welcome drink and check-in, explore the historic Fort Kochi area, colonial architecture, and iconic Chinese Fishing Nets. Conclude with a traditional Kerala dinner.' },
      { day: 2, title: 'Scenic Drive to Munnar Hills', description: 'Scenic drive towards the misty tea estates of Munnar. Stop at Cheeyappara Waterfalls. Check into your hill-station resort and spend the evening sipping freshly brewed local tea.' },
      { day: 3, title: 'Munnar Tea Estates & Wildlife', description: 'Visit Eravikulam National Park (home to the Nilgiri Tahr), Tata Tea Museum, Mattupetty Dam boat ride, and Echo Point.' },
      { day: 4, title: 'Thekkady Spice Plantations & Safari', description: 'Guided tour of spice plantations in Thekkady and boat safari on Periyar Lake inside Periyar National Park.' },
      { day: 5, title: 'Alleppey Houseboat Cruise & Departure', description: 'Board a traditional luxury houseboat (Kettuvallam) in Alleppey. Cruise through serene canals before transferring to Kochi airport.' }
    ]
  },
  {
    id: 2,
    title: 'Royal Rajasthan',
    location: 'Jaipur',
    price: 'Rs. 32,000',
    rating: '4.8',
    duration: '7 Days',
    image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['10 Oct 2026', '25 Oct 2026', '12 Nov 2026'],
    categories: {
      Economy: { price: 'Rs. 20,000', facilities: ['Standard Room', 'Breakfast', 'Bus Transfers'] },
      Standard: { price: 'Rs. 32,000', facilities: ['Heritage Hotel', 'Breakfast & Dinner', 'Private Sedan'] },
      Luxury: { price: 'Rs. 55,000', facilities: ['5-Star Palace Hotel', 'All Meals', 'Luxury SUV', 'Desert Safari'] }
    },
    itinerary: [
      { day: 1, title: 'Welcome to the Pink City', description: 'Arrival in Jaipur, check-in, and evening cultural extravaganza at Chokhi Dhani with folk dances and traditional Rajasthani thali.' },
      { day: 2, title: 'Majesty of Jaipur Forts', description: 'Amer Fort, City Palace, Jantar Mantar observatory, and photo stop at Hawa Mahal. Shopping in Johari Bazaar.' },
      { day: 3, title: 'The Blue City of Jodhpur', description: 'Drive to Jodhpur. Explore Mehrangarh Fort, Jaswant Thada, and stroll through old blue-painted streets.' },
      { day: 4, title: 'Drive to Udaipur via Ranakpur', description: 'Visit the world-famous carved marble Jain temples at Ranakpur before arriving in lakeside Udaipur.' },
      { day: 5, title: 'Udaipur City of Lakes', description: 'City Palace complex, Saheliyon Ki Bari, and a romantic sunset boat cruise on Lake Pichola.' },
      { day: 6, title: 'Spiritual Pushkar', description: 'Brahma Temple, holy Pushkar Lake ghats, and evening Aarti ceremonies.' },
      { day: 7, title: 'Departure', description: 'Final Rajasthani breakfast and transfer to Jaipur Airport.' }
    ]
  },
  {
    id: 3,
    title: 'Majestic Himalayas',
    location: 'Ladakh',
    price: 'Rs. 45,000',
    rating: '5.0',
    duration: '8 Days',
    image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['01 May 2027', '15 May 2027', '05 Jun 2027'],
    categories: {
      Economy: { price: 'Rs. 35,000', facilities: ['Standard Camps', 'Breakfast', 'Shared Tempo Traveller'] },
      Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Camps/Hotels', 'Breakfast & Dinner', 'Private Innova'] },
      Luxury: { price: 'Rs. 75,000', facilities: ['Premium Glamping', 'All Meals', 'Luxury SUV 4x4', 'Oxygen Support'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival & Crucial Acclimatization', description: 'Touch down at Leh Airport (11,500 ft). Complete rest for altitude acclimatization.' },
      { day: 2, title: 'Leh Local Sightseeing', description: 'Shanti Stupa, Leh Palace, and evening stroll through Leh Main Bazaar.' },
      { day: 3, title: 'Over Khardung La to Nubra Valley', description: 'Drive over Khardung La Pass (18,380 ft). Double-humped camel rides at Hunder sand dunes.' },
      { day: 4, title: 'Turtuk Village Near LoC', description: 'Day excursion to Turtuk, exploring unique Balti culture and apricot orchards.' },
      { day: 5, title: 'Journey to Pangong Tso', description: 'Scenic drive along Shyok River to high-altitude color-changing Pangong Lake (14,270 ft).' },
      { day: 6, title: 'Pangong Sunrise & Return to Leh', description: 'Freezing sunrise over Pangong Lake, cross Chang La Pass (17,586 ft) back to Leh.' },
      { day: 7, title: 'Indus Valley Monasteries', description: 'Thiksey and Hemis monasteries, and Druk White Lotus school.' },
      { day: 8, title: 'Departure', description: 'Transfer to Leh Airport for return flight.' }
    ]
  },
  {
    id: 4,
    title: 'Goa Beach Escape',
    location: 'Goa',
    price: 'Rs. 18,000',
    rating: '4.7',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 12,000', facilities: ['Budget Hotel', 'Breakfast', 'No Transfers'] },
      Standard: { price: 'Rs. 18,000', facilities: ['3-Star Resort', 'Breakfast', 'Airport Transfers'] },
      Luxury: { price: 'Rs. 35,000', facilities: ['5-Star Beach Resort', 'All Meals', 'Private Cab', 'Yacht Ride'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival & Beach Relaxation', description: 'Transfer to North Goa resort, evening sunset walk on the shoreline.' },
      { day: 2, title: 'North Goa Beaches & Water Sports', description: 'Calangute, Baga beach water sports, Aguada Fort, and nightlife at Tito\'s Lane.' },
      { day: 3, title: 'Heritage of Old Goa & River Cruise', description: 'Basilica of Bom Jesus, Fontainhas Latin Quarter, and Mandovi sunset river cruise.' },
      { day: 4, title: 'Farewell Goa', description: 'Souvenir shopping and transfer to airport/railway station.' }
    ]
  },
  {
    id: 5,
    title: 'Kedarkantha Snow Trek',
    location: 'Sankri, Uttarakhand',
    price: 'Rs. 9,500',
    rating: '4.9',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['10 Dec 2026', '20 Dec 2026', '02 Jan 2027', '18 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 7,500', facilities: ['Alpine Tents', 'Nutritious Veg Meals', 'Certified Guides', 'Forest Permits'] },
      Standard: { price: 'Rs. 9,500', facilities: ['Deluxe Alpine Tents (Triple Sharing)', 'All Meals Included', 'Microspikes & Gaiters', 'Oxygen Kit', 'Summit Certificate'] },
      Luxury: { price: 'Rs. 14,000', facilities: ['Private Wooden Homestay in Sankri', 'All Meals & Snacks', 'Dedicated Guide & Porter', 'Personal Crampons', 'Campfire Evening'] }
    },
    itinerary: [
      { day: 1, title: 'Dehradun to Sankri Base Camp', description: 'Scenic 195 km drive along the Yamuna and Tons rivers via Mussoorie and Kempty Falls. Arrive at Sankri base camp (6,400 ft), meet your Invincible trek guides, complete health checkup and briefing.' },
      { day: 2, title: 'Trek from Sankri to Juda Ka Talab', description: 'Begin your 4 km ascent through thick pine, oak, and maple forests. Arrive at the frozen glacial lake of Juda Ka Talab (9,100 ft) surrounded by snow-draped pine woods for lakeside camping.' },
      { day: 3, title: 'Juda Ka Talab to Kedarkantha Base', description: 'Trek 4 km across open sub-alpine snow meadows. Pitch tents at Kedarkantha Base Camp (11,250 ft) with breathtaking vistas of Bandarpoonch, Swargarohini, and Black Peak illuminated by sunset.' },
      { day: 4, title: 'Summit Push (12,500 ft) & Hargaon', description: 'Early 3:30 AM summit push. Reach Kedarkantha Peak (12,500 ft) to witness a stunning 360-degree Himalayan sunrise. Enjoy fun snow glissades down to the Hargaon campsite (8,900 ft).' },
      { day: 5, title: 'Hargaon to Sankri Base Camp', description: 'A pleasant 6 km downhill trek back to Sankri base camp through blooming rhododendron forests. Evening celebration, music, campfire, and trek completion certificates.' },
      { day: 6, title: 'Sankri to Dehradun Departure', description: 'Morning breakfast and farewell. Board return transport to Dehradun railway station/airport carrying memories of conquering the Kedarkantha summit.' }
    ]
  },
  {
    id: 6,
    title: 'Manali Adventure & Trekking Camp',
    location: 'Manali, Himachal Pradesh',
    price: 'Rs. 7,800',
    rating: '4.8',
    duration: '7 Days',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['15 Nov 2026', '05 Dec 2026', '24 Dec 2026', '10 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 6,200', facilities: ['Alpine Tents', 'All Meals', 'Guided Trekking', 'River Rafting'] },
      Standard: { price: 'Rs. 7,800', facilities: ['Riverside Campsite', 'Beas River Rafting', 'Solang Valley Snow Sports', 'Jogini Falls Trek', 'Campfire & DJ'] },
      Luxury: { price: 'Rs. 13,500', facilities: ['Boutique Apple Orchard Resort', 'Private Heated Cottage', 'River Crossing', 'Paragliding Tickets', 'Bonfire Music'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival at Manali Campsite', description: 'Check-in at the scenic riverside campsite in Kullu-Manali valley. Tent allocation, camp orientation, and acclimatization stroll along Beas River.' },
      { day: 2, title: 'Jogini Waterfalls & Vashisht Springs', description: 'Trek through apple orchards and pine woods to the spectacular cascading Jogini Waterfalls; dip into natural sulphur hot springs in Vashisht.' },
      { day: 3, title: 'Solang Valley & Atal Tunnel Excursion', description: 'Excursion to Solang Valley for skiing, tube slides, and zorbing. Drive through the historic Atal Tunnel into Sissu (Lahaul Valley).' },
      { day: 4, title: 'High Altitude Trek to Lama Dugh', description: 'Thrilling ridge trek offering spellbinding aerial vistas of Manali town, Pir Panjal ranges, and glaciers.' },
      { day: 5, title: 'White Water Rafting & Rock Climbing', description: 'Rafting across roaring rapids of the Beas River, followed by rappelling, rock climbing, and adventure obstacle courses.' },
      { day: 6, title: 'Old Manali, Hadimba & Mall Road', description: 'Cultural exploration of centuries-old wooden Hadimba Temple, Tibetan monasteries, and shopping on Mall Road.' },
      { day: 7, title: 'Farewell & Departure', description: 'Closing ceremony, certification, and departure towards Chandigarh/Delhi.' }
    ]
  },
  {
    id: 7,
    title: 'Polo Forest Trek & Eco Camp',
    location: 'Polo Forest, Gujarat',
    price: 'Rs. 1,850',
    rating: '4.9',
    duration: '2 Days',
    image: 'https://images.unsplash.com/photo-1511497584788-87676104235f?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['17 Oct 2026', '24 Oct 2026', '07 Nov 2026', '21 Nov 2026'],
    categories: {
      Economy: { price: 'Rs. 1,450', facilities: ['Forest Campsite Tents', 'Kathiyawadi / Gujarati Meals', 'Forest Permits', 'Trek Guide'] },
      Standard: { price: 'Rs. 1,850', facilities: ['Dome Tents', 'All Meals Included', 'Rock Climbing & Rappelling', 'Harnav River Crossing', 'Stargazing Astronomy Session'] },
      Luxury: { price: 'Rs. 3,500', facilities: ['Deluxe AC Cottages at Forest Eco Resort', 'Private Guide', 'Stargazing Telescope Experience', 'Open Gypsy Safari'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival, Ancient Temples & Rock Climbing', description: 'Report at Polo Forest Campsite near the Harnav River. Explore 15th-century ancient Jain and Shiva temples entwined with roots. Afternoon rock climbing and bouldering session. Night campfire with guided stargazing and astronomy workshop.' },
      { day: 2, title: 'Idar Hills Sunrise, River Crossing & Departure', description: 'Early morning trek to the hilltop for sunrise over the Aravalli forest canopy. River crossing and wading through pristine Harnav River waters. Visit Vanaj Dam and botanical nature trail before evening departure.' }
    ]
  },
  {
    id: 8,
    title: 'Beyt Dwarka Marine & Beach Camp',
    location: 'Beyt Dwarka, Gujarat',
    price: 'Rs. 3,800',
    rating: '4.8',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['14 Nov 2026', '28 Nov 2026', '12 Dec 2026', '26 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 2,900', facilities: ['Beach Tents', 'All Vegetarian Meals', 'Ferry Transfers', 'Marine Guide'] },
      Standard: { price: 'Rs. 3,800', facilities: ['Beachfront Dome Tents', 'Coral Reef Walk', 'Dolphin Boat Safari', 'Dunny Point Trek', 'Campfire & Music'] },
      Luxury: { price: 'Rs. 6,500', facilities: ['Premium Sea-facing Swiss Tents', 'Private Dolphin Cruise', 'Water Sports', 'Dedicated Marine Biologist Guide'] }
    },
    itinerary: [
      { day: 1, title: 'Ferry to Island & Beach Camping', description: 'Scenic ferry ride from Okha jetty across the Gulf of Kutch to Beyt Dwarka island. Camp setup on untouched white sands. Sunset coastal walk and beach games around a campfire.' },
      { day: 2, title: 'Coral Reef Walk & Wild Dolphin Safari', description: 'Low-tide marine trail to spot live corals, sea anemones, pufferfish, and crabs. Boat safari into Gulf waters to witness wild dolphins leaping. Sunset visit to Dunny Point where the Arabian Sea and Gulf meet.' },
      { day: 3, title: 'Lord Krishna Temple & Blue Flag Beach', description: 'Visit historic Beyt Dwarka Krishna Temple. Boat back to Okha with visit to Dwarkadhish temple and pristine Shivrajpur Blue Flag Beach before departure.' }
    ]
  },
  {
    id: 9,
    title: 'Saputara Adventure & Nature Camp',
    location: 'Saputara, Gujarat',
    price: 'Rs. 2,900',
    rating: '4.7',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['23 Oct 2026', '06 Nov 2026', '20 Nov 2026', '04 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 2,200', facilities: ['Nature Camp Tents', 'Dangi/Gujarati Meals', 'Group Hikes', 'Instructors'] },
      Standard: { price: 'Rs. 2,900', facilities: ['Deluxe Alpine Tents', 'All Meals', 'Zipline & Commando Net', 'Gira Waterfalls Trek', 'Sunset Point', 'Campfire'] },
      Luxury: { price: 'Rs. 5,200', facilities: ['Hilltop Resort Cottage', 'Lake Boating', 'Private Valley Excursion', 'Ropeway Tickets', 'Dangi Tribal Tasting'] }
    },
    itinerary: [
      { day: 1, title: 'Welcome to Gujarat\'s Sahyadri Hills', description: 'Arrival at Saputara Camp. Tent allocation and trek to Sunset Point offering vistas over Maharashtra and Gujarat valleys. Evening campfire with music and storytelling.' },
      { day: 2, title: 'Governor Hill & Gira Waterfalls', description: 'Early morning hike to Governor Hill and Table Point. High-rope adventure circuit including zipline and commando net. Afternoon excursion to the roaring Gira Waterfalls amidst dense bamboo groves.' },
      { day: 3, title: 'Lake Boating, Tribal Crafts & Departure', description: 'Morning boat ride on serene Saputara Lake. Visit tribal craft museum, Rose Garden, and honey bee center. Closing ceremony and departure.' }
    ]
  },
  {
    id: 10,
    title: 'Chopta Tungnath Chandrashila Trek',
    location: 'Chopta, Uttarakhand',
    price: 'Rs. 8,900',
    rating: '5.0',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['15 Nov 2026', '01 Dec 2026', '15 Dec 2026', '05 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 7,200', facilities: ['Alpine Tents', 'All Meals', 'Forest Permits', 'Trek Leader'] },
      Standard: { price: 'Rs. 8,900', facilities: ['Meadow Campsite', 'Trek to Tungnath Temple & Chandrashila Peak', 'Deoriatal Lake Camp', 'Bonfire & Certificates'] },
      Luxury: { price: 'Rs. 14,500', facilities: ['Heated Wooden Chalet in Chopta', 'Private Guide', 'Crampons/Gaiters Included', 'Dedicated Vehicle Support', 'Gourmet Meals'] }
    },
    itinerary: [
      { day: 1, title: 'Rishikesh to Sari Village', description: 'Drive along holy rivers via Devprayag and Rudraprayag through Alaknanda valley. Camp in picturesque Sari village.' },
      { day: 2, title: 'Sari to Deoriatal Glacial Lake', description: 'Scenic 3 km trek to emerald Deoriatal lake reflecting the mighty Chaukhamba peaks in its crystal waters. Lakeside camping.' },
      { day: 3, title: 'Deoriatal to Chopta "Mini Switzerland"', description: 'Forest ridge trek through ancient oak and rhododendron canopies to the sprawling alpine meadows of Chopta.' },
      { day: 4, title: 'Summit Day: Tungnath Temple & Chandrashila', description: 'Climb the stone trail to Tungnath (12,073 ft), the highest Shiva temple on earth; ascend Chandrashila summit (13,123 ft) for 360-degree vistas of Nanda Devi, Trishul, and Chaukhamba.' },
      { day: 5, title: 'Chopta to Rishikesh Return', description: 'Descent from Chopta meadows and drive back to Rishikesh. Evening Ganga Aarti on the Triveni Ghat.' },
      { day: 6, title: 'Departure', description: 'Farewell breakfast and onward travel with memories of the Himalayan peaks.' }
    ]
  },
  {
    id: 11,
    title: 'Spiti Valley Road Trip & Odyssey',
    location: 'Spiti Valley, Himachal Pradesh',
    price: 'Rs. 19,500',
    rating: '5.0',
    duration: '9 Days',
    image: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['10 May 2027', '24 May 2027', '07 Jun 2027', '21 Jun 2027'],
    categories: {
      Economy: { price: 'Rs. 15,500', facilities: ['Homestays/Dorms', 'Breakfast & Dinner', 'Shared Tempo Traveller'] },
      Standard: { price: 'Rs. 19,500', facilities: ['Deluxe Boutique Homestays & Camps', 'All Meals', 'Force Urbania/Innova', 'Oxygen Cylinders', 'Tour Leader'] },
      Luxury: { price: 'Rs. 32,000', facilities: ['Premium Luxury Spitian Villas', 'Private 4x4 SUV', 'Dedicated Stargazing Setup', 'High-Altitude Medical Support'] }
    },
    itinerary: [
      { day: 1, title: 'Chandigarh/Shimla to Kalpa', description: 'Drive through Kinnaur along the dramatic Hindustan-Tibet road. Marvel at the sunset over the sacred Kinnaur Kailash range.' },
      { day: 2, title: 'Kalpa to Tabo via Khab & Nako Lake', description: 'Enter the cold desert wonderland of Spiti. Visit the 1,000-year-old Tabo Monastery, known as the Ajanta of the Himalayas.' },
      { day: 3, title: 'Tabo to Dhankar & Kaza', description: 'Climb to cliff-hanging Dhankar Monastery overlooking Spiti-Pin confluence. Arrive in Kaza, sub-divisional capital.' },
      { day: 4, title: 'Highest Villages: Hikkim, Komic & Langza', description: 'Send a postcard from Hikkim (world\'s highest post office at 14,567 ft). Visit Komic village and photograph the giant Buddha statue at Langza.' },
      { day: 5, title: 'Key Monastery & Chicham Bridge', description: 'Explore the fortress-like Key Monastery perched at 13,668 ft, and the iconic high suspension bridge of Chicham.' },
      { day: 6, title: 'Kaza to Chandratal via Kunzum Pass', description: 'Traverse Kunzum Pass at 15,060 ft. Camp near the legendary crescent-shaped Chandratal "Moon Lake".' },
      { day: 7, title: 'Chandratal to Manali via Atal Tunnel', description: 'Cross rugged Batal water crossings and Atal Tunnel descending back into lush green Manali.' },
      { day: 8, title: 'Manali Leisure & Old Town Cafes', description: 'Explore Old Manali cafes, relax, and celebrate completing the epic high-altitude circuit.' },
      { day: 9, title: 'Departure towards Chandigarh', description: 'Transfer to Chandigarh airport/railway station carrying the spirit of the Himalayas.' }
    ]
  },
  {
    id: 12,
    title: 'Kasol & Kheerganga Hot Springs Trek',
    location: 'Kasol, Himachal Pradesh',
    price: 'Rs. 6,800',
    rating: '4.8',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    departureDates: ['20 Oct 2026', '10 Nov 2026', '01 Dec 2026', '20 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 5,200', facilities: ['Riverside Tents', 'Breakfast & Dinner', 'Trek Guide'] },
      Standard: { price: 'Rs. 6,800', facilities: ['Riverside Campsite', 'Kheerganga Dome Tents', 'Tosh Village Tour', 'Natural Hot Springs Bath', 'Bonfire'] },
      Luxury: { price: 'Rs. 11,500', facilities: ['Boutique Wooden Chalet in Kasol', 'Private Guide', 'Cafe Hopping Credit', 'Hot Sulphur Spring Access'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Kasol & Parvati Trail', description: 'Check into riverside camp by the gushing Parvati River. Explore bohemian cafes, German bakeries, and Chalal nature trail.' },
      { day: 2, title: 'Manikaran Sahib & Tosh Village', description: 'Visit holy Manikaran Sahib Gurudwara and dip in natural hot springs. Hike to the rustic wooden village of Tosh overlooking snow peaks.' },
      { day: 3, title: 'Trek from Barshaini to Kheerganga', description: 'Trek 12 km through oak forests and roaring Rudranag waterfall to Kheerganga (9,700 ft). Soak in natural hot sulphur pools under the stars.' },
      { day: 4, title: 'Kheerganga to Barshaini & Kasol Return', description: 'Morning sunrise hike over the alpine meadow. Descend back to Barshaini and return to Kasol for evening music and campfire.' },
      { day: 5, title: 'Souvenir Shopping & Departure', description: 'Shop for Kullu shawls and handicrafts in Kasol market before heading back to Bhuntar/Chandigarh.' }
    ]
  }
];

// 1. Get Trending Packages
app.get('/api/packages/trending', async (req, res) => {
  try {
    res.json(allPackages);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// 2. Search Packages
app.get('/api/packages/search', async (req, res) => {
  try {
    const { from, to, month } = req.query;
    let results = allPackages;
    if (to && to.trim().length > 0) {
      const query = to.trim().toLowerCase();
      results = results.filter(pkg =>
        pkg.location.toLowerCase().includes(query) ||
        pkg.title.toLowerCase().includes(query)
      );
    }
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// 3. Search/Autocomplete Locations (using LatLng API with robust destination fallback)
const fallbackLocations = [
  { name: 'Delhi', state: 'Delhi', country: 'India' },
  { name: 'Mumbai', state: 'Maharashtra', country: 'India' },
  { name: 'Ahmedabad', state: 'Gujarat', country: 'India' },
  { name: 'Surat', state: 'Gujarat', country: 'India' },
  { name: 'Vadodara', state: 'Gujarat', country: 'India' },
  { name: 'Bangalore', state: 'Karnataka', country: 'India' },
  { name: 'Kochi', state: 'Kerala', country: 'India' },
  { name: 'Kerala', state: 'Kerala', country: 'India' },
  { name: 'Goa', state: 'Goa', country: 'India' },
  { name: 'Jaipur', state: 'Rajasthan', country: 'India' },
  { name: 'Udaipur', state: 'Rajasthan', country: 'India' },
  { name: 'Leh', state: 'Ladakh', country: 'India' },
  { name: 'Ladakh', state: 'Ladakh', country: 'India' },
  { name: 'Sankri', state: 'Uttarakhand', country: 'India' },
  { name: 'Kedarkantha', state: 'Uttarakhand', country: 'India' },
  { name: 'Manali', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Polo Forest', state: 'Gujarat', country: 'India' },
  { name: 'Beyt Dwarka', state: 'Gujarat', country: 'India' },
  { name: 'Dwarka', state: 'Gujarat', country: 'India' },
  { name: 'Saputara', state: 'Gujarat', country: 'India' },
  { name: 'Chopta', state: 'Uttarakhand', country: 'India' },
  { name: 'Tungnath', state: 'Uttarakhand', country: 'India' },
  { name: 'Spiti Valley', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Kaza', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Kasol', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Kheerganga', state: 'Himachal Pradesh', country: 'India' }
];

app.get('/api/locations', async (req, res) => {
  try {
    const { query } = req.query;
    if (!query || query.length < 2) return res.json([]);

    const q = query.trim().toLowerCase();
    const localMatches = fallbackLocations.filter(loc =>
      loc.name.toLowerCase().includes(q) ||
      loc.state.toLowerCase().includes(q)
    );

    try {
      const response = await fetch(`https://suggest.latlng.work/autosuggest?q=${encodeURIComponent(query)}`, {
        headers: {
          'X-Api-Key': process.env.LATLNG_API_KEY || ''
        }
      });

      if (response.ok) {
        const data = await response.json();
        const places = data.suggestions || [];
        if (places.length > 0) {
          const formattedLocations = places.slice(0, 5).map(place => ({
            name: place.name || place.city || query,
            state: place.region || '',
            country: place.country || ''
          }));
          return res.json(formattedLocations);
        }
      }
    } catch (_) {
      // Fallback seamlessly to local matches
    }

    res.json(localMatches.slice(0, 6));
  } catch (error) {
    res.json([]);
  }
});

// 4. Get Current Weather
app.get('/api/weather', async (req, res) => {
  try {
    const { location } = req.query;
    if (!location) return res.status(400).json({ error: 'Location is required' });

    let searchCity = location.split(',')[0].trim();
    const locLower = location.toLowerCase();
    if (locLower.includes('kerala')) searchCity = 'Kochi';
    else if (locLower.includes('ladakh')) searchCity = 'Leh';
    else if (locLower.includes('kedarkantha') || locLower.includes('sankri')) searchCity = 'Uttarkashi';
    else if (locLower.includes('manali')) searchCity = 'Manali';
    else if (locLower.includes('polo')) searchCity = 'Himmatnagar';
    else if (locLower.includes('dwarka')) searchCity = 'Dwarka';
    else if (locLower.includes('saputara')) searchCity = 'Saputara';
    else if (locLower.includes('chopta') || locLower.includes('tungnath')) searchCity = 'Rudraprayag';
    else if (locLower.includes('spiti') || locLower.includes('kaza')) searchCity = 'Kaza';
    else if (locLower.includes('kasol') || locLower.includes('kheerganga')) searchCity = 'Kullu';

    const response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(searchCity)}&appid=${process.env.WEATHER_API_KEY}&units=metric`);
    
    if (!response.ok) {
      return res.json({
        location: searchCity,
        temperature: locLower.includes('snow') || locLower.includes('kedarkantha') || locLower.includes('spiti') ? 4 : 21,
        description: 'Clear Mountain Sky & Fresh Air',
        icon: 'https://openweathermap.org/img/wn/01d@2x.png',
        humidity: 48,
        windSpeed: 3.5
      });
    }

    const data = await response.json();
    
    // Send a simplified weather object to the frontend
    res.json({
      location: data.name || searchCity,
      temperature: data.main?.temp ?? 20,
      description: data.weather?.[0]?.description ?? 'Clear Sky',
      icon: data.weather?.[0]?.icon ? `https://openweathermap.org/img/wn/${data.weather[0].icon}@2x.png` : 'https://openweathermap.org/img/wn/01d@2x.png',
      humidity: data.main?.humidity ?? 50,
      windSpeed: data.wind?.speed ?? 3
    });
  } catch (error) {
    console.error('Weather API Error:', error);
    res.status(500).json({ error: 'Failed to fetch weather data' });
  }
});

// 5. Get Hotels
app.get('/api/hotels', (req, res) => {
  const { location, type } = req.query;
  const loc = location || 'City';
  
  if (type === 'Resort') {
    res.json([
      {
        id: 11,
        name: `Grand ${loc} Resort`,
        image: 'https://picsum.photos/seed/resort1/600/400',
        price: 8500,
        rating: 4.9,
        contact: '+91-9876500001',
        rules: ['No loud music after 10 PM', 'Check-in: 2 PM', 'Pool open till 8 PM']
      },
      {
        id: 12,
        name: `Nature Retreat Resort ${loc}`,
        image: 'https://picsum.photos/seed/resort2/600/400',
        price: 6000,
        rating: 4.6,
        contact: '+91-9876500002',
        rules: ['Check-in: 12 PM', 'Check-out: 11 AM']
      }
    ]);
  } else {
    res.json([
      {
        id: 1,
        name: `Premium Hotel ${loc}`,
        image: 'https://picsum.photos/seed/hotel1/600/400',
        price: 5000,
        rating: 4.8,
        contact: '+91-9876543210',
        rules: ['No smoking inside rooms', 'Check-in: 2 PM', 'Couples allowed']
      },
      {
        id: 2,
        name: `Budget Inn ${loc}`,
        image: 'https://picsum.photos/seed/hotel2/600/400',
        price: 2000,
        rating: 4.2,
        contact: '+91-9876543211',
        rules: ['Check-in: 12 PM', 'Check-out: 11 AM']
      },
      {
        id: 3,
        name: `Boutique Stay ${loc}`,
        image: 'https://picsum.photos/seed/hotel3/600/400',
        price: 3500,
        rating: 4.5,
        contact: '+91-9876543212',
        rules: ['No pets allowed', 'Check-in: 1 PM']
      }
    ]);
  }
});

// 6. Get Transport
app.get('/api/transport', (req, res) => {
  const { from, to, mode, classType } = req.query;
  
  if (from && to && from.toLowerCase() === to.toLowerCase()) {
    return res.json([]);
  }
  
  const generateRandomTime = (startHour) => {
    const hr = Math.floor(Math.random() * 5) + startHour;
    const min = Math.floor(Math.random() * 60);
    const ampm = hr >= 12 && hr < 24 ? 'PM' : 'AM';
    const displayHr = hr > 12 ? (hr === 24 ? 12 : hr - 12) : (hr === 0 ? 12 : hr);
    return `${displayHr.toString().padStart(2, '0')}:${min.toString().padStart(2, '0')} ${ampm}`;
  };

  if (mode === 'flight') {
    let multiplier = 1;
    if (classType === 'Business') multiplier = 2.5;
    if (classType === 'First Class') multiplier = 4;
    
    return res.json([
      { id: 'f1', name: `Air India AI-${Math.floor(Math.random()*900)+100} | ${from} ➔ ${to}`, departure: generateRandomTime(5), arrival: generateRandomTime(9), price: Math.floor((Math.random()*2000 + 3500) * multiplier) },
      { id: 'f2', name: `IndiGo 6E-${Math.floor(Math.random()*900)+100} | ${from} ➔ ${to}`, departure: generateRandomTime(11), arrival: generateRandomTime(14), price: Math.floor((Math.random()*1500 + 3000) * multiplier) },
      { id: 'f3', name: `SpiceJet SG-${Math.floor(Math.random()*900)+100} | ${from} ➔ ${to}`, departure: generateRandomTime(16), arrival: generateRandomTime(19), price: Math.floor((Math.random()*2000 + 2800) * multiplier) }
    ]);
  } else {
    // REAL IRCTC API INTEGRATION
    const cityToStation = {
      'delhi': 'NDLS', 'new delhi': 'NDLS',
      'mumbai': 'MMCT', 'bombay': 'MMCT',
      'kerala': 'ERS', 'kochi': 'ERS', 'ernakulam': 'ERS',
      'jaipur': 'JP',
      'ladakh': 'JAT', // Jammu Tawi is closest major railhead
      'goa': 'MAO', 'madgaon': 'MAO',
      'bangalore': 'SBC', 'bengaluru': 'SBC',
      'chennai': 'MAS', 'madras': 'MAS',
      'kolkata': 'HWH', 'howrah': 'HWH',
      'hyderabad': 'SC', 'secunderabad': 'SC',
      'agra': 'AGC'
    };

    const fromCode = cityToStation[from.toLowerCase()] || 'NDLS';
    let toCode = cityToStation[to.toLowerCase()];
    // Handle cases where 'to' contains "Kerala" but might have other words
    if (!toCode) {
      const lower = to.toLowerCase();
      if (lower.includes('kerala')) toCode = 'ERS';
      else if (lower.includes('jaipur')) toCode = 'JP';
      else if (lower.includes('ladakh')) toCode = 'JAT';
      else if (lower.includes('goa')) toCode = 'MAO';
      else if (lower.includes('kedarkantha') || lower.includes('sankri') || lower.includes('chopta') || lower.includes('uttarakhand')) toCode = 'DDN';
      else if (lower.includes('manali') || lower.includes('spiti') || lower.includes('kasol') || lower.includes('himachal')) toCode = 'CDG';
      else if (lower.includes('polo')) toCode = 'ADI';
      else if (lower.includes('dwarka')) toCode = 'DWK';
      else if (lower.includes('saputara')) toCode = 'BIM';
      else toCode = 'MMCT'; // Default fallback
    }

    if (fromCode === toCode) return res.json([]);

    // Get date 3 days from now
    const d = new Date();
    d.setDate(d.getDate() + 3);
    const dateStr = `${d.getFullYear()}-${(d.getMonth()+1).toString().padStart(2,'0')}-${d.getDate().toString().padStart(2,'0')}`;

    fetch(`https://irctc1.p.rapidapi.com/api/v3/trainBetweenStations?fromStationCode=${fromCode}&toStationCode=${toCode}&dateOfJourney=${dateStr}`, {
      method: 'GET',
      headers: {
        'x-rapidapi-key': '3bb29e74bamsh6df9d79706ecae1p1ff4cdjsn76b9637ab4ee',
        'x-rapidapi-host': 'irctc1.p.rapidapi.com'
      }
    })
    .then(response => response.json())
    .then(json => {
      if (!json.status || !json.data || json.data.length === 0) {
        return res.json([]);
      }
      
      let multiplier = 1;
      if (classType === '3-Tier AC') multiplier = 2.5;
      if (classType === '1-Tier AC') multiplier = 4;
      
      const realTrains = json.data.slice(0, 5).map(train => {
        // Base price calculation: roughly Rs. 1 per km for Sleeper class
        const basePrice = Math.max(500, Math.floor((train.distance || 800) * 0.9));
        
        return {
          id: train.train_number,
          name: `${train.train_name} (${train.train_number}) | ${fromCode} ➔ ${toCode}`,
          departure: train.from_std,
          arrival: train.to_sta,
          price: Math.floor(basePrice * multiplier)
        };
      });
      
      res.json(realTrains);
    })
    .catch(err => {
      console.error('IRCTC API Error:', err);
      res.status(500).json([]);
    });
  }
});

// Root Route
app.get('/', (req, res) => {
  res.send('TravelMaster Backend API is running!');
});

// Start Server (only if not running on Vercel)
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// Export the Express API for Vercel
module.exports = app;
