import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bus_points_model.dart';
import '../../services/bus_points_service.dart';

class BusSchedulePointsScreen extends StatefulWidget {
  final int scheduleId;
  final String fromCity;
  final String toCity;
  final String? operatorName;
  final String? busType;

  const BusSchedulePointsScreen({
    super.key,
    this.scheduleId = 15,
    this.fromCity = 'Lucknow',
    this.toCity = 'Delhi',
    this.operatorName = 'SPinGO Express Line',
    this.busType = 'AC Sleeper (2+1)',
  });

  @override
  State<BusSchedulePointsScreen> createState() => _BusSchedulePointsScreenState();
}

class _BusSchedulePointsScreenState extends State<BusSchedulePointsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BusPointItemModel> _boardingPoints = [];
  List<BusPointItemModel> _droppingPoints = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color brandGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPoints();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPoints({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final bundle = await BusPointsService.instance.getPointsBundle(
      widget.scheduleId,
      forceRefresh: forceRefresh,
    );

    if (mounted) {
      setState(() {
        _boardingPoints = bundle.boardingPoints;
        _droppingPoints = bundle.droppingPoints;
        _isLoading = false;
      });
    }
  }

  List<BusPointItemModel> _filter(List<BusPointItemModel> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.trim().toLowerCase();
    return list.where((p) {
      return p.pointName.toLowerCase().contains(q) ||
          p.cityName.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q) ||
          (p.landmark != null && p.landmark!.toLowerCase().contains(q));
    }).toList();
  }

  void _showPointDetailsModal(BusPointItemModel pt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: pt.type == 'boarding' ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: pt.type == 'boarding' ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Text(
                      pt.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: pt.type == 'boarding' ? const Color(0xFF047857) : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    pt.formattedTime12h,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: darkNavy),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                pt.pointName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy),
              ),
              const SizedBox(height: 4),
              Text(
                'City: ${pt.cityName}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 20, color: primaryRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address & Landmark',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pt.fullAddress,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkNavy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '${pt.pointName}, ${pt.fullAddress}'));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Address copied: ${pt.pointName}'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('COPY ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.fromCity,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF84CC16), size: 16),
                ),
                Text(
                  widget.toCity,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.operatorName ?? 'Bus Schedule'} • Schedule #${widget.scheduleId}',
              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF84CC16),
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: 'BOARDING (${_boardingPoints.length})'),
            Tab(text: 'DROPPING (${_droppingPoints.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Live API Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF1F5F9),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: brandGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Points for Schedule #${widget.scheduleId}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: darkNavy),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: primaryRed),
                  tooltip: 'Refresh API Data',
                  onPressed: () => _loadPoints(forceRefresh: true),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkNavy),
                      decoration: const InputDecoration(
                        hintText: 'Search by point name, landmark or area...',
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const LinearProgressIndicator(color: primaryRed, minHeight: 2.5),

          // Points List TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointsList(_filter(_boardingPoints), isBoarding: true),
                _buildPointsList(_filter(_droppingPoints), isBoarding: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList(List<BusPointItemModel> points, {required bool isBoarding}) {
    if (points.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No ${isBoarding ? 'boarding' : 'dropping'} points found',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkNavy),
              ),
              const SizedBox(height: 4),
              const Text(
                'Check search keywords or refresh the schedule points',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: points.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pt = points[index];
        return _buildPointCard(pt, index + 1);
      },
    );
  }

  Widget _buildPointCard(BusPointItemModel pt, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showPointDetailsModal(pt),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stop order badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkNavy),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time
                          Text(
                            pt.formattedTime12h,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: darkNavy,
                            ),
                          ),
                          // City pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pt.cityName,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Point Name
                      Text(
                        pt.pointName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pt.fullAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Chevron icon
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
