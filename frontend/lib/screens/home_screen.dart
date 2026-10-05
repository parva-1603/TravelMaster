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
      if (query.isEmpty) return true;
      final location = (package['location'] ?? '').toString().toLowerCase();
      final title = (package['title'] ?? '').toString().toLowerCase();
      return location.contains(query) || title.contains(query);
    }).toList();

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
                        const SizedBox(height: 42),
                        _buildPackageHeading(context, filteredPackages.length),
                        const SizedBox(height: 16),
                        _buildPackageRail(context, filteredPackages),
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

  Widget _buildPackageHeading(BuildContext context, int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A good place to start',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                queryLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        if (!_isLoading)
          Text(
            '$count ${count == 1 ? 'trip' : 'trips'}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
      ],
    );
  }

  String get queryLabel {
    final route = [
      if (_leavingFrom.trim().isNotEmpty) _leavingFrom.trim(),
      if (_goingTo.trim().isNotEmpty) _goingTo.trim(),
    ].join(' to ');
    if (route.isEmpty) {
      return 'Handpicked escapes, from quiet coastlines to high country.';
    }
    final month = _selectedMonth == 'Any month' ? '' : ' in $_selectedMonth';
    return 'Trips from $route$month';
  }

  Widget _buildPackageRail(
    BuildContext context,
    List<Map<String, dynamic>> packages,
  ) {
    if (_isLoading) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (packages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            const Icon(Icons.travel_explore_rounded, size: 30),
            const SizedBox(height: 10),
            Text(
              'No trips found for that search.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => setState(() => _goingTo = ''),
              child: const Text('Clear destination'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 332,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 6),
        itemCount: packages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _PackageCard(
          package: packages[index],
          onThemeToggle: widget.onThemeToggle,
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 90 * index))
            .slideY(begin: 0.06),
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  final Map<String, dynamic> package;
  final VoidCallback onThemeToggle;

  const _PackageCard({required this.package, required this.onThemeToggle});

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final title = (widget.package['title'] ?? 'Untitled escape').toString();
    final location =
        (widget.package['location'] ?? 'Somewhere worth going').toString();
    final image = (widget.package['image'] ?? '').toString();
    final duration = (widget.package['duration'] ?? '').toString();
    final rating = (widget.package['rating'] ?? '').toString();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 268,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 192,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AnimatedScale(
                        scale: _isHovered ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
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
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.place_outlined,
                                  size: 15,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ),
                              if (rating.isNotEmpty) ...[
                                const Icon(Icons.star_rounded,
                                    size: 16, color: Color(0xFFE49C39)),
                                const SizedBox(width: 3),
                                Text(rating,
                                    style:
                                        Theme.of(context).textTheme.labelMedium),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: _isHovered
                                          ? Theme.of(context).colorScheme.primary
                                          : null,
                                    ),
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  (widget.package['price'] ?? '').toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              if (duration.isNotEmpty)
                                Text(
                                  duration,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
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
        ),
      ),
    );
  }
}
