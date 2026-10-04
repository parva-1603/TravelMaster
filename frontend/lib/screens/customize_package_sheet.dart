import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CustomizePackageSheet extends StatefulWidget {
  final Map<String, dynamic> pkg;
  final String startingCity;
  final Function(
    int additionalPrice,
    String details,
    Map<String, dynamic>? selectedTransport,
    Map<String, dynamic>? selectedHotel,
  ) onCustomizationComplete;

  const CustomizePackageSheet({
    super.key,
    required this.pkg,
    required this.startingCity,
    required this.onCustomizationComplete,
  });

  @override
  State<CustomizePackageSheet> createState() => _CustomizePackageSheetState();
}

class _CustomizePackageSheetState extends State<CustomizePackageSheet> {
  String _transportMode = 'flight';
  List<dynamic> _transports = [];
  List<dynamic> _hotels = [];
  bool _isLoading = false;
  String _transportClass = 'Economy';
  String _accommodationType = 'Hotel';
  final TextEditingController _fromController = TextEditingController();

  Map<String, dynamic>? _selectedTransport;
  Map<String, dynamic>? _selectedHotel;

  @override
  void initState() {
    super.initState();
    _fromController.text =
        widget.startingCity.isEmpty ? 'Delhi' : widget.startingCity;
    _fetchOptions();
  }

