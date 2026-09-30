import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomizePackageSheet extends StatefulWidget {
  final Map<String, dynamic> pkg;
  final String startingCity;
  final Function(int additionalPrice, String details) onCustomizationComplete;

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
    _fromController.text = widget.startingCity.isEmpty ? 'Delhi' : widget.startingCity;
    _fetchOptions();
  }

  @override
  void dispose() {
    _fromController.dispose();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    setState(() => _isLoading = true);
    try {
      final loc = widget.pkg['location'].toString().split(',').first;
      final startCity = _fromController.text.isEmpty ? 'Delhi' : _fromController.text;
      
      final tRes = await http.get(Uri.parse('http://localhost:5000/api/transport?from=$startCity&to=$loc&mode=$_transportMode&classType=$_transportClass'));
      final hRes = await http.get(Uri.parse('http://localhost:5000/api/hotels?location=$loc&type=$_accommodationType'));
      
      if (tRes.statusCode == 200 && hRes.statusCode == 200) {
        if (mounted) {
          setState(() {
            _transports = json.decode(tRes.body);
            _hotels = json.decode(hRes.body);
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _applyCustomization() {
    if (_selectedHotel == null || _selectedTransport == null) return;
    
    int tPrice = _selectedTransport!['price'] as int;
    int hPrice = _selectedHotel!['price'] as int;
    
    widget.onCustomizationComplete(tPrice + hPrice, 'Transport: ${_selectedTransport!['name']} | Hotel: ${_selectedHotel!['name']}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customize Your Trip', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Cities
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromController,
                  decoration: const InputDecoration(
                    labelText: 'Leaving From',
                    prefixIcon: Icon(Icons.flight_takeoff),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) { _selectedTransport = null; _fetchOptions(); },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: widget.pkg['location'].toString().split(',').first),
                  decoration: const InputDecoration(
                    labelText: 'Going To',
                    prefixIcon: Icon(Icons.flight_land),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Transport
          const Text('1. Select Transportation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Radio<String>(
                value: 'flight', 
                groupValue: _transportMode, 
                onChanged: (v) { 
                  setState(() { _transportMode = v!; _transportClass = 'Economy'; _selectedTransport = null; }); 
                  _fetchOptions(); 
                }
              ),
              const Text('Flight'),
              Radio<String>(
                value: 'train', 
                groupValue: _transportMode, 
                onChanged: (v) { 
                  setState(() { _transportMode = v!; _transportClass = 'Sleeper'; _selectedTransport = null; }); 
                  _fetchOptions(); 
                }
              ),
              const Text('Train'),
              const Spacer(),
              DropdownButton<String>(
                value: _transportClass,
                items: (_transportMode == 'flight' 
                    ? ['Economy', 'Business', 'First Class'] 
                    : ['Sleeper', '3-Tier AC', '1-Tier AC']
                ).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _transportClass = v);
                    _fetchOptions();
                  }
                },
              ),
            ],
          ),
          
          if (_isLoading) const Center(child: CircularProgressIndicator())
          else if (_transports.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No flights/trains available for this route.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else 
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: _transports.length,
                itemBuilder: (c, i) {
                  final t = _transports[i];
                  final isSelected = _selectedTransport == t;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    title: Text(t['name']),
                    subtitle: Text('${t['departure']} - ${t['arrival']}'),
                    trailing: Text('Rs. ${t['price']}'),
                    onTap: () => setState(() => _selectedTransport = t),
                  );
                }
              ),
            ),
          
          const SizedBox(height: 16),
          // Hotel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2. Select Accommodation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _accommodationType,
                items: ['Hotel', 'Resort'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _accommodationType = v;
                      _selectedHotel = null;
                    });
                    _fetchOptions();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoading) const SizedBox()
          else if (_hotels.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _hotels.length,
                itemBuilder: (c, i) {
                  final h = _hotels[i];
                  final isSelected = _selectedHotel == h;
                  return Card(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedHotel = h),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(h['image'], width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('⭐ ${h['rating']} | 📞 ${h['contact']}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                                  const SizedBox(height: 4),
                                  Text('Rules: ${h['rules'].join(', ')}', style: const TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text('Rs. ${h['price']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
            
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedTransport != null && _selectedHotel != null) ? _applyCustomization : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Customizations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          )
        ],
      ),
    );
  }
}
