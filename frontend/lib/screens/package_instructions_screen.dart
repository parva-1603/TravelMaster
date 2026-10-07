import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PackageInstructionsScreen extends StatelessWidget {
  final Map<String, dynamic> pkg;
  final VoidCallback onThemeToggle;

  const PackageInstructionsScreen({
    super.key,
    required this.pkg,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final title = pkg['title'] ?? 'Travel Package';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text('$title - Guidelines', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Toggle Theme',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: onThemeToggle,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.check_circle_outline, size: 18), text: 'Inclusions'),
              Tab(icon: Icon(Icons.highlight_off, size: 18), text: 'Exclusions'),
              Tab(icon: Icon(Icons.card_travel, size: 18), text: 'What to Carry'),
              Tab(icon: Icon(Icons.rule, size: 18), text: 'Travel Rules'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_outlined, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Comprehensive Travel Instructions & Important Policies',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // 1. Inclusions Tab
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeaderTitle(context, 'What is Included in This Package', Icons.check_circle, Colors.green),
                      const SizedBox(height: 12),
                      _buildTile(context, Icons.hotel, 'Accommodation', 'Handpicked 3-Star / 4-Star / Luxury resort stays with daily complimentary breakfast and dinner.', Colors.green),
                      _buildTile(context, Icons.directions_bus, 'Intercity & Sightseeing Transport', 'Private AC / Non-AC vehicle for all transfers, sightseeing tours, and airport/station pick-up and drop.', Colors.green),
                      _buildTile(context, Icons.train, 'Transit Tickets & Hub Connectivity', 'Confirmed Train / Flight booking assistance from designated departure hubs (Ahmedabad / Delhi).', Colors.green),
                      _buildTile(context, Icons.confirmation_number, 'State Permits & Toll Taxes', 'All inner-line state entry permits, toll taxes, parking fees, and driver allowances.', Colors.green),
                      _buildTile(context, Icons.support_agent, 'Dedicated Local Tour Guide', 'Experienced local tour manager and 24/7 TravelMaster ground coordinator throughout the trip.', Colors.green),
                      _buildTile(context, Icons.water_drop, 'Complimentary Refreshments', 'Packaged mineral drinking water provided daily during bus/vehicle travel.', Colors.green),
                    ],
                  ),

                  // 2. Exclusions Tab
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeaderTitle(context, 'What is NOT Included in This Package', Icons.cancel, Colors.red),
                      const SizedBox(height: 12),
                      _buildTile(context, Icons.shopping_bag, 'Personal Expenses', 'Shopping, laundry, room service charges, telephone calls, alcoholic beverages, and extra meals.', Colors.red, isExclusion: true),
                      _buildTile(context, Icons.paragliding, 'Optional Adventure Sports & Monument Entry', 'Entry tickets to monuments not listed in the day-wise plan, camel safaris, boating, or ropeway charges.', Colors.red, isExclusion: true),
                      _buildTile(context, Icons.medical_services, 'Medical & Emergency Expenses', 'Medical treatment costs, personal travel insurance, or emergency evacuation expenses.', Colors.red, isExclusion: true),
                      _buildTile(context, Icons.volunteer_activism, 'Tips & Gratuities', 'Tips to vehicle drivers, hotel bellboys, and local destination guides.', Colors.red, isExclusion: true),
                      _buildTile(context, Icons.warning_amber_rounded, 'Unforeseen Delay Expenses', 'Extra lodging or food charges incurred due to flight delays, train reschedules, or natural landslides.', Colors.red, isExclusion: true),
                    ],
                  ),

                  // 3. What to Carry Tab
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeaderTitle(context, 'Packing Checklist - What You Need to Carry', Icons.card_travel, Colors.blue),
                      const SizedBox(height: 12),
                      _buildTile(context, Icons.badge, 'Original Govt Photo ID & Aadhar', 'Original Aadhar Card / Voter ID / Passport along with 2 printed physical copies for hotel check-ins and state permits.', Colors.blue),
                      _buildTile(context, Icons.checkroom, 'Season-Appropriate Clothing', 'Heavy woolens/thermals for high altitudes (Ladakh/Kashmir); breathable cottons for coastal areas (Goa/Kerala).', Colors.blue),
                      _buildTile(context, Icons.hiking, 'Footwear', 'Sturdy trekking/walking shoes with good grip and 3-4 pairs of comfortable cotton socks.', Colors.blue),
                      _buildTile(context, Icons.medication, 'Personal Medical Kit', 'Personal prescription medicines, motion sickness tablets, ORS packets, lip balm, and band-aids.', Colors.blue),
                      _buildTile(context, Icons.battery_charging_full, 'Electronics & Powerbank', 'Power bank (10,000mAh+), universal camera charger, extra memory card, and waterproof phone pouch.', Colors.blue),
                      _buildTile(context, Icons.wb_sunny, 'Sun Protection & Toiletries', 'Sunscreen lotion (SPF 50+), sunglasses, wet wipes, hand sanitizer, and personal toiletries.', Colors.blue),
                    ],
                  ),

                  // 4. Travel Guidelines & Rules Tab
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeaderTitle(context, 'Important Travel Guidelines & Regulations', Icons.rule, Colors.amber.shade800),
                      const SizedBox(height: 12),
                      _buildTile(context, Icons.schedule, 'Punctuality', 'Please strictly report 15 minutes prior to scheduled bus/train departure times to prevent delays.', Colors.amber.shade800),
                      _buildTile(context, Icons.eco, 'Eco-Friendly & Responsible Tourism', 'Littering or plastic waste disposal in natural eco-sensitive zones is strictly prohibited.', Colors.amber.shade800),
                      _buildTile(context, Icons.verified_user, 'Mandatory Aadhar Verification', 'Every traveler must upload clear Aadhar card photos during booking for instant identity verification.', Colors.amber.shade800),
                      _buildTile(context, Icons.currency_rupee, 'Cancellation & Refund Policy', '100% full refund for cancellations made 7+ days prior to trip start date; 50% refund between 3-7 days.', Colors.amber.shade800),
                      _buildTile(context, Icons.security, 'Safety & Health Protocol', 'Follow guide instructions at high-altitude spots and ocean beaches for individual safety.', Colors.amber.shade800),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context, String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String desc, Color color, {bool isExclusion = false}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 13, height: 1.4, color: theme.colorScheme.onSurface.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
