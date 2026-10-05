require('dotenv').config({ override: true });
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Package = require('./models/Package');
const Location = require('./models/Location');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/travelmaster';
mongoose
  .connect(MONGODB_URI)
  .then(() => console.log('Connected to MongoDB Successfully'))
  .catch((err) => console.error('MongoDB connection error:', err));

// =======================
// SEED DATABASE ROUTE
// =======================
app.post('/api/seed', async (req, res) => {
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
          Economy: { price: 'Rs. 18,000', facilities: ['Standard Room', 'Breakfast Only', 'Shared Coach Transfers'] },
          Standard: { price: 'Rs. 25,000', facilities: ['3-Star Hotel', 'Breakfast & Dinner', 'Private Cab Transfers'] },
          Luxury: { price: 'Rs. 45,000', facilities: ['5-Star Premium Houseboat', 'All Meals Included', 'Private SUV', 'Ayurvedic Spa'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival in Kochi & Heritage Walk', description: 'Upon arrival at the Kochi International Airport, our representative will greet you and transfer you to your hotel. After a refreshing welcome drink and check-in, you will have some time to relax. In the late afternoon, step out to explore the historic Fort Kochi area.' },
          { day: 2, title: 'Scenic Drive to Munnar Hills', description: 'After a hearty breakfast, begin your scenic drive towards the misty hills of Munnar, famously known as the Kashmir of South India.' },
          { day: 3, title: 'Munnar Tea Estates & Wildlife', description: 'Wake up to the cool mountain breeze and head out for a full day of sightseeing.' },
          { day: 4, title: 'Thekkady Spice Plantations & Safari', description: 'Check out from Munnar and drive towards Thekkady, the heart of Kerala\'s spice region.' },
          { day: 5, title: 'Alleppey Houseboat Cruise', description: 'Today features the highlight of your Kerala trip. Drive to Alleppey, the Venice of the East, and board a luxurious traditional houseboat.' },
          { day: 6, title: 'Departure with Memories', description: 'Wake up to a beautiful sunrise over the backwaters. Enjoy a relaxed breakfast on the deck of your houseboat before checking out.' }
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
          Economy: { price: 'Rs. 20,000', facilities: ['Standard Room', 'Breakfast', 'Bus Transfers'] },
          Standard: { price: 'Rs. 32,000', facilities: ['Heritage Hotel', 'Breakfast & Dinner', 'Private Sedan'] },
          Luxury: { price: 'Rs. 55,000', facilities: ['5-Star Palace Hotel', 'All Meals', 'Luxury SUV', 'Desert Safari'] }
        },
        itinerary: [
          { day: 1, title: 'Welcome to the Pink City', description: 'Arrive at Jaipur International Airport where our royal host will welcome you.' },
          { day: 2, title: 'Majesty of Jaipur Forts', description: 'After an early breakfast, proceed to the magnificent Amer Fort, situated on a hilltop.' }
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
          Economy: { price: 'Rs. 35,000', facilities: ['Standard Camps', 'Breakfast', 'Shared Tempo Traveller'] },
          Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Camps/Hotels', 'Breakfast & Dinner', 'Private Innova'] },
          Luxury: { price: 'Rs. 75,000', facilities: ['Premium Glamping', 'All Meals', 'Luxury SUV 4x4', 'Oxygen Support'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival & Crucial Acclimatization', description: 'Touch down at the Kushok Bakula Rimpochee Airport in Leh, one of the highest commercial airports in the world.' }
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
          Economy: { price: 'Rs. 12,000', facilities: ['Budget Hotel', 'Breakfast', 'No Transfers'] },
          Standard: { price: 'Rs. 18,000', facilities: ['3-Star Resort', 'Breakfast', 'Airport Transfers'] },
          Luxury: { price: 'Rs. 35,000', facilities: ['5-Star Beach Resort', 'All Meals', 'Private Cab', 'Yacht Ride'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival & Beach Relaxation', description: 'Welcome to the party capital of India! Transfer to your beautiful beach resort in North Goa.' }
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

    res.json({ message: 'Database seeded successfully with dummy data in MongoDB!' });
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
    let packages = await Package.find({ isTrending: true });
    if (!packages || packages.length === 0) {
      packages = await Package.find({});
    }
    
    // Fallback default packages if database has not been seeded yet
    if (!packages || packages.length === 0) {
      packages = [
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
            { day: 1, title: 'Arrival in Kochi & Heritage Walk', description: 'Upon arrival at the Kochi International Airport, our representative will greet you and transfer you to your hotel. After a refreshing welcome drink and check-in, you will have some time to relax. In the late afternoon, step out to explore the historic Fort Kochi area.' },
            { day: 2, title: 'Scenic Drive to Munnar Hills', description: 'After a hearty breakfast, begin your scenic drive towards the misty hills of Munnar, famously known as the Kashmir of South India.' }
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
          }
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
          departureDates: ['01 May 2027', '15 May 2027', '05 Jun 2027']
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
          departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026']
        }
      ];
    }

    res.json(packages);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// 2. Search Packages
app.get('/api/packages/search', async (req, res) => {
  try {
    const { from, to, month } = req.query;
    
    let filter = {};
    if (to) {
      filter = {
        $or: [
          { location: { $regex: to, $options: 'i' } },
          { title: { $regex: to, $options: 'i' } }
        ]
      };
    }
    
    const packages = await Package.find(filter);
    res.json(packages);
  } catch (error) {
    console.error(error);
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
  const { location } = req.query;
  if (!location) return res.status(400).json({ error: 'Location is required' });

  let searchCity = location;
  const locLower = location.toLowerCase();
  if (locLower.includes('kerala')) searchCity = 'Kochi';
  if (locLower.includes('ladakh')) searchCity = 'Leh';

  const defaultWeatherData = {
    kerala: { location: 'Kerala', temperature: '28°C', description: 'Sunny & Pleasant', icon: 'https://openweathermap.org/img/wn/02d@2x.png', humidity: 76, windSpeed: 3.6 },
    kochi: { location: 'Kerala (Kochi)', temperature: '28°C', description: 'Sunny & Pleasant', icon: 'https://openweathermap.org/img/wn/02d@2x.png', humidity: 76, windSpeed: 3.6 },
    jaipur: { location: 'Jaipur', temperature: '31°C', description: 'Warm & Clear', icon: 'https://openweathermap.org/img/wn/01d@2x.png', humidity: 40, windSpeed: 2.5 },
    ladakh: { location: 'Ladakh', temperature: '14°C', description: 'Crisp Mountain Breeze', icon: 'https://openweathermap.org/img/wn/01d@2x.png', humidity: 22, windSpeed: 4.2 },
    leh: { location: 'Ladakh (Leh)', temperature: '14°C', description: 'Crisp Mountain Breeze', icon: 'https://openweathermap.org/img/wn/01d@2x.png', humidity: 22, windSpeed: 4.2 },
    goa: { location: 'Goa', temperature: '29°C', description: 'Tropical Sunshine', icon: 'https://openweathermap.org/img/wn/01d@2x.png', humidity: 68, windSpeed: 3.1 }
  };

  const key = searchCity.toLowerCase();
  const fallback = defaultWeatherData[key] || {
    location: searchCity,
    temperature: '26°C',
    description: 'Pleasant Weather',
    icon: 'https://openweathermap.org/img/wn/02d@2x.png',
    humidity: 60,
    windSpeed: 3.0
  };

  try {
    if (process.env.WEATHER_API_KEY) {
      const response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(searchCity)}&appid=${process.env.WEATHER_API_KEY}&units=metric`);
      if (response.ok) {
        const data = await response.json();
        return res.json({
          location: data.name,
          temperature: `${Math.round(data.main.temp)}°C`,
          description: data.weather[0].description,
          icon: `https://openweathermap.org/img/wn/${data.weather[0].icon}@2x.png`,
          humidity: data.main.humidity,
          windSpeed: data.wind.speed
        });
      }
    }
    return res.json(fallback);
  } catch (error) {
    console.error('Weather API Error, returning fallback weather:', error.message);
    return res.json(fallback);
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
    // REAL IRCTC API INTEGRATION WITH GUARANTEED FALLBACK
    const resolveStation = (cityName, isFrom = true) => {
      const name = (cityName || '').toLowerCase().trim();
      if (name.includes('delhi')) return 'NDLS';
      if (name.includes('kerala') || name.includes('kochi') || name.includes('ernakulam') || name.includes('munnar') || name.includes('alappuzha') || name.includes('wayanad') || name.includes('trivandrum') || name.includes('thiruvananthapuram')) return 'ERS';
      if (name.includes('mumbai') || name.includes('bombay')) return 'MMCT';
      if (name.includes('jaipur')) return 'JP';
      if (name.includes('ladakh') || name.includes('leh')) return 'JAT';
      if (name.includes('goa') || name.includes('madgaon')) return 'MAO';
      if (name.includes('bangalore') || name.includes('bengaluru')) return 'SBC';
      if (name.includes('chennai') || name.includes('madras')) return 'MAS';
      if (name.includes('kolkata') || name.includes('howrah')) return 'HWH';
      if (name.includes('hyderabad') || name.includes('secunderabad')) return 'SC';
      if (name.includes('agra')) return 'AGC';
      if (name.includes('shimla') || name.includes('manali') || name.includes('kalka')) return 'KLK';
      return isFrom ? 'NDLS' : 'ERS';
    };

    const fromCode = resolveStation(from, true);
    const toCode = resolveStation(to, false);

    let multiplier = 1;
    if (classType === '3-Tier AC' || classType === '3AC') multiplier = 2.2;
    if (classType === '1-Tier AC' || classType === 'First AC' || classType === '1AC') multiplier = 3.8;

    const getFallbackTrains = (fromStr, toStr, fCode, tCode, mult) => {
      const fLow = (fromStr || '').toLowerCase();
      const tLow = (toStr || '').toLowerCase();

      if ((fLow.includes('delhi') || fCode === 'NDLS') && (tLow.includes('kerala') || tLow.includes('kochi') || tLow.includes('ernakulam') || tCode === 'ERS')) {
        return [
          { id: '12626', name: `Kerala Express (12626) | NDLS ➔ ERS`, departure: '20:10 PM', arrival: '05:55 PM (+2 days)', price: Math.floor(1250 * mult) },
          { id: '12618', name: `Mangala Lakshadweep SF Exp (12618) | NZM ➔ ERS`, departure: '05:40 AM', arrival: '10:25 AM (+2 days)', price: Math.floor(1180 * mult) },
          { id: '12432', name: `Trivandrum Rajdhani Express (12432) | NZM ➔ ERS`, departure: '06:16 AM', arrival: '02:05 PM (+1 day)', price: Math.floor(3450 * mult) },
          { id: '12284', name: `Ernakulam Duronto Express (12284) | NZM ➔ ERS`, departure: '09:40 PM', arrival: '02:30 PM (+1 day)', price: Math.floor(2950 * mult) },
          { id: '12646', name: `Millennium Superfast Express (12646) | NZM ➔ ERS`, departure: '05:10 AM', arrival: '02:10 PM (+2 days)', price: Math.floor(1150 * mult) }
        ];
      }

      return [
        { id: '12626', name: `${fromStr || 'Delhi'} - ${toStr || 'Destination'} Express (12626) | ${fCode} ➔ ${tCode}`, departure: '08:00 AM', arrival: '06:30 PM (+1 day)', price: Math.floor(1150 * mult) },
        { id: '12618', name: `${fromStr || 'Delhi'} - ${toStr || 'Destination'} Superfast (12618) | ${fCode} ➔ ${tCode}`, departure: '11:15 AM', arrival: '09:45 AM (+2 days)', price: Math.floor(1050 * mult) },
        { id: '12432', name: `${fromStr || 'Delhi'} - ${toStr || 'Destination'} Rajdhani (12432) | ${fCode} ➔ ${tCode}`, departure: '06:30 PM', arrival: '02:15 PM (+1 day)', price: Math.floor(2950 * mult) }
      ];
    };

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
      if (!json || !json.status || !json.data || !Array.isArray(json.data) || json.data.length === 0) {
        return res.json(getFallbackTrains(from, to, fromCode, toCode, multiplier));
      }
      
      const realTrains = json.data.slice(0, 5).map(train => {
        const basePrice = Math.max(500, Math.floor((train.distance || 800) * 0.9));
        return {
          id: train.train_number,
          name: `${train.train_name} (${train.train_number}) | ${fromCode} ➔ ${toCode}`,
          departure: train.from_std || '08:00 AM',
          arrival: train.to_sta || '06:00 PM',
          price: Math.floor(basePrice * multiplier)
        };
      });
      
      res.json(realTrains);
    })
    .catch(err => {
      console.error('IRCTC API Error:', err);
      res.json(getFallbackTrains(from, to, fromCode, toCode, multiplier));
    });
  }
});

const path = require('path');
const frontendBuildPath = path.join(__dirname, '../frontend/build/web');

// Serve static Flutter web app files (with cache prevention)
app.use(express.static(frontendBuildPath, {
  etag: false,
  maxAge: 0,
  setHeaders: (res, path) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
  }
}));

// Serve Flutter index.html for non-API web routes
app.use((req, res, next) => {
  if (req.path.startsWith('/api')) {
    return next();
  }
  res.sendFile(path.join(frontendBuildPath, 'index.html'), (err) => {
    if (err) {
      res.status(404).send('TravelMaster Backend API is running! (To load Flutter UI here, run "flutter build web" inside frontend folder).');
    }
  });
});

// Start Server (only if not running on Vercel)
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// Export the Express API for Vercel
module.exports = app;
