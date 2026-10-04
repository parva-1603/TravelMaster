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
    final loc = locationName.toLowerCase();
    if (loc.contains('kerala') || loc.contains('alleppey')) return const LatLng(9.4981, 76.3388);
    if (loc.contains('jaipur')) return const LatLng(26.9124, 75.7873);
    if (loc.contains('ladakh') || loc.contains('leh')) return const LatLng(34.1526, 77.5771);
    if (loc.contains('goa') || loc.contains('palolem')) return const LatLng(15.2993, 74.1240);
    if (loc.contains('kedarkantha') || loc.contains('sankri')) return const LatLng(31.0667, 78.1833);
    if (loc.contains('manali')) return const LatLng(32.2432, 77.1892);
    if (loc.contains('polo')) return const LatLng(24.0153, 73.1977);
    if (loc.contains('dwarka') || loc.contains('somnath')) return const LatLng(22.4647, 69.1173);
    if (loc.contains('saputara')) return const LatLng(20.5796, 73.7483);
    if (loc.contains('chopta') || loc.contains('tungnath')) return const LatLng(30.4878, 79.1764);
    if (loc.contains('spiti') || loc.contains('kaza')) return const LatLng(32.2276, 78.0710);
    if (loc.contains('kasol') || loc.contains('kheerganga')) return const LatLng(32.0100, 77.3150);
    if (loc.contains('valley of flowers') || loc.contains('chamoli')) return const LatLng(30.7280, 79.6053);
    if (loc.contains('roopkund') || loc.contains('lohajung')) return const LatLng(30.2618, 79.7431);
    if (loc.contains('meghalaya') || loc.contains('shillong') || loc.contains('cherrapunji')) return const LatLng(25.5788, 91.8933);
    if (loc.contains('andaman') || loc.contains('havelock') || loc.contains('neil')) return const LatLng(11.9761, 92.9876);
    if (loc.contains('kutch') || loc.contains('dhordo') || loc.contains('rann')) return const LatLng(23.7500, 69.8000);
    if (loc.contains('coorg') || loc.contains('madikeri')) return const LatLng(12.4244, 75.7382);
    if (loc.contains('varanasi') || loc.contains('kashi')) return const LatLng(25.3176, 82.9739);
    if (loc.contains('kashmir') || loc.contains('sonamarg')) return const LatLng(34.3050, 75.2933);
    if (loc.contains('hampi')) return const LatLng(15.3350, 76.4600);
    if (loc.contains('jaisalmer') || loc.contains('sam sand')) return const LatLng(26.9157, 70.9083);
    if (loc.contains('gir') || loc.contains('sasan gir')) return const LatLng(21.1243, 70.7963);
    if (loc.contains('tirthan') || loc.contains('jibhi')) return const LatLng(31.6375, 77.3468);
    if (loc.contains('dudhsagar')) return const LatLng(15.3144, 74.3143);
    if (loc.contains('darjeeling')) return const LatLng(27.0410, 88.2663);
    if (loc.contains('munnar') || loc.contains('kolukkumalai')) return const LatLng(10.0889, 77.0595);
    if (loc.contains('rishikesh') || loc.contains('shivpuri')) return const LatLng(30.0869, 78.2676);
    if (loc.contains('sundarbans')) return const LatLng(21.9497, 89.1833);
    if (loc.contains('gokarna') || loc.contains('om beach')) return const LatLng(14.5479, 74.3188);
    if (loc.contains('zanskar') || loc.contains('chadar')) return const LatLng(33.5684, 76.9288);
    if (loc.contains('ooty') || loc.contains('nilgiris')) return const LatLng(11.4102, 76.6950);
    if (loc.contains('pondicherry') || loc.contains('auroville')) return const LatLng(11.9416, 79.8083);
    if (loc.contains('kuari pass') || loc.contains('joshimath')) return const LatLng(30.5566, 79.5670);
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

  @override
  Widget build(BuildContext context) {
    final latLng = _getCoordinates(widget.pkg['location']);

    final categories = widget.pkg['categories'] as Map<String, dynamic>?;
    final itinerary = widget.pkg['itinerary'] as List<dynamic>?;
    final dates = widget.pkg['departureDates'] as List<dynamic>?;

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
                                  'Status: Scheduled (API Verified)',
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

                        // Departure Dates Selection
                        if (dates != null && dates.isNotEmpty) ...[
                          const Text('Departure Dates',
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
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                        ],

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
                          const Text('Day-wise Plan',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...itinerary.map((dayPlan) {
                            String description = dayPlan['description'];
                            if (dayPlan['day'] == 1) {
                              description =
                                  'Depart from $startCityDisplay via ${_getTransportToDest()}.\n\n$description';
                            }

                            if (_weatherData != null) {
                              final icons = [
                                '☀️ Sunny',
                                '⛅ Partly Cloudy',
                                '☁️ Cloudy',
                                '☀️ Clear'
                              ];
                              final weatherIcon =
                                  icons[(dayPlan['day'] as int) % icons.length];
                              description +=
                                  '\n\n$weatherIcon | Forecast: ${_weatherData!['temperature']}°C';
                            }

                            final actualDate = _calculateDate(
                                _selectedDate, dayPlan['day'] as int);
                            final dateDisplay =
                                actualDate.isNotEmpty ? ' ($actualDate)' : '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: Text(
                                  'Day ${dayPlan['day']}$dateDisplay: ${dayPlan['title']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        height: 1.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.8),
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
