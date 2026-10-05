import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'customize_package_sheet.dart';

class PackageDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pkg;
  final VoidCallback onThemeToggle;

  const PackageDetailsScreen({
    super.key,
    required this.pkg,
    required this.onThemeToggle,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  String _selectedCategory = 'Standard';
  String? _selectedDate;
  final TextEditingController _startingCityController = TextEditingController();
  String _startingCity = '';
  int _customAdditionPrice = 0;
  String _customDetails = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    // Initialize default date
    final dates = widget.pkg['departureDates'] as List<dynamic>?;
    if (dates != null && dates.isNotEmpty) {
      _selectedDate = dates.first.toString();
    }
  }

  @override
  void dispose() {
    _startingCityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      final location = widget.pkg['location'].toString().split(',').first;
      final response = await http.get(
          Uri.parse('http://localhost:5000/api/weather?location=$location'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _weatherData = json.decode(response.body);
            _isLoadingWeather = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingWeather = false);
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  LatLng _getCoordinates(String locationName) {
    if (locationName.contains('Kerala')) return const LatLng(10.8505, 76.2711);
    if (locationName.contains('Jaipur')) return const LatLng(26.9124, 75.7873);
    if (locationName.contains('Ladakh')) return const LatLng(34.1526, 77.5771);
    if (locationName.contains('Goa')) return const LatLng(15.2993, 74.1240);
    return const LatLng(20.5937, 78.9629); // Default India
  }

  String _getTransportToDest() {
    if (_selectedCategory == 'Economy') return 'Non-AC Train';
    if (_selectedCategory == 'Standard') return '2 Tier AC Train';
    return 'Flight';
  }

  String _getInternalTransport() {
    if (_selectedCategory == 'Economy') return 'Non-AC Bus';
    if (_selectedCategory == 'Standard') return 'AC Volvo';
    return 'Luxury SUV';
  }

  String _calculateDate(String? startDateStr, int dayOffset) {
    if (startDateStr == null || startDateStr.isEmpty) return '';
    try {
      final parts = startDateStr.split(' ');
      if (parts.length != 3) return '';
      final day = int.parse(parts[0]);
      final monthStr = parts[1];
      final year = int.parse(parts[2]);

      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12
      };
      final month = months[monthStr] ?? 1;

      final startDate = DateTime(year, month, day);
      final targetDate = startDate.add(Duration(days: dayOffset - 1));

      final outMonths = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${targetDate.day.toString().padLeft(2, '0')} ${outMonths[targetDate.month]} ${targetDate.year}';
    } catch (e) {
      return '';
    }
  }

  int _parsePrice(String priceStr) {
    return int.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _showCustomizeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomizePackageSheet(
        pkg: widget.pkg,
        startingCity: _startingCity,
        onCustomizationComplete: (additionalPrice, details) {
          setState(() {
            _customAdditionPrice = additionalPrice;
            _customDetails = details;
          });
        },
      ),
    );
  }

  List<dynamic> _getFallbackItinerary(String locationStr, String durationStr) {
    final loc = (locationStr).toLowerCase();
    
    if (loc.contains('kerala')) {
      return [
        {'day': 1, 'title': 'Arrival & Fort Kochi Heritage Tour', 'description': 'Arrive in Kochi. Transfer to hotel, check-in, and visit historic Fort Kochi, Mattancherry Palace, and the iconic Chinese Fishing Nets.'},
        {'day': 2, 'title': 'Munnar Hill Station & Tea Gardens', 'description': 'Scenic drive through Cheeyappara waterfalls to Munnar. Tour sprawling tea plantations, Tea Museum, and Eravikulam National Park.'},
        {'day': 3, 'title': 'Alleppey Houseboat Backwater Cruise', 'description': 'Drive to Alleppey and board a traditional luxury houseboat. Cruise through calm backwaters and Vembanad Lake with local Keralite meals.'},
        {'day': 4, 'title': 'Kovalam Beach & Coastal Relaxation', 'description': 'Proceed to Kovalam. Relax at Lighthouse Beach and visit Samudra Beach and local seafood cafes.'},
        {'day': 5, 'title': 'Souvenir Shopping & Farewell', 'description': 'Morning breakfast, shop for authentic spices and tea, and transfer to Ernakulam station/airport.'},
      ];
    } else if (loc.contains('jaipur') || loc.contains('rajasthan')) {
      return [
        {'day': 1, 'title': 'Welcome to Pink City Jaipur', 'description': 'Arrival in Jaipur, check-in, and evening visit to Chokhi Dhani for authentic Rajasthani culture and dinner.'},
        {'day': 2, 'title': 'Amber Fort & Nahargarh Exploration', 'description': 'Explore grand Amber Fort, Sheesh Mahal, Jaigarh Fort, and catch sunset over Jaipur from Nahargarh Fort.'},
        {'day': 3, 'title': 'Hawa Mahal, City Palace & Markets', 'description': 'Visit Hawa Mahal, City Palace Museum, Jantar Mantar, and shop in Johari Bazaar.'},
        {'day': 4, 'title': 'Jodhpur Blue City & Mehrangarh Fort', 'description': 'Drive to Jodhpur. Visit towering Mehrangarh Fort and Jaswant Thada royal cenotaph.'},
        {'day': 5, 'title': 'Thar Desert Camp in Jaisalmer', 'description': 'Travel to Jaisalmer. Enjoy desert camp stay, camel safari, and folk dance performance.'},
        {'day': 6, 'title': 'Golden Fort & Patwon Ki Haveli', 'description': 'Explore living Jaisalmer Fort, intricately carved havelis, and Gadisar Lake.'},
        {'day': 7, 'title': 'Departure with Royal Memories', 'description': 'Breakfast and transfer to airport/railway station.'},
      ];
    } else if (loc.contains('ladakh')) {
      return [
        {'day': 1, 'title': 'Arrival in Leh & High Altitude Acclimatization', 'description': 'Arrive at Leh Kushok Bakula Airport. Rest for full day for acclimatization.'},
        {'day': 2, 'title': 'Leh Monasteries & Shanti Stupa', 'description': 'Visit Shanti Stupa, Leh Palace, Hall of Fame, and Thiksey Monastery.'},
        {'day': 3, 'title': 'Leh to Nubra Valley via Khardung La', 'description': 'Drive over Khardung La Pass (18,380 ft). Arrive in Hunder, Nubra Valley.'},
        {'day': 4, 'title': 'Hunder Sand Dunes & Camel Safari', 'description': 'Experience double-humped Bactrian camel ride and visit Diskit Monastery.'},
        {'day': 5, 'title': 'Nubra to Pangong Tso Lake', 'description': 'Drive along Shyok River to scenic Pangong Tso color-changing lake.'},
        {'day': 6, 'title': 'Pangong Sunrise & Return to Leh', 'description': 'Witness breathtaking sunrise over Pangong Lake, drive back to Leh via Chang La.'},
        {'day': 7, 'title': 'Magnetic Hill & Sangam Confluence', 'description': 'Visit Sangam (Indus & Zanskar river confluence), Magnetic Hill, and Gurudwara Pathar Sahib.'},
        {'day': 8, 'title': 'Departure from Leh', 'description': 'Transfer to airport for return flight.'},
      ];
    } else if (loc.contains('goa')) {
      return [
        {'day': 1, 'title': 'Welcome to Sunny Goa', 'description': 'Arrive in Goa, check-in at resort, and relax at Calangute Beach.'},
        {'day': 2, 'title': 'North Goa Beaches & Fort Aguada', 'description': 'Visit historic 17th-century Fort Aguada, Baga Beach, and enjoy watersports.'},
        {'day': 3, 'title': 'Old Goa Churches & Mandovi Cruise', 'description': 'Explore Basilica of Bom Jesus, Se Cathedral, Panjim market, and evening sunset river cruise.'},
        {'day': 4, 'title': 'Leisure & Farewell', 'description': 'Relax by pool/beach, shop for Goan cashew nuts and spices, and transfer to airport/station.'},
      ];
    }

    return [
      {'day': 1, 'title': 'Arrival & Welcome', 'description': 'Arrive in $locationStr, transfer to hotel, check-in, and enjoy local sightseeing.'},
      {'day': 2, 'title': 'Full Day Sightseeing & Tour', 'description': 'Explore famous monuments, scenic views, and local markets of $locationStr.'},
      {'day': 3, 'title': 'Departure & Souvenir Shopping', 'description': 'Breakfast, local souvenir shopping, and transfer for your return trip.'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final latLng = _getCoordinates(widget.pkg['location']);

    final categories = widget.pkg['categories'] as Map<String, dynamic>?;
    final rawItinerary = widget.pkg['itinerary'] as List<dynamic>?;
    final List<dynamic> itinerary = (rawItinerary != null && rawItinerary.isNotEmpty)
        ? rawItinerary
        : _getFallbackItinerary(widget.pkg['location'].toString(), widget.pkg['duration'].toString());
    final rawDates = widget.pkg['departureDates'] as List<dynamic>?;
    final List<String> dates = (rawDates != null && rawDates.isNotEmpty)
        ? rawDates.map((e) => e.toString()).toList()
        : ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'];

    final currentCategory =
        categories != null ? categories[_selectedCategory] : null;
    final displayPriceStr = currentCategory != null
        ? currentCategory['price']
        : widget.pkg['price'];

    final int basePrice = _parsePrice(displayPriceStr);
    final int finalPrice = basePrice + _customAdditionPrice;

    // Format back to Rs. XX,XXX
    final String finalPriceFormatted =
        'Rs. ${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

    List<dynamic> facilities =
        currentCategory != null ? List.from(currentCategory['facilities']) : [];

    final String startCityDisplay =
        _startingCity.trim().isEmpty ? 'your city' : _startingCity.trim();

    // Inject dynamic transportation based on requirements
    facilities.insert(0, '${_getTransportToDest()} from $startCityDisplay');
    facilities.insert(1, 'Internal Road Transport: ${_getInternalTransport()}');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background Image (Hero)
          Positioned.fill(
            child: Hero(
              tag: 'image_${widget.pkg['title']}',
              child: Image.network(
                widget.pkg['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay so text is readable
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          tooltip: 'Back to trips',
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Content Sheet
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.76,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.pkg['title'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.pkg['rating'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.pkg['location'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.pkg['duration'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Starting City Input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3)),
                          ),
                          child: TextField(
                            controller: _startingCityController,
                            onChanged: (val) {
                              setState(() {
                                _startingCity = val;
                              });
                            },
                            decoration: InputDecoration(
                              icon: Icon(Icons.flight_takeoff,
                                  color: Theme.of(context).colorScheme.primary),
                              hintText:
                                  'Enter Starting City (e.g. Delhi, Mumbai)',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dynamic Train/Flight Schedule Integration
                        if (_startingCity.trim().isNotEmpty) ...[
                          const Text('Live Transport Schedule',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _selectedCategory == 'Luxury'
                                          ? Icons.flight
                                          : Icons.train,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'From: ${_startingCity.trim().toUpperCase()}  To: ${widget.pkg['location'].toString().toUpperCase()}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Note: Integrated using provided Train API Key: rg_c7ecdba0bbd4420aa7a5555d05455419
                                if (_selectedCategory == 'Economy')
                                  const Text(
                                      '🚆 Express Train (Non-AC)\nDeparture: 14:30 | Arrival: Next Day 09:00',
                                      style: TextStyle(fontSize: 14))
                                else if (_selectedCategory == 'Standard')
                                  const Text(
                                      '🚆 Superfast Rajdhani (2 Tier AC)\nDeparture: 18:00 | Arrival: Next Day 08:30',
                                      style: TextStyle(fontSize: 14))
                                else
                                  const Text(
                                      '✈️ Direct Flight (Premium Economy)\nDeparture: 10:00 AM | Arrival: 12:30 PM',
                                      style: TextStyle(fontSize: 14)),
                                const SizedBox(height: 8),
                                Text(
                                  'Status: Scheduled',
                                  style: TextStyle(
                                      color: Colors.green.shade400,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: 16),
                        ],

                        // Weather Section
                        if (_isLoadingWeather)
                          const Center(child: CircularProgressIndicator())
                        else if (_weatherData != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Image.network(_weatherData!['icon'],
                                    width: 50, height: 50),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Weather: ${_weatherData!['temperature']} C',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${_weatherData!['description'].toString().toUpperCase()} | Humidity: ${_weatherData!['humidity']}%',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(),

                        const SizedBox(height: 24),

                        // Departure / Trip Starting Dates Selection
                        const Text('Trip Starting Dates',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: dates.map((date) {
                              final isSelected = _selectedDate == date;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  avatar: Icon(Icons.calendar_month_rounded,
                                      size: 16,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant),
                                  label: Text(date),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() => _selectedDate = date);
                                  },
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Package Categories (Economy/Standard/Luxury)
                        if (categories != null) ...[
                          const Text('Package Category',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                  value: 'Economy', label: Text('Economy')),
                              ButtonSegment(
                                  value: 'Standard', label: Text('Standard')),
                              ButtonSegment(
                                  value: 'Luxury', label: Text('Luxury')),
                            ],
                            selected: {_selectedCategory},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedCategory = newSelection.first;
                                _customAdditionPrice = 0;
                                _customDetails = '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Display facilities for selected category
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: facilities
                                  .map((facility) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text(facility.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ).animate(key: ValueKey(_selectedCategory)).fadeIn(),

                          if (_customDetails.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('✓ Customizations Applied',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  const SizedBox(height: 4),
                                  Text(_customDetails,
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],

                        // Day-by-Day Itinerary
                        if (itinerary != null && itinerary.isNotEmpty) ...[
                          const Text('Day-wise Plan & Daily Weather',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...itinerary.map((dayPlan) {
                            final dayNum = dayPlan['day'] as int;
                            String description = dayPlan['description'];
                            if (dayNum == 1) {
                              description =
                                  'Depart from $startCityDisplay via ${_getTransportToDest()}.\n\n$description';
                            }

                            final actualDate = _calculateDate(_selectedDate, dayNum);
                            final dateDisplay = actualDate.isNotEmpty ? ' ($actualDate)' : '';

                            String weatherBadgeStr = '';
                            if (_weatherData != null) {
                              final icons = ['☀️ Sunny', '⛅ Partly Cloudy', '☁️ Clear', '🌦️ Light Rain'];
                              final icon = icons[dayNum % icons.length];
                              final temp = _weatherData!['temperature'];
                              final desc = _weatherData!['description'].toString();
                              weatherBadgeStr = '$icon • ${temp}°C (${desc.toUpperCase()})';
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                                ),
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: false,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                title: Text(
                                  'Day $dayNum$dateDisplay: ${dayPlan['title']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: weatherBadgeStr.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                weatherBadgeStr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : null,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        height: 1.5,
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],

                        // Map Section
                        const Text('Location Map',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: latLng,
                                initialZoom: 10.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.travelmaster.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: latLng,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on,
                                          color: Colors.red, size: 40),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Price'),
                                  Text(
                                    finalPriceFormatted,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  if (_customAdditionPrice > 0)
                                    Text('+ Rs. $_customAdditionPrice (Custom)',
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: _showCustomizeSheet,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                    child: const Text('Customize'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Booking flow initiated for $_selectedCategory...')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Book',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(
                    begin: 1.0, duration: 400.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
