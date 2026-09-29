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
        image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?q=80&w=600&auto=format&fit=crop',
        isTrending: true
      },
      {
        title: 'Royal Rajasthan',
        location: 'Jaipur',
        price: 'Rs. 32,000',
        rating: '4.8',
        duration: '7 Days',
        image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?q=80&w=600&auto=format&fit=crop',
        isTrending: true
      },
      {
        title: 'Majestic Himalayas',
        location: 'Ladakh',
        price: 'Rs. 45,000',
        rating: '5.0',
        duration: '8 Days',
        image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=600&auto=format&fit=crop',
        isTrending: true
      },
      {
        title: 'Goa Beach Escape',
        location: 'Goa',
        price: 'Rs. 18,000',
        rating: '4.7',
        duration: '4 Days',
        image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=600&auto=format&fit=crop',
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
        image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?q=80&w=600&auto=format&fit=crop',
        isTrending: true,
        departureDates: ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'],
        categories: {
          Economy: { price: 'Rs. 18,000', facilities: ['Standard Room', 'Breakfast Only', 'Shared Coach Transfers'] },
          Standard: { price: 'Rs. 25,000', facilities: ['3-Star Hotel', 'Breakfast & Dinner', 'Private Cab Transfers'] },
          Luxury: { price: 'Rs. 45,000', facilities: ['5-Star Premium Houseboat', 'All Meals Included', 'Private SUV', 'Ayurvedic Spa'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival in Kochi', description: 'Arrive at Kochi airport, transfer to hotel. Evening visit to Fort Kochi and Chinese Fishing Nets.' },
          { day: 2, title: 'Munnar Hills', description: 'Drive to Munnar. Visit tea gardens, Mattupetty Dam, and Echo Point. Enjoy the cool breeze.' },
          { day: 3, title: 'Thekkady Wildlife', description: 'Proceed to Thekkady. Enjoy a boat ride in Periyar Lake and watch wildlife.' },
          { day: 4, title: 'Alleppey Houseboat', description: 'Check into a traditional houseboat in Alleppey. Cruise through the backwaters.' },
          { day: 5, title: 'Departure', description: 'Morning breakfast on the houseboat. Transfer to Kochi airport for departure.' }
        ]
      },
      {
        id: 2,
        title: 'Royal Rajasthan',
        location: 'Jaipur',
        price: 'Rs. 32,000',
        rating: '4.8',
        duration: '7 Days',
        image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?q=80&w=600&auto=format&fit=crop',
        isTrending: true,
        departureDates: ['10 Oct 2026', '25 Oct 2026', '12 Nov 2026'],
        categories: {
          Economy: { price: 'Rs. 20,000', facilities: ['Standard Room', 'Breakfast', 'Bus Transfers'] },
          Standard: { price: 'Rs. 32,000', facilities: ['Heritage Hotel', 'Breakfast & Dinner', 'Private Sedan'] },
          Luxury: { price: 'Rs. 55,000', facilities: ['5-Star Palace Hotel', 'All Meals', 'Luxury SUV', 'Desert Safari'] }
        },
        itinerary: [
          { day: 1, title: 'Welcome to Jaipur', description: 'Arrive in the Pink City. Transfer to hotel. Evening visit to Chokhi Dhani.' },
          { day: 2, title: 'Jaipur Forts', description: 'Explore Amer Fort, Hawa Mahal, and City Palace. Shopping at Johari Bazaar.' },
          { day: 3, title: 'Jodhpur Blue City', description: 'Drive to Jodhpur. Visit Mehrangarh Fort and Umaid Bhawan Palace.' },
          { day: 4, title: 'Udaipur Lakes', description: 'Proceed to Udaipur. Enjoy a boat ride on Lake Pichola in the evening.' },
          { day: 5, title: 'Udaipur Sightseeing', description: 'Visit City Palace, Jag Mandir, and Saheliyon Ki Bari.' },
          { day: 6, title: 'Pushkar Visit', description: 'Drive back towards Jaipur via Pushkar. Visit the Brahma Temple.' },
          { day: 7, title: 'Departure', description: 'Transfer to Jaipur airport with royal memories.' }
        ]
      },
      {
        id: 3,
        title: 'Majestic Himalayas',
        location: 'Ladakh',
        price: 'Rs. 45,000',
        rating: '5.0',
        duration: '8 Days',
        image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=600&auto=format&fit=crop',
        isTrending: true,
        departureDates: ['01 May 2027', '15 May 2027', '05 Jun 2027'],
        categories: {
          Economy: { price: 'Rs. 35,000', facilities: ['Standard Camps', 'Breakfast', 'Shared Tempo Traveller'] },
          Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Camps/Hotels', 'Breakfast & Dinner', 'Private Innova'] },
          Luxury: { price: 'Rs. 75,000', facilities: ['Premium Glamping', 'All Meals', 'Luxury SUV 4x4', 'Oxygen Support'] }
        },
        itinerary: [
          { day: 1, title: 'Arrival & Acclimatization', description: 'Arrive in Leh. Rest for the entire day to acclimatize to the high altitude.' },
          { day: 2, title: 'Leh Local Sightseeing', description: 'Visit Shanti Stupa, Leh Palace, and local markets.' },
          { day: 3, title: 'Nubra Valley via Khardung La', description: 'Drive to Nubra Valley via the world\'s highest motorable road. Enjoy camel safari.' },
          { day: 4, title: 'Turtuk Village', description: 'Day trip to the beautiful border village of Turtuk. Return to Nubra.' },
          { day: 5, title: 'Pangong Tso', description: 'Drive to the majestic Pangong Lake. Camp overnight by the blue waters.' },
          { day: 6, title: 'Return to Leh', description: 'Wake up to a beautiful sunrise. Drive back to Leh via Chang La pass.' },
          { day: 7, title: 'Monasteries Tour', description: 'Visit Hemis, Thiksey, and Shey Monasteries.' },
          { day: 8, title: 'Departure', description: 'Transfer to Leh airport with memories of a lifetime.' }
        ]
      },
      {
        id: 4,
        title: 'Goa Beach Escape',
        location: 'Goa',
        price: 'Rs. 18,000',
        rating: '4.7',
        duration: '4 Days',
        image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=600&auto=format&fit=crop',
        isTrending: true,
        departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026'],
        categories: {
          Economy: { price: 'Rs. 12,000', facilities: ['Budget Hotel', 'Breakfast', 'No Transfers'] },
          Standard: { price: 'Rs. 18,000', facilities: ['3-Star Resort', 'Breakfast', 'Airport Transfers'] },
          Luxury: { price: 'Rs. 35,000', facilities: ['5-Star Beach Resort', 'All Meals', 'Private Cab', 'Yacht Ride'] }
        },
        itinerary: [
          { day: 1, title: 'Welcome to Goa', description: 'Arrive in Goa. Check into your beach resort. Relax by the sea.' },
          { day: 2, title: 'North Goa Beaches', description: 'Visit Baga, Calangute, and Anjuna beaches. Enjoy water sports.' },
          { day: 3, title: 'Old Goa & Cruise', description: 'Explore the churches of Old Goa. Evening Mandovi river cruise.' },
          { day: 4, title: 'Departure', description: 'Morning shopping at local markets. Transfer to airport.' }
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

    const response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(location)}&appid=${process.env.WEATHER_API_KEY}&units=metric`);
    
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

// Start Server (only if not running on Vercel)
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// Export the Express API for Vercel
module.exports = app;
