import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripried/view/account/sub_features/personal_info/models/saved_passenger_model.dart';
import 'package:tripried/view/account/sub_features/personal_info/services/passenger_storage_service.dart';
import 'package:tripried/view/account/sub_features/personal_info/presentations/screen/new_passenger_screen.dart';

class PassengersScreen extends StatefulWidget {
  const PassengersScreen({super.key});

  @override
  State<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends State<PassengersScreen> {
  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    PassengerStorageService.instance.addListener(_onStorageChanged);
    PassengerStorageService.instance.loadPassengers();
  }

  @override
  void dispose() {
    PassengerStorageService.instance.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _navigateToAddPassenger() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const NewPassengerScreen(),
      ),
    );
    if (added == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _navigateToEditPassenger(SavedPassengerModel passenger) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NewPassengerScreen(passengerToEdit: passenger),
      ),
    );
    if (updated == true && mounted) {
      setState(() {});
    }
  }

  void _confirmDeletePassenger(SavedPassengerModel p) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: primaryRed, size: 24),
              SizedBox(width: 10),
              Text(
                'Delete Passenger?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: darkNavy,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${p.name}"? This action cannot be undone.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final res = await PassengerStorageService.instance
                    .deletePassenger(p.id);

                if (!mounted) return;
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.message.isNotEmpty
                        ? res.message
                        : 'Passenger deleted successfully.'),
                    backgroundColor: darkNavy,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final passengers = PassengerStorageService.instance.passengers;
    final isLoading = PassengerStorageService.instance.isLoading;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Passengers',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryRed),
            tooltip: 'Refresh passengers',
            onPressed: () =>
                PassengerStorageService.instance.loadPassengers(forceRefresh: true),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isLoading)
              const LinearProgressIndicator(color: primaryRed, minHeight: 2.5),
            Expanded(
              child: RefreshIndicator(
                color: primaryRed,
                onRefresh: () =>
                    PassengerStorageService.instance.loadPassengers(forceRefresh: true),
                child: passengers.isEmpty && !isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_outline_rounded,
                                      size: 56, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No passengers added yet',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: darkNavy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Add co-travelers, family, and seniors for quick one-tap bookings.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        itemCount: passengers.length,
                        itemBuilder: (context, index) {
                          final p = passengers[index];
                          return _buildPassengerCard(p);
                        },
                      ),
              ),
            ),

            // Bottom Full-width Red Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _navigateToAddPassenger,
                  icon: const Icon(Icons.person_add_alt_1_rounded,
                      size: 20, color: Colors.white),
                  label: const Text(
                    'ADD NEW PASSENGER',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard(SavedPassengerModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToEditPassenger(p),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular Initials Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: p.gender.toLowerCase() == 'female'
                          ? const Color(0xFFFCE7F3)
                          : const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        p.initials,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: p.gender.toLowerCase() == 'female'
                              ? const Color(0xFFDB2777)
                              : const Color(0xFF4338CA),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: darkNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.subtitleDisplay,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Edit and Delete
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: Color(0xFF64748B)),
                        tooltip: 'Edit',
                        onPressed: () => _navigateToEditPassenger(p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 20, color: primaryRed),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeletePassenger(p),
                      ),
                    ],
                  ),
                ],
              ),

              // Badges row (Senior Citizen, Child, Added Date)
              if (p.isSeniorCitizenEffective ||
                  p.isChildEffective ||
                  (p.formattedDate != null && p.formattedDate!.isNotEmpty)) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (p.isSeniorCitizenEffective)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.elderly_rounded,
                                size: 14, color: Color(0xFF15803D)),
                            SizedBox(width: 4),
                            Text(
                              'Senior Citizen',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (p.isChildEffective)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.child_care_rounded,
                                size: 14, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 4),
                            Text(
                              'Child',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (p.formattedDate != null && p.formattedDate!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              p.formattedDate!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
