import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutUsScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const AboutUsScreen({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('About TravelMaster', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flight_takeoff_rounded, size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TravelMaster',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crafting Unforgettable Journeys Across India & Beyond',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Our Mission & Story
                  _buildSectionCard(
                    context,
                    title: 'Our Story & Mission',
                    icon: Icons.auto_awesome,
                    color: Colors.orange,
                    child: const Text(
                      'Founded with a passion to revolutionize travel in India, TravelMaster brings smart technology, curated local experiences, and live transportation synchronization under one platform. We believe travel should be seamless, inspiring, and accessible to everyone — whether you are taking a train from Ahmedabad or flying from Delhi.',
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ).animate().slideY(begin: 0.2, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Key Stats Row
                  Row(
                    children: [
                      _buildStatBox(context, '50,000+', 'Happy Travelers', Icons.groups_rounded, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatBox(context, '120+', 'Destinations', Icons.map_rounded, Colors.green),
                      const SizedBox(width: 12),
                      _buildStatBox(context, '4.9 ★', 'User Rating', Icons.star_rounded, Colors.amber),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Why Choose Us
                  Text(
                    'Why TravelMaster?',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureTile(
                    context,
                    icon: Icons.train_rounded,
                    title: 'Smart Starting Point Logic',
                    subtitle: 'Automatic routing via Ahmedabad or Delhi depending on your trip destination with live train synchronization.',
                  ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.verified_user_rounded,
                    title: 'Verified Safety & Aadhar Check',
                    subtitle: 'Every booking includes 100% verified traveler identity verification for maximum security & hotel compliance.',
                  ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Transparent Pricing & E-Vouchers',
                    subtitle: 'Instant GST tax invoices and downloadable travel tickets with no hidden fees.',
                  ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.support_agent_rounded,
                    title: '24/7 Dedicated Ground Support',
                    subtitle: 'Local tour coordinators and 24/7 helpline assistance throughout your journey.',
                  ),

                  const SizedBox(height: 32),

                  // Contact Us & HQ Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.business_rounded, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Text(
                              'TravelMaster Headquarters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildContactInfo(Icons.location_on, 'SG Highway, Bodakdev, Ahmedabad, Gujarat - 380015'),
                        const SizedBox(height: 8),
                        _buildContactInfo(Icons.phone, '+91 98765 43210 / +91 79 2684 0000'),
                        const SizedBox(height: 8),
                        _buildContactInfo(Icons.email, 'support@travelmaster.com'),
                        const SizedBox(height: 8),
                        _buildContactInfo(Icons.language, 'www.travelmaster.com'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // Copyright Footer
                  Center(
                    child: Text(
                      '© 2026 TravelMaster Technologies Pvt. Ltd. All rights reserved.',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String value, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3))),
      ],
    );
  }
}
