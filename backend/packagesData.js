// 35 Comprehensive, authentic travel & trekking packages across India
// Categorized by weather, ideal months, seasons, and adventure type

const allPackages = [
  // 1. KERALA BACKWATERS
  {
    id: 1,
    title: 'Kerala Backwaters',
    location: 'Kerala',
    price: 'Rs. 25,000',
    rating: '4.9',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Autumn & Winter (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '☀️ Pleasant 24°C • Breezy Backwaters',
    tripType: 'Beach & Island',
    departureDates: ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026', '12 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 18,000', facilities: ['Standard Room', 'Breakfast Only', 'Shared Coach Transfers'] },
      Standard: { price: 'Rs. 25,000', facilities: ['3-Star Hotel', 'Breakfast & Dinner', 'Private Cab Transfers'] },
      Luxury: { price: 'Rs. 45,000', facilities: ['5-Star Premium Houseboat', 'All Meals Included', 'Private SUV', 'Ayurvedic Spa'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Kochi & Heritage Walk', description: 'Arrive at Kochi airport, transfer to hotel. Explore colonial Fort Kochi, St. Francis Church, and Chinese Fishing Nets at sunset.' },
      { day: 2, title: 'Scenic Drive to Munnar Hills', description: 'Drive past Cheeyappara waterfalls to mist-covered Munnar tea plantations. Evening stroll through aromatic spice markets.' },
      { day: 3, title: 'Munnar Tea Estates & Wildlife', description: 'Visit Eravikulam National Park (Nilgiri Tahr), Tata Tea Museum, Mattupetty Dam, and Echo Point.' },
      { day: 4, title: 'Thekkady Spice Plantations & Safari', description: 'Guided spice plantation walk in Thekkady and Periyar Lake wildlife boat safari.' },
      { day: 5, title: 'Alleppey Houseboat Cruise & Departure', description: 'Cruise on a traditional houseboat in Alleppey backwaters with fresh Kerala lunch before airport transfer.' }
    ]
  },

  // 2. ROYAL RAJASTHAN
  {
    id: 2,
    title: 'Royal Rajasthan',
    location: 'Jaipur, Rajasthan',
    price: 'Rs. 32,000',
    rating: '4.8',
    duration: '7 Days',
    image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Winter & Festive (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '☀️ Sunny Days & Cool Nights • 18°C',
    tripType: 'Heritage & Culture',
    departureDates: ['10 Oct 2026', '25 Oct 2026', '12 Nov 2026', '08 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 20,000', facilities: ['Standard Room', 'Breakfast', 'Bus Transfers'] },
      Standard: { price: 'Rs. 32,000', facilities: ['Heritage Hotel', 'Breakfast & Dinner', 'Private Sedan'] },
      Luxury: { price: 'Rs. 55,000', facilities: ['5-Star Palace Hotel', 'All Meals', 'Luxury SUV', 'Desert Safari'] }
    },
    itinerary: [
      { day: 1, title: 'Welcome to the Pink City', description: 'Check-in and evening cultural extravaganza at Chokhi Dhani with folk dances and traditional Rajasthani thali.' },
      { day: 2, title: 'Majesty of Jaipur Forts', description: 'Amer Fort, City Palace, Jantar Mantar, and Hawa Mahal photoshoot.' },
      { day: 3, title: 'The Blue City of Jodhpur', description: 'Mehrangarh Fort, Jaswant Thada, and stroll through old blue-painted streets.' },
      { day: 4, title: 'Ranakpur Marble Temples to Udaipur', description: 'Admire 1,444 carved marble pillars at Ranakpur before arriving at Lake Pichola in Udaipur.' },
      { day: 5, title: 'Udaipur City of Lakes', description: 'City Palace complex, Saheliyon Ki Bari, and sunset boat cruise.' },
      { day: 6, title: 'Spiritual Pushkar', description: 'Brahma Temple and evening Aarti ceremonies on the sacred ghats.' },
      { day: 7, title: 'Departure', description: 'Breakfast and airport transfer from Jaipur.' }
    ]
  },

  // 3. MAJESTIC HIMALAYAS (LADAKH)
  {
    id: 3,
    title: 'Majestic Himalayas',
    location: 'Leh Ladakh',
    price: 'Rs. 45,000',
    rating: '5.0',
    duration: '8 Days',
    image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Summer High-Passes (May - Sep)',
    bestMonths: ['May', 'June', 'July', 'August', 'September'],
    weatherHighlight: '🏔️ High Altitude Sun & Crisp Air • 15°C',
    tripType: 'Trek & Adventure',
    departureDates: ['15 May 2027', '05 Jun 2027', '20 Jun 2027', '10 Jul 2027'],
    categories: {
      Economy: { price: 'Rs. 35,000', facilities: ['Standard Camps', 'Breakfast', 'Shared Tempo Traveller'] },
      Standard: { price: 'Rs. 45,000', facilities: ['Deluxe Camps/Hotels', 'Breakfast & Dinner', 'Private Innova'] },
      Luxury: { price: 'Rs. 75,000', facilities: ['Premium Glamping', 'All Meals', 'Luxury SUV 4x4', 'Oxygen Support'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival & Crucial Acclimatization', description: 'Arrive at Leh Airport (11,500 ft). Full day rest for altitude acclimatization.' },
      { day: 2, title: 'Leh Local Sightseeing', description: 'Shanti Stupa, ancient Leh Palace, and Leh Main Bazaar.' },
      { day: 3, title: 'Over Khardung La to Nubra Valley', description: 'Cross world-famous Khardung La Pass (18,380 ft). Camel safari at Hunder dunes.' },
      { day: 4, title: 'Turtuk Village Expedition', description: 'Day trip to border village Turtuk, lush apricot orchards and Balti culture.' },
      { day: 5, title: 'Pangong Tso Lake', description: 'Scenic drive along Shyok River to turquoise Pangong Lake (14,270 ft).' },
      { day: 6, title: 'Sunrise & Return via Chang La', description: 'Sunrise at Pangong, cross Chang La Pass (17,586 ft) back to Leh.' },
      { day: 7, title: 'Indus Valley Monasteries', description: 'Thiksey and Hemis monasteries, Rancho School.' },
      { day: 8, title: 'Departure', description: 'Transfer to Leh Airport.' }
    ]
  },

  // 4. GOA BEACH ESCAPE
  {
    id: 4,
    title: 'Goa Beach Escape',
    location: 'Goa',
    price: 'Rs. 18,000',
    rating: '4.7',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Winter Beach Days (Nov - Feb)',
    bestMonths: ['November', 'December', 'January', 'February'],
    weatherHighlight: '🏖️ Golden Sunshine • 28°C Beach Weather',
    tripType: 'Beach & Island',
    departureDates: ['20 Nov 2026', '25 Nov 2026', '10 Dec 2026', '15 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 12,000', facilities: ['Budget Hotel', 'Breakfast', 'No Transfers'] },
      Standard: { price: 'Rs. 18,000', facilities: ['3-Star Resort', 'Breakfast', 'Airport Transfers'] },
      Luxury: { price: 'Rs. 35,000', facilities: ['5-Star Beach Resort', 'All Meals', 'Private Cab', 'Yacht Ride'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival & Beach Relaxation', description: 'Check into North Goa resort, evening sunset walk on the shoreline.' },
      { day: 2, title: 'North Goa Water Sports', description: 'Parasailing, jet ski at Baga/Calangute, visit Aguada Fort and Tito\'s Lane.' },
      { day: 3, title: 'Old Goa & Mandovi River Cruise', description: 'Basilica of Bom Jesus, colorful Fontainhas quarter, and sunset cruise.' },
      { day: 4, title: 'Farewell Goa', description: 'Souvenir shopping and transfer to airport/railway station.' }
    ]
  },

  // 5. KEDARKANTHA SNOW TREK (INVINCIBLE NGO)
  {
    id: 5,
    title: 'Kedarkantha Snow Trek',
    location: 'Sankri, Uttarakhand',
    price: 'Rs. 9,500',
    rating: '4.9',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Winter Snow (Dec - Apr)',
    bestMonths: ['December', 'January', 'February', 'March', 'April'],
    weatherHighlight: '❄️ Sub-Zero Snow Peak • -4°C to 6°C',
    tripType: 'Trek & Adventure',
    departureDates: ['10 Dec 2026', '20 Dec 2026', '02 Jan 2027', '18 Jan 2027', '05 Feb 2027'],
    categories: {
      Economy: { price: 'Rs. 7,500', facilities: ['Alpine Tents', 'Nutritious Veg Meals', 'Certified Guides', 'Forest Permits'] },
      Standard: { price: 'Rs. 9,500', facilities: ['Deluxe Alpine Tents (Triple Sharing)', 'All Meals Included', 'Microspikes & Gaiters', 'Oxygen Kit', 'Summit Certificate'] },
      Luxury: { price: 'Rs. 14,000', facilities: ['Private Wooden Homestay in Sankri', 'All Meals & Snacks', 'Dedicated Guide & Porter', 'Personal Crampons', 'Campfire Evening'] }
    },
    itinerary: [
      { day: 1, title: 'Dehradun to Sankri Base Camp', description: 'Drive 195 km along Yamuna and Tons rivers through Mussoorie to Sankri (6,400 ft).' },
      { day: 2, title: 'Sankri to Juda Ka Talab', description: 'Trek 4 km through pine and oak woods to the frozen glacial lake of Juda Ka Talab (9,100 ft).' },
      { day: 3, title: 'Juda Ka Talab to Kedarkantha Base', description: 'Ascend to Kedarkantha Base Camp (11,250 ft) with sunset views of Swargarohini & Bandarpoonch.' },
      { day: 4, title: 'Summit Push (12,500 ft) & Hargaon', description: 'Dawn summit climb to 12,500 ft for 360-degree Himalayan sunrise. Glissade down to Hargaon.' },
      { day: 5, title: 'Hargaon to Sankri Base Camp', description: 'Descend through rhododendrons back to Sankri base camp. Celebratory campfire and certificates.' },
      { day: 6, title: 'Departure to Dehradun', description: 'Scenic drive back to Dehradun railway station/airport.' }
    ]
  },

  // 6. MANALI ADVENTURE & TREKKING CAMP (INVINCIBLE NGO)
  {
    id: 6,
    title: 'Manali Adventure & Trekking Camp',
    location: 'Manali, Himachal Pradesh',
    price: 'Rs. 7,800',
    rating: '4.8',
    duration: '7 Days',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Spring & Summer (Apr - Jul)',
    bestMonths: ['April', 'May', 'June', 'July', 'October', 'December'],
    weatherHighlight: '🌲 Cool Alpine Weather • 14°C to 20°C',
    tripType: 'Trek & Adventure',
    departureDates: ['15 Nov 2026', '05 Dec 2026', '24 Dec 2026', '10 Jan 2027', '02 May 2027'],
    categories: {
      Economy: { price: 'Rs. 6,200', facilities: ['Alpine Tents', 'All Meals', 'Guided Trekking', 'River Rafting'] },
      Standard: { price: 'Rs. 7,800', facilities: ['Riverside Campsite', 'Beas River Rafting', 'Solang Valley Snow Sports', 'Jogini Falls Trek', 'Campfire & DJ'] },
      Luxury: { price: 'Rs. 13,500', facilities: ['Boutique Apple Orchard Resort', 'Private Heated Cottage', 'River Crossing', 'Paragliding Tickets', 'Bonfire Music'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival at Manali Campsite', description: 'Riverside campsite check-in, tent allocation, and orientation along Beas river.' },
      { day: 2, title: 'Jogini Waterfalls & Vashisht Springs', description: 'Trek through pine woods to Jogini Waterfalls; natural sulphur spring baths in Vashisht.' },
      { day: 3, title: 'Solang Valley & Atal Tunnel', description: 'Adventure sports in Solang Valley and drive through Atal Tunnel to Sissu.' },
      { day: 4, title: 'Lama Dugh Ridge Trek', description: 'High-altitude ridge hike offering aerial panoramas of Manali valley and glaciers.' },
      { day: 5, title: 'Beas River Rafting & Rock Climbing', description: 'Whitewater rafting over Beas rapids, rappelling, and obstacle courses.' },
      { day: 6, title: 'Old Manali, Hadimba & Mall Road', description: 'Centuries-old wooden Hadimba Temple, cafes of Old Manali, and Mall Road shopping.' },
      { day: 7, title: 'Farewell & Departure', description: 'Closing ceremony and departure towards Chandigarh.' }
    ]
  },

  // 7. POLO FOREST TREK & ECO CAMP (INVINCIBLE NGO)
  {
    id: 7,
    title: 'Polo Forest Trek & Eco Camp',
    location: 'Polo Forest, Gujarat',
    price: 'Rs. 1,850',
    rating: '4.9',
    duration: '2 Days',
    image: 'https://images.unsplash.com/photo-1511497584788-87676104235f?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Monsoon & Winter (Jul - Feb)',
    bestMonths: ['July', 'August', 'September', 'October', 'November', 'December', 'January', 'February'],
    weatherHighlight: '🌿 Lush Forest Mist • 22°C Stargazing',
    tripType: 'Nature & Hills',
    departureDates: ['17 Oct 2026', '24 Oct 2026', '07 Nov 2026', '21 Nov 2026', '05 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 1,450', facilities: ['Forest Campsite Tents', 'Kathiyawadi / Gujarati Meals', 'Forest Permits', 'Trek Guide'] },
      Standard: { price: 'Rs. 1,850', facilities: ['Dome Tents', 'All Meals Included', 'Rock Climbing & Rappelling', 'Harnav River Crossing', 'Stargazing Astronomy Session'] },
      Luxury: { price: 'Rs. 3,500', facilities: ['Deluxe AC Cottages at Forest Eco Resort', 'Private Guide', 'Stargazing Telescope Experience', 'Open Gypsy Safari'] }
    },
    itinerary: [
      { day: 1, title: 'Ancient Jain Temples & Stargazing', description: 'Camp setup near Harnav River. Explore 15th-century vine-clad Jain temples, bouldering, and night astronomy stargazing.' },
      { day: 2, title: 'Idar Hills Sunrise & River Crossing', description: 'Hilltop sunrise hike over Aravalli forest canopy, river wading in Harnav, and visit to Vanaj Dam before departure.' }
    ]
  },

  // 8. BEYT DWARKA MARINE & BEACH CAMP (INVINCIBLE NGO)
  {
    id: 8,
    title: 'Beyt Dwarka Marine & Beach Camp',
    location: 'Beyt Dwarka, Gujarat',
    price: 'Rs. 3,800',
    rating: '4.8',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Winter Marine Season (Nov - Mar)',
    bestMonths: ['November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '🌊 Coastal Island Breeze • 23°C',
    tripType: 'Beach & Island',
    departureDates: ['14 Nov 2026', '28 Nov 2026', '12 Dec 2026', '26 Dec 2026', '09 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 2,900', facilities: ['Beach Tents', 'All Vegetarian Meals', 'Ferry Transfers', 'Marine Guide'] },
      Standard: { price: 'Rs. 3,800', facilities: ['Beachfront Dome Tents', 'Coral Reef Walk', 'Dolphin Boat Safari', 'Dunny Point Trek', 'Campfire & Music'] },
      Luxury: { price: 'Rs. 6,500', facilities: ['Premium Sea-facing Swiss Tents', 'Private Dolphin Cruise', 'Water Sports', 'Dedicated Marine Biologist Guide'] }
    },
    itinerary: [
      { day: 1, title: 'Ferry to Island & Beach Camping', description: 'Ferry ride from Okha across Gulf of Kutch to Beyt Dwarka. White sand camping and sunset beach games around campfire.' },
      { day: 2, title: 'Coral Reef Walk & Dolphin Safari', description: 'Low-tide marine walk to spot live corals, octopus, and pufferfish. Boat safari deep in the Gulf to watch dolphins leap.' },
      { day: 3, title: 'Lord Krishna Temple & Return', description: 'Visit historic Beyt Dwarka temple and Shivrajpur Blue Flag Beach before departure.' }
    ]
  },

  // 9. SAPUTARA ADVENTURE & NATURE CAMP (INVINCIBLE NGO)
  {
    id: 9,
    title: 'Saputara Adventure & Nature Camp',
    location: 'Saputara, Gujarat',
    price: 'Rs. 2,900',
    rating: '4.7',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Monsoon & Post-Monsoon (Jul - Nov)',
    bestMonths: ['July', 'August', 'September', 'October', 'November', 'December'],
    weatherHighlight: '🌧️ Misty Sahyadri Peaks • 21°C',
    tripType: 'Nature & Hills',
    departureDates: ['23 Oct 2026', '06 Nov 2026', '20 Nov 2026', '04 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 2,200', facilities: ['Nature Camp Tents', 'Dangi/Gujarati Meals', 'Group Hikes', 'Instructors'] },
      Standard: { price: 'Rs. 2,900', facilities: ['Deluxe Alpine Tents', 'All Meals', 'Zipline & Commando Net', 'Gira Waterfalls Trek', 'Sunset Point', 'Campfire'] },
      Luxury: { price: 'Rs. 5,200', facilities: ['Hilltop Resort Cottage', 'Lake Boating', 'Private Valley Excursion', 'Ropeway Tickets', 'Dangi Tribal Tasting'] }
    },
    itinerary: [
      { day: 1, title: 'Welcome to Saputara Sahyadri', description: 'Arrival, tent allotment, sunset hike over Maharashtra and Gujarat valleys, campfire music.' },
      { day: 2, title: 'Governor Hill & Gira Waterfalls', description: 'High-rope zipline circuit and excursion to roaring Gira Waterfalls among dense bamboo forests.' },
      { day: 3, title: 'Saputara Lake Boating & Crafts', description: 'Lake boating, tribal heritage museum, and rose gardens before departure.' }
    ]
  },

  // 10. CHOPTA TUNGNATH CHANDRASHILA TREK (INVINCIBLE NGO)
  {
    id: 10,
    title: 'Chopta Tungnath Chandrashila Trek',
    location: 'Chopta, Uttarakhand',
    price: 'Rs. 8,900',
    rating: '5.0',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Autumn & Spring (Oct - Dec & Apr - Jun)',
    bestMonths: ['April', 'May', 'June', 'October', 'November', 'December'],
    weatherHighlight: '❄️ Highest Shiva Temple • 5°C to 12°C',
    tripType: 'Trek & Adventure',
    departureDates: ['15 Nov 2026', '01 Dec 2026', '15 Dec 2026', '05 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 7,200', facilities: ['Alpine Tents', 'All Meals', 'Forest Permits', 'Trek Leader'] },
      Standard: { price: 'Rs. 8,900', facilities: ['Meadow Campsite', 'Trek to Tungnath Temple & Chandrashila Peak', 'Deoriatal Lake Camp', 'Bonfire & Certificates'] },
      Luxury: { price: 'Rs. 14,500', facilities: ['Heated Wooden Chalet in Chopta', 'Private Guide', 'Crampons/Gaiters Included', 'Dedicated Vehicle Support', 'Gourmet Meals'] }
    },
    itinerary: [
      { day: 1, title: 'Rishikesh to Sari Village', description: 'Drive along holy rivers via Devprayag and Rudraprayag through Alaknanda valley to Sari.' },
      { day: 2, title: 'Sari to Deoriatal Lake', description: 'Trek 3 km to emerald Deoriatal lake reflecting Chaukhamba snow peaks in its waters.' },
      { day: 3, title: 'Deoriatal to Chopta Meadows', description: 'Ridge trek through oak and rhododendron canopies to alpine meadows of Chopta.' },
      { day: 4, title: 'Tungnath Temple (12,073 ft) & Chandrashila (13,123 ft)', description: 'Ascend to world\'s highest Shiva temple and Chandrashila summit for 360-degree Garhwal views.' },
      { day: 5, title: 'Chopta to Rishikesh Return', description: 'Descent to roadhead and drive back to Rishikesh for evening Ganga Aarti.' },
      { day: 6, title: 'Departure', description: 'Morning breakfast and onward travel.' }
    ]
  },

  // 11. SPITI VALLEY ROAD TRIP & ODYSSEY (INVINCIBLE NGO)
  {
    id: 11,
    title: 'Spiti Valley Road Trip & Odyssey',
    location: 'Spiti Valley, Himachal Pradesh',
    price: 'Rs. 19,500',
    rating: '5.0',
    duration: '9 Days',
    image: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Summer High-Passes (May - Oct)',
    bestMonths: ['May', 'June', 'July', 'August', 'September', 'October'],
    weatherHighlight: '🌌 Stargazing Desert • 8°C to 16°C',
    tripType: 'Trek & Adventure',
    departureDates: ['10 May 2027', '24 May 2027', '07 Jun 2027', '21 Jun 2027'],
    categories: {
      Economy: { price: 'Rs. 15,500', facilities: ['Homestays/Dorms', 'Breakfast & Dinner', 'Shared Tempo Traveller'] },
      Standard: { price: 'Rs. 19,500', facilities: ['Deluxe Boutique Homestays & Camps', 'All Meals', 'Force Urbania/Innova', 'Oxygen Cylinders', 'Tour Leader'] },
      Luxury: { price: 'Rs. 32,000', facilities: ['Premium Luxury Spitian Villas', 'Private 4x4 SUV', 'Dedicated Stargazing Setup', 'High-Altitude Medical Support'] }
    },
    itinerary: [
      { day: 1, title: 'Chandigarh to Kalpa', description: 'Drive through Kinnaur along Hindustan-Tibet road. Sunset over Kinnaur Kailash.' },
      { day: 2, title: 'Kalpa to Tabo Monastery', description: 'Enter Spiti cold desert. Visit 1,000-year-old Tabo Monastery.' },
      { day: 3, title: 'Dhankar Monastery & Kaza', description: 'Climb to cliff-hanging Dhankar Monastery, reach Kaza.' },
      { day: 4, title: 'Hikkim, Komic & Langza', description: 'World\'s highest post office at Hikkim (14,567 ft), Komic village, and giant Buddha at Langza.' },
      { day: 5, title: 'Key Monastery & Chicham Bridge', description: 'Iconic fortress-like Key Monastery and dizzying Chicham gorge suspension bridge.' },
      { day: 6, title: 'Kunzum Pass & Chandratal Lake', description: 'Traverse 15,060 ft Kunzum Pass. Camp near crescent-shaped Chandratal Moon Lake.' },
      { day: 7, title: 'Chandratal to Manali via Atal Tunnel', description: 'Batal water crossings and Atal Tunnel back into green Manali.' },
      { day: 8, title: 'Manali Leisure Day', description: 'Old Manali cafes and celebratory dinner.' },
      { day: 9, title: 'Departure to Chandigarh', description: 'Return transfer to Chandigarh.' }
    ]
  },

  // 12. KASOL & KHEERGANGA HOT SPRINGS TREK (INVINCIBLE NGO)
  {
    id: 12,
    title: 'Kasol & Kheerganga Hot Springs Trek',
    location: 'Kasol, Himachal Pradesh',
    price: 'Rs. 6,800',
    rating: '4.8',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Spring & Autumn (Apr - Jun & Sep - Nov)',
    bestMonths: ['April', 'May', 'June', 'September', 'October', 'November'],
    weatherHighlight: '♨️ Hot Springs & Pine Forests • 15°C',
    tripType: 'Trek & Adventure',
    departureDates: ['20 Oct 2026', '10 Nov 2026', '01 Dec 2026', '20 Dec 2026'],
    categories: {
      Economy: { price: 'Rs. 5,200', facilities: ['Riverside Tents', 'Breakfast & Dinner', 'Trek Guide'] },
      Standard: { price: 'Rs. 6,800', facilities: ['Riverside Campsite', 'Kheerganga Dome Tents', 'Tosh Village Tour', 'Natural Hot Springs Bath', 'Bonfire'] },
      Luxury: { price: 'Rs. 11,500', facilities: ['Boutique Wooden Chalet in Kasol', 'Private Guide', 'Cafe Hopping Credit', 'Hot Sulphur Spring Access'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Kasol & Parvati Trail', description: 'Camp along Parvati river, German bakeries, and Chalal nature walk.' },
      { day: 2, title: 'Manikaran Sahib & Tosh Village', description: 'Manikaran natural hot springs and hike to rustic wooden village of Tosh.' },
      { day: 3, title: 'Trek to Kheerganga (9,700 ft)', description: '12 km trek past Rudranag waterfall to Kheerganga. Soak in natural hot sulphur pools under the stars.' },
      { day: 4, title: 'Kheerganga Sunrise & Kasol Return', description: 'Sunrise hike over alpine meadows, descent to Barshaini, and campfire in Kasol.' },
      { day: 5, title: 'Kasol Shopping & Departure', description: 'Souvenir shopping and departure towards Bhuntar/Chandigarh.' }
    ]
  },

  // 13. VALLEY OF FLOWERS & HEMKUND SAHIB TREK
  {
    id: 13,
    title: 'Valley of Flowers & Hemkund Sahib',
    location: 'Chamoli, Uttarakhand',
    price: 'Rs. 11,500',
    rating: '5.0',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Monsoon Floral Bloom (Jul - Sep)',
    bestMonths: ['July', 'August', 'September'],
    weatherHighlight: '🌸 Millions of Wildflowers • 12°C to 18°C',
    tripType: 'Trek & Adventure',
    departureDates: ['10 Jul 2027', '24 Jul 2027', '07 Aug 2027', '21 Aug 2027'],
    categories: {
      Economy: { price: 'Rs. 9,200', facilities: ['Guesthouse Stay in Ghangaria', 'All Veg Meals', 'National Park Permits', 'Trek Leader'] },
      Standard: { price: 'Rs. 11,500', facilities: ['Deluxe Lodge in Ghangaria', 'All Meals', 'Hemkund Sahib Guide', 'Rain Ponchos & Gaiters', 'Certificates'] },
      Luxury: { price: 'Rs. 18,500', facilities: ['Premium Mountain Lodge in Joshimath & Ghangaria', 'Private Porter Support', 'Dedicated Naturalist', 'Helicopter Option Support'] }
    },
    itinerary: [
      { day: 1, title: 'Rishikesh to Govindghat / Joshimath', description: 'Scenic drive along Alaknanda River via Devprayag to Govindghat.' },
      { day: 2, title: 'Govindghat to Ghangaria Base', description: 'Trek 13 km along roaring Pushpawati river to the pine-scented base of Ghangaria (9,800 ft).' },
      { day: 3, title: 'UNESCO Valley of Flowers Exploration', description: 'Enter the national park to witness 500+ species of wild alpine blooms, blue poppies, and glacial streams.' },
      { day: 4, title: 'Hemkund Sahib Glacial Lake (14,107 ft)', description: 'Ascend stone staircase to the sacred high-altitude lake of Hemkund Sahib surrounded by 7 snow peaks.' },
      { day: 5, title: 'Ghangaria to Govindghat & Joshimath', description: 'Descend to Govindghat and transfer to Joshimath for celebration.' },
      { day: 6, title: 'Departure to Rishikesh', description: 'Drive back to Rishikesh with memories of the floral paradise.' }
    ]
  },

  // 14. BRAHMATAL FROZEN LAKE TREK
  {
    id: 14,
    title: 'Brahmatal Frozen Lake Trek',
    location: 'Lohajung, Uttarakhand',
    price: 'Rs. 9,800',
    rating: '4.9',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Winter Snow (Dec - Mar)',
    bestMonths: ['December', 'January', 'February', 'March'],
    weatherHighlight: '❄️ Frozen Alpine Lake • -6°C to 4°C',
    tripType: 'Trek & Adventure',
    departureDates: ['15 Dec 2026', '28 Dec 2026', '10 Jan 2027', '24 Jan 2027', '07 Feb 2027'],
    categories: {
      Economy: { price: 'Rs. 7,800', facilities: ['Alpine Snow Tents', 'Nutritious Meals', 'Forest Entry', 'Certified Guides'] },
      Standard: { price: 'Rs. 9,800', facilities: ['Deluxe Snow Tents (Triple)', 'Microspikes & Gaiters', 'Oxygen Cylinder', 'Summit Certificate'] },
      Luxury: { price: 'Rs. 15,000', facilities: ['Heated Wooden Cottage in Lohajung', 'All Trail Meals', 'Dedicated Guide & Porter', 'Personal Crampons'] }
    },
    itinerary: [
      { day: 1, title: 'Kathgodam to Lohajung Base', description: '210 km drive through Kumaon hills via Almora and Kausani to Lohajung (7,600 ft).' },
      { day: 2, title: 'Lohajung to Bekaltal Lake', description: 'Trek 6 km through dense oak and rhododendron forests to the frozen Bekaltal lake.' },
      { day: 3, title: 'Bekaltal to Brahmatal Campsite', description: 'Walk across expansive snow meadows offering panoramic views of Mt. Trishul and Nanda Ghunti.' },
      { day: 4, title: 'Brahmatal Pass Summit (12,250 ft)', description: 'Climb to Brahmatal Pass for views of Roopkund trail and Chaukhamba range, then visit frozen Brahmatal lake.' },
      { day: 5, title: 'Brahmatal to Lohajung', description: 'Direct descent back to Lohajung village with celebratory campfire.' },
      { day: 6, title: 'Departure to Kathgodam', description: 'Scenic drive back to Kathgodam railway station.' }
    ]
  },

  // 15. HAMPTA PASS & CHANDRATAL TREK
  {
    id: 15,
    title: 'Hampta Pass & Chandratal Crossover',
    location: 'Manali to Spiti, Himachal',
    price: 'Rs. 10,800',
    rating: '5.0',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Summer & Monsoon (Jun - Oct)',
    bestMonths: ['June', 'July', 'August', 'September', 'October'],
    weatherHighlight: '🏔️ Lush Green to Cold Desert • 10°C to 16°C',
    tripType: 'Trek & Adventure',
    departureDates: ['20 Jun 2027', '05 Jul 2027', '20 Jul 2027', '10 Aug 2027', '01 Sep 2027'],
    categories: {
      Economy: { price: 'Rs. 8,500', facilities: ['Dome Tents', 'All Trail Meals', 'Forest Permits', 'Trek Leader'] },
      Standard: { price: 'Rs. 10,800', facilities: ['Deluxe Alpine Tents', 'Chandratal Lake Excursion', 'Spiti Vehicle Support', 'Safety Gear & Certificate'] },
      Luxury: { price: 'Rs. 16,500', facilities: ['Private Glamping in Manali & Chhatru', 'SUV Transfers', 'Dedicated Mountain Guide', 'High Altitude Medical Support'] }
    },
    itinerary: [
      { day: 1, title: 'Manali to Jobra & Chika Camp', description: 'Drive past Prini to Jobra. 2-hour walk through maple and birch trees to riverside Chika (10,100 ft).' },
      { day: 2, title: 'Chika to Balu Ka Ghera', description: 'Trek through boulder fields and wild river crossings to snow-melt meadow of Balu Ka Ghera (11,900 ft).' },
      { day: 3, title: 'Hampta Pass Crossing (14,100 ft) to Shea Goru', description: 'Climb steep snowfields to Hampta Pass summit; crossover into the dramatic barren Lahaul valley to Shea Goru.' },
      { day: 4, title: 'Shea Goru to Chhatru & Chandratal', description: 'Cross freezing Shea Goru stream, descend to Chhatru roadhead, and drive to the turquoise crescent Chandratal Lake.' },
      { day: 5, title: 'Chandratal to Manali via Atal Tunnel', description: 'Drive through Batal, Gramphu, and Atal Tunnel back to Manali.' },
      { day: 6, title: 'Departure from Manali', description: 'Morning leisure in Manali and onward travel.' }
    ]
  },

  // 16. MEGHALAYA LIVING ROOT BRIDGES & WATERFALLS
  {
    id: 16,
    title: 'Meghalaya Living Root Bridges & Waterfalls',
    location: 'Shillong & Cherrapunji, Meghalaya',
    price: 'Rs. 22,000',
    rating: '4.9',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1511497584788-87676104235f?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Autumn & Winter (Oct - Apr)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March', 'April'],
    weatherHighlight: '🌿 Crystal Waters & Misty Hills • 18°C',
    tripType: 'Nature & Hills',
    departureDates: ['18 Oct 2026', '08 Nov 2026', '22 Nov 2026', '15 Dec 2026', '10 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 16,000', facilities: ['Cozy Homestays', 'Breakfast', 'Shared Coach'] },
      Standard: { price: 'Rs. 22,000', facilities: ['Boutique Eco Resort', 'Breakfast & Dinner', 'Private Cab', 'Caving Guide'] },
      Luxury: { price: 'Rs. 38,000', facilities: ['5-Star Luxury Resort in Shillong & Cherrapunji', 'All Meals', 'Private Innova Crysta', 'Boat Safari at Dawki'] }
    },
    itinerary: [
      { day: 1, title: 'Guwahati to Shillong "Scotland of the East"', description: 'Pickup at Guwahati, stop at serene Umiam Lake (Barapani), evening walk around Police Bazar in Shillong.' },
      { day: 2, title: 'Shillong to Cherrapunji Waterfalls', description: 'Visit Elephant Falls, Mawkdok Dympep Valley viewpoint, Nohkalikai Falls (tallest plunge waterfall), and Mawsmai Cave.' },
      { day: 3, title: 'Double Decker Living Root Bridge Trek', description: 'Descend 3,500 stone stairs into the rainforest of Nongriat to marvel at the 250-year-old bio-engineered root bridges and turquoise natural pools.' },
      { day: 4, title: 'Mawlynnong Cleanest Village & Dawki River', description: 'Explore Mawlynnong (Asia\'s cleanest village), then boat ride on the glass-transparent waters of Umngot River in Dawki near Bangladesh border.' },
      { day: 5, title: 'Krang Shuri Falls & Jowai', description: 'Swim in the magical azure pool of Krang Shuri Waterfalls and explore Laitlum Canyons.' },
      { day: 6, title: 'Shillong to Guwahati Departure', description: 'Visit Kamakhya Temple in Guwahati before airport drop-off.' }
    ]
  },

  // 17. ANDAMAN ISLANDS TROPICAL SCUBA & BEACH PARADISE
  {
    id: 17,
    title: 'Andaman Islands Tropical Paradise',
    location: 'Havelock & Neil Island, Andaman',
    price: 'Rs. 34,000',
    rating: '5.0',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Tropical Winter & Spring (Oct - May)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March', 'April', 'May'],
    weatherHighlight: '🏝️ Azure Seas & Coral Reefs • 27°C',
    tripType: 'Beach & Island',
    departureDates: ['25 Oct 2026', '12 Nov 2026', '05 Dec 2026', '20 Dec 2026', '15 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 24,000', facilities: ['Standard AC Hotel', 'Breakfast', 'Government Ferry'] },
      Standard: { price: 'Rs. 34,000', facilities: ['3-Star Beach Resort', 'Breakfast & Dinner', 'Makruzz Luxury Cruise', 'Scuba Diving Intro'] },
      Luxury: { price: 'Rs. 62,000', facilities: ['5-Star Beachfront Villa (Taj/Barefoot)', 'All Meals', 'Private Catamaran', 'PADI Certified Scuba', 'Sunset Candlelight Dinner'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Port Blair & Cellular Jail', description: 'Arrive at Veer Savarkar Airport. Visit historic Cellular Jail and witness the evocative Light & Sound show.' },
      { day: 2, title: 'Makruzz Cruise to Havelock (Swaraj Dweep)', description: 'High-speed catamaran cruise to Havelock. Spend afternoon at Asia\'s best Radhanagar Beach (Beach No. 7) for a fiery sunset.' },
      { day: 3, title: 'Elephant Beach Snorkeling & Water Sports', description: 'Speedboat to Elephant Beach for vibrant coral snorkeling, sea walking, and parasailing.' },
      { day: 4, title: 'Neil Island (Shaheed Dweep) Exploration', description: 'Cruise to Neil Island. Visit natural rock bridge (Howrah Bridge), Laxmanpur Beach sunset, and Bharatpur coral reef.' },
      { day: 5, title: 'Return to Port Blair & Chidiya Tapu', description: 'Cruise back to Port Blair. Sunset excursion to Chidiya Tapu and local handicraft shopping at Sagarika Emporium.' },
      { day: 6, title: 'Departure with Tropical Memories', description: 'Transfer to Port Blair airport for flight home.' }
    ]
  },

  // 18. RANN OF KUTCH WHITE DESERT FESTIVAL
  {
    id: 18,
    title: 'Rann of Kutch White Desert Festival',
    location: 'Dhordo, Gujarat',
    price: 'Rs. 16,500',
    rating: '4.9',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Rann Utsav Winter (Nov - Feb)',
    bestMonths: ['November', 'December', 'January', 'February'],
    weatherHighlight: '🌕 Full Moon White Salt Desert • 16°C to 24°C',
    tripType: 'Heritage & Culture',
    departureDates: ['14 Nov 2026', '28 Nov 2026', '12 Dec 2026', '26 Dec 2026', '09 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 12,000', facilities: ['Standard Swiss Tents', 'Authentic Kutchi Meals', 'Shared Transfers', 'Rann Entry Permits'] },
      Standard: { price: 'Rs. 16,500', facilities: ['Deluxe AC Swiss Tents / Bhungas', 'All Meals', 'Sunset Camel Cart Safari', 'Kalo Dungar Visit'] },
      Luxury: { price: 'Rs. 28,000', facilities: ['Premium Royal Tent City Suite', 'VIP Access Rann Utsav', 'Private SUV', 'Folk Music Concerts', 'Dholavira Harappan Tour'] }
    },
    itinerary: [
      { day: 1, title: 'Bhuj to Dhordo Tent City', description: 'Arrive in Bhuj, visit Aina Mahal and Prag Mahal. Drive to Dhordo white desert village. Sunset on the endless white salt desert.' },
      { day: 2, title: 'White Rann Sunrise & Kalo Dungar', description: 'Sunrise over white salt desert. Afternoon visit to Kalo Dungar (Black Hill), highest point in Kutch overlooking the Indo-Pak border. Evening cultural folk music around campfire.' },
      { day: 3, title: 'Handicraft Villages & Dholavira UNESCO Site', description: 'Visit artisan villages of Nirona (Rogan art) and Hodka (mirror embroidery). Excursion to ancient Harappan civilization ruins at Dholavira.' },
      { day: 4, title: 'Bhuj Shopping & Departure', description: 'Shop for Kutchi bandhani, shawls, and leathercraft in Bhuj markets before train/flight departure.' }
    ]
  },

  // 19. COORG & WAYANAD COFFEE PLANTATION TRAILS
  {
    id: 19,
    title: 'Coorg & Wayanad Plantation Trails',
    location: 'Coorg & Wayanad, South India',
    price: 'Rs. 19,000',
    rating: '4.8',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Post-Monsoon & Winter (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '☕ Aromatic Coffee Mist • 19°C',
    tripType: 'Nature & Hills',
    departureDates: ['20 Oct 2026', '10 Nov 2026', '01 Dec 2026', '20 Dec 2026', '15 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 14,000', facilities: ['Estate Homestay', 'Breakfast', 'Shared Coach'] },
      Standard: { price: 'Rs. 19,000', facilities: ['Heritage Coffee Estate Resort', 'Breakfast & Dinner', 'Private Cab', 'Plantation Tour'] },
      Luxury: { price: 'Rs. 36,000', facilities: ['5-Star Luxury Wilderness Resort (Evolve Back)', 'All Meals', 'Private Pool Villa', 'Ayurvedic Massage'] }
    },
    itinerary: [
      { day: 1, title: 'Bangalore / Mysore to Coorg "Scotland of India"', description: 'Scenic drive to Coorg. Stop at Bylakuppe Golden Temple (Tibetan monastery). Check into coffee plantation estate.' },
      { day: 2, title: 'Abbey Falls, Talacauvery & Raja’s Seat', description: 'Visit sacred Talacauvery (origin of Cauvery River), trek down to Abbey Falls, and watch sunset at Raja’s Seat.' },
      { day: 3, title: 'Coorg to Wayanad Rainforest', description: 'Cross into Wayanad, Kerala. Trek to Edakkal Caves with prehistoric stone carvings. Explore Chembra Peak heart-shaped lake.' },
      { day: 4, title: 'Banasura Sagar Dam & Bamboo Rafting', description: 'Visit India\'s largest earth dam Banasura Sagar, followed by bamboo rafting on Kuruva Island in Kabini River.' },
      { day: 5, title: 'Spice Garden Tour & Departure', description: 'Sample fresh cardamom, pepper, and coffee before drop-off at Calicut or Bangalore.' }
    ]
  },

  // 20. VARANASI & PRAYAGRAJ SPIRITUAL HERITAGE
  {
    id: 20,
    title: 'Varanasi & Prayagraj Spiritual Heritage',
    location: 'Varanasi, Uttar Pradesh',
    price: 'Rs. 14,500',
    rating: '4.9',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Winter Heritage Season (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '🪔 Holy Ganga Morning Breeze • 17°C to 23°C',
    tripType: 'Heritage & Culture',
    departureDates: ['15 Oct 2026', '05 Nov 2026', '26 Nov 2026', '17 Dec 2026', '14 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 10,500', facilities: ['Standard Hotel Near Ghats', 'Breakfast', 'Walking Heritage Tour'] },
      Standard: { price: 'Rs. 14,500', facilities: ['Riverside Heritage Haveli', 'Breakfast & Dinner', 'Private Cab', 'Private Boat for Ganga Aarti'] },
      Luxury: { price: 'Rs. 29,000', facilities: ['5-Star Palace (BrijRama / Taj Ganges)', 'All Meals', 'Bajra Boat with Classical Music', 'VIP Temple Darshan'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Varanasi & Evening Ganga Aarti', description: 'Check into hotel. Stroll through the ancient alleys to Dashashwamedh Ghat for the grand evening Ganga Aarti from a private boat.' },
      { day: 2, title: 'Sunrise Boat on Ganga & Kashi Vishwanath', description: 'Dawn boat ride past Manikarnika and Assi ghats. Darshan at Kashi Vishwanath Corridor and visit to Banaras Hindu University.' },
      { day: 3, title: 'Day Trip to Triveni Sangam Prayagraj', description: 'Drive to Prayagraj to take a boat to Triveni Sangam (confluence of Ganga, Yamuna & mythical Saraswati). Visit Anand Bhavan.' },
      { day: 4, title: 'Buddhist Sarnath & Departure', description: 'Visit Sarnath where Lord Buddha gave his first sermon (Dhamek Stupa & Ashoka Pillar museum). Silk saree shopping and airport drop.' }
    ]
  },

  // 21. KASHMIR GREAT LAKES TREK & DAL LAKE SHIKARA
  {
    id: 21,
    title: 'Kashmir Great Lakes & Dal Paradise',
    location: 'Sonamarg & Srinagar, Kashmir',
    price: 'Rs. 24,500',
    rating: '5.0',
    duration: '8 Days',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Summer Alpine Meadows (Jul - Sep)',
    bestMonths: ['July', 'August', 'September'],
    weatherHighlight: '🏔️ Pristine Turquoise Alpine Lakes • 12°C to 18°C',
    tripType: 'Trek & Adventure',
    departureDates: ['10 Jul 2027', '25 Jul 2027', '08 Aug 2027', '22 Aug 2027'],
    categories: {
      Economy: { price: 'Rs. 18,500', facilities: ['Alpine Tents', 'All Meals', 'Trek Permits', 'Experienced Mountain Guides'] },
      Standard: { price: 'Rs. 24,500', facilities: ['Deluxe Alpine Camps', 'Dal Lake Houseboat Night', 'Shikara Ride', 'Pony Support for Bags', 'Safety Kit'] },
      Luxury: { price: 'Rs. 42,000', facilities: ['Luxury Houseboat in Srinagar', 'Private Glamping Tents on Trail', 'All Gourmet Kashmiri Wazwan', 'Helicopter Option'] }
    },
    itinerary: [
      { day: 1, title: 'Srinagar to Sonamarg Base', description: 'Drive along Sindh river from Srinagar to Sonamarg "Meadow of Gold" (7,800 ft).' },
      { day: 2, title: 'Sonamarg to Nichnai via Shekdur', description: 'Trek through silver birch forests with aerial views of Sonamarg valley to Nichnai (11,500 ft).' },
      { day: 3, title: 'Nichnai Pass (13,100 ft) to Vishansar Lake', description: 'Climb Nichnai Pass to behold the mesmerizing turquoise glacial waters of Vishansar Lake.' },
      { day: 4, title: 'Vishansar to Gadsar via Gadsar Pass (13,750 ft)', description: 'Trek past twin Kishansar lake, conquer highest point Gadsar Pass, and descend to the wildflower meadows of Gadsar.' },
      { day: 5, title: 'Gadsar to Satsar (Seven Lakes)', description: 'Trek across picturesque boulders and stream cascades to the collection of seven connected alpine lakes.' },
      { day: 6, title: 'Satsar to Gangabal & Nundkol Lakes', description: 'Ascend Zaj Pass to witness the twin lakes of Gangabal and Nundkol resting beneath the mighty Mt. Harmukh (16,870 ft).' },
      { day: 7, title: 'Gangabal to Naranag & Srinagar Houseboat', description: 'Descend through pine woods to ancient Naranag temple ruins. Drive to Srinagar and board a heritage Dal Lake houseboat.' },
      { day: 8, title: 'Shikara Ride & Departure', description: 'Morning Shikara ride to floating vegetable market, visit Mughal Gardens, and transfer to Srinagar Airport.' }
    ]
  },

  // 22. HAMPI & BADAMI UNESCO ARCHITECTURAL ODYSSEY
  {
    id: 22,
    title: 'Hampi & Badami UNESCO Architectural Odyssey',
    location: 'Hampi, Karnataka',
    price: 'Rs. 15,000',
    rating: '4.8',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Winter Boulder Exploring (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '🏛️ Golden Boulders & Sunsets • 22°C',
    tripType: 'Heritage & Culture',
    departureDates: ['24 Oct 2026', '14 Nov 2026', '05 Dec 2026', '19 Dec 2026', '09 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 10,500', facilities: ['Guesthouse on Hippie Island', 'Breakfast', 'Bicycle Rental'] },
      Standard: { price: 'Rs. 15,000', facilities: ['Heritage Heritage Resort', 'Breakfast & Dinner', 'Private Auto/Cab', 'Licensed Archeologist Guide'] },
      Luxury: { price: 'Rs. 32,000', facilities: ['5-Star Palace (Evolve Back Kamalapura)', 'All Meals', 'Private Luxury SUV', 'Coracle Boat Ride in Tungabhadra'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Hampi & Tungabhadra Sunset', description: 'Arrive at Hospet/Hampi. Explore Virupaksha Temple, Hemakuta Hill boulders, and sunset over Tungabhadra River.' },
      { day: 2, title: 'Vijayanagara Empire Wonders', description: 'Visit iconic Stone Chariot at Vijaya Vittala Temple, Lotus Mahal, Elephant Stables, and Queen\'s Bath.' },
      { day: 3, title: 'Day Trip to Badami Cave Temples, Aihole & Pattadakal', description: 'Excursion to 6th-century rock-cut cave temples of Badami overlooking Agastya lake, and UNESCO temples at Pattadakal.' },
      { day: 4, title: 'Coracle Ride & Departure', description: 'Circular coracle boat ride on Tungabhadra river and Anjaneya Hill before departure.' }
    ]
  },

  // 23. JAISALMER THAR DESERT CAMEL SAFARI & SAM DUNES
  {
    id: 23,
    title: 'Jaisalmer Thar Desert Camel Safari',
    location: 'Jaisalmer, Rajasthan',
    price: 'Rs. 13,800',
    rating: '4.9',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Desert Winter (Nov - Feb)',
    bestMonths: ['November', 'December', 'January', 'February'],
    weatherHighlight: '🏜️ Warm Days & Starlit Cold Nights • 12°C to 24°C',
    tripType: 'Heritage & Culture',
    departureDates: ['07 Nov 2026', '21 Nov 2026', '12 Dec 2026', '25 Dec 2026', '08 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 9,500', facilities: ['Desert Camp Tents', 'Rajasthani Buffet', 'Camel Ride', 'Folk Dance'] },
      Standard: { price: 'Rs. 13,800', facilities: ['Deluxe Swiss Desert Camp', 'Breakfast & Dinner', 'Dune Bashing Jeep Safari', 'Golden Fort Tour'] },
      Luxury: { price: 'Rs. 26,000', facilities: ['Luxury Glamping (Suryagarh / Serai)', 'All Meals', 'Private 4x4 Thar Dune Safari', 'Stargazing Astronomer'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in the Golden City', description: 'Check in. Explore the living golden sandstone fort (Sonar Qila) and Patwon Ki Haveli.' },
      { day: 2, title: 'Sam Sand Dunes Camel Safari', description: 'Drive to Sam Sand Dunes. Sunset camel ride across rippling golden sands. Night folk dance, Kalbelia fire show, and dinner under stars.' },
      { day: 3, title: 'Abandoned Kuldhara Village & Gadisar Lake', description: 'Visit the haunting cursed village of Kuldhara and enjoy a peaceful boat ride on Gadisar Lake.' },
      { day: 4, title: 'Desert Crafts & Departure', description: 'Shop for camel leather crafts, mirror-work textiles, and transfer to Jaisalmer station/airport.' }
    ]
  },

  // 24. GIR NATIONAL PARK LION SAFARI & SOMNATH
  {
    id: 24,
    title: 'Gir Lion Safari & Coastal Somnath',
    location: 'Sasan Gir, Gujarat',
    price: 'Rs. 12,800',
    rating: '4.8',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Winter & Spring Safari (Dec - Apr)',
    bestMonths: ['December', 'January', 'February', 'March', 'April'],
    weatherHighlight: '🦁 Wild Dry Deciduous Forest • 20°C',
    tripType: 'Nature & Hills',
    departureDates: ['04 Dec 2026', '18 Dec 2026', '08 Jan 2027', '22 Jan 2027', '05 Feb 2027'],
    categories: {
      Economy: { price: 'Rs. 9,200', facilities: ['Forest Resort Stay', 'Kathiyawadi Meals', 'Shared Safari Gypsy Permit'] },
      Standard: { price: 'Rs. 12,800', facilities: ['Deluxe Jungle Lodge', 'All Meals', 'Open 4x4 Gypsy Lion Safari', 'Somnath Temple Visit'] },
      Luxury: { price: 'Rs. 24,000', facilities: ['5-Star Luxury Safari Camp (Woods at Sasan / Taj)', 'All Meals', 'Private Guided Gypsy Safari', 'Tribal Siddi Dance Night'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Sasan Gir & Tribal Culture', description: 'Check into jungle lodge amidst mango orchards. Evening cultural performance by the African-origin Siddi tribe.' },
      { day: 2, title: 'Open Gypsy Asiatic Lion Safari', description: 'Early morning open 4x4 gypsy safari inside Gir National Park to track Asiatic lions, leopards, and spotted deer.' },
      { day: 3, title: 'Somnath Jyotirlinga Temple & Departure', description: 'Drive to sacred seaside Somnath Temple on Arabian Sea coastline before departure.' }
    ]
  },

  // 25. TIRTHAN VALLEY & GREAT HIMALAYAN NATIONAL PARK
  {
    id: 25,
    title: 'Tirthan Valley & Great Himalayan Park',
    location: 'Tirthan Valley, Himachal Pradesh',
    price: 'Rs. 11,200',
    rating: '4.9',
    duration: '5 Days',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Spring & Autumn (Mar - Jun & Sep - Nov)',
    bestMonths: ['March', 'April', 'May', 'June', 'September', 'October', 'November'],
    weatherHighlight: '🎣 Gushing Trout River & Pine Air • 16°C',
    tripType: 'Nature & Hills',
    departureDates: ['20 Oct 2026', '12 Nov 2026', '05 Dec 2026', '02 Apr 2027', '16 May 2027'],
    categories: {
      Economy: { price: 'Rs. 8,500', facilities: ['Riverside Wooden Cottages', 'All Veg Meals', 'Trek Guide'] },
      Standard: { price: 'Rs. 11,200', facilities: ['Boutique River Chalet', 'All Meals', 'Jalori Pass & Serolsar Lake Trek', 'Trout Angling Demo'] },
      Luxury: { price: 'Rs. 19,500', facilities: ['Luxury Treehouse / River Villa', 'All Meals', 'Private 4x4 Vehicle', 'Great Himalayan National Park Permit'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival in Serene Tirthan Valley', description: 'Check into riverside wooden lodge by the crystal Tirthan river. Walk through traditional Kullu villages.' },
      { day: 2, title: 'Great Himalayan National Park Trek', description: 'Hike along gushing streams into the UNESCO World Heritage park; picnic beside waterfalls.' },
      { day: 3, title: 'Jalori Pass (10,800 ft) & Serolsar Lake', description: 'Scenic drive to Jalori Pass, followed by a 5 km forest walk to sacred Serolsar Lake.' },
      { day: 4, title: 'Chehni Kothi 1500-Year-Old Tower', description: 'Trek to the tallest timber tower-fort in the Western Himalayas built without cement.' },
      { day: 5, title: 'Farewell Tirthan', description: 'Fresh trout tasting, local honey shopping, and departure.' }
    ]
  },

  // 26. DUDHSAGAR WATERFALLS & GOA RAINFOREST TREK
  {
    id: 26,
    title: 'Dudhsagar Falls & Rainforest Trek',
    location: 'Dudhsagar, Goa & Karnataka',
    price: 'Rs. 8,500',
    rating: '4.8',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Monsoon Roar (Jul - Oct)',
    bestMonths: ['July', 'August', 'September', 'October'],
    weatherHighlight: '🌧️ Roaring White Waterfall • 24°C Lush Monsoon',
    tripType: 'Trek & Adventure',
    departureDates: ['25 Jul 2027', '08 Aug 2027', '22 Aug 2027', '05 Sep 2027'],
    categories: {
      Economy: { price: 'Rs. 6,500', facilities: ['Jungle Campsite Tents', 'Meals Included', 'Railway Track / Forest Trek Guide'] },
      Standard: { price: 'Rs. 8,500', facilities: ['Eco Farm Cottages', 'All Meals', '4x4 Bhagwan Mahaveer Jungle Safari', 'Lifejackets for Natural Pool Bath'] },
      Luxury: { price: 'Rs. 15,000', facilities: ['Luxury Spice Plantation Resort', 'Private SUV', 'Spice Tour Buffet', 'Dedicated Naturalist'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival at Mollem National Park', description: 'Arrive at Mollem jungle camp. Evening trek through Western Ghats evergreen forests.' },
      { day: 2, title: 'The Majestic Dudhsagar Waterfall', description: '4x4 jeep safari crossing jungle streams to the base of the massive 4-tiered "Sea of Milk" waterfall. Swim in the freshwater pool.' },
      { day: 3, title: 'Spice Plantation Tour & Departure', description: 'Traditional Goan buffet at an organic spice plantation and return transfer.' }
    ]
  },

  // 27. DARJEELING & SIKKIM KANCHENJUNGA ODYSSEY
  {
    id: 27,
    title: 'Darjeeling & Sikkim Himalayan Odyssey',
    location: 'Darjeeling & Gangtok, East India',
    price: 'Rs. 26,000',
    rating: '4.9',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Spring & Autumn (Mar - May & Oct - Dec)',
    bestMonths: ['March', 'April', 'May', 'October', 'November', 'December'],
    weatherHighlight: '🏔️ Mt. Kanchenjunga Sunrise • 11°C to 17°C',
    tripType: 'Nature & Hills',
    departureDates: ['22 Oct 2026', '12 Nov 2026', '03 Dec 2026', '15 Mar 2027', '10 Apr 2027'],
    categories: {
      Economy: { price: 'Rs. 19,000', facilities: ['Standard Hotel', 'Breakfast', 'Shared Coach'] },
      Standard: { price: 'Rs. 26,000', facilities: ['Heritage Tea Estate Resort', 'Breakfast & Dinner', 'Private Cab', 'Toy Train Tickets'] },
      Luxury: { price: 'Rs. 48,000', facilities: ['5-Star Luxury (Mayfair / Windamere)', 'All Meals', 'Private Innova Crysta', 'Helicopter Ride Option'] }
    },
    itinerary: [
      { day: 1, title: 'Bagdogra to Darjeeling Queen of Hills', description: 'Drive past emerald tea gardens climbing into mist-clad Darjeeling (6,700 ft).' },
      { day: 2, title: 'Tiger Hill Sunrise & Himalayan Toy Train', description: 'Watch the sunrise turn Mt. Kanchenjunga into pure gold from Tiger Hill. Ride the UNESCO Himalayan Toy Train and visit Ghoom Monastery.' },
      { day: 3, title: 'Tea Estate Tasting to Gangtok', description: 'Tour Makaibari tea estate, cross the Teesta River into Gangtok, capital of Sikkim.' },
      { day: 4, title: 'Tsomgo Lake & Baba Mandir (12,400 ft)', description: 'Excursion to the sacred high-altitude glacial Tsomgo (Changu) Lake and Nathula Pass viewpoint.' },
      { day: 5, title: 'Rumtek Monastery & Enchey', description: 'Explore the grand Tibetan Rumtek Monastery, flower exhibition, and MG Marg pedestrian boulevard.' },
      { day: 6, title: 'Departure to Bagdogra', description: 'Transfer to Bagdogra airport carrying Darjeeling orthodox tea.' }
    ]
  },

  // 28. MUNNAR & KOLUKKUMALAI TEA ESTATE
  {
    id: 28,
    title: 'Kolukkumalai & Munnar Cloud Trail',
    location: 'Munnar, Kerala',
    price: 'Rs. 13,500',
    rating: '4.8',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Post-Monsoon & Winter (Sep - Mar)',
    bestMonths: ['September', 'October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '☁️ Above the Clouds • 15°C',
    tripType: 'Nature & Hills',
    departureDates: ['24 Oct 2026', '14 Nov 2026', '05 Dec 2026', '19 Dec 2026', '09 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 9,800', facilities: ['Tea Plantation Campsite Tents', 'All Meals', 'Jeep Safari'] },
      Standard: { price: 'Rs. 13,500', facilities: ['Boutique Cloud Cottages', 'All Meals', '4x4 Offroad Jeep to Kolukkumalai Sunrise', 'Tea Factory Tasting'] },
      Luxury: { price: 'Rs. 24,000', facilities: ['Luxury Hill Resort Villa', 'All Meals', 'Private Guide', 'Tented Glamping above Clouds'] }
    },
    itinerary: [
      { day: 1, title: 'Kochi to Munnar Tea Valley', description: 'Drive through Cheeyappara waterfalls and tea carpets to Munnar.' },
      { day: 2, title: 'Offroad Jeep to World\'s Highest Tea Estate', description: '4x4 mountain jeep safari to Kolukkumalai (7,900 ft). Witness sunrise over a sea of white clouds.' },
      { day: 3, title: 'Meesapulimala Viewpoint Trek', description: 'Trek along mountain ridges through rhododendrons with views of Tamil Nadu plains.' },
      { day: 4, title: 'Return Transfer to Kochi', description: 'Organic tea shopping and return to Kochi.' }
    ]
  },

  // 29. RISHIKESH RIVER RAFTING & YOGA RETREAT
  {
    id: 29,
    title: 'Rishikesh Rafting & Yoga Retreat',
    location: 'Rishikesh, Uttarakhand',
    price: 'Rs. 7,500',
    rating: '4.9',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Spring & Autumn (Sep - Nov & Mar - May)',
    bestMonths: ['March', 'April', 'May', 'September', 'October', 'November'],
    weatherHighlight: '🌊 Gushing Ganga Rapids • 21°C',
    tripType: 'Trek & Adventure',
    departureDates: ['18 Oct 2026', '08 Nov 2026', '22 Nov 2026', '06 Dec 2026', '12 Mar 2027'],
    categories: {
      Economy: { price: 'Rs. 5,500', facilities: ['Riverside Alpine Tents', 'All Meals', '16 km River Rafting', 'Bonfire'] },
      Standard: { price: 'Rs. 7,500', facilities: ['Deluxe AC Swiss Tents with Swimming Pool', 'All Meals', '26 km Marine Drive Rafting', 'Cliff Jumping & Body Surfing', 'Morning Yoga'] },
      Luxury: { price: 'Rs. 14,000', facilities: ['5-Star Luxury Yoga Resort (Aloha / Taj Rishikesh)', 'Ayurvedic Spa', 'Private Instructor', 'Bungee Jumping Ticket'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival at Shivpuri & Ganga Campfire', description: 'Check into beach camp by the Ganges. Evening volleyball, music, and campfire under starlit hills.' },
      { day: 2, title: 'Thrilling 26 km Rafting & Cliff Jump', description: 'Navigate roller-coaster rapids like "Three Blind Mice", "Crossfire", and "Golf Course". Cliff jumping from 30 ft rock into the holy river. Evening Ganga Aarti at Parmarth Niketan.' },
      { day: 3, title: 'Morning Sunrise Yoga & Beatles Ashram', description: 'Sunrise yoga session on white sand beach, visit Beatles Ashram, and departure.' }
    ]
  },

  // 30. SUNDARBANS MANGROVE ROYAL BENGAL TIGER CRUISE
  {
    id: 30,
    title: 'Sundarbans Mangrove Tiger Safari',
    location: 'Sundarbans, West Bengal',
    price: 'Rs. 13,000',
    rating: '4.7',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1511497584788-87676104235f?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Winter Safari (Nov - Mar)',
    bestMonths: ['November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '🐅 Mangrove Waterways • 19°C',
    tripType: 'Nature & Hills',
    departureDates: ['20 Nov 2026', '04 Dec 2026', '18 Dec 2026', '15 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 9,500', facilities: ['Standard Eco Cottage', 'Bengali Meals', 'Boat Cruise'] },
      Standard: { price: 'Rs. 13,000', facilities: ['Deluxe Jungle Resort', 'All Meals', 'Full-Day Motorboat Tiger Safari', 'Watchtower Permits'] },
      Luxury: { price: 'Rs. 24,000', facilities: ['Private Luxury Houseboat Cruise', 'All Meals Fresh Prepared', 'Forest Naturalist', 'Village Folk Baul Music'] }
    },
    itinerary: [
      { day: 1, title: 'Kolkata to Godkhali & Boat to Island', description: 'Drive from Kolkata to Godkhali jetty. Board safari boat through mangrove delta to eco resort. Sunset birdwatching.' },
      { day: 2, title: 'Full Day Mangrove Boat Safari', description: 'Cruise narrow creek networks inside Tiger Reserve. Visit Sajnekhali, Sudhanyakhali watchtowers to spot Royal Bengal tigers, estuarine crocodiles, and spotted deer.' },
      { day: 3, title: 'Do Banki Canopy Walk & Return', description: 'Elevated canopy walk above the mangrove canopy, village walk, and boat transfer back to Kolkata.' }
    ]
  },

  // 31. GOKARNA BEACH TREK & COASTAL TRAIL
  {
    id: 31,
    title: 'Gokarna Beach Trek & Coastal Trail',
    location: 'Gokarna, Karnataka',
    price: 'Rs. 6,500',
    rating: '4.8',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Autumn & Winter (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '🌊 Cliff Trails & Golden Sand • 26°C',
    tripType: 'Beach & Island',
    departureDates: ['23 Oct 2026', '06 Nov 2026', '20 Nov 2026', '11 Dec 2026', '08 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 4,800', facilities: ['Beach Shacks / Tents', 'Breakfast & Dinner', 'Trek Guide'] },
      Standard: { price: 'Rs. 6,500', facilities: ['Cliffside Cottages', 'All Meals', '5-Beach Trek Route', 'Campfire on Kudle Beach'] },
      Luxury: { price: 'Rs. 13,000', facilities: ['Luxury Wellness Resort (SwaSwara / Kahani Paradise)', 'All Gourmet Meals', 'Ayurvedic Massage', 'Private Yoga'] }
    },
    itinerary: [
      { day: 1, title: 'Arrival & Sunset on Kudle Beach', description: 'Arrive in holy town of Gokarna, check into beachfront camp, relax at Kudle beach cafes.' },
      { day: 2, title: '5-Beaches Cliff Trek', description: 'Trek across headlands connecting Belekan beach, Paradise beach, Half Moon beach, Om beach, and Kudle.' },
      { day: 3, title: 'Mahabaleshwar Temple & Return', description: 'Visit historic 4th-century Shiva temple and departure.' }
    ]
  },

  // 32. ZANSKAR FROZEN RIVER CHADAR TREK
  {
    id: 32,
    title: 'Zanskar Frozen River Chadar Trek',
    location: 'Zanskar, Ladakh',
    price: 'Rs. 38,000',
    rating: '5.0',
    duration: '9 Days',
    image: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Peak Winter Ice (Jan - Feb)',
    bestMonths: ['January', 'February'],
    weatherHighlight: '🧊 Frozen River Ice Sheet • -15°C to -25°C',
    tripType: 'Trek & Adventure',
    departureDates: ['10 Jan 2027', '20 Jan 2027', '30 Jan 2027', '08 Feb 2027'],
    categories: {
      Economy: { price: 'Rs. 32,000', facilities: ['Sub-zero Mountain Tents', 'Hot High-Calorie Meals', 'Zanskari Porters & Guides', 'Permits'] },
      Standard: { price: 'Rs. 38,000', facilities: ['Extreme Sub-zero Insulated Tents', 'Gumboots & Crampons', 'Medical Oxygen Support', 'Leh Acclimatization Hotel Stay'] },
      Luxury: { price: 'Rs. 58,000', facilities: ['Heated Hotel in Leh', 'Private Chef on Trail', 'Dedicated Zanskari Guide', 'Rescue Evacuation Assurance'] }
    },
    itinerary: [
      { day: 1, title: 'Fly to Leh & Complete Rest', description: 'Touch down on snowy Leh runway (-10°C). Mandatory acclimatization.' },
      { day: 2, title: 'Mandatory Medical Checkup in Leh', description: 'Undergo blood oxygen and fitness check at Sonam Norboo Memorial Hospital.' },
      { day: 3, title: 'Leh to Chilling & Step on the Ice', description: 'Drive along frozen Indus river to roadhead at Chilling. Step onto the glass-like ice sheet (Chadar) of Zanskar.' },
      { day: 4, title: 'Trek to Tibb Cave Campsite', description: 'Walk through deep mountain gorges where waterfalls hang completely frozen in mid-air.' },
      { day: 5, title: 'Tibb to Naerak Frozen Waterfall (Iconic Landmark)', description: 'Behold the gigantic 60-foot frozen emerald waterfall of Naerak and suspension bridge.' },
      { day: 6, title: 'Naerak to Tibb Return', description: 'Notice how the shifting river ice re-forms different patterns overnight.' },
      { day: 7, title: 'Tibb to Chilling & Drive to Leh', description: 'Final walk on the frozen ice and warm celebration in Leh.' },
      { day: 8, title: 'Buffer Day in Leh', description: 'Souvenir shopping and cultural exploration.' },
      { day: 9, title: 'Departure Flight from Leh', description: 'Fly over snowy peaks back home.' }
    ]
  },

  // 33. OOTY & NILGIRI MOUNTAIN TOY TRAIN ESCAPE
  {
    id: 33,
    title: 'Ooty & Nilgiri Mountain Toy Train',
    location: 'Ooty, Tamil Nadu',
    price: 'Rs. 14,000',
    rating: '4.8',
    duration: '4 Days',
    image: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Spring & Summer (Oct - Jun)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March', 'April', 'May'],
    weatherHighlight: '🚂 Colonial Hills & Pine Valleys • 17°C',
    tripType: 'Nature & Hills',
    departureDates: ['20 Oct 2026', '12 Nov 2026', '04 Dec 2026', '24 Dec 2026', '15 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 10,000', facilities: ['Standard Hill Resort', 'Breakfast', 'Shared Sightseeing'] },
      Standard: { price: 'Rs. 14,000', facilities: ['Colonial Heritage Bungalow', 'Breakfast & Dinner', 'Private Cab', 'Toy Train Tickets'] },
      Luxury: { price: 'Rs. 28,000', facilities: ['5-Star Luxury (Savoy - IHCL / King’s Cliff)', 'All Meals', 'Private Chauffeur', 'Botanical High Tea'] }
    },
    itinerary: [
      { day: 1, title: 'Coimbatore / Mysore to Ooty Queen of Hills', description: 'Scenic hair-pin drive through Nilgiri biosphere to Ooty.' },
      { day: 2, title: 'Nilgiri Mountain UNESCO Toy Train', description: 'Steam engine toy train ride over stone viaducts and tunnels to Coonoor. Visit Sim\'s Park and Dolphin\'s Nose.' },
      { day: 3, title: 'Doddabetta Peak & Botanical Gardens', description: 'Ascend Doddabetta (highest peak in Nilgiris at 8,650 ft), visit Government Botanical Garden and Pykara lake.' },
      { day: 4, title: 'Tea Factory & Return', description: 'Homemade chocolate and Nilgiri tea shopping before return transfer.' }
    ]
  },

  // 34. PONDICHERRY FRENCH QUARTER & AUROVILLE
  {
    id: 34,
    title: 'Pondicherry French Quarter & Auroville',
    location: 'Pondicherry',
    price: 'Rs. 12,500',
    rating: '4.7',
    duration: '3 Days',
    image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'TravelMaster Signature',
    bestSeason: 'Winter Coastal (Oct - Mar)',
    bestMonths: ['October', 'November', 'December', 'January', 'February', 'March'],
    weatherHighlight: '🥐 French Pastel Streets & Ocean Breeze • 25°C',
    tripType: 'Beach & Island',
    departureDates: ['24 Oct 2026', '14 Nov 2026', '05 Dec 2026', '19 Dec 2026', '09 Jan 2027'],
    categories: {
      Economy: { price: 'Rs. 8,500', facilities: ['French Quarter Guesthouse', 'Breakfast', 'Bicycle Rental'] },
      Standard: { price: 'Rs. 12,500', facilities: ['Heritage French Villa Hotel', 'Breakfast & Dinner', 'Private Auto/Cab', 'Auroville Pass'] },
      Luxury: { price: 'Rs. 25,000', facilities: ['5-Star Heritage Villa (Palais de Mahe)', 'All Meals', 'Private French Dining Experience', 'Scuba Diving Intro'] }
    },
    itinerary: [
      { day: 1, title: 'White Town French Heritage Walk', description: 'Explore mustard-yellow French colonial streets, Promenade beach, and Sri Aurobindo Ashram.' },
      { day: 2, title: 'Universal City of Auroville & Matrimandir', description: 'Visit golden globe Matrimandir in Auroville, organic cafes, and Serenity beach surfing.' },
      { day: 3, title: 'Paradise Beach Boating & Departure', description: 'Ferry ride through Chunnambar backwaters to isolated Paradise Beach before return to Chennai.' }
    ]
  },

  // 35. KUARI PASS LORD CURZON HIMALAYAN TREK
  {
    id: 35,
    title: 'Kuari Pass Lord Curzon Trail',
    location: 'Joshimath, Uttarakhand',
    price: 'Rs. 9,400',
    rating: '5.0',
    duration: '6 Days',
    image: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1400&q=85',
    isTrending: true,
    organizer: 'Invincible NGO',
    bestSeason: 'Autumn & Winter Snow (Nov - Apr)',
    bestMonths: ['November', 'December', 'January', 'February', 'March', 'April'],
    weatherHighlight: '🏔️ Grandstand Nanda Devi Vista • 0°C to 10°C',
    tripType: 'Trek & Adventure',
    departureDates: ['15 Nov 2026', '01 Dec 2026', '20 Dec 2026', '10 Jan 2027', '05 Feb 2027'],
    categories: {
      Economy: { price: 'Rs. 7,400', facilities: ['Alpine Snow Tents', 'Nutritious Meals', 'Forest Permits', 'Trek Guide'] },
      Standard: { price: 'Rs. 9,400', facilities: ['Deluxe Alpine Camps', 'Microspikes & Gaiters', 'Oxygen Cylinder', 'Summit Certificate'] },
      Luxury: { price: 'Rs. 15,500', facilities: ['Wooden Chalet in Joshimath & Auli', 'All Meals', 'Dedicated Guide & Porter', 'Personal Crampons'] }
    },
    itinerary: [
      { day: 1, title: 'Rishikesh to Joshimath', description: 'Scenic 250 km mountain drive passing 5 holy confluences (Panchprayag) to Joshimath.' },
      { day: 2, title: 'Joshimath to Dhak & Gulling Camp', description: 'Drive to Dhak village, then trek through oak forests to Gulling campsite (9,600 ft).' },
      { day: 3, title: 'Gulling to Khullara Meadow', description: 'Climb through snowline to alpine meadow of Khullara (11,100 ft) facing Mt. Dronagiri.' },
      { day: 4, title: 'Kuari Pass Summit (12,516 ft)', description: 'Ascend to Kuari Pass for the grandest panorama of Mt. Nanda Devi (India’s second highest peak), Kamet, and Trishul.' },
      { day: 5, title: 'Khullara to Auli Ski Slopes & Joshimath', description: 'Trek down to Auli snow ski slopes and cable car to Joshimath.' },
      { day: 6, title: 'Departure to Rishikesh', description: 'Drive back to Rishikesh with memories of Nanda Devi.' }
    ]
  }
];

module.exports = allPackages;
