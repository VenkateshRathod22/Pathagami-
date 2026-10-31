import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripried/main.dart';
import 'package:tripried/view/auth/presentations/screen/login_screen.dart';
import 'package:tripried/view/auth/presentations/screen/signup_sccreen.dart';
import 'package:tripried/view/splash_screen/splace_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_booking_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_screen.dart';

import 'package:tripried/view/account/sub_features/personal_info/presentations/screen/personal_info_screen.dart';

void main() {
  testWidgets('SplaceScreen launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplaceScreen), findsOneWidget);
    expect(find.text('SMART BUS & RIDE BOOKING'), findsOneWidget);
    expect(find.text('Safe & Verified'), findsOneWidget);
    expect(find.text('Live GPS'), findsOneWidget);
  });

  testWidgets('SignupSccreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SignupSccreen(),
    ));

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    expect(find.text('Sign up with Google'), findsOneWidget);
    expect(find.text('Log In'), findsWidgets);
  });

  testWidgets('LoginScreen smoke test with live fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('Demo User'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.textContaining('Sign Up'), findsWidgets);
  });

  testWidgets('BusScreen smoke test with search card and routes', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BusScreen(),
    ));

    expect(find.text('Bus Tickets'), findsOneWidget);
    expect(find.text('Search buses'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets('BusBookingScreen smoke test with filters and CTA', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: BusBookingScreen(fromCity: 'Delhi', toCity: 'Lucknow'),
    ));

    expect(find.text('Delhi'), findsOneWidget);
    expect(find.text('Lucknow'), findsOneWidget);
  });

  testWidgets('PersonalInfoScreen renders all sections, fields and save button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PersonalInfoScreen(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Account & Contact Details'), findsOneWidget);
    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('Wallet & Loyalty Benefits'), findsOneWidget);
    expect(find.text('SIGN OUT OF ACCOUNT'), findsOneWidget);
    expect(find.text('Edit'), findsWidgets);
  });
}
