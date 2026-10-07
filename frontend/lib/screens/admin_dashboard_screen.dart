import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auto_slideshow_image.dart';
import '../widgets/live_background.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Stats Data
  int _totalBookings = 0;
  int _totalRevenue = 0;
  int _totalPackagesCount = 0;
  int _totalLocationsCount = 0;

  // Lists
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _locations = [];

  String _searchBookingQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _verifyAdminAccess();
  }

  void _verifyAdminAccess() {
    final user = FirebaseAuth.instance.currentUser;
    final currentEmail = user?.email?.toLowerCase().trim() ?? '';
    if (user == null || currentEmail != '24ceuoz014@ddu.ac.in') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access Denied: Admin Panel is restricted exclusively to 24ceuoz014@ddu.ac.in'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    } else {
      _loadAllAdminData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchStats(),
      _fetchBookings(),
      _fetchPackages(),
      _fetchLocations(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStats() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/admin/stats'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _totalBookings = data['totalBookings'] ?? 0;
        _totalRevenue = data['totalRevenue'] ?? 0;
        _totalPackagesCount = data['totalPackages'] ?? 0;
        _totalLocationsCount = data['totalLocations'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching admin stats: $e');
    }
  }

  Future<void> _fetchBookings() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/admin/bookings'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        if (mounted) {
          setState(() {
            _bookings = data.cast<Map<String, dynamic>>();
            _totalBookings = _bookings.length;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    }
  }

  Future<void> _fetchPackages() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/admin/packages'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        if (mounted) {
          setState(() {
            _packages = data.cast<Map<String, dynamic>>();
            _totalPackagesCount = _packages.length;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching admin packages: $e');
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/admin/locations'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        if (mounted) {
          setState(() {
            _locations = data.cast<Map<String, dynamic>>();
            _totalLocationsCount = _locations.length;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching admin locations: $e');
    }
  }

  // ==========================================
  // PACKAGE CRUD OPERATIONS
  // ==========================================

  Future<void> _deletePackage(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final res = await http.delete(Uri.parse('http://localhost:5000/api/admin/packages/$id'));
        if (res.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Package "$title" deleted successfully!')),
            );
          }
          _loadAllAdminData();
        }
      } catch (e) {
        debugPrint('Delete package error: $e');
      }
    }
  }

  void _showPackageFormDialog({Map<String, dynamic>? existingPkg}) {
    final isEditing = existingPkg != null;
    final titleCtrl = TextEditingController(text: existingPkg?['title'] ?? '');
    final locCtrl = TextEditingController(text: existingPkg?['location'] ?? '');
    final priceCtrl = TextEditingController(text: existingPkg?['price'] ?? 'Rs. 25,000');
    final durationCtrl = TextEditingController(text: existingPkg?['duration'] ?? '5 Days');
    final ratingCtrl = TextEditingController(text: existingPkg?['rating'] ?? '4.8');
    final imageCtrl = TextEditingController(
      text: existingPkg?['image'] ??
          'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=85',
    );
    bool isTrending = existingPkg?['isTrending'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? '✏️ Edit Package' : '➕ Add New Package'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Package Title', prefixIcon: Icon(Icons.title)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locCtrl,
                    decoration: const InputDecoration(labelText: 'Location / City', prefixIcon: Icon(Icons.location_on)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(labelText: 'Price (e.g. Rs. 25,000)', prefixIcon: Icon(Icons.payments)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: durationCtrl,
                          decoration: const InputDecoration(labelText: 'Duration (e.g. 5 Days)', prefixIcon: Icon(Icons.timer)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ratingCtrl,
                          decoration: const InputDecoration(labelText: 'Rating (e.g. 4.9)', prefixIcon: Icon(Icons.star)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Trending'),
                          value: isTrending,
                          onChanged: (val) => setDialogState(() => isTrending = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: 'Image URL', prefixIcon: Icon(Icons.image)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || locCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and Location are required!')),
                  );
                  return;
                }

                final payload = {
                  'title': titleCtrl.text.trim(),
                  'location': locCtrl.text.trim(),
                  'price': priceCtrl.text.trim(),
                  'duration': durationCtrl.text.trim(),
                  'rating': ratingCtrl.text.trim(),
                  'image': imageCtrl.text.trim(),
                  'isTrending': isTrending,
                  'departureDates': ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'],
                  'categories': {
                    'Economy': {'price': 'Rs. 18,000', 'facilities': ['Standard Hotel', 'Breakfast']},
                    'Standard': {'price': priceCtrl.text.trim(), 'facilities': ['3-Star Hotel', 'Breakfast & Dinner']},
                    'Luxury': {'price': 'Rs. 45,000', 'facilities': ['5-Star Resort', 'All Meals Included']}
                  }
                };

                try {
                  http.Response res;
                  if (isEditing) {
                    final id = existingPkg['_id'];
                    res = await http.put(
                      Uri.parse('http://localhost:5000/api/admin/packages/$id'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(payload),
                    );
                  } else {
                    res = await http.post(
                      Uri.parse('http://localhost:5000/api/admin/packages'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(payload),
                    );
                  }

                  if (res.statusCode == 200 || res.statusCode == 201) {
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Package updated!' : 'Package created!')),
                      );
                    }
                    _loadAllAdminData();
                  }
                } catch (e) {
                  debugPrint('Save package error: $e');
                }
              },
              child: Text(isEditing ? 'Update Package' : 'Create Package'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOOKING CRUD OPERATIONS
  // ==========================================

  Future<void> _deleteBooking(String id, String ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text('Are you sure you want to delete booking "$ref"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final res = await http.delete(Uri.parse('http://localhost:5000/api/admin/bookings/$id'));
        if (res.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking $ref deleted successfully!')),
            );
          }
          _loadAllAdminData();
        }
      } catch (e) {
        debugPrint('Delete booking error: $e');
      }
    }
  }

  void _showBookingFormDialog({Map<String, dynamic>? existingBooking}) {
    final isEditing = existingBooking != null;
    final nameCtrl = TextEditingController(text: existingBooking?['customerName'] ?? '');
    final emailCtrl = TextEditingController(text: existingBooking?['customerEmail'] ?? '');
    final phoneCtrl = TextEditingController(text: existingBooking?['customerPhone'] ?? '');
    final pkgCtrl = TextEditingController(text: existingBooking?['packageName'] ?? '');
    final dateCtrl = TextEditingController(text: existingBooking?['travelDate'] ?? '15 Oct 2026');
    final categoryCtrl = TextEditingController(text: existingBooking?['category'] ?? 'Standard');
    final amountCtrl = TextEditingController(text: (existingBooking?['amount'] ?? 25000).toString());
    final utrCtrl = TextEditingController(text: existingBooking?['utrNumber'] ?? '');
    String status = existingBooking?['paymentStatus'] ?? 'CONFIRMED';
    final id = existingBooking?['_id'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? '✏️ Edit Booking Details' : '➕ Create New Booking'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Customer Email', prefixIcon: Icon(Icons.email)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Customer Phone', prefixIcon: Icon(Icons.phone)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pkgCtrl,
                    decoration: const InputDecoration(labelText: 'Tour Package Name', prefixIcon: Icon(Icons.card_travel)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateCtrl,
                          decoration: const InputDecoration(labelText: 'Travel Date', prefixIcon: Icon(Icons.calendar_month)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: categoryCtrl,
                          decoration: const InputDecoration(labelText: 'Category (Economy/Standard/Luxury)', prefixIcon: Icon(Icons.category)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.payments)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: utrCtrl,
                          decoration: const InputDecoration(labelText: 'UTR / Payment Ref', prefixIcon: Icon(Icons.receipt)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Payment Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: status,
                          isExpanded: true,
                          items: ['CONFIRMED', 'PENDING', 'CANCELLED']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => status = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || pkgCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Package Name are required!')),
                  );
                  return;
                }

                final payload = {
                  'customerName': nameCtrl.text.trim(),
                  'customerEmail': emailCtrl.text.trim(),
                  'customerPhone': phoneCtrl.text.trim(),
                  'packageName': pkgCtrl.text.trim(),
                  'travelDate': dateCtrl.text.trim(),
                  'category': categoryCtrl.text.trim(),
                  'amount': int.tryParse(amountCtrl.text.trim()) ?? 25000,
                  'utrNumber': utrCtrl.text.trim(),
                  'paymentStatus': status,
                };

                try {
                  final res = isEditing
                      ? await http.put(
                          Uri.parse('http://localhost:5000/api/admin/bookings/$id'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(payload),
                        )
                      : await http.post(
                          Uri.parse('http://localhost:5000/api/admin/bookings'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode(payload),
                        );

                  if (res.statusCode == 200 || res.statusCode == 201) {
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Booking updated successfully!' : 'Booking created successfully!')),
                      );
                    }
                    _loadAllAdminData();
                  }
                } catch (e) {
                  debugPrint('Save booking error: $e');
                }
              },
              child: Text(isEditing ? 'Update Booking' : 'Create Booking'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOCATION CRUD OPERATIONS
  // ==========================================

  void _showAddLocationDialog() {
    final nameCtrl = TextEditingController();
    final stateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📍 Add New Destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'City / Location Name', prefixIcon: Icon(Icons.location_city)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stateCtrl,
              decoration: const InputDecoration(labelText: 'State / Region', prefixIcon: Icon(Icons.map)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                final res = await http.post(
                  Uri.parse('http://localhost:5000/api/admin/locations'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'name': nameCtrl.text.trim(),
                    'state': stateCtrl.text.trim(),
                  }),
                );
                if (res.statusCode == 201) {
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location added!')),
                    );
                  }
                  _loadAllAdminData();
                }
              } catch (e) {
                debugPrint('Add location error: $e');
              }
            },
            child: const Text('Add Location'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocation(String id, String name) async {
    try {
      final res = await http.delete(Uri.parse('http://localhost:5000/api/admin/locations/$id'));
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location "$name" deleted!')),
          );
        }
        _loadAllAdminData();
      }
    } catch (e) {
      debugPrint('Delete location error: $e');
    }
  }

  // ==========================================
  // UI BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: 28),
            SizedBox(width: 10),
            Text('TravelMaster Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllAdminData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Bookings & Stats'),
            Tab(icon: Icon(Icons.card_travel_rounded), text: 'Packages (CRUD)'),
            Tab(icon: Icon(Icons.place_rounded), text: 'Destinations'),
          ],
        ),
      ),
      body: LiveBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsAndOverviewTab(colors),
                  _buildPackagesTab(colors),
                  _buildLocationsTab(colors),
                ],
              ),
      ),
    );
  }

  // TAB 1: OVERVIEW & BOOKINGS
  Widget _buildBookingsAndOverviewTab(ColorScheme colors) {
    final filteredBookings = _bookings.where((b) {
      if (_searchBookingQuery.isEmpty) return true;
      final q = _searchBookingQuery.toLowerCase();
      final name = (b['customerName'] ?? '').toString().toLowerCase();
      final ref = (b['bookingReference'] ?? '').toString().toLowerCase();
      final pkg = (b['packageName'] ?? '').toString().toLowerCase();
      return name.contains(q) || ref.contains(q) || pkg.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STAT CARDS ROW
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(
                colors,
                title: 'Total Revenue',
                value: '₹${_totalRevenue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                icon: Icons.account_balance_wallet_rounded,
                color: colors.brightness == Brightness.dark ? const Color(0xFF10B981) : Colors.green.shade700,
              ),
              _buildStatCard(
                colors,
                title: 'Total Bookings',
                value: '$_totalBookings',
                icon: Icons.confirmation_number_rounded,
                color: Colors.blue,
              ),
              _buildStatCard(
                colors,
                title: 'Active Packages',
                value: '$_totalPackagesCount',
                icon: Icons.tour_rounded,
                color: Colors.purple,
              ),
              _buildStatCard(
                colors,
                title: 'Destinations',
                value: '$_totalLocationsCount',
                icon: Icons.map_rounded,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // BOOKINGS SECTION HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📋 Customer Bookings Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _showBookingFormDialog(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Booking'),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search customer name, ref...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _searchBookingQuery = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (filteredBookings.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded, size: 48, color: colors.onSurfaceVariant),
                      const SizedBox(height: 12),
                      const Text('No bookings found matching search criteria.'),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final b = filteredBookings[index];
                final status = b['paymentStatus'] ?? 'CONFIRMED';
                final isConfirmed = status == 'CONFIRMED';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                b['bookingReference'] ?? 'BK-TM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                b['packageName'] ?? 'Tour Package',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isConfirmed ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isConfirmed ? Colors.green : Colors.orange,
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isConfirmed ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('👤 Customer: ${b['customerName'] ?? 'Valued Traveler'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('📧 Email: ${b['customerEmail'] ?? 'N/A'}'),
                                  Text('📞 Phone: ${b['customerPhone'] ?? 'N/A'}'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('📅 Travel Date: ${b['travelDate'] ?? 'N/A'}'),
                                  const SizedBox(height: 4),
                                  Row(
                                      children: [
                                        const Text('🏷️ Category: '),
                                        if ((b['category'] == 'Customized') || ((b['customDetails'] ?? '').toString().trim().isNotEmpty) || (b['selectedTransport'] is Map && (b['selectedTransport'] as Map).isNotEmpty) || (b['selectedHotel'] is Map && (b['selectedHotel'] as Map).isNotEmpty))
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.purple.shade700, borderRadius: BorderRadius.circular(6)),
                                            child: const Text('✨ Customized Plan', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          )
                                        else
                                          Text(b['category'] ?? 'Standard', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  Text('💳 Amount Paid: ₹${b['amount'] ?? 25000}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('UTR: ${b['utrNumber'] ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.receipt_long_rounded, size: 16),
                                      label: const Text('View Details & Aadhar', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colors.primary,
                                        foregroundColor: colors.onPrimary,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      onPressed: () => _showFullBookingDetailsModal(b),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filledTonal(
                                      tooltip: 'Change Status',
                                      icon: const Icon(Icons.edit_note_rounded),
                                      onPressed: () => _showBookingFormDialog(existingBooking: b),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filledTonal(
                                      tooltip: 'Delete Booking',
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                      onPressed: () => _deleteBooking(b['_id'], b['bookingReference'] ?? 'BK'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _downloadAadharCard(String? fileUrl, String travelerName, {String? fileName}) {
    final name = (fileName != null && fileName.trim().isNotEmpty) ? fileName : '${travelerName.replaceAll(" ", "_")}_Aadhar.jpg';
    final url = (fileUrl != null && fileUrl.trim().isNotEmpty)
        ? fileUrl.trim()
        : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80';

    try {
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = name;
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
    } catch (_) {
      html.window.open(url, '_blank');
    }
  }

  void _viewAadharDocument(String? fileUrl, String travelerName) {
    final url = (fileUrl != null && fileUrl.trim().isNotEmpty)
        ? fileUrl.trim()
        : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.badge_rounded, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(child: Text('Identity Proof: $travelerName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (url.contains('application/pdf') || url.endsWith('.pdf'))
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 64),
                        const SizedBox(height: 12),
                        const Text('PDF Aadhar Document Uploaded', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open PDF in Browser'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          onPressed: () => html.window.open(url, '_blank'),
                        ),
                      ],
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.badge_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Document Photo Preview'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download Document'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
            onPressed: () => _downloadAadharCard(url, travelerName),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFullBookingDetailsModal(Map<String, dynamic> b) {
    final customDetails = (b['customDetails'] ?? '').toString();
    final startingCity = (b['startingCity'] ?? '').toString();
    final List<dynamic> travelers = (b['travelers'] is List) ? b['travelers'] : [];
    final selectedTrainCat = (b['selectedTrainCategory'] ?? '').toString();
    final connectingTrain = b['connectingTrain'] is Map ? b['connectingTrain'] as Map : null;
    final selTransport = b['selectedTransport'] is Map ? b['selectedTransport'] as Map : null;
    final selHotel = b['selectedHotel'] is Map ? b['selectedHotel'] as Map : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Booking Details: ${b['bookingReference'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section 1: Customer & Package Summary
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Package: ${b['packageName'] ?? 'N/A'} ' + (((b['category'] == 'Customized') || ((b['customDetails'] ?? '').toString().trim().isNotEmpty) || (b['selectedTransport'] is Map && (b['selectedTransport'] as Map).isNotEmpty) || (b['selectedHotel'] is Map && (b['selectedHotel'] as Map).isNotEmpty)) ? '(✨ Customized Plan)' : '(${b['category'] ?? 'Standard'})'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text('Customer Name: ${b['customerName'] ?? 'Valued Traveler'}'),
                          Text('Email: ${b['customerEmail'] ?? 'N/A'}'),
                          Text('Phone: ${b['customerPhone'] ?? 'N/A'}'),
                          Text('Travel Date: ${b['travelDate'] ?? 'N/A'}'),
                          if (startingCity.isNotEmpty)
                            Text('Trip Starting Hub: $startingCity', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                          const SizedBox(height: 4),
                          Text('Amount Paid: ₹${b['amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('Transaction ID: ${b['transactionId'] ?? 'N/A'} | UTR: ${b['utrNumber'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Section 2: Transport & Travel Selections
                  Text('🚆✈️ Transport & Travel Selections:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),

                  // Category-level transport
                  if (selectedTrainCat.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_num_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Package Category Transport:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                                Text(selectedTrainCat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Connecting train
                  if (connectingTrain != null && (connectingTrain['trainNumber'] ?? '').toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.train, color: Colors.blue, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(
                              'Connecting Train: ${connectingTrain['trainNumber']} – ${connectingTrain['trainName']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                            )),
                          ]),
                          const SizedBox(height: 4),
                          Text('From: ${connectingTrain['fromJunction']}  →  To: ${connectingTrain['toJunction']}'),
                          Text('Departs: ${connectingTrain['departureTime']}  |  Arrives: ${connectingTrain['arrivalTime']}'),
                          if ((connectingTrain['price'] ?? 0) > 0)
                            Text('Fare: ₹${connectingTrain['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),

                  // Custom transport (from customize sheet)
                  if (selTransport != null && (selTransport['name'] ?? '').toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ((selTransport['mode'] ?? '') == 'flight' ? Colors.purple : Colors.teal).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ((selTransport['mode'] ?? '') == 'flight' ? Colors.purple : Colors.teal).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon((selTransport['mode'] ?? '') == 'flight' ? Icons.flight_rounded : Icons.train_rounded,
                                color: (selTransport['mode'] ?? '') == 'flight' ? Colors.purple : Colors.teal, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(
                              'Customize ${(selTransport['mode'] ?? '') == 'flight' ? "Flight" : "Train"}: ${selTransport['name']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                                  color: (selTransport['mode'] ?? '') == 'flight' ? Colors.purple : Colors.teal),
                            )),
                          ]),
                          const SizedBox(height: 4),
                          Text('Class: ${selTransport['classType'] ?? 'N/A'}'),
                          if ((selTransport['departure'] ?? '').toString().isNotEmpty)
                            Text('Departs: ${selTransport['departure']}  |  Arrives: ${selTransport['arrival']}'),
                          if ((selTransport['price'] ?? 0) > 0)
                            Text('Cost: ₹${selTransport['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),

                  if (selectedTrainCat.isEmpty && connectingTrain == null && (selTransport == null || (selTransport['name'] ?? '').isEmpty))
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Standard package transport (no specific transport customization recorded)', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),
                  const SizedBox(height: 14),

                  // Section 3: Hotel / Resort Selection
                  Text('🏨 Hotel / Resort Selection:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),

                  if (selHotel != null && (selHotel['name'] ?? '').toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ((selHotel['type'] ?? '') == 'Resort' ? Colors.pink : Colors.indigo).withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ((selHotel['type'] ?? '') == 'Resort' ? Colors.pink : Colors.indigo).withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon((selHotel['type'] ?? '') == 'Resort' ? Icons.beach_access_rounded : Icons.hotel_rounded,
                                color: (selHotel['type'] ?? '') == 'Resort' ? Colors.pink : Colors.indigo, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              '${selHotel['type'] ?? 'Hotel'}: ${selHotel['name']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                                  color: (selHotel['type'] ?? '') == 'Resort' ? Colors.pink.shade800 : Colors.indigo),
                            )),
                          ]),
                          const SizedBox(height: 6),
                          if ((selHotel['rating'] ?? '').toString().isNotEmpty)
                            Text('⭐ Rating: ${selHotel['rating']}'),
                          if ((selHotel['contact'] ?? '').toString().isNotEmpty)
                            Text('📞 Contact: ${selHotel['contact']}'),
                          if ((selHotel['price'] ?? 0) > 0)
                            Text('Cost: ₹${selHotel['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        customDetails.contains('Hotel') || customDetails.contains('Resort')
                            ? customDetails
                            : 'Standard package accommodation (no hotel/resort customization recorded)',
                        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Section 4: Full Customized Plan Summary
                  if (customDetails.isNotEmpty) ...[
                    Text('🛠️ Full Customized Plan Summary:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Text(customDetails, style: const TextStyle(fontSize: 13, height: 1.4)),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Section 5: Registered Travelers & Aadhar Download
                  Text('👤 Registered Travelers & Identity Verification:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),
                  if (travelers.isEmpty)
                    const Text('No individual traveler records registered.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                  else
                    Column(
                      children: travelers.map((t) {
                        final tName = t['name'] ?? 'Traveler';
                        final tAge = t['age'] ?? 'N/A';
                        final tGender = t['gender'] ?? 'N/A';
                        final tAadhar = t['aadharNo'] ?? 'N/A';
                        final fileUrl = t['aadharFile'] ?? '';

                        final fName = t['aadharFileName'] ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: Text(tName.isNotEmpty ? tName[0].toUpperCase() : 'T', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                            ),
                            title: Text('$tName ($tAge Y, $tGender)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Aadhar No: ${tAadhar.toString().isEmpty ? 'N/A' : tAadhar}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.visibility_rounded, size: 15),
                                  label: const Text('View Doc', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  onPressed: () => _viewAadharDocument(fileUrl.toString(), tName.toString()),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.download_rounded, size: 15),
                                  label: const Text('Download', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  onPressed: () => _downloadAadharCard(fileUrl.toString(), tName.toString(), fileName: fName.toString()),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildStatCard(
    ColorScheme colors, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 2: PACKAGES CRUD
  Widget _buildPackagesTab(ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📦 Package Management (Full CRUD)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () => _showPackageFormDialog(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add New Package'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380,
              childAspectRatio: 0.82,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _packages.length,
            itemBuilder: (context, index) {
              final pkg = _packages[index];
              final id = pkg['_id'] ?? '';
              final title = pkg['title'] ?? 'Package Title';
              final loc = pkg['location'] ?? 'Location';
              final price = pkg['price'] ?? 'Rs. 25,000';
              final img = pkg['image'] ?? 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944';

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AutoSlideshowImage(
                            images: (pkg['images'] is List && (pkg['images'] as List).isNotEmpty)
                                ? List<String>.from(pkg['images'])
                                : [img],
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    pkg['rating'] ?? '4.9',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 15, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(loc, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(price, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(pkg['duration'] ?? '5 Days', style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showPackageFormDialog(existingPkg: pkg),
                                    icon: const Icon(Icons.edit_rounded, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.15)),
                                  onPressed: () => _deletePackage(id, title),
                                  icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
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
            },
          ),
        ],
      ),
    );
  }

  // TAB 3: DESTINATIONS / LOCATIONS
  Widget _buildLocationsTab(ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📍 Destinations & Locations Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: _showAddLocationDialog,
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Add New Destination'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _locations.map((loc) {
              final id = loc['_id'] ?? '';
              final name = loc['name'] ?? 'City';
              final state = loc['state'] ?? '';

              return Chip(
                avatar: const Icon(Icons.place_rounded, size: 18),
                label: Text('$name${state.isNotEmpty ? ", $state" : ""}'),
                onDeleted: () => _deleteLocation(id, name),
                deleteIconColor: Colors.red,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
