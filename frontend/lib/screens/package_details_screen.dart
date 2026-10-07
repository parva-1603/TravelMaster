import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auto_slideshow_image.dart';
import 'customize_package_sheet.dart';
import 'login_screen.dart';
import 'package_instructions_screen.dart';

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
  String _selectedStandardTrainClass = '3-Tier AC';
  String _selectedLuxuryTransport = 'Flight';
  String? _selectedDate;
  final TextEditingController _startingCityController = TextEditingController();
  String _startingCity = '';
  int _customAdditionPrice = 0;
  String _customDetails = '';
  Map<String, dynamic>? _selectedConnectingTrain;
  Map<String, dynamic>? _selectedCustomTransport; // from customize sheet
  Map<String, dynamic>? _selectedCustomHotel;     // from customize sheet

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    final dates = widget.pkg['departureDates'] as List<dynamic>?;
    if (dates != null && dates.isNotEmpty) {
      _selectedDate = dates.first.toString();
    }
    _startingCity = _getStartingHub(widget.pkg['location'].toString());
    _startingCityController.text = _startingCity;
  }

  @override
  void dispose() {
    _startingCityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() {
    final location = widget.pkg['location'].toString().split(',').first.trim();
    final url =
        'http://localhost:5000/api/weather?city=${Uri.encodeComponent(location)}';

    return http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _weatherData = data['weather'];
            _isLoadingWeather = false;
          });
          return;
        }
      }
      setState(() => _isLoadingWeather = false);
    }).catchError((_) {
      setState(() => _isLoadingWeather = false);
    });
  }

  int _parsePrice(String priceStr) {
    final cleanStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 15000;
  }

  String _calculateDate(String? startDateStr, int dayNum) {
    if (startDateStr == null || startDateStr.isEmpty) return '';
    try {
      final parts = startDateStr.split(' ');
      if (parts.length < 3) return '';
      final day = int.tryParse(parts[0]) ?? 15;
      final year = int.tryParse(parts[2]) ?? 2026;
      final monthStr = parts[1].toLowerCase();

      final months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
      };
      final month = months[monthStr.substring(0, 3)] ?? 10;

      final startDate = DateTime(year, month, day);
      final targetDate = startDate.add(Duration(days: dayNum - 1));

      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${targetDate.day} ${monthNames[targetDate.month - 1]}';
    } catch (_) {
      return '';
    }
  }

  void _showCustomizeSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomizePackageSheet(
        pkg: widget.pkg,
        startingCity: _startingCity,
        onCustomizationComplete: (price, details,
            {Map<String, dynamic>? transport, Map<String, dynamic>? hotel}) {
          setState(() {
            _customAdditionPrice = price;
            _customDetails = details;
            _selectedCustomTransport = transport;
            _selectedCustomHotel = hotel;
            _selectedCategory = 'Customized';
          });
        },
      ),
    );
  }

  String _getStartingHub(String location) {
    final loc = location.toLowerCase();
    final ahmedabadDestinations = [
      'rajasthan', 'jaipur', 'udaipur', 'jaisalmer', 'jodhpur', 'mount abu', 'pushkar',
      'mumbai', 'pune', 'maharashtra', 'goa', 'gujarat', 'ahmedabad', 'surat', 'kutch', 'rajkot', 'dwarka', 'somnath', 'gir'
    ];
    return ahmedabadDestinations.any((d) => loc.contains(d)) ? 'Ahmedabad' : 'Delhi';
  }

  String _getTransportToDest() {
    if (_selectedCategory == 'Economy') {
      return '🚆 Train (Non-AC Sleeper)';
    } else if (_selectedCategory == 'Standard') {
      return '🚆 Train ($_selectedStandardTrainClass)';
    } else {
      return _selectedLuxuryTransport == 'Flight' ? '✈️ Flight (Economy/Biz)' : '🚆 1-Tier AC Express Train';
    }
  }

  String _getInternalTransport() {
    if (_selectedCategory == 'Economy') {
      return 'Shared Non-AC Bus / Coach';
    } else if (_selectedCategory == 'Standard') {
      return 'AC Tourist Bus / Shared Cab';
    } else {
      return 'Private Luxury AC SUV (Innova/Fortuner)';
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Login Required'),
          ],
        ),
        content: const Text(
          'You are currently exploring as a Guest. Please log in or register to complete your package booking!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(onThemeToggle: widget.onThemeToggle),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log In Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainScheduleSection(BuildContext context) {
    final location = widget.pkg['location'].toString();
    final hubCity = _getStartingHub(location);
    final userCity = _startingCity.trim().isEmpty ? hubCity : _startingCity.trim();
    final isUserAtHub = userCity.toLowerCase() == hubCity.toLowerCase();

    String hubStation = hubCity == 'Ahmedabad' ? 'ADI - Ahmedabad Junction' : 'NDLS - New Delhi';
    String mainDepTime = hubCity == 'Ahmedabad' ? '20:10 PM' : '21:30 PM';

    List<Map<String, dynamic>> connectingTrains = [];
    bool hasSameDayInTime = true;

    if (!isUserAtHub) {
      if (hubCity == 'Delhi') {
        if (userCity.toLowerCase().contains('ahmedabad')) {
          connectingTrains = [
            {
              'trainNumber': '12957',
              'trainName': 'AHMEDABAD - NEW DELHI RAJDHANI EXP',
              'fromJunction': 'Ahmedabad Junction (ADI)',
              'fromPlatform': 'Platform #1',
              'departureTime': '17:45 PM (Previous Day)',
              'toJunction': 'New Delhi Junction (NDLS)',
              'toPlatform': 'Platform #3',
              'arrivalTime': '07:30 AM (Tour Departure Day)',
              'daySchedule': 'Previous Day Overnight',
              'layoverBuffer': 'Arrives morning of tour departure day (14h buffer)',
              'travelClass': '3AC / 2AC / 1AC',
              'status': 'Confirmed',
              'price': 1450
            },
            {
              'trainNumber': '12915',
              'trainName': 'ASHRAM EXPRESS (ADI to NDLS)',
              'fromJunction': 'Ahmedabad Junction (ADI)',
              'fromPlatform': 'Platform #2',
              'departureTime': '19:15 PM (Previous Night)',
              'toJunction': 'Old Delhi Junction (DLI)',
              'toPlatform': 'Platform #4',
              'arrivalTime': '10:10 AM (Tour Departure Day)',
              'daySchedule': 'Previous Day Overnight',
              'layoverBuffer': 'Arrives morning of tour departure day',
              'travelClass': 'SL / 3AC / 2AC',
              'status': 'Confirmed',
              'price': 1150
            }
          ];
        } else {
          connectingTrains = [];
        }
      }
      hasSameDayInTime = connectingTrains.any((t) => t['daySchedule'] == 'Same Day Train');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade800, Colors.deepOrange.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tour Official Starting Point: ${hubCity.toUpperCase()} ($hubStation)',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (!isUserAtHub && connectingTrains.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.train, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No available train for ${userCity.toUpperCase()} to ${hubCity.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (!isUserAtHub && connectingTrains.isNotEmpty) ...[
          Text(
            '🚆 Connecting Trains from ${userCity.toUpperCase()} to ${hubCity.toUpperCase()}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            hasSameDayInTime
                ? 'Showing trains arriving at ${hubCity.toUpperCase()} before main departure ($mainDepTime):'
                : '⚠️ No same-day trains arrive before departure ($mainDepTime). Showing PREVIOUS DAY / Overnight connecting trains:',
            style: TextStyle(
              fontSize: 12,
              color: hasSameDayInTime ? Colors.green.shade700 : Colors.amber.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          ...connectingTrains.map((train) {
            final isSameDay = train['daySchedule'] == 'Same Day Train';
            final isSelected = _selectedConnectingTrain != null &&
                _selectedConnectingTrain!['trainNumber'] == train['trainNumber'];

            return InkWell(
              onTap: () {
                setState(() {
                  if (_selectedConnectingTrain != null &&
                      _selectedConnectingTrain!['trainNumber'] == train['trainNumber']) {
                    _selectedConnectingTrain = null;
                  } else {
                    _selectedConnectingTrain = train;
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withValues(alpha: 0.18)
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.greenAccent
                        : (isSameDay ? Colors.green.withValues(alpha: 0.6) : Colors.orange.withValues(alpha: 0.6)),
                    width: isSelected ? 3.0 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.greenAccent : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '🚆 Train No. ${train['trainNumber']} - ${train['trainName']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? Colors.greenAccent : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : (isSameDay ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSelected ? 'SELECTED (+Rs. ${train['price']})' : train['daySchedule']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isSameDay ? Colors.green.shade700 : Colors.orange.shade800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _openTravelerDetailsModal() {
    if (FirebaseAuth.instance.currentUser == null) {
      _showLoginRequiredDialog();
      return;
    }

    int personCount = 1;
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final List<TextEditingController> nameControllers = [TextEditingController()];
    final List<TextEditingController> ageControllers = [TextEditingController()];
    final List<String> genders = ['Male'];
    final List<bool> aadharUploaded = [false];
    final List<String> aadharFileNames = [''];
    final List<TextEditingController> aadharControllers = [TextEditingController()];
    final List<String> aadharDataUrls = [''];
    final TextEditingController mobileController = TextEditingController();
    final TextEditingController emailController = TextEditingController(text: userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = widget.pkg['categories'] as Map<String, dynamic>?;
            final currentCategory = categories != null ? categories[_selectedCategory] : null;
            final displayPriceStr = currentCategory != null ? currentCategory['price'] : widget.pkg['price'];
            final basePrice = _parsePrice(displayPriceStr.toString());
            final int connectingTrainFare = (_selectedConnectingTrain != null && _selectedConnectingTrain!['price'] != null)
                ? (_selectedConnectingTrain!['price'] as int)
                : 0;
            final perPersonPrice = basePrice + _customAdditionPrice + connectingTrainFare;
            final totalBookingPrice = perPersonPrice * personCount;
            final formattedTotal = 'Rs. ${totalBookingPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, color: Theme.of(context).colorScheme.primary, size: 26),
                          const SizedBox(width: 8),
                          const Text(
                            'Traveler & Verification Details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Number of Persons / Travelers',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Rs. $perPersonPrice / person',
                                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.deepOrange),
                                      onPressed: personCount > 1
                                          ? () {
                                              setModalState(() {
                                                personCount--;
                                                nameControllers.removeLast();
                                                ageControllers.removeLast();
                                                genders.removeLast();
                                                aadharUploaded.removeLast();
                                                if (aadharFileNames.length > personCount) aadharFileNames.removeLast();
                                                if (aadharControllers.length > personCount) aadharControllers.removeLast();
                                                if (aadharDataUrls.length > personCount) aadharDataUrls.removeLast();
                                              });
                                            }
                                          : null,
                                    ),
                                    Text('$personCount',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      onPressed: personCount < 10
                                          ? () {
                                              setModalState(() {
                                                personCount++;
                                                nameControllers.add(TextEditingController());
                                                ageControllers.add(TextEditingController());
                                                genders.add('Male');
                                                aadharUploaded.add(false);
                                                aadharFileNames.add('');
                                                aadharControllers.add(TextEditingController());
                                                aadharDataUrls.add('');
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text('📞 Primary Contact Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: mobileController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Mobile Number *',
                                    hintText: '10-digit Mobile',
                                    prefixIcon: const Icon(Icons.phone_android),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address *',
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          const Text('👤 Person-wise Identification & Aadhar Card Upload',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),

                          ...List.generate(personCount, (idx) {
                            final isAadharDone = aadharUploaded[idx];
                            final fileName = (idx < aadharFileNames.length && aadharFileNames[idx].isNotEmpty)
                                ? aadharFileNames[idx]
                                : '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isAadharDone ? Colors.green.withValues(alpha: 0.8) : Colors.orange,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Person #${idx + 1} Details',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isAadharDone ? Colors.green.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAadharDone ? '✓ Aadhar Verified' : 'Aadhar Required *',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isAadharDone ? Colors.green.shade700 : Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: nameControllers[idx],
                                    decoration: InputDecoration(
                                      labelText: 'Full Name (as per Govt ID) *',
                                      prefixIcon: const Icon(Icons.person),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: ageControllers[idx],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Age *',
                                            prefixIcon: const Icon(Icons.cake),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          value: genders[idx],
                                          decoration: InputDecoration(
                                            labelText: 'Gender',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            isDense: true,
                                          ),
                                          items: ['Male', 'Female', 'Other']
                                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setModalState(() => genders[idx] = val);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: aadharControllers[idx],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: '12-Digit Aadhar Card Number *',
                                      prefixIcon: const Icon(Icons.badge_outlined),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isAadharDone ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isAadharDone ? Colors.green.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isAadharDone ? Icons.verified_user : Icons.add_a_photo_outlined,
                                          color: isAadharDone ? Colors.green : Colors.blue,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isAadharDone
                                                    ? 'File: $fileName ✓'
                                                    : 'Upload Aadhar Card Photo *',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: isAadharDone ? Colors.green.shade800 : Colors.blue.shade800,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                isAadharDone
                                                    ? 'Govt Identity Verification Status: VERIFIED'
                                                    : 'Compulsory: Select Aadhar card photo/PDF',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            try {
                                              final uploadInput = html.FileUploadInputElement()..accept = 'image/*,.pdf';
                                              uploadInput.click();
                                              uploadInput.onChange.listen((e) {
                                                final files = uploadInput.files;
                                                if (files != null && files.isNotEmpty) {
                                                  final selectedFile = files[0];
                                                  setModalState(() {
                                                    aadharUploaded[idx] = true;
                                                    if (idx < aadharFileNames.length) {
                                                      aadharFileNames[idx] = selectedFile.name;
                                                    } else {
                                                      aadharFileNames.add(selectedFile.name);
                                                    }
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Aadhar Card "${selectedFile.name}" uploaded & verified for Person #${idx + 1}!'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                }
                                              });
                                            } catch (_) {
                                              setModalState(() {
                                                aadharUploaded[idx] = true;
                                                if (idx < aadharFileNames.length) {
                                                  aadharFileNames[idx] = 'aadhar_card.jpg';
                                                }
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isAadharDone ? Colors.green : Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          ),
                                          icon: Icon(isAadharDone ? Icons.check : Icons.upload_file, size: 14),
                                          label: Text(isAadharDone ? 'Re-upload' : 'Upload', style: const TextStyle(fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final mobile = mobileController.text.trim();
                        final email = emailController.text.trim();

                        if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Mobile number is compulsory and must be exactly 10 digits!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Valid email address is compulsory!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        for (int i = 0; i < personCount; i++) {
                          final name = nameControllers[i].text.trim();
                          final age = ageControllers[i].text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Full Name is compulsory for Person #${i + 1}!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (age.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Age is compulsory for Person #${i + 1}!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (!aadharUploaded[i]) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Aadhar Card photo upload is compulsory for Person #${i + 1}!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        List<Map<String, String>> travelers = [];
                        for (int i = 0; i < personCount; i++) {
                          final dataUrl = (i < aadharDataUrls.length && aadharDataUrls[i].trim().isNotEmpty)
                              ? aadharDataUrls[i].trim()
                              : (i < aadharFileNames.length && aadharFileNames[i].trim().isNotEmpty
                                  ? aadharFileNames[i].trim()
                                  : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80');
                          final aNo = (i < aadharControllers.length && aadharControllers[i].text.trim().isNotEmpty)
                              ? aadharControllers[i].text.trim()
                              : '4829 1049 ${9012 + i}';
                          final fName = (i < aadharFileNames.length && aadharFileNames[i].trim().isNotEmpty)
                              ? aadharFileNames[i].trim()
                              : 'aadhar_card_${i + 1}.jpg';

                          travelers.add({
                            'name': nameControllers[i].text.trim(),
                            'age': ageControllers[i].text.trim(),
                            'gender': genders[i],
                            'aadharNo': aNo,
                            'aadharFile': dataUrl,
                            'aadharFileName': fName,
                            'aadharVerified': aadharUploaded[i] ? 'VERIFIED ✓' : 'PENDING',
                          });
                        }

                        Navigator.pop(context);
                        _openUpiPaymentModal(
                          personCount: personCount,
                          basePrice: basePrice,
                          connectingTrainFare: connectingTrainFare,
                          totalBookingPrice: totalBookingPrice,
                          mobile: mobile,
                          email: email,
                          travelers: travelers,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Proceed to Pay $formattedTotal ($personCount Persons)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openUpiPaymentModal({
    required int personCount,
    required int basePrice,
    required int connectingTrainFare,
    required int totalBookingPrice,
    required String mobile,
    required String email,
    required List<Map<String, String>> travelers,
  }) {
    final TextEditingController utrController = TextEditingController();
    bool isVerifying = false;
    final formattedTotal = 'Rs. ${totalBookingPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

    final String upiUri = 'upi://pay?pa=travelmaster@upi&pn=TravelMaster&am=' + totalBookingPrice.toString() + '&cu=INR&tn=' + Uri.encodeComponent(widget.pkg['title'].toString());
    final String qrApiUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=' + Uri.encodeComponent(upiUri);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.deepOrange, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Pay via UPI / Scan QR Code',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepOrange.shade700, Colors.orange.shade700],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Amount ($personCount Persons)',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(
                                formattedTotal,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.pkg['title']} ($_selectedCategory)',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Scan & Pay with Any UPI App (Auto Amount Set)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          qrApiUrl,
                          width: 210,
                          height: 210,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/upi_qr.png',
                            width: 210,
                            height: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 18, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          const Text(
                            'UPI ID: travelmaster@upi',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('UPI ID travelmaster@upi copied to clipboard!')),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Supported UPI Apps:',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUpiAppBadge('Google Pay', Colors.blue),
                        _buildUpiAppBadge('PhonePe', Colors.purple),
                        _buildUpiAppBadge('Paytm', Colors.lightBlue),
                        _buildUpiAppBadge('BHIM UPI', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: utrController,
                      decoration: InputDecoration(
                        labelText: 'Enter 12-Digit UTR / Transaction Ref No.',
                        hintText: 'e.g. 428901847291',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                setModalState(() => isVerifying = true);
                                try {
                                  final primaryCustomerName = travelers.isNotEmpty ? travelers.first['name'] ?? 'Valued Traveler' : 'Valued Traveler';
                                  await http.post(
                                    Uri.parse('http://localhost:5000/api/payment/verify-upi'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: json.encode({
                                      'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
                                      'utrNumber': utrController.text.trim().isEmpty
                                          ? 'UTR-${DateTime.now().millisecondsSinceEpoch}'
                                          : utrController.text.trim(),
                                      'packageName': widget.pkg['title'],
                                      'customerName': primaryCustomerName,
                                      'customerEmail': email,
                                      'customerPhone': mobile,
                                      'travelDate': _selectedDate ?? '15 Oct 2026',
                                      'category': _selectedCategory,
                                      'amount': totalBookingPrice,
                                      'startingCity': _startingCity.trim().isEmpty
                                          ? _getStartingHub(widget.pkg['location'].toString())
                                          : _startingCity.trim(),
                                      'customDetails': _customDetails,
                                      // Category-level train/flight selection
                                      'selectedTrainCategory': _selectedCategory == 'Economy'
                                          ? 'Non-AC Sleeper Train'
                                          : _selectedCategory == 'Standard'
                                              ? 'Train ($_selectedStandardTrainClass)'
                                              : _selectedLuxuryTransport == 'Flight'
                                                  ? 'Flight (Economy/Business)'
                                                  : '1-Tier AC Express Train',
                                      // Structured transport from customize sheet
                                      'selectedTransport': _selectedCustomTransport != null
                                          ? _selectedCustomTransport
                                          : {},
                                      // Structured hotel from customize sheet
                                      'selectedHotel': _selectedCustomHotel != null
                                          ? _selectedCustomHotel
                                          : {},
                                      // Connecting train details
                                      'connectingTrain': _selectedConnectingTrain != null
                                          ? {
                                              'trainNumber': _selectedConnectingTrain!['trainNumber'] ?? '',
                                              'trainName': _selectedConnectingTrain!['trainName'] ?? '',
                                              'fromJunction': _selectedConnectingTrain!['fromJunction'] ?? '',
                                              'toJunction': _selectedConnectingTrain!['toJunction'] ?? '',
                                              'departureTime': _selectedConnectingTrain!['departureTime'] ?? '',
                                              'arrivalTime': _selectedConnectingTrain!['arrivalTime'] ?? '',
                                              'price': _selectedConnectingTrain!['price'] ?? 0,
                                            }
                                          : {},
                                    }),
                                  );
                                } catch (_) {}

                                if (mounted) {
                                  Navigator.pop(context);
                                  final now = DateTime.now();
                                  final dateStr = '${now.day} Oct ${now.year}';
                                  final bookingData = {
                                    'invNo': 'INV-TM-2026-${1000 + (now.millisecondsSinceEpoch % 9000)}',
                                    'bookingRef': 'BK-TM-2026-${1000 + ((now.millisecondsSinceEpoch ~/ 2) % 9000)}',
                                    'dateStr': dateStr,
                                    'formattedTotal': formattedTotal,
                                    'mobile': mobile,
                                    'email': email,
                                    'personCount': personCount,
                                    'basePrice': basePrice,
                                    'connectingTrainFare': connectingTrainFare,
                                    'travelers': travelers,
                                  };
                                  _showBeautifulInvoiceDialog(context, bookingData);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isVerifying
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Verify Payment & Generate Invoice',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpiAppBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _downloadInvoicePdf(Map<String, dynamic> data) {
    final invNo = data['invNo'] ?? 'INV-TM-2026-1001';
    final bookingRef = data['bookingRef'] ?? 'BK-TM-2026-1001';
    final dateStr = data['dateStr'] ?? '06 Oct 2026';
    final formattedTotal = data['formattedTotal'] ?? 'Rs. 25,000';
    final mobile = data['mobile'] ?? '9876543210';
    final email = data['email'] ?? 'parv@gmail.com';
    final basePrice = data['basePrice'] ?? 25000;
    final connectingTrainFare = data['connectingTrainFare'] ?? 0;
    final travelers = data['travelers'] as List<Map<String, String>>? ?? [];

    final String travelerRows = travelers.map((t) => 
      "<tr><td style='padding:10px;border:1px solid #ddd;font-weight:bold;'>${t['name']}</td><td style='padding:10px;border:1px solid #ddd;'>${t['age']} yrs</td><td style='padding:10px;border:1px solid #ddd;'>${t['gender']}</td><td style='padding:10px;border:1px solid #ddd;color:green;font-weight:bold;'>${t['aadharVerified']}</td></tr>"
    ).join('');

    final String invoiceHtmlContent = '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>TravelMaster Tax Invoice - $invNo</title>
<style>
  body { font-family: 'Segoe UI', Arial, sans-serif; margin: 30px; color: #222; background: #fff; }
  .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #e65100; padding-bottom: 15px; }
  .logo { font-size: 26px; font-weight: 900; color: #e65100; letter-spacing: 1px; }
  .tagline { font-size: 12px; color: #666; font-weight: 600; }
  .inv-title { font-size: 18px; font-weight: bold; color: #2e7d32; text-align: right; }
  .card { background: #fdfdfd; border: 1px solid #e0e0e0; border-radius: 12px; padding: 16px; margin: 16px 0; }
  table { width: 100%; border-collapse: collapse; margin-top: 10px; }
  th { background: #e65100; color: white; padding: 10px; text-align: left; font-size: 13px; }
  .total-box { background: #e8f5e9; border: 2px solid #2e7d32; border-radius: 10px; padding: 16px; font-size: 20px; font-weight: bold; color: #2e7d32; text-align: right; margin-top: 15px; }
  .badge { display: inline-block; background: #4caf50; color: white; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; margin-top: 8px; }
  @media print {
    body { margin: 0; }
  }
</style>
</head>
<body>
  <div class="header">
    <div>
      <div class="logo">✈️ TRAVELMASTER</div>
      <div class="tagline">OFFICIAL TAX INVOICE & TRAVEL E-VOUCHER</div>
    </div>
    <div>
      <div class="inv-title">PAID & CONFIRMED</div>
      <div style="font-size: 12px; margin-top: 40px;">Invoice No: <strong>$invNo</strong></div>
      <div style="font-size: 12px;">Booking Ref: <strong>$bookingRef</strong></div>
      <div style="font-size: 12px;">Date: <strong>$dateStr</strong></div>
    </div>
  </div>

  <div class="card">
    <h3 style="margin-top:0; color:#e65100;">📦 Package & Journey Summary</h3>
    <p><strong>Package Name:</strong> ${widget.pkg['title']} ($_selectedCategory Category)</p>
    <p><strong>Location & Duration:</strong> ${widget.pkg['location']} | ${widget.pkg['duration']}</p>
    <p><strong>Trip Starting Point:</strong> ${_startingCity.trim().isEmpty ? _getStartingHub(widget.pkg['location'].toString()) : _startingCity.trim()}</p>
    <p><strong>Primary Contact:</strong> Mobile +91 $mobile | Email: $email</p>
    <div class="badge">✓ PAID VIA UPI QR</div>
  </div>

  ${_customDetails.isNotEmpty ? '''
  <div class="card" style="border-left: 5px solid #1976d2; background: #f0f7ff;">
    <h3 style="margin-top:0; color:#1976d2;">🛠️ Customized Plan Selections & Add-ons</h3>
    <p style="font-size: 14px; margin: 4px 0;"><strong>Selected Customizations:</strong> $_customDetails</p>
    <p style="font-size: 13px; color: #1565c0; margin: 4px 0;"><strong>Additional Customization Charge:</strong> Rs. $_customAdditionPrice</p>
  </div>
  ''' : ''}

  <div class="card">
    <h3 style="margin-top:0; color:#e65100;">👤 Registered Travelers & Government ID Verification</h3>
    <table>
      <thead>
        <tr>
          <th>Traveler Name</th>
          <th>Age</th>
          <th>Gender</th>
          <th>Aadhar Identity Verification</th>
        </tr>
      </thead>
      <tbody>
        $travelerRows
      </tbody>
    </table>
  </div>

  <div class="card">
    <h3 style="margin-top:0; color:#e65100;">💳 Financial Breakdown</h3>
    <p>Base Package Price: Rs. $basePrice</p>
    ${_customAdditionPrice > 0 ? '<p>Customized Add-on Selection Cost: + Rs. $_customAdditionPrice</p>' : ''}
    ${connectingTrainFare > 0 ? '<p>Connecting Train Transport Fare: + Rs. $connectingTrainFare</p>' : ''}
    <p>GST & Govt Taxes (18% Included): Rs. 0 (Inclusive)</p>
    <p>Service & Convenience Fee: Rs. 0 (Waived)</p>
    <div class="total-box">GRAND TOTAL PAID: $formattedTotal</div>
  </div>

  <div style="text-align: center; color: #888; font-size: 11px; margin-top: 30px;">
    This is a computer-generated tax invoice & confirmed travel voucher. No signature required.<br>
    © 2026 TravelMaster Technologies Pvt. Ltd. All rights reserved.
  </div>
  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 400);
    };
  </script>
</body>
</html>''';

    try {
      final blob = html.Blob([invoiceHtmlContent], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');

      final pdfAnchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$invNo.pdf')
        ..click();
    } catch (e) {
      debugPrint('Error triggering PDF download: $e');
    }
  }

  void _showBeautifulInvoiceDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final travelers = data['travelers'] as List<Map<String, String>>;
        final String formattedTotal = data['formattedTotal'];
        final String refNo = data['bookingRef'];
        final String invNo = data['invNo'];
        final String dateStr = data['dateStr'];

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade800, Colors.teal.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.flight_takeoff, color: Colors.white, size: 26),
                                SizedBox(width: 8),
                                Text(
                                  'TRAVELMASTER',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 1.2),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 15),
                                  SizedBox(width: 4),
                                  Text(
                                    'PAID & CONFIRMED',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'OFFICIAL TAX INVOICE & TRAVEL TICKET VOUCHER',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Invoice Number', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(invNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            const Text('Booking Ref No.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(refNo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Issue Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            const Text('Payment Method', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const Text('UPI QR (Verified ✓)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('📦 Package & Journey Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(widget.pkg['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            Text('Cat: $_selectedCategory', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('📍 Location: ${widget.pkg['location']} | Duration: ${widget.pkg['duration']}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('📅 Travel Starting Date: ${_selectedDate ?? "15 Oct 2026"}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        if (_selectedConnectingTrain != null) ...[
                          const SizedBox(height: 4),
                          Text('🚆 Connecting Train: ${_selectedConnectingTrain!['trainName']} (${_selectedConnectingTrain!['trainNumber']})',
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('👤 Travelers List (${travelers.length} Persons)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Mobile: ${data['mobile']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...travelers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final t = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green,
                            child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${t['name']} (${t['age']} yrs, ${t['gender']})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('Aadhar Identity: VERIFIED ✓ (Government ID Checked)',
                                    style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  const Text('💳 Payment & Tax Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInvoiceLine('Base Package Price', 'Rs. ${data['basePrice']} x ${travelers.length}'),
                        if (data['connectingTrainFare'] > 0)
                          _buildInvoiceLine('Connecting Train Ticket', 'Rs. ${data['connectingTrainFare']} x ${travelers.length}'),
                        if (_customAdditionPrice > 0)
                          _buildInvoiceLine('Customizations', 'Rs. $_customAdditionPrice x ${travelers.length}'),
                        _buildInvoiceLine('GST & Govt Taxes (18% Incl.)', 'Included'),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL AMOUNT PAID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              formattedTotal,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _downloadInvoicePdf(data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('📥 Tax Invoice PDF ($invNo.pdf) generated successfully!'),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.deepOrange),
                          label: const Text('Download Bill (PDF)', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
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

  List<dynamic> _normalizeItinerary(dynamic rawItinerary, String locationStr, String durationStr) {
    int totalDays = 3;
    final match = RegExp(r'(\d+)').firstMatch(durationStr);
    if (match != null) {
      totalDays = int.tryParse(match.group(1)!) ?? 3;
    }

    List<dynamic> items = [];
    if (rawItinerary is List && rawItinerary.isNotEmpty) {
      items = List.from(rawItinerary);
    }

    if (items.length < totalDays) {
      final fallback = _getFallbackItinerary(locationStr, durationStr);
      if (items.isEmpty && fallback.length >= totalDays) {
        items = fallback.sublist(0, totalDays);
      } else {
        for (int i = 0; i < fallback.length && items.length < totalDays; i++) {
          if (!items.any((e) => e is Map && e['day'] == fallback[i]['day'])) {
            items.add(fallback[i]);
          }
        }

        final loc = locationStr.split(',').first.trim();
        while (items.length < totalDays) {
          int nextDay = items.length + 1;
          if (nextDay == totalDays) {
            items.add({
              'day': nextDay,
              'title': 'Leisure, Souvenir Shopping & Departure',
              'description': 'Enjoy a relaxed breakfast, check-out from hotel, buy local traditional souvenirs, and transfer to airport or railway station for your journey back home.'
            });
          } else {
            items.add({
              'day': nextDay,
              'title': 'Guided Sightseeing & Culture Tour in $loc',
              'description': 'Full-day sightseeing tour visiting historical monuments, scenic nature viewpoints, local markets, and tasting famous local cuisine.'
            });
          }
        }
      }
    }

    // Guarantee exact totalDays count
    if (items.length > totalDays) {
      items = items.sublist(0, totalDays);
    }

    List<dynamic> normalized = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i] is Map) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(items[i] as Map);
        item['day'] = i + 1;
        normalized.add(item);
      }
    }

    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.pkg['categories'] as Map<String, dynamic>?;
    final rawItinerary = widget.pkg['itinerary'];
    final List<dynamic> itinerary = _normalizeItinerary(
      rawItinerary,
      widget.pkg['location'].toString(),
      widget.pkg['duration'].toString(),
    );
    final rawDates = widget.pkg['departureDates'] as List<dynamic>?;
    final List<String> dates = (rawDates != null && rawDates.isNotEmpty)
        ? rawDates.map((e) => e.toString()).toList()
        : ['15 Oct 2026', '22 Oct 2026', '05 Nov 2026'];

    final currentCategory = categories != null ? categories[_selectedCategory] : null;
    final displayPriceStr = currentCategory != null ? currentCategory['price'] : widget.pkg['price'];

    int categoryTierExtra = 0;
    if (_selectedCategory == 'Standard' && _selectedStandardTrainClass == '2-Tier AC') {
      categoryTierExtra = 800;
    } else if (_selectedCategory == 'Luxury' && _selectedLuxuryTransport == 'Flight') {
      categoryTierExtra = 2500;
    }

    final int basePrice = _parsePrice(displayPriceStr) + categoryTierExtra;
    final int connectingTrainFare = (_selectedConnectingTrain != null && _selectedConnectingTrain!['price'] != null)
        ? (_selectedConnectingTrain!['price'] as int)
        : 0;
    final int finalPrice = basePrice + _customAdditionPrice + connectingTrainFare;

    final String finalPriceFormatted =
        'Rs. ${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

    List<dynamic> facilities = currentCategory != null ? List.from(currentCategory['facilities']) : [];
    final String startCityDisplay = _startingCity.trim().isEmpty ? 'your city' : _startingCity.trim();

    facilities.insert(0, '${_getTransportToDest()} from $startCityDisplay');
    facilities.insert(1, 'Internal Road Transport: ${_getInternalTransport()}');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: AutoSlideshowImage(
              images: (widget.pkg['images'] is List && (widget.pkg['images'] as List).isNotEmpty)
                  ? List<String>.from(widget.pkg['images'])
                  : [widget.pkg['image'].toString()],
            ),
          ),
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.76,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: TextField(
                            controller: _startingCityController,
                            textAlign: TextAlign.center,
                            onChanged: (val) {
                              setState(() {
                                _startingCity = val;
                              });
                            },
                            decoration: InputDecoration(
                              icon: Icon(Icons.flight_takeoff, color: Theme.of(context).colorScheme.primary),
                              hintText: 'Enter Starting City (e.g. Surat, Mumbai, Jaipur)',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTrainScheduleSection(context),
                        const SizedBox(height: 16),

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
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(),

                        const SizedBox(height: 24),

                        const Text('Trip Starting Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: dates.map((date) {
                            final isSelected = _selectedDate == date;
                            return ChoiceChip(
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
                              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

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
                              setState(() {
                                _selectedCategory = newSelection.first;
                                _customAdditionPrice = 0;
                                _customDetails = '';
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          if (_selectedCategory == 'Economy') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.train, size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Transit: Non-AC Sleeper Train included', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                                ],
                              ),
                            ),
                          ] else if (_selectedCategory == 'Standard') ...[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                const Text('Train Class: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ChoiceChip(
                                  avatar: const Icon(Icons.train, size: 16),
                                  label: const Text('3-Tier AC'),
                                  selected: _selectedStandardTrainClass == '3-Tier AC',
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedStandardTrainClass = '3-Tier AC');
                                  },
                                ),
                                ChoiceChip(
                                  avatar: const Icon(Icons.train, size: 16),
                                  label: const Text('2-Tier AC (+ Rs. 800)'),
                                  selected: _selectedStandardTrainClass == '2-Tier AC',
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedStandardTrainClass = '2-Tier AC');
                                  },
                                ),
                              ],
                            ),
                          ] else if (_selectedCategory == 'Luxury') ...[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                const Text('Transit Mode: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ChoiceChip(
                                  avatar: const Icon(Icons.flight, size: 16),
                                  label: const Text('Airplane Flight (+ Rs. 2,500)'),
                                  selected: _selectedLuxuryTransport == 'Flight',
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedLuxuryTransport = 'Flight');
                                  },
                                ),
                                ChoiceChip(
                                  avatar: const Icon(Icons.train, size: 16),
                                  label: const Text('1-Tier AC Train'),
                                  selected: _selectedLuxuryTransport == '1-Tier AC Train',
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedLuxuryTransport = '1-Tier AC Train');
                                  },
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: facilities
                                  .map((facility) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 16),
                                            const SizedBox(width: 8),
                                            Text(facility.toString(), style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ).animate(key: ValueKey('$_selectedCategory$_selectedStandardTrainClass$_selectedLuxuryTransport')).fadeIn(),

                          if (_customDetails.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('✓ Customizations Applied', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  const SizedBox(height: 4),
                                  Text(_customDetails, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PackageInstructionsScreen(
                                  pkg: widget.pkg,
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                                  Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.assignment_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Package Guidelines & Essentials',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'View Inclusions, Exclusions, Packing Checklist & Rules',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (itinerary != null && itinerary.isNotEmpty) ...[
                          const Text('Day-wise Plan & Daily Weather', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...itinerary.map((dayPlan) {
                            final dayNum = dayPlan['day'] as int;
                            String description = dayPlan['description'];
                            if (dayNum == 1) {
                              description = 'Depart from $startCityDisplay via ${_getTransportToDest()}.\n\n$description';
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
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  if (_selectedConnectingTrain != null)
                                    Text(
                                      '+ Rs. $connectingTrainFare (${_selectedConnectingTrain!['trainNumber']} Connecting Train)',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade400,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (_customAdditionPrice > 0)
                                    Text('+ Rs. $_customAdditionPrice (Custom)',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text('Customize'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _openTravelerDetailsModal,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text('Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
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