  @override
  void dispose() {
    _fromController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    var target = urlString.trim();
    if (!target.startsWith('http://') &&
        !target.startsWith('https://') &&
        !target.startsWith('tel:')) {
      target = 'https://$target';
    }
    final uri = Uri.tryParse(target);
    if (uri != null) {
      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open link: $target')),
            );
          }
        }
      }
    }
  }

  Future<void> _fetchOptions() async {
    setState(() => _isLoading = true);
    try {
      final loc = widget.pkg['location'].toString().split(',').first.trim();
      final startCity =
          _fromController.text.isEmpty ? 'Delhi' : _fromController.text.trim();

      final tRes = await http.get(Uri.parse(
          'http://localhost:5000/api/transport?from=$startCity&to=$loc&mode=$_transportMode&classType=$_transportClass'));
      final hRes = await http.get(Uri.parse(
          'http://localhost:5000/api/hotels?location=$loc&type=$_accommodationType'));

      if (tRes.statusCode == 200 && hRes.statusCode == 200) {
        if (mounted) {
          setState(() {
            _transports = json.decode(tRes.body);
            _hotels = json.decode(hRes.body);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching customization options: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _applyCustomization() {
    int tPrice = _selectedTransport != null
        ? (_selectedTransport!['price'] as int? ?? 0)
        : 0;
    int hPrice =
        _selectedHotel != null ? (_selectedHotel!['price'] as int? ?? 0) : 0;

    String details = '';
    if (_selectedTransport != null && _selectedHotel != null) {
      details =
          'Transport: ${_selectedTransport!['name']} | Stay: ${_selectedHotel!['name']}';
    } else if (_selectedTransport != null) {
      details = 'Transport: ${_selectedTransport!['name']}';
    } else if (_selectedHotel != null) {
      details = 'Stay: ${_selectedHotel!['name']}';
    }

    widget.onCustomizationComplete(
      tPrice + hPrice,
      details,
      _selectedTransport,
      _selectedHotel,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = widget.pkg['location'].toString().split(',').first.trim();
    final startCity =
        _fromController.text.isEmpty ? 'Delhi' : _fromController.text.trim();

    final int tPrice = _selectedTransport != null
        ? (_selectedTransport!['price'] as int? ?? 0)
        : 0;
    final int hPrice =
        _selectedHotel != null ? (_selectedHotel!['price'] as int? ?? 0) : 0;
    final int totalCustomPrice = tPrice + hPrice;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top grab handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize & Direct Book',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Connect directly with official IRCTC, airline & hotel booking portals',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Route Selector
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fromController,
                          decoration: InputDecoration(
                            labelText: 'Leaving From',
                            hintText: 'e.g. Delhi, Mumbai',
                            prefixIcon: Icon(Icons.flight_takeoff_rounded,
                                color: theme.colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          onSubmitted: (_) {
                            _selectedTransport = null;
                            _fetchOptions();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: loc),
                          decoration: InputDecoration(
                            labelText: 'Going To',
                            prefixIcon: Icon(Icons.place_rounded,
                                color: theme.colorScheme.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ----------------------------------------------------
                  // 01 TRANSPORTATION
                  // ----------------------------------------------------
                  Row(
                    children: [
                      Text(
                        '01  Transportation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // Direct portal badge
                      if (_transportMode == 'train')
                        InkWell(
                          onTap: () =>
                              _openUrl('https://www.irctc.co.in/nget/train-search'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.train_rounded,
                                    size: 14, color: Color(0xFF1E3A8A)),
                                SizedBox(width: 4),
                                Text(
                                  'IRCTC Official ↗',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () => _openUrl(
                              'https://www.google.com/travel/flights?q=flights+from+${Uri.encodeComponent(startCity)}+to+${Uri.encodeComponent(loc)}'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flight_takeoff_rounded,
                                    size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Google Flights ↗',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Mode Radios & Class Dropdown
                  Row(
                    children: [
                      Radio<String>(
                        value: 'flight',
                        groupValue: _transportMode,
                        onChanged: (v) {
                          setState(() {
                            _transportMode = v!;
                            _transportClass = 'Economy';
                            _selectedTransport = null;
                          });
                          _fetchOptions();
                        },
                      ),
                      const Text('Flight',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Radio<String>(
                        value: 'train',
                        groupValue: _transportMode,
                        onChanged: (v) {
                          setState(() {
                            _transportMode = v!;
                            _transportClass = '3-Tier AC';
                            _selectedTransport = null;
                          });
                          _fetchOptions();
                        },
                      ),
                      const Text('Train (IRCTC)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      DropdownButtonHideUnderline(
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _transportClass,
                            items: (_transportMode == 'flight'
                                    ? ['Economy', 'Business', 'First Class']
                                    : ['Sleeper', '3-Tier AC', '1-Tier AC'])
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _transportClass = v);
                                _fetchOptions();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Transports List
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_transports.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 26, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(
                            'No direct schedules found for $startCity ➔ $loc.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(_transportMode == 'train'
                                ? 'Search all routes on official IRCTC portal'
                                : 'Search live flights on Google Flights'),
                            onPressed: () {
                              if (_transportMode == 'train') {
                                _openUrl(
                                    'https://www.irctc.co.in/nget/train-search');
                              } else {
                                _openUrl(
                                    'https://www.google.com/travel/flights?q=flights+from+${Uri.encodeComponent(startCity)}+to+${Uri.encodeComponent(loc)}');
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    ..._transports.map((t) {
                      final isSelected = _selectedTransport == t;
                      final bookingUrl = t['bookingUrl']?.toString() ??
                          (_transportMode == 'train'
                              ? 'https://www.irctc.co.in/nget/train-search'
                              : 'https://www.google.com/travel/flights');
                      final confirmTktUrl = t['confirmTktUrl']?.toString();
                      final portalUrl = t['portalUrl']?.toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.08)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() => _selectedTransport = t),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _transportMode == 'train'
                                          ? Icons.train_rounded
                                          : Icons.flight_rounded,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t['name'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Rs. ${t['price']}',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_rounded,
                                        size: 14,
                                        color:
                                            theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${t['departure']}  ➔  ${t['arrival']}',
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Selected',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                // Direct Booking Action Buttons
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (_transportMode == 'train') ...[
                                      FilledButton.tonalIcon(
                                        onPressed: () => _openUrl(bookingUrl),
                                        icon: const Icon(Icons.open_in_new,
                                            size: 13),
                                        label: const Text(
                                          'Book on IRCTC ↗',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      if (confirmTktUrl != null)
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _openUrl(confirmTktUrl),
                                          icon: const Icon(
                                              Icons.confirmation_number_outlined,
                                              size: 13),
                                          label: const Text(
                                            'Live Seats & PNR ↗',
                                            style: TextStyle(fontSize: 11.5),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                    ] else ...[
                                      FilledButton.tonalIcon(
                                        onPressed: () => _openUrl(bookingUrl),
                                        icon: const Icon(Icons.open_in_new,
                                            size: 13),
                                        label: const Text(
                                          'Book Flight ↗',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      if (portalUrl != null)
                                        OutlinedButton.icon(
                                          onPressed: () => _openUrl(portalUrl),
                                          icon: const Icon(Icons.flight_outlined,
                                              size: 13),
                                          label: Text(
                                            '${t['airline'] ?? 'Airline'} Portal ↗',
                                            style:
                                                const TextStyle(fontSize: 11.5),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // ----------------------------------------------------
                  // 02 STAY / HOTELS
                  // ----------------------------------------------------
                  Row(
                    children: [
                      Text(
                        '02  Stay & Hotels',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // Booking portal link
                      InkWell(
                        onTap: () => _openUrl(
                            'https://www.booking.com/searchresults.html?ss=${Uri.encodeComponent(loc)}'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003580).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF003580).withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.hotel_rounded,
                                  size: 14, color: Color(0xFF003580)),
                              SizedBox(width: 4),
                              Text(
                                'Booking.com ↗',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF003580),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Accommodation type selector
                  Row(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Hotel', label: Text('Hotels')),
                          ButtonSegment(value: 'Resort', label: Text('Resorts')),
                        ],
                        selected: {_accommodationType},
                        onSelectionChanged: (newVal) {
                          setState(() {
                            _accommodationType = newVal.first;
                            _selectedHotel = null;
                          });
                          _fetchOptions();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hotel list
                  if (_hotels.isEmpty && !_isLoading)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No hotel listings available.',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ..._hotels.map((h) {
                      final isSelected = _selectedHotel == h;
                      final bookingUrl = h['bookingUrl']?.toString() ??
                          'https://www.booking.com/searchresults.html?ss=${Uri.encodeComponent(h['name'].toString())}';
                      final websiteUrl = h['websiteUrl']?.toString();
                      final contact = h['contact']?.toString() ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.08)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _selectedHotel = h),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        h['image'].toString(),
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(
                                          color: Color(0xFF31594E),
                                          child: SizedBox(
                                              width: 84, height: 84),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  h['name'].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Rs. ${h['price']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: theme
                                                      .colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded,
                                                  size: 15,
                                                  color: Color(0xFFE49C39)),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${h['rating']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '•  ${h['portalName'] ?? 'Verified Stay'}',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rules: ${(h['rules'] as List<dynamic>? ?? []).join(', ')}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                // Direct Booking Links for this Hotel
                                Row(
                                  children: [
                                    FilledButton.tonalIcon(
                                      onPressed: () => _openUrl(bookingUrl),
                                      icon: const Icon(Icons.open_in_new,
                                          size: 13),
                                      label: const Text(
                                        'Book on Official Portal ↗',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (websiteUrl != null)
                                      OutlinedButton.icon(
                                        onPressed: () => _openUrl(websiteUrl),
                                        icon: const Icon(
                                            Icons.travel_explore_rounded,
                                            size: 13),
                                        label: const Text(
                                          'Google Hotels ↗',
                                          style: TextStyle(fontSize: 11.5),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    const Spacer(),
                                    if (contact.isNotEmpty)
                                      IconButton(
                                        tooltip: 'Call Hotel: $contact',
                                        icon: Icon(Icons.phone_outlined,
                                            size: 18,
                                            color: theme.colorScheme.primary),
                                        onPressed: () =>
                                            _openUrl('tel:$contact'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Bottom Bar & Action Summary
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Portal Access Chips
                if (_selectedTransport != null || _selectedHotel != null) ...[
                  Row(
                    children: [
                      const Text(
                        'Direct Portals:',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedTransport != null) ...[
                        ActionChip(
                          avatar: Icon(
                            _transportMode == 'train'
                                ? Icons.train_rounded
                                : Icons.flight_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            _transportMode == 'train'
                                ? 'IRCTC Portal ↗'
                                : 'Flight Portal ↗',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            final url = _selectedTransport!['bookingUrl']
                                    ?.toString() ??
                                (_transportMode == 'train'
                                    ? 'https://www.irctc.co.in/nget/train-search'
                                    : 'https://www.google.com/travel/flights');
                            _openUrl(url);
                          },
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (_selectedHotel != null)
                        ActionChip(
                          avatar: const Icon(Icons.hotel_rounded,
                              size: 14, color: Color(0xFF003580)),
                          label: const Text('Hotel Portal ↗',
                              style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            final url = _selectedHotel!['bookingUrl']
                                    ?.toString() ??
                                _selectedHotel!['websiteUrl']?.toString();
                            _openUrl(url);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Price and Apply Button
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Additions',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          totalCustomPrice > 0
                              ? '+ Rs. $totalCustomPrice'
                              : 'Rs. 0',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_selectedTransport != null ||
                                _selectedHotel != null)
                            ? _applyCustomization
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Apply Customizations',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
    );
  }
}
