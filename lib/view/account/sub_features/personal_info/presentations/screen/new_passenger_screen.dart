import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripried/view/account/sub_features/personal_info/models/saved_passenger_model.dart';
import 'package:tripried/view/account/sub_features/personal_info/services/passenger_storage_service.dart';

class NewPassengerScreen extends StatefulWidget {
  final SavedPassengerModel? passengerToEdit;

  const NewPassengerScreen({super.key, this.passengerToEdit});

  @override
  State<NewPassengerScreen> createState() => _NewPassengerScreenState();
}

class _NewPassengerScreenState extends State<NewPassengerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _dobController;
  late final TextEditingController _phoneController;

  String _selectedGender = 'Female';
  String _selectedCountryCode = '+91 (IND)';
  String? _selectedBerth;
  String? _selectedSeat;
  String? _selectedMeal;
  bool _isSaving = false;
  bool _isDeleting = false;

  static const Color primaryRed = Color(0xFFD83A3A);
  static const Color titleColor = Color(0xFF0F172A);
  static const Color subtextColor = Color(0xFF64748B);
  static const Color darkBorderColor = Color(0xFFCBD5E1);
  static const Color lavenderInfoBox = Color(0xFFE8EEFF);
  static const Color brandGreen = Color(0xFF16A34A);

  static const List<String> _countryCodes = [
    '+91 (IND)',
    '+1 (USA)',
    '+44 (UK)',
    '+971 (UAE)',
    '+65 (SGP)',
    '+61 (AUS)',
    '+1 (CAN)',
  ];

  static const List<String> _berthPreferences = [
    'No preference',
    'Lower berth',
    'Middle berth',
    'Upper berth',
    'Side lower berth',
    'Side upper berth',
  ];

  static const List<String> _seatPreferences = [
    'No preference',
    'Window seat',
    'Aisle seat',
  ];

  static const List<String> _mealPreferences = [
    'No preference',
    'Veg',
    'Non-Veg',
    'Jain Meal',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.passengerToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _ageController = TextEditingController(
        text: p?.age != null && p!.age! > 0 ? p.age.toString() : '');
    _dobController = TextEditingController(text: p?.dob ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    if (p != null) {
      _selectedGender = p.genderDisplay;
      _selectedCountryCode = p.countryCode;
      _selectedBerth = p.berthPreference;
      _selectedSeat = p.seatPreference;
      _selectedMeal = p.mealPreference;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryRed,
              onPrimary: Colors.white,
              onSurface: titleColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final yyyy = picked.year.toString();
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dobController.text = '$yyyy-$mm-$dd';

        // Automatically calculate age from selected birth date
        int calculatedAge = now.year - picked.year;
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          calculatedAge--;
        }
        if (calculatedAge >= 0) {
          _ageController.text = calculatedAge.toString();
        }
      });
    }
  }

  void _showSelectionModal({
    required String title,
    required List<String> options,
    required String? currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 20, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == currentValue;
                    return ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? primaryRed : titleColor,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check,
                              color: primaryRed, size: 20)
                          : null,
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter passenger name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ageText = _ageController.text.trim();
    final int age = int.tryParse(ageText) ?? 25;

    setState(() {
      _isSaving = true;
    });

    final isEdit = widget.passengerToEdit != null;
    PassengerApiResponse result;

    if (isEdit) {
      result = await PassengerStorageService.instance.updatePassenger(
        id: widget.passengerToEdit!.id,
        name: name,
        age: age,
        gender: _selectedGender,
        dob: _dobController.text.trim(),
        countryCode: _selectedCountryCode,
        phone: _phoneController.text.trim(),
        berthPreference: _selectedBerth,
        seatPreference: _selectedSeat,
        mealPreference: _selectedMeal,
      );
    } else {
      result = await PassengerStorageService.instance.addPassenger(
        name: name,
        age: age,
        gender: _selectedGender,
        dob: _dobController.text.trim(),
        countryCode: _selectedCountryCode,
        phone: _phoneController.text.trim(),
        berthPreference: _selectedBerth,
        seatPreference: _selectedSeat,
        mealPreference: _selectedMeal,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (result.success) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message.isNotEmpty
                      ? result.message
                      : (isEdit
                          ? 'Passenger updated successfully!'
                          : 'Passenger added successfully!'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: brandGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete() {
    final p = widget.passengerToEdit;
    if (p == null) return;

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
                  color: titleColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${p.name}" from your saved passengers list?',
            style: const TextStyle(fontSize: 14, color: subtextColor, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: subtextColor, fontWeight: FontWeight.bold),
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
                setState(() => _isDeleting = true);
                final res = await PassengerStorageService.instance
                    .deletePassenger(p.id);

                if (!mounted) return;
                setState(() => _isDeleting = false);

                if (res.success) {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.message.isNotEmpty
                          ? res.message
                          : 'Passenger deleted successfully.'),
                      backgroundColor: titleColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context, true);
                }
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
    final isEdit = widget.passengerToEdit != null;
    final int currentAge = int.tryParse(_ageController.text.trim()) ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Passenger' : 'New Passenger',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: primaryRed),
                    )
                  : const Icon(Icons.delete_outline_rounded,
                      color: primaryRed, size: 22),
              tooltip: 'Delete Passenger',
              onPressed: _isDeleting ? null : _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // 1. PERSONAL DETAILS
                      // ==========================================
                      const Text(
                        'Personal details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Name Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: darkBorderColor, width: 1.2),
                        ),
                        child: TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Full Name * (e.g. Grandma Rajnu)',
                            hintStyle: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Age Field & Indicator Row
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: darkBorderColor, width: 1.2),
                              ),
                              child: TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Age * (e.g. 65)',
                                  hintStyle: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    color: subtextColor,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 5,
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: darkBorderColor, width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _dobController.text.isNotEmpty
                                            ? _dobController.text
                                            : 'Date of birth',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              _dobController.text.isNotEmpty
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                          color:
                                              _dobController.text.isNotEmpty
                                                  ? titleColor
                                                  : subtextColor,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: subtextColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Age Badges (Senior Citizen / Child)
                      if (currentAge >= 60) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.elderly_rounded,
                                  size: 15, color: Color(0xFF15803D)),
                              SizedBox(width: 4),
                              Text(
                                'Senior Citizen (60+ years)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (currentAge > 0 && currentAge < 12) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF93C5FD)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.child_care_rounded,
                                  size: 15, color: Color(0xFF1D4ED8)),
                              SizedBox(width: 4),
                              Text(
                                'Child (Below 12 years)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Gender Label
                      const Text(
                        'Gender *',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Gender Selector Pills
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderPill(
                              label: 'Female',
                              isSelected: _selectedGender == 'Female',
                              onTap: () =>
                                  setState(() => _selectedGender = 'Female'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildGenderPill(
                              label: 'Male',
                              isSelected: _selectedGender == 'Male',
                              onTap: () =>
                                  setState(() => _selectedGender = 'Male'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildGenderPill(
                              label: 'Others',
                              isSelected: _selectedGender == 'Others',
                              onTap: () =>
                                  setState(() => _selectedGender = 'Others'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Lavender Info Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: lavenderInfoBox,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 18, color: Color(0xFF1E293B)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Providing a mobile number helps us share live trip updates with fellow travelers.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Split Phone Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: darkBorderColor, width: 1.2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left Country Code Selector
                            GestureDetector(
                              onTap: () {
                                _showSelectionModal(
                                  title: 'Select Country Code',
                                  options: _countryCodes,
                                  currentValue: _selectedCountryCode,
                                  onSelected: (val) => setState(
                                      () => _selectedCountryCode = val),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 10, top: 8, bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Country Code',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: subtextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          _selectedCountryCode,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: titleColor,
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down,
                                            color: titleColor, size: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 38,
                                color: darkBorderColor),
                            // Right Phone Input
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 14),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: titleColor,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Mobile number (optional)',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subtextColor,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ==========================================
                      // 2. BUS & TRAVEL PREFERENCES
                      // ==========================================
                      const Text(
                        'Travel preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pre-set preferences for faster bookings',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Berth preference
                      _buildDropdownTile(
                        label: _selectedBerth ?? 'Berth preference',
                        isPlaceholder: _selectedBerth == null,
                        onTap: () {
                          _showSelectionModal(
                            title: 'Select Berth preference',
                            options: _berthPreferences,
                            currentValue: _selectedBerth,
                            onSelected: (val) =>
                                setState(() => _selectedBerth = val),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Seat preference
                      _buildDropdownTile(
                        label: _selectedSeat ?? 'Seat preference',
                        isPlaceholder: _selectedSeat == null,
                        onTap: () {
                          _showSelectionModal(
                            title: 'Select Seat preference',
                            options: _seatPreferences,
                            currentValue: _selectedSeat,
                            onSelected: (val) =>
                                setState(() => _selectedSeat = val),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Meal preference
                      _buildDropdownTile(
                        label: _selectedMeal ?? 'Meal preference',
                        isPlaceholder: _selectedMeal == null,
                        onTap: () {
                          _showSelectionModal(
                            title: 'Select Meal preference',
                            options: _mealPreferences,
                            currentValue: _selectedMeal,
                            onSelected: (val) =>
                                setState(() => _selectedMeal = val),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Delete Passenger Button (if editing)
                      if (isEdit) ...[
                        Center(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryRed,
                              side: const BorderSide(color: primaryRed),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: _isDeleting ? null : _confirmDelete,
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            label: const Text(
                              'DELETE PASSENGER',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Pinned Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('SAVING...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        )
                      : Text(
                          isEdit
                              ? 'SAVE & UPDATE PASSENGER'
                              : 'SAVE & ADD PASSENGER',
                          style: const TextStyle(
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

  Widget _buildGenderPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryRed : darkBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? primaryRed : titleColor,
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryRed : darkBorderColor,
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required bool isPlaceholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: darkBorderColor, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    isPlaceholder ? FontWeight.w500 : FontWeight.w600,
                color: isPlaceholder ? subtextColor : titleColor,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: titleColor, size: 26),
          ],
        ),
      ),
    );
  }
}
