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

// 35 Comprehensive Packages (including authentic Invincible NGO camps, Himalayan expeditions & coastal getaways)
const allPackages = require('./packagesData');

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
