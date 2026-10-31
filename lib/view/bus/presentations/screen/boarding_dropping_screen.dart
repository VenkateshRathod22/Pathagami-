import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/bus_api_models.dart';
import '../../models/bus_booking_model.dart';
import '../../models/bus_points_model.dart';
import '../../services/bus_points_service.dart';
import 'bus_schedule_points_screen.dart';
import 'passenger_details_screen.dart';

class BoardingDroppingScreen extends StatefulWidget {
  final BusItem bus;
  final String fromCity;
  final String toCity;
  final String date;
  final List<String> selectedSeats;
  final SeatLockDataModel? seatLock;

  const BoardingDroppingScreen({
    super.key,
    required this.bus,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.selectedSeats,
    this.seatLock,
  });

  @override
  State<BoardingDroppingScreen> createState() => _BoardingDroppingScreenState();
}

class _BoardingDroppingScreenState extends State<BoardingDroppingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BusPointItemModel> _boardingPoints = [];
  List<BusPointItemModel> _droppingPoints = [];

  BusPointItemModel? _selectedBoarding;
  BusPointItemModel? _selectedDropping;

  bool _isLoadingPoints = true;
  Timer? _holdTimer;
  int _secondsRemaining = 600;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color brandGreen = Color(0xFF16A34A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color primaryRed = Color(0xFFD82C3D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _secondsRemaining = widget.seatLock?.expiresInSeconds ?? 600;
    _startTimer();

    // Load live boarding and dropping points from API
    _loadLivePoints();
  }

  void _startTimer() {
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _loadLivePoints({bool forceRefresh = false}) async {
    setState(() => _isLoadingPoints = true);
    final scheduleId = widget.bus.scheduleModel?.id ?? int.tryParse(widget.bus.id) ?? 15;

    try {
      final bundle = await BusPointsService.instance.getPointsBundle(
        scheduleId,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      setState(() {
        _boardingPoints = bundle.boardingPoints;
        _droppingPoints = bundle.droppingPoints;

        if (_boardingPoints.isNotEmpty) {
          _selectedBoarding = _boardingPoints.first;
        }
        if (_droppingPoints.isNotEmpty) {
          _selectedDropping = _droppingPoints.first;
        }
        _isLoadingPoints = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _boardingPoints = BusPointsService.fallbackBoardingPoints;
        _droppingPoints = BusPointsService.fallbackDroppingPoints;
        _selectedBoarding = _boardingPoints.first;
        _selectedDropping = _droppingPoints.first;
        _isLoadingPoints = false;
      });
    }
  }

  List<BusPointItemModel> _filterPoints(List<BusPointItemModel> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.trim().toLowerCase();
    return list.where((p) {
      return p.pointName.toLowerCase().contains(q) ||
          p.cityName.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q) ||
          (p.landmark != null && p.landmark!.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleId = widget.bus.scheduleModel?.id ?? int.tryParse(widget.bus.id) ?? 15;

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
              '${widget.date} • ${widget.selectedSeats.length} Seat(s) (${widget.selectedSeats.join(', ')})',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Route Stops Detail',
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BusSchedulePointsScreen(
                    scheduleId: scheduleId,
                    fromCity: widget.fromCity,
                    toCity: widget.toCity,
                    operatorName: widget.bus.operator,
                    busType: widget.bus.busType,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh Points',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => _loadLivePoints(forceRefresh: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF84CC16),
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(text: '1. BOARDING (${_boardingPoints.length})'),
            Tab(text: '2. DROPPING (${_droppingPoints.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seat Lock Countdown Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              border: Border(bottom: BorderSide(color: Color(0xFFFDE68A))),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seat(s) ${widget.selectedSeats.join(', ')} held for ${_formatTimer(_secondsRemaining)} mins',
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatTimer(_secondsRemaining),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingPoints)
            const LinearProgressIndicator(minHeight: 2.5, color: primaryRed),

          // Bus Info & Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFCCB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.directions_bus_rounded, color: Color(0xFF65A30D), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bus.operator,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy),
                          ),
                          Text(
                            widget.bus.busType,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusSchedulePointsScreen(
                              scheduleId: scheduleId,
                              fromCity: widget.fromCity,
                              toCity: widget.toCity,
                              operatorName: widget.bus.operator,
                              busType: widget.bus.busType,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text(
                              'Stops Info',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Search Input
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 17, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: darkNavy),
                          decoration: const InputDecoration(
                            hintText: 'Search boarding or dropping point...',
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
                          child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointList(
                  isBoarding: true,
                  points: _filterPoints(_boardingPoints),
                  selected: _selectedBoarding,
                  onSelect: (pt) {
                    setState(() => _selectedBoarding = pt);
                    // Automatically switch to Dropping tab
                    _tabController.animateTo(1);
                  },
                ),
                _buildPointList(
                  isBoarding: false,
                  points: _filterPoints(_droppingPoints),
                  selected: _selectedDropping,
                  onSelect: (pt) {
                    setState(() => _selectedDropping = pt);
                  },
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Fare',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            '₹${widget.selectedSeats.length * widget.bus.price}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF65A30D),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${widget.selectedSeats.length} seats)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD82C3D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_selectedBoarding == null || _selectedDropping == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select both boarding and dropping points'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PassengerDetailsScreen(
                          bus: widget.bus,
                          fromCity: widget.fromCity,
                          toCity: widget.toCity,
                          date: widget.date,
                          selectedSeats: widget.selectedSeats,
                          boardingPoint: _selectedBoarding!.toBusStopPoint(),
                          droppingPoint: _selectedDropping!.toBusStopPoint(),
                          seatLock: widget.seatLock,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointList({
    required bool isBoarding,
    required List<BusPointItemModel> points,
    required BusPointItemModel? selected,
    required ValueChanged<BusPointItemModel> onSelect,
  }) {
    if (points.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No ${isBoarding ? 'boarding' : 'dropping'} points found',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkNavy),
              ),
              const SizedBox(height: 4),
              Text(
                _searchQuery.isNotEmpty ? 'Try a different search keyword' : 'Please refresh to fetch points from API',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
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
        final isSelected = selected != null && pt.id == selected.id;

        return InkWell(
          onTap: () => onSelect(pt),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? brandGreen : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? brandGreen.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio indicator
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? brandGreen : Colors.grey.shade400,
                      width: isSelected ? 6.5 : 2,
                    ),
                  ),
                ),
                // Point information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                pt.formattedTime12h,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected ? brandGreen : darkNavy,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Stop #${pt.displayOrder}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SELECTED',
                                style: TextStyle(
                                  color: Color(0xFF166534),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pt.pointName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pt.fullAddress,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          pt.cityName,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
