import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _selectedBudgetFilter = 'All';
  String _selectedDurationFilter = 'All';
  String _selectedSort = 'Recommended';
  bool _isLoading = true;

  final Set<int> _savedPackageIds = {};
  late final ScrollController _scrollController;
  bool _showBackToTop = false;

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

  static const _budgetFilters = [
    'All',
    'Under ₹10,000',
    '₹10,000 - ₹20,000',
    '₹20,000 - ₹35,000',
    'Above ₹35,000',
  ];

  static const _durationFilters = [
    'All',
    '1-3 Days',
    '4-7 Days',
    '8+ Days',
  ];

  bool get _hasActiveFilters =>
      _leavingFrom.isNotEmpty ||
      _goingTo.isNotEmpty ||
      _selectedMonth != 'Any month' ||
      _selectedSeasonFilter != 'All' ||
      _selectedBudgetFilter != 'All' ||
      _selectedDurationFilter != 'All' ||
      _selectedSort != 'Recommended';

  void _resetAllFilters() {
    setState(() {
      _leavingFrom = '';
      _goingTo = '';
      _selectedMonth = 'Any month';
      _selectedSeasonFilter = 'All';
      _selectedBudgetFilter = 'All';
      _selectedDurationFilter = 'All';
      _selectedSort = 'Recommended';
    });
  }

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
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchPackages();
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 450;
    if (show != _showBackToTop) {
      setState(() => _showBackToTop = show);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
      final pkgId = package['id'] is int
          ? package['id'] as int
          : int.tryParse(package['id'].toString()) ?? 0;

      // Check Saved (Wishlist) filter
      if (_selectedSeasonFilter == 'Saved') {
        if (!_savedPackageIds.contains(pkgId)) return false;
      }

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
      if (_selectedSeasonFilter != 'All' && _selectedSeasonFilter != 'Saved') {
        final season = (package['bestSeason'] ?? '').toString();
        final type = (package['tripType'] ?? '').toString().toLowerCase();
        if (_selectedSeasonFilter == 'Winter & Snow' && !season.contains('Winter')) return false;
        if (_selectedSeasonFilter == 'Spring & Summer' && !season.contains('Summer') && !season.contains('Spring')) return false;
        if (_selectedSeasonFilter == 'Monsoon Greens' && !season.contains('Monsoon')) return false;
        if (_selectedSeasonFilter == 'Autumn & Festive' && !season.contains('Autumn') && !season.contains('Festive')) return false;
        if (_selectedSeasonFilter == 'Treks' && !type.contains('trek')) return false;
        if (_selectedSeasonFilter == 'Beaches' && !type.contains('beach') && !type.contains('island')) return false;
        if (_selectedSeasonFilter == 'Heritage' && !type.contains('heritage') && !type.contains('culture')) return false;
        if (_selectedSeasonFilter == 'Wildlife' && !type.contains('wildlife') && !type.contains('nature')) return false;
      }

      // Check budget filter
      if (_selectedBudgetFilter != 'All') {
        final price = _extractPrice(package['price']);
        if (_selectedBudgetFilter == 'Under ₹10,000' && price > 10000) return false;
        if (_selectedBudgetFilter == '₹10,000 - ₹20,000' && (price < 10000 || price > 20000)) return false;
        if (_selectedBudgetFilter == '₹20,000 - ₹35,000' && (price < 20000 || price > 35000)) return false;
        if (_selectedBudgetFilter == 'Above ₹35,000' && price <= 35000) return false;
      }

      // Check duration filter
      if (_selectedDurationFilter != 'All') {
        final days = _extractDuration(package['duration']);
        if (_selectedDurationFilter == '1-3 Days' && (days < 1 || days > 3)) return false;
        if (_selectedDurationFilter == '4-7 Days' && (days < 4 || days > 7)) return false;
        if (_selectedDurationFilter == '8+ Days' && days < 8) return false;
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'fab_scroll_top',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeOutCubic,
                );
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Scroll to top',
              child: const Icon(Icons.arrow_upward_rounded),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton.extended(
            heroTag: 'fab_ask_local',
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
        ],
      ),
      body: LiveBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              final wide = viewport.maxWidth >= 760;
              return SingleChildScrollView(
                controller: _scrollController,
                padding:
                    EdgeInsets.fromLTRB(wide ? 32 : 20, 8, wide ? 32 : 20, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _RotatingHeroBanner(
                          allPackages: _allPackages,
                          wide: wide,
                          onThemeToggle: widget.onThemeToggle,
                        ),
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
                suffixIcon: (isOrigin ? _leavingFrom : _goingTo).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        tooltip: 'Clear',
                        onPressed: () {
                          controller.clear();
                          setState(() {
                            if (isOrigin) {
                              _leavingFrom = '';
                            } else {
                              _goingTo = '';
                            }
                          });
                        },
                      )
                    : null,
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
    final activeFilters = [
      _seasonFilters[0],
      if (_savedPackageIds.isNotEmpty)
        {
          'label': '❤️ Saved (${_savedPackageIds.length})',
          'value': 'Saved',
          'icon': Icons.favorite_rounded,
        },
      ..._seasonFilters.sublist(1),
    ];

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
              '55 Verified Trips',
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
            itemCount: activeFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = activeFilters[index];
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
        const SizedBox(height: 12),
        // Secondary Filter Bar: Budget, Duration, and Reset Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Budget Dropdown / Filter
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedBudgetFilter != 'All'
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.currency_rupee_rounded,
                        size: 15,
                        color: _selectedBudgetFilter != 'All'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBudgetFilter,
                        isDense: true,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        items: _budgetFilters.map((b) {
                          return DropdownMenuItem<String>(
                            value: b,
                            child: Text(b == 'All' ? 'Budget: Any' : b),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedBudgetFilter = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Duration Dropdown / Filter
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedDurationFilter != 'All'
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timelapse_rounded,
                        size: 15,
                        color: _selectedDurationFilter != 'All'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDurationFilter,
                        isDense: true,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        items: _durationFilters.map((d) {
                          return DropdownMenuItem<String>(
                            value: d,
                            child: Text(d == 'All' ? 'Duration: Any' : d),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDurationFilter = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Reset All Filters button
              if (_hasActiveFilters)
                ActionChip(
                  avatar: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset All',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                  onPressed: _resetAllFilters,
                ),
            ],
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
            '$count ${_allPackages.isNotEmpty ? 'of ${_allPackages.length} ' : ''}${count == 1 ? 'Trip' : 'Trips'}',
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
    final season = _selectedSeasonFilter == 'All'
        ? ''
        : (_selectedSeasonFilter == 'Saved'
            ? ' • Saved Wishlist ❤️'
            : ' • $_selectedSeasonFilter');
    final budget =
        _selectedBudgetFilter == 'All' ? '' : ' • $_selectedBudgetFilter';
    final duration =
        _selectedDurationFilter == 'All' ? '' : ' • $_selectedDurationFilter';

    if (route.isEmpty &&
        month.isEmpty &&
        season.isEmpty &&
        budget.isEmpty &&
        duration.isEmpty) {
      return '55 Handpicked escapes with optimal weather, seasonal views, and vetted routes.';
    }
    return 'Trips${route.isNotEmpty ? ' for $route' : ''}$month$season$budget$duration';
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
              onPressed: _resetAllFilters,
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      );
    }

    final int crossAxisCount = screenWidth >= 1200
        ? 4
        : (screenWidth >= 900
            ? 3
            : (screenWidth >= 600 ? 2 : 1));
    final double childAspectRatio = screenWidth >= 1200
        ? 0.63
        : (screenWidth >= 900
            ? 0.70
            : (screenWidth >= 600 ? 0.72 : 0.86));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final pkg = packages[index];
        final pkgId = pkg['id'] is int
            ? pkg['id'] as int
            : int.tryParse(pkg['id'].toString()) ?? 0;
        final title = (pkg['title'] ?? 'Trip').toString();
        final loc = (pkg['location'] ?? 'India').toString();
        final price = (pkg['price'] ?? '').toString();
        final duration = (pkg['duration'] ?? '').toString();

        return _VerticalPackageCard(
          package: pkg,
          onThemeToggle: widget.onThemeToggle,
          isSaved: _savedPackageIds.contains(pkgId),
          onToggleSave: () {
            final willSave = !_savedPackageIds.contains(pkgId);
            setState(() {
              if (willSave) {
                _savedPackageIds.add(pkgId);
              } else {
                _savedPackageIds.remove(pkgId);
              }
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  willSave
                      ? 'Saved "$title" to your Wishlist ❤️'
                      : 'Removed "$title" from your Wishlist',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onShare: () {
            Clipboard.setData(ClipboardData(
              text:
                  'Check out "$title" in $loc ($duration, $price) on TravelMaster! Book now: http://localhost:3000',
            ));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Trip details copied to clipboard! 📋 Ready to share.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 35 * (index % 12)))
            .slideY(begin: 0.04);
      },
    );
  }
}

class _RotatingHeroBanner extends StatefulWidget {
  final List<Map<String, dynamic>> allPackages;
  final bool wide;
  final VoidCallback onThemeToggle;

  const _RotatingHeroBanner({
    required this.allPackages,
    required this.wide,
    required this.onThemeToggle,
  });

  @override
  State<_RotatingHeroBanner> createState() => _RotatingHeroBannerState();
}

class _RotatingHeroBannerState extends State<_RotatingHeroBanner> {
  late final PageController _heroPageController;
  Timer? _heroTimer;
  int _currentHeroIndex = 0;

  static const List<_HeroPlaceSlide> _defaultHeroSlides = [
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?auto=format&fit=crop&w=1800&q=85',
      title: 'More world.\nLess routine.',
      subtitle: 'Drift through serene palm lagoons & emerald backwaters',
      location: 'Alleppey, Kerala',
      tag: '🌴 TROPICAL OASIS • 26°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1800&q=85',
      title: 'Touch the clouds.\nWalk on snow.',
      subtitle:
          'Winter summit trail & snow-covered pine ridges at 12,500 ft',
      location: 'Kedarkantha, Uttarakhand',
      tag: '❄️ SUB-ZERO SNOW • -4°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1800&q=85',
      title: 'The Middle Land.\nPure wilderness.',
      subtitle:
          'Ancient high-altitude monasteries & trans-Himalayan valleys',
      location: 'Spiti Valley, Himachal',
      tag: '🏔️ HIGH PASSES • 14°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=1800&q=85',
      title: 'Golden sunsets.\nOcean breeze.',
      subtitle: 'Hidden secluded coves, palm shores & coastal adventures',
      location: 'Palolem Beach, South Goa',
      tag: '🏖️ COASTAL BREEZE • 29°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=1800&q=85',
      title: 'Starry skies.\nGolden dunes.',
      subtitle:
          'Camel safaris, folklore music & desert camps under the stars',
      location: 'Jaisalmer, Thar Desert',
      tag: '✨ DESERT NIGHTS • 22°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=1800&q=85',
      title: 'Living root bridges.\nMisty gorges.',
      subtitle:
          'Centuries-old bio-root engineering & thundering emerald falls',
      location: 'Cherrapunji, Meghalaya',
      tag: '🌧️ MONSOON RAIN • 19°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?auto=format&fit=crop&w=1800&q=85',
      title: 'Turquoise sea.\nCoral reefs.',
      subtitle:
          'Radhanagar white sands & world-class deep coral reef diving',
      location: 'Havelock, Andaman Islands',
      tag: '🌊 ISLAND RETREAT • 28°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=1800&q=85',
      title: 'Eternal city.\nSacred riverbanks.',
      subtitle: 'Evening Ganga Aarti lights & timeless spiritual heritage',
      location: 'Varanasi, Uttar Pradesh',
      tag: '🪔 SPIRITUAL HERITAGE • 21°C',
    ),
    _HeroPlaceSlide(
      image:
          'https://images.unsplash.com/photo-1570789210967-2cac24afeb00?auto=format&fit=crop&w=1800&q=85',
      title: 'Morning mist.\nKanchenjunga.',
      subtitle: 'Rolling emerald tea hills & panoramic golden sunrises',
      location: 'Darjeeling, West Bengal',
      tag: '☕ ALPINE DAWN • 13°C',
    ),
  ];

  List<_HeroPlaceSlide> _getHeroSlides() {
    if (widget.allPackages.isEmpty) return _defaultHeroSlides;

    final dynamicSlides = widget.allPackages.take(12).map((pkg) {
      final title = (pkg['title'] ?? 'Scenic Escape').toString();
      final loc = (pkg['location'] ?? 'India').toString();
      final image = (pkg['image'] ?? '').toString();
      final weather =
          (pkg['weatherHighlight'] ?? 'Optimal Travel Season').toString();
      final season = (pkg['bestSeason'] ?? 'All Seasons').toString();

      String heroTitle = 'More world.\nLess routine.';
      final lower = title.toLowerCase();
      if (lower.contains('trek') ||
          lower.contains('pass') ||
          lower.contains('peak')) {
        heroTitle = 'Walk the heights.\nReach the peak.';
      } else if (lower.contains('beach') ||
          lower.contains('coast') ||
          lower.contains('island')) {
        heroTitle = 'Golden shores.\nOcean breeze.';
      } else if (lower.contains('desert') ||
          lower.contains('kutch') ||
          lower.contains('dunes')) {
        heroTitle = 'Starry skies.\nEndless horizon.';
      } else if (lower.contains('waterfall') ||
          lower.contains('forest') ||
          lower.contains('meghalaya')) {
        heroTitle = 'Lush canopies.\nMisty cascades.';
      } else if (lower.contains('heritage') ||
          lower.contains('kashi') ||
          lower.contains('temple') ||
          lower.contains('hampi')) {
        heroTitle = 'Timeless tales.\nAncient stones.';
      } else if (lower.contains('backwaters') || lower.contains('kerala')) {
        heroTitle = 'More world.\nLess routine.';
      }

      return _HeroPlaceSlide(
        image: image,
        title: heroTitle,
        subtitle: '$title • $loc',
        location: loc,
        tag: '$weather • $season',
        package: pkg,
      );
    }).toList();

    return dynamicSlides.isNotEmpty ? dynamicSlides : _defaultHeroSlides;
  }

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController();
    _startHeroAutoPlay();
  }

  void _startHeroAutoPlay() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final slides = _getHeroSlides();
      if (slides.isEmpty) return;
      final nextIndex = (_currentHeroIndex + 1) % slides.length;
      if (_heroPageController.hasClients) {
        _heroPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _nextHeroSlide() {
    final slides = _getHeroSlides();
    if (slides.isEmpty) return;
    final nextIndex = (_currentHeroIndex + 1) % slides.length;
    if (_heroPageController.hasClients) {
      _heroPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
    _startHeroAutoPlay();
  }

  void _prevHeroSlide() {
    final slides = _getHeroSlides();
    if (slides.isEmpty) return;
    final prevIndex = (_currentHeroIndex - 1 + slides.length) % slides.length;
    if (_heroPageController.hasClients) {
      _heroPageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
    _startHeroAutoPlay();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _getHeroSlides();
    final wide = widget.wide;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: wide ? 400 : 360,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // PageView cycling through all places every 5 seconds without triggering parent rebuilds
            PageView.builder(
              controller: _heroPageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() => _currentHeroIndex = index);
                _startHeroAutoPlay(); // Reset timer so full 5s is given after manual swipe
              },
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      slide.image,
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
                            Color(0x35000000),
                            Color(0x18000000),
                            Color(0xC8000000),
                          ],
                          stops: [0, 0.42, 1],
                        ),
                      ),
                    ),
                    // Slide content
                    Positioned(
                      left: wide ? 38 : 20,
                      right: wide ? 280 : 20,
                      bottom: 42,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Location Tag & Weather
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.place_rounded,
                                        size: 13, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      slide.location,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    slide.tag,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: wide ? 46 : 34,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top Bar
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'FEATURED DESTINATIONS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 5-second indicator & Slide counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 5),
                        Text(
                          '${_currentHeroIndex + 1} / ${slides.length} • 5s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Left & Right manual navigation buttons
            if (wide) ...[
              Positioned(
                left: 14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.38),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _prevHeroSlide,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.chevron_left_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.38),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _nextHeroSlide,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Bottom Right Action Button: "Explore Place"
            Positioned(
              right: 22,
              bottom: 24,
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    final currentSlide = slides[_currentHeroIndex];
                    if (currentSlide.package != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackageDetailsScreen(
                            pkg: currentSlide.package!,
                            onThemeToggle: widget.onThemeToggle,
                          ),
                        ),
                      );
                    } else if (widget.allPackages.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackageDetailsScreen(
                            pkg: widget.allPackages.first,
                            onThemeToggle: widget.onThemeToggle,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Explore Place',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Indicators (Line / Dots that advance)
            Positioned(
              bottom: 14,
              left: 24,
              child: Row(
                children: List.generate(slides.length, (i) {
                  final isCurrent = i == _currentHeroIndex;
                  return GestureDetector(
                    onTap: () {
                      _heroPageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeInOutCubic,
                      );
                      _startHeroAutoPlay();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 5),
                      height: 4.5,
                      width: isCurrent ? 24 : 7,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalPackageCard extends StatefulWidget {
  final Map<String, dynamic> package;
  final VoidCallback onThemeToggle;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;

  const _VerticalPackageCard({
    required this.package,
    required this.onThemeToggle,
    required this.isSaved,
    required this.onToggleSave,
    required this.onShare,
  });

  @override
  State<_VerticalPackageCard> createState() => _VerticalPackageCardState();
}

class _VerticalPackageCardState extends State<_VerticalPackageCard> {
  int _selectedDateIndex = 0;
  int _selectedMonthIndex = 0;
  int _currentImageIndex = 0;
  late final PageController _imagePageController;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  static List<String> _getPackageImages(Map<String, dynamic> pkg) {
    final title = (pkg['title'] ?? '').toString().toLowerCase();
    if (title.contains('saputara')) {
      return [
        'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1518457607834-6e8d80c183c5?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=1200&q=80',
      ];
    }
    if (title.contains('polo')) {
      return [
        'https://images.unsplash.com/photo-1516214104703-d870798883c5?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1621847468516-1ed5d0df56fe?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1426604966848-d7adac402bff?auto=format&fit=crop&w=1200&q=80',
      ];
    }

    final raw = pkg['images'];
    if (raw is List && raw.isNotEmpty) {
      final list = raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      if (list.isNotEmpty) return list;
    }
    final single = (pkg['image'] ?? '').toString().trim();
    if (single.isNotEmpty) {
      return [
        single,
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=1200&q=80',
      ];
    }
    return [
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80',
    ];
  }

  static String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) return '₹3,499';
    final str = rawPrice.toString().trim();
    if (str.startsWith('₹')) return str;
    if (str.toLowerCase().startsWith('rs.')) {
      return '₹${str.substring(3).trim()}';
    }
    if (str.toLowerCase().startsWith('rs')) {
      return '₹${str.substring(2).trim()}';
    }
    final digits = str.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isNotEmpty) {
      final val = int.tryParse(digits) ?? 0;
      return '₹${val.toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (Match m) => '${m[1]},')}';
    }
    return str;
  }

  static String _cleanLocation(dynamic rawLoc) {
    final str = (rawLoc ?? 'India').toString().trim();
    if (str.toLowerCase().contains('dang') || str.toLowerCase().contains('saputara')) {
      return 'The Dang, South Gujarat';
    }
    if (str.contains(',')) {
      final parts = str.split(',');
      if (parts.length > 1) {
        final state = parts.last.trim();
        if (state.isNotEmpty) return state;
      }
    }
    return str;
  }

  static int _getDifficultyLevel(Map<String, dynamic> pkg) {
    final title = (pkg['title'] ?? '').toString().toLowerCase();
    final type = (pkg['tripType'] ?? '').toString().toLowerCase();
    final dur = int.tryParse((pkg['duration'] ?? '').toString().split(' ').first) ?? 3;
    if (title.contains('chadar') ||
        title.contains('roopkund') ||
        title.contains('sandakphu') ||
        title.contains('brahmatal') ||
        title.contains('kedarkantha') ||
        title.contains('spiti') ||
        title.contains('tawang') ||
        title.contains('kuari pass')) {
      return 3;
    }
    if (type.contains('trek') ||
        title.contains('chopta') ||
        title.contains('kerala') ||
        title.contains('maharashtra') ||
        dur >= 4) {
      return 2;
    }
    return 1;
  }

  static String _getPackageTagline(Map<String, dynamic> pkg) {
    final title = (pkg['title'] ?? '').toString().toLowerCase();
    if (title.contains('saputara')) return 'Simply Kashmir of Gujarat!';
    if (title.contains('kerala')) return "God's Own Country!";
    if (title.contains('chopta') || title.contains('tungnath')) {
      return 'A Mountain Day, A Lifetime Memory';
    }
    if (title.contains('maharashtra') || title.contains('kalsubai')) {
      return 'Unveil the mysterious treks of Maharashtra!';
    }
    if (title.contains('kedarkantha')) return 'Queen of Winter Treks & Summit Snow';
    if (title.contains('manali')) return 'Valley of the Gods & Alpine Glades';
    if (title.contains('polo forest')) return 'Ancient Temples & Lush Greenery!';
    if (title.contains('beyt dwarka')) return 'Sacred Island & Marine Coral Trails';
    if (title.contains('rajasthan') || title.contains('jaipur')) {
      return 'Land of Kings & Royal Forts!';
    }
    if (title.contains('ladakh') || title.contains('himalayas')) {
      return 'The Land of High Mountain Passes!';
    }
    if (title.contains('goa')) return 'Sun, Sand, Waves & Palm-lined Shores';
    if (title.contains('spiti')) return 'The Middle Land Between Earth & Sky';
    if (title.contains('kasol') || title.contains('kheerganga')) {
      return 'Parvati Valley & Thermal Springs!';
    }
    if (title.contains('valley of flowers')) {
      return 'UNESCO Wonderland of Alpine Blooms!';
    }
    if (title.contains('brahmatal')) return 'Frozen Glacial Lake & Mt. Trishul!';
    if (title.contains('hampta')) return 'Dramatic Green to Desert Crossover';
    if (title.contains('meghalaya')) return 'Abode of Clouds & Living Root Bridges';
    if (title.contains('andaman')) return 'Turquoise Lagoons & Radhanagar Sunsets';
    if (title.contains('rann of kutch')) return 'Endless White Desert Under Moonlight';
    if (title.contains('coorg')) return 'Scotland of India & Coffee Hills!';
    if (title.contains('varanasi')) return 'Ancient Ghats & Sacred Ganga Aarti';
    if (title.contains('kashmir')) return 'Paradise on Earth & Dal Reflections';
    if (title.contains('hampi')) return 'UNESCO Boulder Capital of Vijayanagara';
    if (title.contains('jaisalmer')) return 'Golden Fort & Thar Desert Safari';
    if (title.contains('gir')) return 'Sole Abode of the Asiatic Lion';
    if (title.contains('rishikesh')) return 'Yoga Capital & Ganga Whitewater Rapids';
    if (title.contains('sundarbans')) {
      return 'World’s Largest Delta & Mangrove Trails';
    }
    if (title.contains('gokarna')) return 'Om Beach Coves & Arabian Sea Cliffs';
    if (title.contains('chadar')) return 'Walking on Frozen Zanskar River';
    if (title.contains('ooty')) return 'Queen of Hill Stations & Toy Train';
    if (title.contains('roopkund')) return 'Glacial Mystery Lake at 15,750 ft';

    final weather = (pkg['weatherHighlight'] ?? '').toString();
    final clean = weather
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '')
        .trim();
    if (clean.isNotEmpty) return clean;
    return 'Experience pristine landscapes & authentic culture!';
  }

  static List<String> _extractMonths(Map<String, dynamic> pkg) {
    final title = (pkg['title'] ?? '').toString().toLowerCase();
    if (title.contains('saputara')) return ['Oct', 'Nov', 'Dec', 'Jan 2027'];
    if (title.contains('kerala')) return ['Oct', 'Nov', 'Dec', 'Jan 2027'];
    if (title.contains('chopta')) {
      return ['Nov', 'Dec', 'Jan 2027', 'Feb 2027', 'Mar 2027'];
    }
    if (title.contains('maharashtra')) return ['Oct', 'Nov'];

    final rawMonths = pkg['bestMonths'] as List<dynamic>?;
    if (rawMonths != null && rawMonths.isNotEmpty) {
      return rawMonths.take(4).map((m) {
        final s = m.toString().trim();
        if (s.length > 3) {
          final prefix = s.substring(0, 3);
          if (s.toLowerCase().contains('jan') || s.toLowerCase().contains('feb')) {
            return '$prefix 2027';
          }
          return prefix;
        }
        return s;
      }).toList();
    }
    return ['Oct', 'Nov', 'Dec', 'Jan 2027'];
  }

  static List<String> _extractDates(Map<String, dynamic> pkg) {
    final title = (pkg['title'] ?? '').toString().toLowerCase();
    if (title.contains('saputara')) return ['09', '16', '23', '30'];
    if (title.contains('kerala')) return ['10', '17', '24', '31'];
    if (title.contains('chopta')) return ['24'];
    if (title.contains('maharashtra')) return ['09', '16', '23', '30'];

    final dates = pkg['departureDates'] as List<dynamic>?;
    if (dates != null && dates.isNotEmpty) {
      final days = dates.map((d) {
        final str = d.toString().trim();
        final match = RegExp(r'^(\d{1,2})').firstMatch(str);
        if (match != null) {
          final n = int.tryParse(match.group(1)!) ?? 9;
          return n.toString().padLeft(2, '0');
        }
        return '09';
      }).toList();
      return days.take(4).toList();
    }
    return ['09', '16', '23', '30'];
  }

  void _openPdfBrochureModal() {
    final title = (widget.package['title'] ?? 'Trip Itinerary').toString();
    final price = _formatPrice(widget.package['price']);
    final duration = (widget.package['duration'] ?? '3 Days').toString();
    final location = _cleanLocation(widget.package['location']);
    final months = _extractMonths(widget.package);
    final dates = _extractDates(widget.package);
    final selectedBatch = dates.isNotEmpty
        ? '${dates[_selectedDateIndex]} ${months.isNotEmpty ? months[_selectedMonthIndex] : ''}'
        : 'Open Batch';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2633) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modal Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151D28) : const Color(0xFFF8FAFC),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? const Color(0xFF283446) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Color(0xFFE5533D),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Official Trip Itinerary & PDF',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Verified by Invincible NGO • Digital Brochure',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Modal Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getPackageTagline(widget.package),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1EE),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5533D).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'STARTING FROM',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    Text(
                                      price,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFE5533D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Badges Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModalBadge(Icons.calendar_today_rounded, duration, isDark),
                              _buildModalBadge(Icons.place_rounded, location, isDark),
                              _buildModalBadge(Icons.event_available_rounded, 'Batch: $selectedBatch', isDark, isHighlight: true),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Package Inclusions',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildInclusionItem(Icons.verified_user_rounded, 'Certified Trek Leaders, Guides & Wilderness Instructors', isDark),
                          _buildInclusionItem(Icons.night_shelter_rounded, 'Deluxe Alpine Tents & Campsite Accommodations', isDark),
                          _buildInclusionItem(Icons.restaurant_rounded, 'Nutritious High-Energy Vegetarian Meals (B/L/D + Snacks)', isDark),
                          _buildInclusionItem(Icons.card_membership_rounded, 'Official Invincible NGO Certificate of Participation', isDark),
                          _buildInclusionItem(Icons.medical_services_rounded, 'First Aid Kit, Stretcher & Emergency Mountain Evacuation Support', isDark),
                          _buildInclusionItem(Icons.confirmation_number_rounded, 'All Forest Department Permits & Environmental Sanctuary Passes', isDark),

                          const SizedBox(height: 18),
                          Text(
                            'Brochure Details',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This comprehensive brochure includes full gear checklist, daily altitude profiles, reporting instructions, travel advisory, and emergency contacts.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Modal Actions
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151D28) : const Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(
                          color: isDark ? const Color(0xFF283446) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Brochure downloaded! "$title - Itinerary.pdf" (3.2 MB) saved to Downloads.',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF16A34A),
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.file_download_outlined, size: 18, color: Color(0xFFE5533D)),
                            label: const Text(
                              'Download PDF',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE5533D),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE5533D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PackageDetailsScreen(
                                    pkg: widget.package,
                                    onThemeToggle: widget.onThemeToggle,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                            label: const Text(
                              'Book Batch',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE5533D),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalBadge(IconData icon, String text, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFFFF0EC)
            : (isDark ? const Color(0xFF283446) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        border: isHighlight
            ? Border.all(color: const Color(0xFFE5533D).withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isHighlight ? const Color(0xFFE5533D) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              color: isHighlight ? const Color(0xFFE5533D) : (isDark ? Colors.white70 : const Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInclusionItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = (widget.package['title'] ?? 'Trip').toString();
    final location = _cleanLocation(widget.package['location']);
    final images = _getPackageImages(widget.package);
    final duration = (widget.package['duration'] ?? '3 Days').toString();
    final price = _formatPrice(widget.package['price']);
    final tagline = _getPackageTagline(widget.package);
    final difficulty = _getDifficultyLevel(widget.package);
    final months = _extractMonths(widget.package);
    final dates = _extractDates(widget.package);

    final selectedMonthSafe = _selectedMonthIndex < months.length ? _selectedMonthIndex : 0;
    final selectedDateSafe = _selectedDateIndex < dates.length ? _selectedDateIndex : 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2632) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3747) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // 1. TOP IMAGE with Horizontally Scrollable PageView & Dynamic Carousel Dots
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 175,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Horizontally Scrollable Multi-photo PageView
                  PageView.builder(
                    controller: _imagePageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: images.length,
                    onPageChanged: (idx) {
                      setState(() => _currentImageIndex = idx);
                    },
                    itemBuilder: (context, imgIdx) {
                      return Image.network(
                        images[imgIdx],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                            child: Icon(
                              Icons.landscape_rounded,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Soft Gradient Overlay
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x35000000),
                              Colors.transparent,
                              Color(0x45000000),
                            ],
                            stops: [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Left Navigation Arrow Button
                  if (images.length > 1)
                    Positioned(
                      left: 6,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.40),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              final prev = (_currentImageIndex - 1 + images.length) % images.length;
                              _imagePageController.animateToPage(
                                prev,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Right Navigation Arrow Button
                  if (images.length > 1)
                    Positioned(
                      right: 6,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.40),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              final next = (_currentImageIndex + 1) % images.length;
                              _imagePageController.animateToPage(
                                next,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Heart Button (Top Right of Image)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.42),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onToggleSave,
                        child: Padding(
                          padding: const EdgeInsets.all(5.5),
                          child: Icon(
                            widget.isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: widget.isSaved ? Colors.redAccent : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dynamic & Interactive Carousel Dots (Center Bottom of Image)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(images.length, (dotIdx) {
                            final isActive = dotIdx == _currentImageIndex;
                            return GestureDetector(
                              onTap: () {
                                _imagePageController.animateToPage(
                                  dotIdx,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 2.2),
                                width: isActive ? 14.0 : 5.5,
                                height: 5.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: isActive
                                      ? const Color(0xFFE5533D)
                                      : Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CARD CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row A: Duration & Location
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13.5,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Row B: Title & Tagline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  // Row C: STARTING FROM & DIFFICULTY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'STARTING FROM',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE5533D),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'DIFFICULTY',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (barIdx) {
                              final isFilled = barIdx < difficulty;
                              return Container(
                                margin: const EdgeInsets.only(left: 3),
                                width: 14,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isFilled
                                      ? const Color(0xFFE5533D)
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Row D: Months Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(months.length, (mIdx) {
                        final isSelected = mIdx == selectedMonthSafe;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMonthIndex = mIdx),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              months[mIdx],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFFE5533D)
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Row E: Circular Departure Date Badges
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(dates.length, (dIdx) {
                        final isSelected = dIdx == selectedDateSafe;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDateIndex = dIdx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selected Batch: ${dates[dIdx]} ${months.isNotEmpty ? months[selectedMonthSafe] : ''} ($title)',
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            margin: const EdgeInsets.only(right: 8),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFFE5533D)
                                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      width: 1,
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE5533D).withValues(alpha: 0.35),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                dates[dIdx],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Row F: Bottom Action Buttons (More Details & Get PDF)
                  Row(
                    children: [
                      // More Details Button
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PackageDetailsScreen(
                                    pkg: widget.package,
                                    onThemeToggle: widget.onThemeToggle,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.info_outline_rounded,
                              size: 15,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            label: Text(
                              'More Details',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF283446)
                                  : const Color(0xFFF1F5F9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Get PDF Button
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: _openPdfBrochureModal,
                            icon: const Icon(
                              Icons.file_download_outlined,
                              size: 16,
                              color: Color(0xFFE5533D),
                            ),
                            label: const Text(
                              'Get PDF',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE5533D),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF2E1C18)
                                  : const Color(0xFFFFF1EE),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: const Color(0xFFE5533D).withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

class _HeroPlaceSlide {
  final String image;
  final String title;
  final String subtitle;
  final String location;
  final String tag;
  final Map<String, dynamic>? package;

  const _HeroPlaceSlide({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.tag,
    this.package,
  });
}
