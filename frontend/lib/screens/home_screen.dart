import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'login_screen.dart';
import 'package_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _leavingFrom = '';
  String _goingTo = '';
  String _selectedMonth = 'Any Month';
  bool _isLoading = true;

  final List<String> _months = ['Any Month', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.flight, 'title': 'Flights', 'active': false},
    {'icon': Icons.hotel, 'title': 'Hotels', 'active': false},
    {'icon': Icons.beach_access, 'title': 'Holidays', 'active': true},
    {'icon': Icons.train, 'title': 'Trains', 'active': false},
    {'icon': Icons.directions_bus, 'title': 'Bus', 'active': false},
    {'icon': Icons.local_taxi, 'title': 'Cabs', 'active': false},
  ];

  List<Map<String, dynamic>> _allPackages = [];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/packages/trending'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _allPackages = data.map((e) => e as Map<String, dynamic>).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLocations(String query) async {
    if (query.length < 2) return [];
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/locations?query=$query'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
    }
    return [];
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(onThemeToggle: widget.onThemeToggle)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter packages dynamically based on search query
    final filteredPackages = _allPackages.where((pkg) {
      if (_goingTo.isEmpty) return true;
      final location = pkg['location'].toString().toLowerCase();
      final title = pkg['title'].toString().toLowerCase();
      final query = _goingTo.toLowerCase();
      return location.contains(query) || title.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Dynamic Background (using simple blurred shapes to match premium aesthetic)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 3.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
          
          // Apply blur to background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.travel_explore, color: Theme.of(context).colorScheme.primary, size: 32),
                            const SizedBox(width: 8),
                            const Text(
                              'EaseMyTrip',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.brightness_6),
                              onPressed: widget.onThemeToggle,
                            ).animate().fadeIn(delay: 400.ms).scale(),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.redAccent),
                              onPressed: () => _logout(context),
                            ).animate().fadeIn(delay: 500.ms).scale(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Services Navigation Tab
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        final isActive = service['active'] as bool;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                for (var s in _services) {
                                  s['active'] = false;
                                }
                                _services[index]['active'] = true;
                                // In the future, this will change the main content view
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                    boxShadow: isActive ? [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ] : [],
                                  ),
                                  child: Icon(
                                    service['icon'] as IconData,
                                    color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  service['title'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: (300 + (index * 50)).ms).slideY(begin: 0.2),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Search Box Widget
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 310, // Adjusted height
                      borderRadius: 24,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book Your Perfect Holiday',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Form fields
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Column(
                                children: [
                                  // Leaving From
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Autocomplete<Map<String, dynamic>>(
                                      optionsBuilder: (TextEditingValue textEditingValue) async {
                                        return await _fetchLocations(textEditingValue.text);
                                      },
                                      displayStringForOption: (option) => "${option['name']}, ${option['country']}",
                                      onSelected: (option) => setState(() => _leavingFrom = option['name']),
                                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          onEditingComplete: onEditingComplete,
                                          decoration: InputDecoration(
                                            icon: Icon(Icons.flight_takeoff, color: Theme.of(context).colorScheme.primary),
                                            labelText: 'Leaving From',
                                            hintText: 'Enter City',
                                            border: InputBorder.none,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                                  // Going To
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Autocomplete<Map<String, dynamic>>(
                                      optionsBuilder: (TextEditingValue textEditingValue) async {
                                        return await _fetchLocations(textEditingValue.text);
                                      },
                                      displayStringForOption: (option) => "${option['name']}, ${option['country']}",
                                      onSelected: (option) => setState(() => _goingTo = option['name']),
                                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          onEditingComplete: onEditingComplete,
                                          decoration: InputDecoration(
                                            icon: Icon(Icons.flight_land, color: Theme.of(context).colorScheme.secondary),
                                            labelText: 'Going To',
                                            hintText: 'Any Destination',
                                            border: InputBorder.none,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedMonth,
                                        isExpanded: true,
                                        icon: const Icon(Icons.calendar_month),
                                        items: _months.map((String month) {
                                          return DropdownMenuItem<String>(
                                            value: month,
                                            child: Text(month),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedMonth = newValue;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Trigger search
                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                    ),
                                    child: const Text(
                                      'SEARCH',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                  ),
                ),

                const SizedBox(height: 32),

                // Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trending Holiday Packages',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Horizontal Packages Carousel
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 320,
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : filteredPackages.isEmpty 
                        ? const Center(child: Text("No packages found."))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredPackages.length,
                            itemBuilder: (context, index) {
                              final pkg = filteredPackages[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: PackageCard(
                                  pkg: pkg,
                                  index: index,
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PackageCard extends StatefulWidget {
  final Map<String, dynamic> pkg;
  final int index;
  final VoidCallback onThemeToggle;

  const PackageCard({
    super.key,
    required this.pkg,
    required this.index,
    required this.onThemeToggle,
  });

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackageDetailsScreen(
                pkg: widget.pkg,
                onThemeToggle: widget.onThemeToggle,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          child: Stack(
            children: [
              GlassmorphicContainer(
                width: 240,
                height: 320,
                borderRadius: 24,
                blur: 20,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      child: Hero(
                        tag: 'image_${widget.pkg['title']}',
                        child: Image.network(
                          widget.pkg['image'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // Details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.pkg['rating'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                widget.pkg['location'],
                                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.pkg['price'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.pkg['duration'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Hover Details Overlay
              if (_isHovered)
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: GlassmorphicContainer(
                          width: 120,
                          height: 45,
                          borderRadius: 20,
                          blur: 15,
                          alignment: Alignment.center,
                          border: 1,
                          linearGradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ).animate().scale(duration: 200.ms),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (800 + (widget.index * 100)).ms).slideY(begin: 0.2);
  }
}
