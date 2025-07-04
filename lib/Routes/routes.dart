import 'package:flutter/material.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Screens/Auth/forgot_pass_screen.dart';
import 'package:fuel_route/Screens/Auth/login_screen.dart';
import 'package:fuel_route/Screens/Auth/signup_screen.dart';
import 'package:fuel_route/Screens/Home/home_screen.dart';
import 'package:fuel_route/Screens/Payment/payment_screen.dart';
import 'package:fuel_route/Screens/Splash/find_places_screen.dart';
import 'package:fuel_route/Screens/Splash/get_updated_screen.dart';
import 'package:fuel_route/Screens/Splash/navigate_screen.dart';
import 'package:fuel_route/Screens/Splash/plan_trip_screen.dart';
import 'package:fuel_route/Screens/Splash/splash_screen.dart';
import 'package:fuel_route/Screens/Splash/welcome_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      //splash
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case RouteNames.welcomeScreen:
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      case RouteNames.findPlacesScreen:
        return MaterialPageRoute(
          builder: (context) => const FindPlacesScreen(),
        );
      case RouteNames.getUpdatedScreen:
        return MaterialPageRoute(
          builder: (context) => const GetUpdatedScreen(),
        );
      case RouteNames.navigateScreen:
        return MaterialPageRoute(builder: (context) => const NavigateScreen());
      case RouteNames.planTripScreen:
        return MaterialPageRoute(builder: (context) => const PlanTripScreen());

      // payment

      case RouteNames.paymentScreen:
        return MaterialPageRoute(builder: (context) => const PaymentScreen());
      //auth
      case RouteNames.loginScreen:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case RouteNames.signupScreen:
        return MaterialPageRoute(builder: (context) => const SignupScreen());
      case RouteNames.forgotPassScreen:
        return MaterialPageRoute(
          builder: (context) => const ForgetPassScreen(),
        );

      //home

      case RouteNames.homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeScreen());

      default:
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('No Route Found!'))),
        );
    }
  }
}
