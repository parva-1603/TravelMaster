import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;

import '../widgets/live_background.dart';
import 'chat_screen.dart';
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
  String _selectedMonth = 'Any month';
  String _selectedSeasonFilter = 'All';
  String _selectedSort = 'Recommended';
  bool _isLoading = true;

  static const _months = [
    'Any month',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _seasonFilters = [
    {'label': 'All Trips', 'value': 'All', 'icon': Icons.public_rounded},
    {'label': '❄️ Winter & Snow (Dec–Feb)', 'value': 'Winter & Snow', 'icon': Icons.ac_unit_rounded},
    {'label': '☀️ Spring & Summer (Mar–Jun)', 'value': 'Spring & Summer', 'icon': Icons.wb_sunny_rounded},
    {'label': '🌧️ Monsoon Greens (Jul–Sep)', 'value': 'Monsoon Greens', 'icon': Icons.water_drop_rounded},
    {'label': '🍂 Autumn & Festive (Oct–Nov)', 'value': 'Autumn & Festive', 'icon': Icons.eco_rounded},
    {'label': '🏔️ Treks & Summits', 'value': 'Treks', 'icon': Icons.terrain_rounded},
    {'label': '🏖️ Beaches & Islands', 'value': 'Beaches', 'icon': Icons.beach_access_rounded},
    {'label': '🏛️ Heritage & Culture', 'value': 'Heritage', 'icon': Icons.temple_hindu_rounded},
    {'label': '🌿 Wildlife & Nature', 'value': 'Wildlife', 'icon': Icons.pets_rounded},
  ];

  static const _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
    'Duration: Short to Long',
    'Duration: Long to Short',
  ];

  int _extractPrice(dynamic priceStr) {
    if (priceStr == null) return 0;
    final digits = priceStr.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  double _extractRating(dynamic ratingStr) {
    if (ratingStr == null) return 0.0;
    return double.tryParse(ratingStr.toString()) ?? 0.0;
  }

  int _extractDuration(dynamic durStr) {
    if (durStr == null) return 0;
    final parts = durStr.toString().trim().split(' ');
    return int.tryParse(parts.first) ?? 0;
  }

  List<Map<String, dynamic>> _allPackages = [];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/packages/trending'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load packages');
      }
      final data = json.decode(response.body) as List<dynamic>;
      if (mounted) {
        setState(() {
          _allPackages = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching packages from backend: $error');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLocations(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final uri =
          Uri.http('localhost:5000', '/api/locations', {'query': query});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (error) {
      debugPrint('Error fetching locations: $error');
    }
    return [];
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onThemeToggle: widget.onThemeToggle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _goingTo.trim().toLowerCase();
    final filteredPackages = _allPackages.where((package) {
      if (query.isNotEmpty) {
        final location = (package['location'] ?? '').toString().toLowerCase();
        final title = (package['title'] ?? '').toString().toLowerCase();
        if (!location.contains(query) && !title.contains(query)) return false;
      }

      // Check month filter from top search panel
      if (_selectedMonth != 'Any month') {
        final bestMonths = (package['bestMonths'] as List<dynamic>?)
            ?.map((m) => m.toString().toLowerCase())
            .toList() ?? [];
        if (bestMonths.isNotEmpty &&
            !bestMonths.contains(_selectedMonth.toLowerCase())) {
          return false;
        }
      }

      // Check season / trip type filter
      if (_selectedSeasonFilter != 'All') {
        final season = (package['bestSeason'] ?? '').toString();
        final type = (package['tripType'] ?? '').toString().toLowerCase();
        if (_selectedSeasonFilter == 'Winter & Snow' && !season.contains('Winter')) return false;
        if (_selectedSeasonFilter == 'Spring & Summer' && !season.contains('Summer') && !season.contains('Spring')) return false;
        if (_selectedSeasonFilter == 'Monsoon Greens' && !season.contains('Monsoon')) return false;
        if (_selectedSeasonFilter == 'Autumn & Festive' && !season.contains('Autumn') && !season.contains('Festive')) return false;
        if (_selectedSeasonFilter == 'Treks' && !type.contains('trek')) return false;
        if (_selectedSeasonFilter == 'Beaches' && !type.contains('beach') && !type.contains('island')) return false;
        if (_selectedSeasonFilter == 'Heritage' && !type.contains('heritage') && !type.contains('culture')) return false;
        if (_selectedSeasonFilter == 'Wildlife' && !type.contains('wildlife')) return false;
      }

      return true;
    }).toList();

    // Apply sorting
    if (_selectedSort == 'Price: Low to High') {
      filteredPackages.sort((a, b) => _extractPrice(a['price']).compareTo(_extractPrice(b['price'])));
    } else if (_selectedSort == 'Price: High to Low') {
      filteredPackages.sort((a, b) => _extractPrice(b['price']).compareTo(_extractPrice(a['price'])));
    } else if (_selectedSort == 'Top Rated') {
      filteredPackages.sort((a, b) => _extractRating(b['rating']).compareTo(_extractRating(a['rating'])));
    } else if (_selectedSort == 'Duration: Short to Long') {
      filteredPackages.sort((a, b) => _extractDuration(a['duration']).compareTo(_extractDuration(b['duration'])));
    } else if (_selectedSort == 'Duration: Long to Short') {
      filteredPackages.sort((a, b) => _extractDuration(b['duration']).compareTo(_extractDuration(a['duration'])));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Ask a local'),
      ),
      body: LiveBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              final wide = viewport.maxWidth >= 760;
              return SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(wide ? 32 : 20, 8, wide ? 32 : 20, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildHero(wide: wide),
                        const SizedBox(height: 20),
                        _buildSearchPanel(wide: wide),
                        const SizedBox(height: 36),
                        _buildSeasonFilterBar(context),
                        const SizedBox(height: 18),
                        _buildSortAndSummaryBar(context, filteredPackages.length, wide),
                        const SizedBox(height: 20),
                        _buildVerticalPackageGrid(context, filteredPackages, viewport.maxWidth),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child:
              const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TravelMaster',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
            ),
            Text(
              'GO A LITTLE FURTHER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
          onPressed: widget.onThemeToggle,
          icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    ).animate().fadeIn(duration: 450.ms).slideY(begin: -0.08);
  }

  Widget _buildHero({required bool wide}) {
    final image = _allPackages.isNotEmpty
        ? (_allPackages.first['image'] ?? '').toString()
        : 'https://images.unsplash.com/photo-1530789253388-582c481c54b0?auto=format&fit=crop&w=1800&q=85';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: wide ? 390 : 350,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFF31594E)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x12000000),
                    Color(0x22000000),
                    Color(0xB5000000),
                  ],
                  stops: [0, 0.42, 1],
                ),
              ),
            ),
            Positioned(
              top: 22,
              left: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.42)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Text(
                    'TAKE THE SCENIC ROUTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: wide ? 38 : 24,
              right: wide ? 340 : 20,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More world.\nLess routine.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: wide ? 50 : 40,
                      height: 1.02,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find a trip that feels like yours.',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.1),
            ),
            Positioned(
              right: 24,
              bottom: 30,
              child: Icon(
                Icons.north_east_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel({required bool wide}) {
    final fields = wide
        ? Row(
            children: [
              Expanded(child: _buildLocationField('Leaving from', true)),
              const SizedBox(width: 12),
              Expanded(child: _buildLocationField('Going to', false)),
              const SizedBox(width: 12),
              SizedBox(width: 190, child: _buildMonthField()),
              const SizedBox(width: 12),
              _buildSearchButton(),
            ],
          )
        : Column(
            children: [
              _buildLocationField('Leaving from', true),
              const SizedBox(height: 12),
              _buildLocationField('Going to', false),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMonthField()),
                  const SizedBox(width: 10),
                  _buildSearchButton(),
                ],
              ),
            ],
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 20 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Where to next?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Icon(Icons.route_outlined,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Build your route',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          fields,
        ],
      ),
    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.08);
  }

  Widget _buildLocationField(String label, bool isOrigin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (value) => _fetchLocations(value.text),
          displayStringForOption: (option) {
            final country = option['country']?.toString();
            return country == null || country.isEmpty
                ? option['name'].toString()
                : '${option['name']}, $country';
          },
          onSelected: (option) => setState(() {
            if (isOrigin) {
              _leavingFrom = option['name'].toString();
            } else {
              _goingTo = option['name'].toString();
            }
          }),
          fieldViewBuilder:
              (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              onChanged: (value) => setState(() {
                if (isOrigin) {
                  _leavingFrom = value;
                } else {
                  _goingTo = value;
                }
              }),
              decoration: InputDecoration(
                hintText: isOrigin ? 'Choose a city' : 'Pick a destination',
                prefixIcon: Icon(
                  isOrigin
                      ? Icons.flight_takeoff_rounded
                      : Icons.place_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text('When', style: Theme.of(context).textTheme.labelMedium),
        ),
        DropdownButtonFormField<String>(
          initialValue: _selectedMonth,
          isExpanded: true,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_month_outlined, size: 20)),
          items: _months
              .map(
                  (month) => DropdownMenuItem(value: month, child: Text(month)))
              .toList(),
          onChanged: (month) {
            if (month != null) setState(() => _selectedMonth = month);
          },
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => setState(() {}),
        icon: const Icon(Icons.search_rounded, size: 19),
        label: const Text('Explore'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSeasonFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.wb_twilight_rounded,
                size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Explore by Season & Weather',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              'Weather-Curated',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _seasonFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _seasonFilters[index];
              final isSelected = _selectedSeasonFilter == filter['value'];
              return FilterChip(
                selected: isSelected,
                showCheckmark: false,
                label: Text(
                  filter['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedSeasonFilter = filter['value'] as String;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortAndSummaryBar(
    BuildContext context,
    int count,
    bool wide,
  ) {
    final theme = Theme.of(context);

    final summaryWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count ${count == 1 ? 'Trip' : 'Trips'}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            queryLabel,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    final sortWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sort_rounded, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Sort by:',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSort,
              icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              items: _sortOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (newSort) {
                if (newSort != null) {
                  setState(() => _selectedSort = newSort);
                }
              },
            ),
          ),
        ),
      ],
    );

    if (wide) {
      return Row(
        children: [
          Expanded(child: summaryWidget),
          const SizedBox(width: 16),
          sortWidget,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryWidget,
          const SizedBox(height: 12),
          sortWidget,
        ],
      );
    }
  }

  String get queryLabel {
    final route = [
      if (_leavingFrom.trim().isNotEmpty) _leavingFrom.trim(),
      if (_goingTo.trim().isNotEmpty) _goingTo.trim(),
    ].join(' to ');
    final month = _selectedMonth == 'Any month' ? '' : ' in $_selectedMonth';
    final season = _selectedSeasonFilter == 'All' ? '' : ' • $_selectedSeasonFilter';

    if (route.isEmpty && month.isEmpty && season.isEmpty) {
      return 'Handpicked escapes with optimal weather, seasonal views, and vetted routes.';
    }
    return 'Trips${route.isNotEmpty ? ' for $route' : ''}$month$season';
  }

  Widget _buildVerticalPackageGrid(
    BuildContext context,
    List<Map<String, dynamic>> packages,
    double screenWidth,
  ) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (packages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.travel_explore_rounded, size: 40),
            const SizedBox(height: 12),
            Text(
              'No trips found matching your weather and filter criteria.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Try selecting another season, changing the month, or resetting filters.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _goingTo = '';
                  _selectedMonth = 'Any month';
                  _selectedSeasonFilter = 'All';
                  _selectedSort = 'Recommended';
                });
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      );
    }

    final int crossAxisCount =
        screenWidth >= 1050 ? 3 : (screenWidth >= 680 ? 2 : 1);
    final double childAspectRatio = screenWidth >= 1050
        ? 0.73
        : (screenWidth >= 680 ? 0.75 : 0.88);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 22,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => _VerticalPackageCard(
        package: packages[index],
        onThemeToggle: widget.onThemeToggle,
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 35 * (index % 12)))
          .slideY(begin: 0.04),
    );
  }
}

