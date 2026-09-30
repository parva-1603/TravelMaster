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
        image: 'https://picsum.photos/seed/kerala/600/400',
        isTrending: true
      },
      {
        title: 'Royal Rajasthan',
        location: 'Jaipur',
        price: 'Rs. 32,000',
        rating: '4.8',
        duration: '7 Days',
        image: 'https://picsum.photos/seed/rajasthan/600/400',
        isTrending: true
      },
      {
        title: 'Majestic Himalayas',
        location: 'Ladakh',
        price: 'Rs. 45,000',
        rating: '5.0',
        duration: '8 Days',
        image: 'https://picsum.photos/seed/himalayas/600/400',
        isTrending: true
      },
      {
        title: 'Goa Beach Escape',
        location: 'Goa',
        price: 'Rs. 18,000',
        rating: '4.7',
        duration: '4 Days',
        image: 'https://picsum.photos/seed/goa/600/400',
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

// 1. Get Trending Packages
app.get('/api/packages/trending', async (req, res) => {
  try {
    const packages = [
      {
        id: 1,
        title: 'Kerala Backwaters',
        location: 'Kerala',
        price: 'Rs. 25,000',
        rating: '4.9',
        duration: '5 Days',
        image: 'https://picsum.photos/seed/kerala/600/400',
        isTrending: true,
        departureDates: ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'],
        categories: {
          Economy: { price: 'Rs. 18,000', facilities: ['Standard Room', 'Breakfast Only', 'Shared Coach Transfers'] },
          Standard: { price: 'Rs. 25,000', facilities: ['3-Star Hotel', 'Breakfast & Dinner', 'Private Cab Transfers'] },
          Luxury: { price: 'Rs. 45,000', facilities: ['5-Star Premium Houseboat', 'All Meals Included', 'Private SUV', 'Ayurvedic Spa'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival in Kochi & Heritage Walk', description: 'Upon arrival at the Kochi International Airport, our representative will greet you and transfer you to your hotel. After a refreshing welcome drink and check-in, you will have some time to relax. In the late afternoon, step out to explore the historic Fort Kochi area. Walk along the vibrant streets lined with colonial-era architecture, visit the iconic St. Francis Church, and witness the fascinating Chinese Fishing Nets in action as the sun sets over the Arabian Sea. Conclude the day with a traditional Kerala dinner.' },
          { day: 2, title: 'Scenic Drive to Munnar Hills', description: 'After a hearty breakfast, begin your scenic drive towards the misty hills of Munnar, famously known as the Kashmir of South India. The journey itself is breathtaking, passing through lush green tea plantations, cascading waterfalls, and winding mountain roads. En route, make a stop at the majestic Cheeyappara Waterfalls. Upon reaching Munnar, check into your hill-station resort. Spend the evening at your leisure, sipping freshly brewed local tea and enjoying the panoramic views of the valley.' },
          { day: 3, title: 'Munnar Tea Estates & Wildlife', description: 'Wake up to the cool mountain breeze and head out for a full day of sightseeing. Your first stop is the famous Eravikulam National Park, home to the endangered Nilgiri Tahr. Next, visit the sprawling Tata Tea Museum to learn about the history of tea processing. In the afternoon, head to Mattupetty Dam for a serene boat ride, followed by a visit to Echo Point where your voice bounces back from the surrounding hills. Return to your resort for a cozy overnight stay.' },
          { day: 4, title: 'Thekkady Spice Plantations & Safari', description: 'Check out from Munnar and drive towards Thekkady, the heart of Kerala\'s spice region. After checking into your jungle lodge, embark on a guided tour of a massive spice plantation, learning about the cultivation of cardamom, pepper, and cinnamon. Later in the afternoon, proceed to the Periyar National Park for an unforgettable boat safari on Periyar Lake. Keep your eyes peeled for wild elephants, bison, and exotic bird species drinking from the water\'s edge.' },
          { day: 5, title: 'Alleppey Houseboat Cruise', description: 'Today features the highlight of your Kerala trip. Drive to Alleppey, the Venice of the East, and board a luxurious traditional houseboat (Kettuvallam). As you gently cruise through the intricate network of tranquil backwaters, witness the rustic village life, lush paddy fields, and swaying coconut trees. Enjoy authentic Kerala delicacies prepared fresh on board by your private chef. Spend the night sleeping on the water under the starry sky.' },
          { day: 6, title: 'Departure with Memories', description: 'Wake up to a beautiful sunrise over the backwaters. Enjoy a relaxed breakfast on the deck of your houseboat before checking out. You will be transferred back to the Kochi International Airport for your onward journey, taking with you a lifetime of beautiful memories from "God\'s Own Country".' }
        ]
      },
      {
        id: 2,
        title: 'Royal Rajasthan',
        location: 'Jaipur',
        price: 'Rs. 32,000',
        rating: '4.8',
        duration: '7 Days',
        image: 'https://picsum.photos/seed/rajasthan/600/400',
        isTrending: true,
        departureDates: ['10 Oct 2026', '25 Oct 2026', '12 Nov 2026'],
        categories: {
          Economy: { price: 'Rs. 20,000', facilities: ['Standard Room', 'Breakfast', 'Bus Transfers'] },
          Standard: { price: 'Rs. 32,000', facilities: ['Heritage Hotel', 'Breakfast & Dinner', 'Private Sedan'] },
          Luxury: { price: 'Rs. 55,000', facilities: ['5-Star Palace Hotel', 'All Meals', 'Luxury SUV', 'Desert Safari'] }
        },
        itinerary: [
          { day: 1, title: 'Welcome to the Pink City', description: 'Arrive at Jaipur International Airport where our royal host will welcome you. Transfer to your heritage hotel and freshen up. In the evening, head to Chokhi Dhani, a spectacular ethnic village resort. Here you will experience the true essence of Rajasthani culture with live folk dance, puppet shows, camel rides, and an authentic multi-course traditional thali dinner.' },
          { day: 2, title: 'Majesty of Jaipur Forts', description: 'After an early breakfast, proceed to the magnificent Amer Fort, situated on a hilltop. Enjoy an elephant ride to the courtyard. Next, visit the City Palace, an exquisite blend of Rajput and Mughal architecture, and the Jantar Mantar observatory. Stop by the iconic Hawa Mahal (Palace of Winds) for stunning photographs. Spend your evening shopping for vibrant textiles and jewelry at Johari Bazaar.' },
          { day: 3, title: 'The Blue City of Jodhpur', description: 'Check out and embark on a scenic drive to Jodhpur, the Blue City. Upon arrival, check into your hotel and rest. In the afternoon, visit the colossal Mehrangarh Fort, which towers over the city and houses a museum of royal palanquins and weapons. Later, visit Jaswant Thada, a beautiful marble cenotaph, and take a stroll through the blue-painted streets of the old city.' },
          { day: 4, title: 'Drive to Udaipur', description: 'Today you will journey towards Udaipur, widely considered the most romantic city in India. En route, stop at the mesmerizing Ranakpur Jain Temple, famous for its 1,444 intricately carved marble pillars, no two of which are identical. Continue to Udaipur and check into your lakeside hotel. Relax and enjoy the tranquil atmosphere.' },
          { day: 5, title: 'Udaipur City of Lakes', description: 'Start your day exploring the massive City Palace complex overlooking Lake Pichola. Visit the Crystal Gallery and the vintage car museum. In the afternoon, wander through the beautiful Saheliyon Ki Bari (Garden of the Maidens). As the sun begins to set, embark on a magical boat ride on Lake Pichola, offering spectacular views of Jag Mandir and the illuminated Lake Palace.' },
          { day: 6, title: 'Spiritual Pushkar', description: 'Leave Udaipur and drive towards the holy town of Pushkar. Upon arrival, visit the famous Brahma Temple, one of the very few temples in the world dedicated to Lord Brahma. Walk down to the sacred Pushkar Lake and witness the evening Aarti ceremony on the ghats, accompanied by the chanting of mantras and ringing of bells.' },
          { day: 7, title: 'Departure', description: 'Enjoy your final Rajasthani breakfast. Based on your flight schedule, you will be transferred to Jaipur Airport. Depart with a royal experience etched in your memory forever.' }
        ]
      },
      {
        id: 3,
        title: 'Majestic Himalayas',
        location: 'Ladakh',
        price: 'Rs. 45,000',
        rating: '5.0',
        duration: '8 Days',
        image: 'https://picsum.photos/seed/himalayas/600/400',
        isTrending: true,
        departureDates: ['01 May 2027', '15 May 2027', '05 Jun 2027'],
        categories: {
          Economy: { price: 'Rs. 35,000', facilities: ['Standard Camps', 'Breakfast', 'Shared Tempo Traveller'] },
          Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Camps/Hotels', 'Breakfast & Dinner', 'Private Innova'] },
          Luxury: { price: 'Rs. 75,000', facilities: ['Premium Glamping', 'All Meals', 'Luxury SUV 4x4', 'Oxygen Support'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival & Crucial Acclimatization', description: 'Touch down at the Kushok Bakula Rimpochee Airport in Leh, one of the highest commercial airports in the world. Transfer to your hotel. Since Leh is situated at an altitude of 11,500 feet, it is strictly advised to rest for the entire day to let your body acclimatize to the thin air. Hydrate well and enjoy a light dinner.' },
          { day: 2, title: 'Leh Local Sightseeing', description: 'Once acclimatized, start exploring Leh. Visit the stunning Shanti Stupa, offering panoramic views of the city and surrounding mountains. Next, explore the ancient Leh Palace, a nine-story royal residence built in the 17th century. Spend the evening walking through the Leh Main Bazaar, picking up Tibetan handicrafts and trying local apricot juice.' },
          { day: 3, title: 'Over the Khardung La to Nubra', description: 'Today features a thrilling drive to the Nubra Valley via the legendary Khardung La Pass, the highest motorable road in the world at 18,380 feet. Stop briefly at the summit for photos. Descend into the breathtaking Nubra Valley and check into your camp at Hunder. In the evening, enjoy a ride on the rare double-humped Bactrian camels across the cold desert sand dunes.' },
          { day: 4, title: 'The Edge of the World - Turtuk', description: 'Take a day trip to Turtuk, the northernmost village in India, located mere kilometers from the Line of Control. Opened to tourists only recently, this picturesque village offers a unique glimpse into Balti culture. Walk through lush apricot orchards, interact with the warm locals, and enjoy views of the Karakoram range. Return to Nubra for the night.' },
          { day: 5, title: 'Journey to Pangong Tso', description: 'Leave Nubra Valley and take the rugged, adventurous route alongside the Shyok River to reach the spectacular Pangong Tso Lake. Situated at 14,270 feet, this massive high-altitude saltwater lake famously changes colors from brilliant blue to emerald green. Check into your lakeside camp and spend the evening mesmerized by the sheer beauty of the landscape.' },
          { day: 6, title: 'Sunrise at Pangong & Return to Leh', description: 'Wake up early to witness a magical, freezing sunrise over Pangong Lake, an absolute paradise for photographers. After breakfast, begin your drive back to Leh, crossing the formidable Chang La Pass (17,586 feet). You will arrive in Leh by late afternoon. The rest of the day is free for relaxation.' },
          { day: 7, title: 'Monasteries of the Indus Valley', description: 'Spend your final day immersing yourself in Ladakhi spirituality. Visit the Thiksey Monastery, renowned for its massive two-story statue of Maitreya Buddha. Proceed to the Hemis Monastery, the largest and wealthiest in Ladakh, hidden inside a gorge. End the day with a visit to the 3 Idiots famous Druk White Lotus School.' },
          { day: 8, title: 'Departure', description: 'After an early breakfast, transfer to the Leh airport for your flight back home, carrying unforgettable memories of the rugged Himalayas.' }
        ]
      },
      {
        id: 4,
        title: 'Goa Beach Escape',
        location: 'Goa',
        price: 'Rs. 18,000',
        rating: '4.7',
        duration: '4 Days',
        image: 'https://picsum.photos/seed/goa/600/400',
        isTrending: true,
        departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026'],
        categories: {
          Economy: { price: 'Rs. 12,000', facilities: ['Budget Hotel', 'Breakfast', 'No Transfers'] },
          Standard: { price: 'Rs. 18,000', facilities: ['3-Star Resort', 'Breakfast', 'Airport Transfers'] },
          Luxury: { price: 'Rs. 35,000', facilities: ['5-Star Beach Resort', 'All Meals', 'Private Cab', 'Yacht Ride'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival & Beach Relaxation', description: 'Welcome to the party capital of India! Upon arrival at Dabolim Airport or Madgaon Railway Station, transfer to your beautiful beach resort in North Goa. After checking in and resting, spend your late afternoon taking a leisurely walk along the shoreline. Watch a glorious sunset while sipping a refreshing drink at a seaside shack.' },
          { day: 2, title: 'North Goa Beaches & Water Sports', description: 'Get ready for an action-packed day exploring the vibrant beaches of North Goa. Start with Calangute and Baga beaches, where you can indulge in thrilling water sports like parasailing, jet skiing, and banana boat rides. In the afternoon, visit the historic Aguada Fort for panoramic ocean views. Experience Goa\'s legendary nightlife at Tito\'s Lane in the evening.' },
          { day: 3, title: 'Heritage of Old Goa & River Cruise', description: 'Shift your focus from the beaches to Goa\'s rich Portuguese heritage. Visit the UNESCO World Heritage sites in Old Goa, including the magnificent Basilica of Bom Jesus and the Se Cathedral. Walk through the charming Latin Quarter of Fontainhas. In the evening, head to Panjim to board a lively sunset cruise on the Mandovi River, complete with DJ music and Goan folk dances.' },
          { day: 4, title: 'Farewell Goa', description: 'Savor a relaxed Goan breakfast. Depending on your departure time, you can do some last-minute souvenir shopping at the Anjuna Flea Market or pick up some famous Goan cashew nuts. Transfer to the airport or railway station for your journey back home.' }
        ]
      }
    ];
    res.json(packages);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// 2. Search Packages
app.get('/api/packages/search', async (req, res) => {
  try {
    const { from, to, month } = req.query;
    
    // In a real app, 'to' would match location or title. 
    // Here we do a basic regex match on location.
    const query = {};
    if (to) {
      query.OR = [
        { location: { contains: to } },
        { title: { contains: to } }
      ];
    }
    
    const packages = await prisma.package.findMany({ where: query });
    res.json(packages);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// 3. Search/Autocomplete Locations (using LatLng API)
app.get('/api/locations', async (req, res) => {
  try {
    const { query } = req.query;
    if (!query || query.length < 2) return res.json([]);

    const response = await fetch(`https://suggest.latlng.work/autosuggest?q=${encodeURIComponent(query)}`, {
      headers: {
        'X-Api-Key': process.env.LATLNG_API_KEY
      }
    });

    if (!response.ok) {
      throw new Error(`LatLng API returned status ${response.status}`);
    }

    const data = await response.json();
    
    // The LatLng API returns results in the 'suggestions' array.
    const places = data.suggestions || [];
    
    // Map the external data to a simple format for the frontend
    const formattedLocations = places.slice(0, 5).map(place => ({
      name: place.name || place.city || query,
      state: place.region || '',
      country: place.country || ''
    }));

    res.json(formattedLocations);
  } catch (error) {
    console.error('Location Autocomplete Error:', error);
    res.status(500).json({ error: 'Failed to fetch location autocomplete' });
  }
});

// 4. Get Current Weather
app.get('/api/weather', async (req, res) => {
  try {
    const { location } = req.query;
    if (!location) return res.status(400).json({ error: 'Location is required' });

    let searchCity = location;
    if (location.toLowerCase() === 'kerala') searchCity = 'Kochi';
    if (location.toLowerCase() === 'ladakh') searchCity = 'Leh';

    const response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(searchCity)}&appid=${process.env.WEATHER_API_KEY}&units=metric`);
    
    if (!response.ok) {
      throw new Error(`Weather API returned status ${response.status}`);
    }

    const data = await response.json();
    
    // Send a simplified weather object to the frontend
    res.json({
      location: data.name,
      temperature: data.main.temp,
      description: data.weather[0].description,
      icon: `https://openweathermap.org/img/wn/${data.weather[0].icon}@2x.png`,
      humidity: data.main.humidity,
      windSpeed: data.wind.speed
    });
  } catch (error) {
    console.error('Weather API Error:', error);
    res.status(500).json({ error: 'Failed to fetch weather data' });
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
