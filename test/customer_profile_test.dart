import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripried/view/account/sub_features/personal_info/models/user_profile_model.dart';
import 'package:tripried/view/account/sub_features/personal_info/presentations/screen/edit_profile_screen.dart';

void main() {
  group('Customer Profile API & Model Tests', () {
    const rawResponse = '''
{
    "success": true,
    "message": "Profile details updated successfully.",
    "data": {
        "id": 11,
        "name": "Priya Verma",
        "email": "amita@example.com",
        "phone": "9811223348",
        "role": "customer",
        "profile_photo": null,
        "gender": "Female",
        "city": "Noida",
        "dob": "1998-05-15",
        "address": "Flat 402, Sunshine Apartments, Sector 62",
        "home_address": "Flat 402, Sunshine Apartments, Sector 62",
        "office_address": "Tower A, Tech Park, Sector 135",
        "pin_code": "201301",
        "pincode": "201301",
        "customer_details": {
            "customer_id": "CUS000005",
            "gender": "Female",
            "dob": "1998-05-15",
            "city": "Noida",
            "alternate_mobile": "9811223344",
            "home_address": "Flat 402, Sunshine Apartments, Sector 62",
            "office_address": "Tower A, Tech Park, Sector 135",
            "pin_code": "201301",
            "pincode": "201301",
            "reward_points": 0,
            "referral_code": "REF5021EB",
            "total_referrals": 0
        },
        "addresses": {
            "home": {
                "id": 6,
                "street_address": "Flat 402, Sunshine Apartments, Sector 62",
                "city": "Noida",
                "state": "UP",
                "pin_code": "201301"
            },
            "office": {
                "id": 7,
                "street_address": "Tower A, Tech Park, Sector 135",
                "city": "Noida",
                "state": "UP",
                "pin_code": "201301"
            }
        },
        "wallet": {
            "balance": 100,
            "currency": "INR"
        },
        "created_at": "2026-10-22T11:33:41+00:00"
    }
}
''';

    test('Parses exact Customer Edit Profile response cleanly', () {
      final json = jsonDecode(rawResponse) as Map<String, dynamic>;
      final parsed = UserProfileResponseModel.fromJson(json);

      expect(parsed.success, isTrue);
      expect(parsed.message, equals('Profile details updated successfully.'));
      expect(parsed.data, isNotNull);

      final profile = parsed.data!;
      expect(profile.id, equals(11));
      expect(profile.name, equals('Priya Verma'));
      expect(profile.displayName, equals('Priya Verma'));
      expect(profile.initials, equals('PV'));
      expect(profile.email, equals('amita@example.com'));
      expect(profile.phone, equals('9811223348'));
      expect(profile.formattedPhone, equals('+91 98112 23348'));
      expect(profile.effectiveGender, equals('Female'));
      expect(profile.effectiveDob, equals('1998-05-15'));
      expect(profile.effectiveCity, equals('Noida'));
      expect(profile.effectiveAlternateMobile, equals('9811223344'));
      expect(profile.formattedAlternatePhone, equals('+91 98112 23344'));
      expect(profile.effectivePinCode, equals('201301'));
      expect(profile.effectiveHomeAddress, contains('Sunshine Apartments'));
      expect(profile.effectiveOfficeAddress, contains('Tech Park'));

      // Customer Details
      expect(profile.customerDetails?.customerId, equals('CUS000005'));
      expect(profile.customerDetails?.referralCode, equals('REF5021EB'));
      expect(profile.customerDetails?.rewardPoints, equals(0));

      // Addresses Map
      expect(profile.addresses?.home?.id, equals(6));
      expect(profile.addresses?.home?.state, equals('UP'));
      expect(profile.addresses?.office?.id, equals(7));

      // Wallet
      expect(profile.wallet.balance, equals(100));
      expect(profile.wallet.currency, equals('INR'));
    });

    test('CustomerEditProfileRequest generates correct JSON payload', () {
      final request = CustomerEditProfileRequest(
        name: 'Priya Verma',
        gender: 'Female',
        dob: '1998-05-15',
        city: 'Noida',
        alternateMobile: '9811223344',
        pinCode: '201301',
        homeAddress: 'Flat 402, Sunshine Apartments, Sector 62',
        officeAddress: 'Tower A, Tech Park, Sector 135',
      );

      final json = request.toJson();
      expect(json['name'], equals('Priya Verma'));
      expect(json['gender'], equals('Female'));
      expect(json['dob'], equals('1998-05-15'));
      expect(json['city'], equals('Noida'));
      expect(json['alternate_mobile'], equals('9811223344'));
      expect(json['pin_code'], equals('201301'));
      expect(json['home_address'], equals('Flat 402, Sunshine Apartments, Sector 62'));
      expect(json['office_address'], equals('Tower A, Tech Park, Sector 135'));
    });

    testWidgets('EditProfileScreen renders all form fields and save button',
        (WidgetTester tester) async {
      final profile = UserProfileModel.defaultFallback();
      await tester.pumpWidget(MaterialApp(
        home: EditProfileScreen(profile: profile),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Personal Identity'), findsOneWidget);
      expect(find.text('Contact Information'), findsOneWidget);
      expect(find.text('Address & Location'), findsOneWidget);
      expect(find.text('UPDATE PROFILE'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Registered Mobile Number (Primary)'), findsOneWidget);
    });
  });
}
