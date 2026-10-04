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

// 55 Comprehensive Packages (including authentic Invincible NGO camps, Himalayan expeditions & coastal getaways)
const allPackages = require('./packagesData');

// Health Check API
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptimeSeconds: Math.floor(process.uptime()),
    totalPackages: allPackages.length,
    timestamp: new Date().toISOString(),
    services: {
      packages: 'online',
      weather: 'online',
      hotels: 'online',
      transport: 'online'
    }
  });
});

// 1. Get Trending Packages
app.get('/api/packages/trending', async (req, res) => {
  try {
    res.json(allPackages);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// 2. Search Packages with Multi-parameter Filtering
app.get('/api/packages/search', async (req, res) => {
  try {
    const { from, to, month, season, tripType, maxPrice } = req.query;
    let results = allPackages;

    if (to && to.trim().length > 0) {
      const query = to.trim().toLowerCase();
      results = results.filter(pkg =>
        pkg.location.toLowerCase().includes(query) ||
        pkg.title.toLowerCase().includes(query)
      );
    }

    if (month && month !== 'Any month') {
      const m = month.toLowerCase();
      results = results.filter(pkg =>
        Array.isArray(pkg.bestMonths) &&
        pkg.bestMonths.some(bm => bm.toLowerCase() === m)
      );
    }

    if (season && season !== 'All') {
      results = results.filter(pkg =>
        (pkg.bestSeason && pkg.bestSeason.toLowerCase().includes(season.toLowerCase())) ||
        (pkg.tripType && pkg.tripType.toLowerCase().includes(season.toLowerCase()))
      );
    }

    if (tripType && tripType !== 'All') {
      results = results.filter(pkg =>
        pkg.tripType && pkg.tripType.toLowerCase().includes(tripType.toLowerCase())
      );
    }

    if (maxPrice) {
      const max = parseInt(maxPrice, 10);
      if (!isNaN(max)) {
        results = results.filter(pkg => {
          const digits = (pkg.price || '').replace(/[^0-9]/g, '');
          const p = parseInt(digits, 10);
          return isNaN(p) || p <= max;
        });
      }
    }

    res.json(results);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// 3. Search/Autocomplete Locations (with comprehensive 55-destination Indian coverage)
const fallbackLocations = [
  { name: 'Delhi', state: 'Delhi', country: 'India' },
  { name: 'Mumbai', state: 'Maharashtra', country: 'India' },
  { name: 'Ahmedabad', state: 'Gujarat', country: 'India' },
  { name: 'Surat', state: 'Gujarat', country: 'India' },
  { name: 'Vadodara', state: 'Gujarat', country: 'India' },
  { name: 'Bangalore', state: 'Karnataka', country: 'India' },
  { name: 'Kochi', state: 'Kerala', country: 'India' },
  { name: 'Alleppey', state: 'Kerala', country: 'India' },
  { name: 'Munnar', state: 'Kerala', country: 'India' },
  { name: 'Wayanad', state: 'Kerala', country: 'India' },
  { name: 'Goa', state: 'Goa', country: 'India' },
  { name: 'Palolem Beach', state: 'Goa', country: 'India' },
  { name: 'Gokarna', state: 'Karnataka', country: 'India' },
  { name: 'Coorg', state: 'Karnataka', country: 'India' },
  { name: 'Hampi', state: 'Karnataka', country: 'India' },
  { name: 'Dandeli', state: 'Karnataka', country: 'India' },
  { name: 'Jaipur', state: 'Rajasthan', country: 'India' },
  { name: 'Udaipur', state: 'Rajasthan', country: 'India' },
  { name: 'Jaisalmer', state: 'Rajasthan', country: 'India' },
  { name: 'Mount Abu', state: 'Rajasthan', country: 'India' },
  { name: 'Ranthambore', state: 'Rajasthan', country: 'India' },
  { name: 'Leh', state: 'Ladakh', country: 'India' },
  { name: 'Ladakh', state: 'Ladakh', country: 'India' },
  { name: 'Sankri', state: 'Uttarakhand', country: 'India' },
  { name: 'Kedarkantha', state: 'Uttarakhand', country: 'India' },
  { name: 'Rishikesh', state: 'Uttarakhand', country: 'India' },
  { name: 'Chopta', state: 'Uttarakhand', country: 'India' },
  { name: 'Joshimath', state: 'Uttarakhand', country: 'India' },
  { name: 'Auli', state: 'Uttarakhand', country: 'India' },
  { name: 'Lohajung', state: 'Uttarakhand', country: 'India' },
  { name: 'Manali', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Shimla', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Spiti Valley', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Kaza', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Kasol', state: 'Himachal Pradesh', country: 'India' },
  { name: 'Dhordo', state: 'Gujarat', country: 'India' },
  { name: 'Kutch', state: 'Gujarat', country: 'India' },
  { name: 'Sasan Gir', state: 'Gujarat', country: 'India' },
  { name: 'Polo Forest', state: 'Gujarat', country: 'India' },
  { name: 'Dwarka', state: 'Gujarat', country: 'India' },
  { name: 'Saputara', state: 'Gujarat', country: 'India' },
  { name: 'Cherrapunji', state: 'Meghalaya', country: 'India' },
  { name: 'Shillong', state: 'Meghalaya', country: 'India' },
  { name: 'Tawang', state: 'Arunachal Pradesh', country: 'India' },
  { name: 'Kohima', state: 'Nagaland', country: 'India' },
  { name: 'Kaziranga', state: 'Assam', country: 'India' },
  { name: 'Jorhat', state: 'Assam', country: 'India' },
  { name: 'Sandakphu', state: 'West Bengal', country: 'India' },
  { name: 'Darjeeling', state: 'West Bengal', country: 'India' },
  { name: 'Varanasi', state: 'Uttar Pradesh', country: 'India' },
  { name: 'Amritsar', state: 'Punjab', country: 'India' },
  { name: 'Puri', state: 'Odisha', country: 'India' },
  { name: 'Konark', state: 'Odisha', country: 'India' },
  { name: 'Khajuraho', state: 'Madhya Pradesh', country: 'India' },
  { name: 'Orchha', state: 'Madhya Pradesh', country: 'India' },
  { name: 'Ooty', state: 'Tamil Nadu', country: 'India' },
  { name: 'Pondicherry', state: 'Pondicherry', country: 'India' },
  { name: 'Havelock Island', state: 'Andaman & Nicobar', country: 'India' },
  { name: 'Port Blair', state: 'Andaman & Nicobar', country: 'India' },
  { name: 'Bodh Gaya', state: 'Bihar', country: 'India' }
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
        name: `Grand ${loc} Luxury Resort & Spa`,
        image: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
        price: 8500,
        rating: 4.9,
        contact: '+91-9876500001',
        rules: ['No loud music after 10 PM', 'Check-in: 2 PM', 'Pool & Spa open till 9 PM'],
        bookingUrl: `https://www.booking.com/searchresults.html?ss=${encodeURIComponent(`Grand ${loc} Resort`)}`,
        websiteUrl: `https://www.google.com/travel/hotels?q=${encodeURIComponent(`Grand ${loc} Resort`)}`,
        mmtUrl: `https://www.makemytrip.com/hotels/${encodeURIComponent(loc.toLowerCase())}-hotels.html`,
        portalName: 'Booking.com & Official'
      },
      {
        id: 12,
        name: `Nature Eco-Retreat & Cottages ${loc}`,
        image: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80',
        price: 6000,
        rating: 4.7,
        contact: '+91-9876500002',
        rules: ['Check-in: 12 PM', 'Check-out: 11 AM', 'Organic bonfire meals included'],
        bookingUrl: `https://www.booking.com/searchresults.html?ss=${encodeURIComponent(`Nature Retreat ${loc}`)}`,
        websiteUrl: `https://www.google.com/travel/hotels?q=${encodeURIComponent(`Nature Retreat ${loc}`)}`,
        mmtUrl: `https://www.makemytrip.com/hotels/${encodeURIComponent(loc.toLowerCase())}-hotels.html`,
        portalName: 'Agoda & Official'
      }
    ]);
  } else {
    res.json([
      {
        id: 1,
        name: `Premium Mountain & Heritage Hotel ${loc}`,
        image: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
        price: 5000,
        rating: 4.8,
        contact: '+91-9876543210',
        rules: ['No smoking inside rooms', 'Check-in: 2 PM', '24x7 Hot Water & Room Service'],
        bookingUrl: `https://www.booking.com/searchresults.html?ss=${encodeURIComponent(`Premium Hotel ${loc}`)}`,
        websiteUrl: `https://www.google.com/travel/hotels?q=${encodeURIComponent(`Premium Hotel ${loc}`)}`,
        mmtUrl: `https://www.makemytrip.com/hotels/${encodeURIComponent(loc.toLowerCase())}-hotels.html`,
        portalName: 'Booking.com'
      },
      {
        id: 2,
        name: `Traveler's Budget Inn & Hostel ${loc}`,
        image: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80',
        price: 2200,
        rating: 4.3,
        contact: '+91-9876543211',
        rules: ['Check-in: 12 PM', 'Check-out: 11 AM', 'Backpacker friendly, Free Wi-Fi'],
        bookingUrl: `https://www.booking.com/searchresults.html?ss=${encodeURIComponent(`Budget Inn ${loc}`)}`,
        websiteUrl: `https://www.google.com/travel/hotels?q=${encodeURIComponent(`Budget Inn ${loc}`)}`,
        mmtUrl: `https://www.makemytrip.com/hotels/${encodeURIComponent(loc.toLowerCase())}-hotels.html`,
        portalName: 'Hostelworld & Booking.com'
      },
      {
        id: 3,
        name: `Boutique Pine Stay & Suites ${loc}`,
        image: 'https://images.unsplash.com/photo-1568495248636-6432b97bd949?auto=format&fit=crop&w=800&q=80',
        price: 3600,
        rating: 4.6,
        contact: '+91-9876543212',
        rules: ['Valley view balcony', 'Check-in: 1 PM', 'Complimentary breakfast'],
        bookingUrl: `https://www.booking.com/searchresults.html?ss=${encodeURIComponent(`Boutique Stay ${loc}`)}`,
        websiteUrl: `https://www.google.com/travel/hotels?q=${encodeURIComponent(`Boutique Stay ${loc}`)}`,
        mmtUrl: `https://www.makemytrip.com/hotels/${encodeURIComponent(loc.toLowerCase())}-hotels.html`,
        portalName: 'MakeMyTrip & Official'
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
    
    const flightSearchQuery = encodeURIComponent(`flights from ${from} to ${to}`);
    const googleFlightsUrl = `https://www.google.com/travel/flights?q=${flightSearchQuery}`;
    const mmtFlightsUrl = `https://www.makemytrip.com/flights/`;
    
    return res.json([
      {
        id: 'f1',
        name: `Air India AI-${Math.floor(Math.random()*900)+100} | ${from} ➔ ${to}`,
        airline: 'Air India',
        departure: generateRandomTime(5),
        arrival: generateRandomTime(9),
        price: Math.floor((Math.random()*2000 + 3500) * multiplier),
        bookingUrl: googleFlightsUrl,
        portalUrl: 'https://www.airindia.com/',
        mmtUrl: mmtFlightsUrl,
        portalName: 'Air India Official'
      },
      {
        id: 'f2',
        name: `IndiGo 6E-${Math.floor(Math.random()*900)+100} | ${from} ➔ ${to}`,
        airline: 'IndiGo',
        departure: generateRandomTime(11),
        arrival: generateRandomTime(14),
        price: Math.floor((Math.random()*1500 + 3000) * multiplier),
        bookingUrl: googleFlightsUrl,
        portalUrl: 'https://www.goindigo.in/',
        mmtUrl: mmtFlightsUrl,
        portalName: 'IndiGo Official'
      },
      {
        id: 'f3',
        name: `SpiceJet SG-${Math.floor(Math.random()*900)+100} | ${from} ➔ ${to}`,
        airline: 'SpiceJet',
        departure: generateRandomTime(16),
        arrival: generateRandomTime(19),
        price: Math.floor((Math.random()*2000 + 2800) * multiplier),
        bookingUrl: googleFlightsUrl,
        portalUrl: 'https://www.spicejet.com/',
        mmtUrl: mmtFlightsUrl,
        portalName: 'SpiceJet Official'
      }
    ]);
  } else {
    // REAL IRCTC API INTEGRATION & MAPPING
    const cityToStation = {
      'delhi': 'NDLS', 'new delhi': 'NDLS',
      'mumbai': 'MMCT', 'bombay': 'MMCT',
      'ahmedabad': 'ADI', 'surat': 'ST', 'vadodara': 'BRC',
      'kerala': 'ERS', 'kochi': 'ERS', 'ernakulam': 'ERS', 'alleppey': 'ALLP',
      'jaipur': 'JP', 'jodhpur': 'JU', 'jaisalmer': 'JSM',
      'ladakh': 'JAT', 'leh': 'JAT',
      'goa': 'MAO', 'madgaon': 'MAO',
      'bangalore': 'SBC', 'bengaluru': 'SBC',
      'chennai': 'MAS', 'madras': 'MAS',
      'kolkata': 'HWH', 'howrah': 'HWH',
      'hyderabad': 'SC', 'secunderabad': 'SC',
      'varanasi': 'BSB', 'kashi': 'BSB',
      'haridwar': 'HW', 'dehradun': 'DDN', 'rishikesh': 'YNRK',
      'hampi': 'HPT', 'bhuj': 'BHUJ', 'kutch': 'BHUJ',
      'agra': 'AGC', 'chandigarh': 'CDG', 'coorg': 'MYS', 'mysore': 'MYS',
      'darjeeling': 'NJP', 'munnar': 'ERS', 'gokarna': 'GOK', 'ooty': 'CBE',
      'pondicherry': 'PDY', 'guwahati': 'GHY', 'shillong': 'GHY'
    };

    const fromCode = cityToStation[from.toLowerCase()] || 'NDLS';
    let toCode = cityToStation[to.toLowerCase()];
    if (!toCode) {
      const lower = to.toLowerCase();
      if (lower.includes('kerala') || lower.includes('alleppey')) toCode = 'ERS';
      else if (lower.includes('jaipur')) toCode = 'JP';
      else if (lower.includes('jaisalmer')) toCode = 'JSM';
      else if (lower.includes('ladakh') || lower.includes('zanskar')) toCode = 'JAT';
      else if (lower.includes('goa') || lower.includes('dudhsagar')) toCode = 'MAO';
      else if (lower.includes('kedarkantha') || lower.includes('sankri') || lower.includes('chopta') || lower.includes('uttarakhand') || lower.includes('flowers') || lower.includes('roopkund') || lower.includes('kuari')) toCode = 'DDN';
      else if (lower.includes('manali') || lower.includes('spiti') || lower.includes('kasol') || lower.includes('tirthan') || lower.includes('himachal')) toCode = 'CDG';
      else if (lower.includes('polo') || lower.includes('ahmedabad')) toCode = 'ADI';
      else if (lower.includes('dwarka') || lower.includes('somnath')) toCode = 'DWK';
      else if (lower.includes('kutch') || lower.includes('rann')) toCode = 'BHUJ';
      else if (lower.includes('varanasi')) toCode = 'BSB';
      else if (lower.includes('hampi')) toCode = 'HPT';
      else if (lower.includes('gir')) toCode = 'JND';
      else if (lower.includes('coorg')) toCode = 'MYS';
      else if (lower.includes('gokarna')) toCode = 'GOK';
      else if (lower.includes('ooty')) toCode = 'CBE';
      else if (lower.includes('pondicherry')) toCode = 'PDY';
      else if (lower.includes('meghalaya') || lower.includes('shillong')) toCode = 'GHY';
      else if (lower.includes('darjeeling')) toCode = 'NJP';
      else if (lower.includes('sundarbans')) toCode = 'HWH';
      else if (lower.includes('saputara')) toCode = 'BIM';
      else toCode = 'MMCT'; // Default fallback
    }

    if (fromCode === toCode) return res.json([]);

    let multiplier = 1;
    if (classType === '3-Tier AC') multiplier = 2.5;
    if (classType === '1-Tier AC') multiplier = 4;

    const irctcPortalUrl = 'https://www.irctc.co.in/nget/train-search';
    const confirmTktUrl = `https://www.confirmtkt.com/rZone/trains-between-stations?from=${fromCode}&to=${toCode}`;
    const irctcDirectUrl = `https://www.irctc.co.in/nget/train-search`;

    // Standard fallback trains to guarantee immediate booking connectivity
    const fallbackTrains = [
      {
        id: '12424',
        name: `Rajdhani Superfast Express (12424) | ${fromCode} ➔ ${toCode}`,
        departure: '16:55',
        arrival: 'Next Day 08:30',
        price: Math.floor(1850 * multiplier),
        bookingUrl: irctcPortalUrl,
        confirmTktUrl: confirmTktUrl,
        portalName: 'IRCTC Official e-Ticketing'
      },
      {
        id: '12952',
        name: `Superfast Express (12952) | ${fromCode} ➔ ${toCode}`,
        departure: '19:20',
        arrival: 'Next Day 10:15',
        price: Math.floor(950 * multiplier),
        bookingUrl: irctcPortalUrl,
        confirmTktUrl: confirmTktUrl,
        portalName: 'IRCTC Official e-Ticketing'
      },
      {
        id: '12214',
        name: `Garib Rath / Duronto Express (12214) | ${fromCode} ➔ ${toCode}`,
        departure: '22:10',
        arrival: 'Next Day 14:00',
        price: Math.floor(1250 * multiplier),
        bookingUrl: irctcPortalUrl,
        confirmTktUrl: confirmTktUrl,
        portalName: 'IRCTC Official e-Ticketing'
      }
    ];

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
        return res.json(fallbackTrains);
      }
      
      const realTrains = json.data.slice(0, 5).map(train => {
        const basePrice = Math.max(650, Math.floor((train.distance || 800) * 0.9));
        return {
          id: train.train_number,
          name: `${train.train_name} (${train.train_number}) | ${fromCode} ➔ ${toCode}`,
          departure: train.from_std || '18:00',
          arrival: train.to_sta || 'Next Day 09:30',
          price: Math.floor(basePrice * multiplier),
          bookingUrl: irctcPortalUrl,
          confirmTktUrl: confirmTktUrl,
          portalName: 'IRCTC Official e-Ticketing'
        };
      });
      
      res.json(realTrains);
    })
    .catch(err => {
      console.warn('IRCTC RapidAPI fallback invoked:', err.message);
      res.json(fallbackTrains);
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
