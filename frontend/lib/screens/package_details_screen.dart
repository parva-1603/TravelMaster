import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  Future<void> _fetchWeather() async {
    try {
      final location = widget.pkg['location'].toString().split(',').first;
      final response = await http.get(Uri.parse('http://localhost:5000/api/weather?location=$location'));
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

  @override
  Widget build(BuildContext context) {
    final latLng = _getCoordinates(widget.pkg['location']);
    
    final categories = widget.pkg['categories'] as Map<String, dynamic>?;
    final itinerary = widget.pkg['itinerary'] as List<dynamic>?;
    final dates = widget.pkg['departureDates'] as List<dynamic>?;

    final currentCategory = categories != null ? categories[_selectedCategory] : null;
    final displayPrice = currentCategory != null ? currentCategory['price'] : widget.pkg['price'];
    final facilities = currentCategory != null ? currentCategory['facilities'] as List<dynamic> : [];

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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassmorphicContainer(
                        width: 48,
                        height: 48,
                        borderRadius: 24,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 1,
                        linearGradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)]),
                        borderGradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.0)]),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Content Sheet
                GlassmorphicContainer(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.75, // Increased height for more data
                  borderRadius: 40,
                  blur: 30,
                  alignment: Alignment.topCenter,
                  border: 1,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.pkg['rating'],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.pkg['location'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time, color: Theme.of(context).colorScheme.secondary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.pkg['duration'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Weather Section
                        if (_isLoadingWeather)
                           const Center(child: CircularProgressIndicator())
                        else if (_weatherData != null)
                           Container(
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                             ),
                             child: Row(
                               children: [
                                 Image.network(_weatherData!['icon'], width: 50, height: 50),
                                 const SizedBox(width: 12),
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'Current Weather: ${_weatherData!['temperature']} C',
                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                     ),
                                     Text(
                                       '${_weatherData!['description'].toString().toUpperCase()} | Humidity: ${_weatherData!['humidity']}%',
                                       style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ).animate().fadeIn(),

                        const SizedBox(height: 24),
                        
                        // Departure Dates Selection
                        if (dates != null && dates.isNotEmpty) ...[
                          const Text('Departure Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                          const Text('Package Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'Economy', label: Text('Economy')),
                              ButtonSegment(value: 'Standard', label: Text('Standard')),
                              ButtonSegment(value: 'Luxury', label: Text('Luxury')),
                            ],
                            selected: {_selectedCategory},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() => _selectedCategory = newSelection.first);
                            },
                          ),
                          const SizedBox(height: 16),
                          // Display facilities for selected category
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: facilities.map((facility) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 16),
                                    const SizedBox(width: 8),
                                    Text(facility.toString(), style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ).animate(key: ValueKey(_selectedCategory)).fadeIn(),
                          const SizedBox(height: 24),
                        ],

                        // Day-by-Day Itinerary
                        if (itinerary != null && itinerary.isNotEmpty) ...[
                          const Text('Day-wise Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...itinerary.map((dayPlan) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Text(
                                'Day ${dayPlan['day']}: ${dayPlan['title']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    dayPlan['description'],
                                    style: TextStyle(
                                      height: 1.5,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                          const SizedBox(height: 24),
                        ],

                        // Map Section
                        const Text('Location Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                                  urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=UmD3882jQqxEhkk0NONd',
                                  userAgentPackageName: 'com.travelmaster.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: latLng,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Price'),
                                Text(
                                  displayPrice,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Booking flow initiated for $_selectedCategory...')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
