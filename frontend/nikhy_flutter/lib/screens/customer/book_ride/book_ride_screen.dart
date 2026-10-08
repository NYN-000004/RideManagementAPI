import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../models/create_ride_request.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ride_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../current_ride/customer_current_ride_screen.dart';

class BookRideScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPreset;

  const BookRideScreen({super.key, this.initialPreset});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pickupLocationController = TextEditingController();
  final _destinationLocationController = TextEditingController();
  final _pickupLatController = TextEditingController();
  final _pickupLngController = TextEditingController();
  final _destLatController = TextEditingController();
  final _destLngController = TextEditingController();
  final _fareController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();

  bool _showCoordinates = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with given preset or first preset
    _applyPreset(widget.initialPreset ?? AppConstants.locationPresets[0]);
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _pickupLocationController.text = preset['pickupLocation'];
      _destinationLocationController.text = preset['destinationLocation'];
      _pickupLatController.text = preset['pickupLatitude'].toString();
      _pickupLngController.text = preset['pickupLongitude'].toString();
      _destLatController.text = preset['destinationLatitude'].toString();
      _destLngController.text = preset['destinationLongitude'].toString();
      _fareController.text = preset['fare'].toString();
      _distanceController.text = preset['distance'].toString();
      _durationController.text = preset['estimatedDuration'].toString();
    });
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _destinationLocationController.dispose();
    _pickupLatController.dispose();
    _pickupLngController.dispose();
    _destLatController.dispose();
    _destLngController.dispose();
    _fareController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _handleBookRide() async {
    if (!_formKey.currentState!.validate()) return;

    final pickup = _pickupLocationController.text.trim();
    final dest = _destinationLocationController.text.trim();

    if (pickup.toLowerCase() == dest.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup and Destination cannot be identical.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    final passengerId = user?.id ?? 101;

    final request = CreateRideRequest(
      passengerId: passengerId,
      pickupLocation: pickup,
      destinationLocation: dest,
      pickupLatitude: double.parse(_pickupLatController.text.trim()),
      pickupLongitude: double.parse(_pickupLngController.text.trim()),
      destinationLatitude: double.parse(_destLatController.text.trim()),
      destinationLongitude: double.parse(_destLngController.text.trim()),
      fare: double.parse(_fareController.text.trim()),
      distance: double.tryParse(_distanceController.text.trim()),
      estimatedDuration: int.tryParse(_durationController.text.trim()),
    );

    final rideProvider = context.read<RideProvider>();
    final result = await rideProvider.bookRide(request);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride #${result.rideId} requested successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CustomerCurrentRideScreen(rideId: result.rideId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Book a Ride'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Presets Header & Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'POPULAR HYDERABAD ROUTES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'Auto-fills GPS',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.locationPresets.map((preset) {
                          final isSelected =
                              _pickupLocationController.text == preset['pickupLocation'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(
                                Icons.near_me_rounded,
                                size: 14,
                                color: isSelected ? Colors.white : AppTheme.accent,
                              ),
                              label: Text(
                                preset['title'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? AppTheme.primary : AppTheme.border,
                              ),
                              onSelected: (_) => _applyPreset(preset),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Banner
                    if (rideProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                rideProvider.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Route Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.route_rounded,
                                    color: AppTheme.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Route Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            AppTextField(
                              controller: _pickupLocationController,
                              label: 'Pickup Location',
                              hint: 'Enter pickup address',
                              prefixIcon: Icons.my_location_rounded,
                              validator: (v) => Validators.requiredField(v, 'Pickup location'),
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              controller: _destinationLocationController,
                              label: 'Destination Location',
                              hint: 'Enter drop-off location',
                              prefixIcon: Icons.location_on_rounded,
                              validator: (v) => Validators.requiredField(v, 'Destination location'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fare & Trip Estimates Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.currency_rupee_rounded,
                                    color: AppTheme.successDark,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Fare & Estimates',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: AppTextField(
                                    controller: _fareController,
                                    label: 'Estimated Fare (₹)',
                                    hint: '450.00',
                                    prefixIcon: Icons.currency_rupee_rounded,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) => Validators.positiveNumber(v, 'Fare'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: AppTextField(
                                    controller: _distanceController,
                                    label: 'Distance (km)',
                                    hint: '15.2',
                                    prefixIcon: Icons.timeline_rounded,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              controller: _durationController,
                              label: 'Estimated Travel Duration (mins)',
                              hint: '35',
                              prefixIcon: Icons.timer_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Advanced GPS Coordinates Accordion
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _showCoordinates,
                          onExpansionChanged: (val) => setState(() => _showCoordinates = val),
                          title: const Text(
                            'GPS Coordinates',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: const Text(
                            'Pre-filled accurately from selected route',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          leading: const Icon(Icons.gps_fixed_rounded, size: 20, color: AppTheme.accent),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          controller: _pickupLatController,
                                          label: 'Pickup Lat',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: Validators.latitude,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AppTextField(
                                          controller: _pickupLngController,
                                          label: 'Pickup Lng',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: Validators.longitude,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          controller: _destLatController,
                                          label: 'Drop Lat',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: Validators.latitude,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AppTextField(
                                          controller: _destLngController,
                                          label: 'Drop Lng',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: Validators.longitude,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Request Ride Action Button
                    AppButton(
                      text: 'REQUEST RIDE',
                      icon: Icons.electric_moped_rounded,
                      isLoading: rideProvider.isBooking,
                      onPressed: _handleBookRide,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
