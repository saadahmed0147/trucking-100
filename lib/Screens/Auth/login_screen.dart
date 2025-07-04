import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Component/round_textfield.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Services/auth_services.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/Utils/utils.dart';
import 'package:fuel_route/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _loading = false;
  bool _googleSigninLoading = false;
  final _firebaseAuth = FirebaseAuth.instance;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // login with email
  void _handleEmailLogin() {
    if (_formKey.currentState!.validate()) {
      final authService = AuthService();
      authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        context: context,
        onStart: () => setState(() => _loading = true),
        onComplete: () => setState(() => _loading = false),
      );
    }
  }

  void _signInWithFacebook() {
    final authService = AuthService();

    authService.signInWithFacebook(
      context: context,
      onStart: () => setState(() => _googleSigninLoading = true),
      onComplete: () {
        if (mounted) setState(() => _googleSigninLoading = false);
      },
    );
  }

  void _signInWithGoogle() {
    final authService = AuthService();

    authService.signInWithGoogle(
      context: context,
      onStart: () => setState(() => _googleSigninLoading = true),
      onComplete: () {
        if (mounted) setState(() => _googleSigninLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.splashBgColor,

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: SizedBox(
                    height: mq.height * 0.18,

                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    textAlign: TextAlign.center,
                    'We will send your package or anything to your destination We will send your package or anything to your destination We will ckage or anything to your destination We will send your package or anything to your destination.',
                    style: TextStyle(
                      fontFamily: "Eurostile",
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sign in",
                      style: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.signupScreen);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            RoundTextField(
                              label: 'Email',
                              bgColor: AppColors.splashBgColor,
                              hint: 'johndoe@gmail.com',
                              inputType: TextInputType.emailAddress,
                              // prefixIcon: Icons.email,
                              textEditingController: emailController,
                              validatorValue: 'Please Enter Email',
                              focusNode: emailFocusNode,
                              onFieldSubmitted: (value) {
                                Utils.fieldFocusNode(
                                  context,
                                  emailFocusNode,
                                  passFocusNode,
                                );
                              },
                            ),
                            RoundTextField(
                              label: 'Password',
                              hint: 'Password',
                              inputType: TextInputType.name,
                              bgColor: AppColors.splashBgColor,
                              // prefixIcon: Icons.lock,
                              textEditingController: passwordController,
                              isPasswordField: true,
                              validatorValue: 'Please Enter Password',
                              focusNode: passFocusNode,
                              onFieldSubmitted: (value) {
                                _handleEmailLogin();
                              },
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.forgotPassScreen,
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontFamily: "Eurostile",
                            color: AppColors.greyColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          spacing: 20,
                          children: [
                            RoundButton(
                              loading: _loading,
                              borderRadius: 30,
                              title: 'Sign in',
                              fontSize: 18,
                              onPress: () {
                                if (_formKey.currentState!.validate()) {
                                  _handleEmailLogin();
                                }
                              },
                            ),

                            RoundButton(
                              titleColor: AppColors.lightBlueColor,
                              bgColor: AppColors.whiteColor,
                              leadingIcon: FontAwesomeIcons.squareFacebook,
                              // loading: _loading,
                              borderRadius: 30,
                              title: 'Sign in with Google',
                              fontSize: 18,
                              onPress: _signInWithGoogle,
                            ),
                            RoundButton(
                              titleColor: AppColors.lightBlueColor,
                              bgColor: AppColors.whiteColor,
                              // loading: _loading,
                              borderRadius: 30,
                              leadingIcon: FontAwesomeIcons.google,
                              title: 'Sign in with Facebook',
                              fontSize: 18,
                              onPress: _signInWithFacebook,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