class _VerticalPackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onThemeToggle;

  const _VerticalPackageCard({
    required this.package,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final title = (package['title'] ?? 'Untitled escape').toString();
    final location = (package['location'] ?? 'India').toString();
    final image = (package['image'] ?? '').toString();
    final duration = (package['duration'] ?? '').toString();
    final rating = (package['rating'] ?? '4.8').toString();
    final price = (package['price'] ?? '').toString();
    final weatherHighlight = (package['weatherHighlight'] ?? '').toString();
    final bestSeason = (package['bestSeason'] ?? '').toString();
    final organizer = (package['organizer'] ?? 'Invincible NGO').toString();
    final bestMonths = (package['bestMonths'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailsScreen(
                pkg: package,
                onThemeToggle: onThemeToggle,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Container with weather and season badges
              Stack(
                children: [
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: Hero(
                      tag: 'image_$title',
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: Color(0xFF31594E)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Weather Badge (Top Left)
                  if (weatherHighlight.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          weatherHighlight,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Season Badge (Top Right)
                  if (bestSeason.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          bestSeason,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  // Duration Pill (Bottom Right of Image)
                  if (duration.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Body Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Rating Row
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 15, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.star_rounded,
                              size: 17, color: Color(0xFFE49C39)),
                          const SizedBox(width: 3),
                          Text(
                            rating,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      // Trip Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Best Months preview
                      if (bestMonths.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 12,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.8)),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Best: ${bestMonths.take(3).join(', ')}${bestMonths.length > 3 ? '...' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Organizer tag
                      Text(
                        'Verified by $organizer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                      const Spacer(),
                      const Divider(height: 14),
                      // Price & Action Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Per Person',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  price,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PackageDetailsScreen(
                                    pkg: package,
                                    onThemeToggle: onThemeToggle,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('View Trip',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
