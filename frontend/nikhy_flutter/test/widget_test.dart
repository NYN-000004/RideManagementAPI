import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikhy_flutter/core/theme/app_theme.dart';
import 'package:nikhy_flutter/models/ride_status.dart';
import 'package:nikhy_flutter/models/ride_model.dart';
import 'package:nikhy_flutter/models/user_model.dart';
import 'package:nikhy_flutter/models/create_ride_request.dart';
import 'package:nikhy_flutter/core/utils/validators.dart';
import 'package:nikhy_flutter/widgets/nikhy_logo.dart';
import 'package:nikhy_flutter/widgets/app_button.dart';
import 'package:nikhy_flutter/widgets/status_badge.dart';
import 'package:nikhy_flutter/widgets/empty_state.dart';
import 'package:nikhy_flutter/widgets/section_title.dart';
import 'package:nikhy_flutter/widgets/user_avatar.dart';
import 'package:nikhy_flutter/widgets/avatar_picker_dialog.dart';
import 'package:nikhy_flutter/core/constants/rider_avatar_presets.dart';

void main() {
  group('RideStatus Enum & State Machine Tests', () {
    test('Correctly maps status string names to enum', () {
      expect(RideStatus.fromDynamic('REQUESTED'), RideStatus.requested);
      expect(RideStatus.fromDynamic('SEARCHING'), RideStatus.searching);
      expect(RideStatus.fromDynamic('ACCEPTED'), RideStatus.accepted);
      expect(RideStatus.fromDynamic('RIDER_ARRIVING'), RideStatus.riderArriving);
      expect(RideStatus.fromDynamic('ARRIVED'), RideStatus.arrived);
      expect(RideStatus.fromDynamic('STARTED'), RideStatus.started);
      expect(RideStatus.fromDynamic('COMPLETED'), RideStatus.completed);
      expect(RideStatus.fromDynamic('CANCELLED'), RideStatus.cancelled);
    });

    test('Correctly maps status integer codes to enum', () {
      expect(RideStatus.fromDynamic(1), RideStatus.requested);
      expect(RideStatus.fromDynamic(2), RideStatus.searching);
      expect(RideStatus.fromDynamic(3), RideStatus.accepted);
      expect(RideStatus.fromDynamic(4), RideStatus.riderArriving);
      expect(RideStatus.fromDynamic(5), RideStatus.arrived);
      expect(RideStatus.fromDynamic(6), RideStatus.started);
      expect(RideStatus.fromDynamic(7), RideStatus.completed);
      expect(RideStatus.fromDynamic(8), RideStatus.cancelled);
    });

    test('Validates cancellation eligibility according to backend rules', () {
      expect(RideStatus.requested.canCancel, isTrue);
      expect(RideStatus.searching.canCancel, isTrue);
      expect(RideStatus.accepted.canCancel, isTrue);
      expect(RideStatus.riderArriving.canCancel, isTrue);
      expect(RideStatus.arrived.canCancel, isFalse);
      expect(RideStatus.started.canCancel, isFalse);
      expect(RideStatus.completed.canCancel, isFalse);
      expect(RideStatus.cancelled.canCancel, isFalse);
    });

    test('Validates terminal states', () {
      expect(RideStatus.completed.isTerminal, isTrue);
      expect(RideStatus.cancelled.isTerminal, isTrue);
      expect(RideStatus.started.isTerminal, isFalse);
    });
  });

  group('Model Serialization Tests', () {
    test('CreateRideRequest serializes accurately', () {
      const request = CreateRideRequest(
        passengerId: 101,
        pickupLocation: 'Hitec City Cyber Towers, Hyderabad',
        destinationLocation: 'Rajiv Gandhi International Airport, Hyderabad',
        pickupLatitude: 17.4504,
        pickupLongitude: 78.3808,
        destinationLatitude: 17.2403,
        destinationLongitude: 78.4294,
        fare: 750.0,
      );

      final json = request.toJson();
      expect(json['passengerId'], 101);
      expect(json['pickupLocation'], 'Hitec City Cyber Towers, Hyderabad');
      expect(json['destinationLocation'], 'Rajiv Gandhi International Airport, Hyderabad');
      expect(json['fare'], 750.0);
    });

    test('RideModel deserializes from backend response format', () {
      final json = {
        'rideId': 1,
        'bookingId': 1001,
        'passengerId': 101,
        'driverId': 201,
        'pickupLocation': 'Hitec City Cyber Towers, Hyderabad',
        'destinationLocation': 'Rajiv Gandhi International Airport, Hyderabad',
        'pickupLatitude': 17.4504,
        'pickupLongitude': 78.3808,
        'destinationLatitude': 17.2403,
        'destinationLongitude': 78.4294,
        'status': 'ACCEPTED',
        'fare': 750.0,
        'distance': 32.4,
        'estimatedDuration': 45,
        'requestedAt': '2026-10-06T10:00:00Z',
        'acceptedAt': '2026-10-06T10:02:00Z',
        'startedAt': null,
        'completedAt': null,
        'cancelledAt': null,
        'cancellationReason': null,
        'cancelledBy': null,
        'createdAt': '2026-10-06T10:00:00Z',
        'updatedAt': '2026-10-06T10:02:00Z',
      };

      final ride = RideModel.fromJson(json);
      expect(ride.rideId, 1);
      expect(ride.status, RideStatus.accepted);
      expect(ride.driverId, 201);
      expect(ride.fare, 750.0);
    });

    test('UserModel serializes and deserializes avatarUrl accurately', () {
      const user = UserModel(
        id: 201,
        firstName: 'Rajesh',
        lastName: 'Kumar',
        email: 'rajesh@nikhy.com',
        phone: '9876543210',
        role: UserRole.rider,
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      );

      final json = user.toJson();
      expect(json['avatarUrl'], 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d');

      final deserialized = UserModel.fromJson(json);
      expect(deserialized.avatarUrl, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d');
      expect(deserialized.fullName, 'Rajesh Kumar');
      expect(deserialized.isRider, isTrue);
    });
  });

  group('Validators Tests', () {
    test('Latitude and Longitude boundary checks', () {
      expect(Validators.latitude('28.6315'), isNull);
      expect(Validators.latitude('95.0'), isNotNull);
      expect(Validators.latitude('-95.0'), isNotNull);

      expect(Validators.longitude('77.2167'), isNull);
      expect(Validators.longitude('185.0'), isNotNull);
      expect(Validators.longitude('-185.0'), isNotNull);
    });
  });

  group('Reusable UI Widgets Tests', () {
    testWidgets('NikhyLogo renders branding text and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NikhyLogo(size: NikhyLogoSize.normal),
          ),
        ),
      );

      expect(find.text('NIKHY'), findsOneWidget);
      expect(find.text('RIDE MANAGEMENT'), findsOneWidget);
      expect(find.byIcon(Icons.two_wheeler_rounded), findsOneWidget);
    });

    testWidgets('NikhyButton displays text and triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: NikhyButton(
              text: 'Request Ride',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Request Ride'), findsOneWidget);
      await tester.tap(find.text('Request Ride'));
      expect(tapped, isTrue);
    });

    testWidgets('StatusBadge displays correct text and status color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: RideStatus.completed),
          ),
        ),
      );

      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('EmptyState displays icon, title and action', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: EmptyState(
              icon: Icons.two_wheeler_outlined,
              title: 'No Rides Found',
              message: 'Book your first ride now',
              actionText: 'Book Now',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Rides Found'), findsOneWidget);
      expect(find.text('Book your first ride now'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);

      await tester.tap(find.text('Book Now'));
      expect(actionTapped, isTrue);
    });

    testWidgets('SectionTitle displays title and optional action', (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SectionTitle(
              title: 'Recent Bookings',
              actionText: 'View All',
              onAction: () => actionClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Recent Bookings'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      await tester.tap(find.text('View All'));
      expect(actionClicked, isTrue);
    });

    testWidgets('UserAvatar renders user initials correctly', (tester) async {
      const user = UserModel(
        id: 101,
        firstName: 'Amit',
        lastName: 'Sharma',
        email: 'amit@nikhy.com',
        phone: '9876543210',
        role: UserRole.customer,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(user: user, size: 48),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('UserAvatar renders camera edit badge when showEditBadge is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              name: 'Rajesh Kumar',
              size: 64,
              showEditBadge: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });

    test('RiderAvatarPresets provides valid avatars and fallback', () {
      final avatar201 = RiderAvatarPresets.getDefaultAvatarForDriver(201);
      final avatarNull = RiderAvatarPresets.getDefaultAvatarForDriver(null);
      expect(avatar201, isNotEmpty);
      expect(avatarNull, isNotEmpty);
      expect(RiderAvatarPresets.presets.length, greaterThanOrEqualTo(5));
    });

    testWidgets('AvatarPickerDialog displays update photo dialog interface', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarPickerDialog(),
          ),
        ),
      );

      expect(find.text('Update Profile Photo'), findsOneWidget);
      expect(find.text('Select Verified Captain Portrait'), findsOneWidget);
      expect(find.text('Captain Rajesh'), findsOneWidget);
      expect(find.text('Save Photo'), findsOneWidget);
    });
  });
}
