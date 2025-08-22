import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Component/round_textfield.dart';
import 'package:fuel_route/Screens/Auth/forgot_pass_screen.dart';
import 'package:fuel_route/Screens/Auth/signup_screen.dart';
import 'package:fuel_route/Services/auth_services.dart';
import 'package:fuel_route/Utils/animated_page_route.dart';
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
  // bool _facebookSigninLoading = false;

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
        onComplete: () async {
          setState(() => _loading = false);
          // final hasLocation = await isLocationSaved();

          // if (!mounted) return;

          // if (hasLocation) {
          // Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
          // } else {
          //   Navigator.pushReplacementNamed(
          //     context,
          //     RouteNames.askLocationScreen,
          //   );
          // }
        },
      );
    }
  }

  // void _signInWithFacebook() {
  //   final authService = AuthService();

  //   authService.signInWithFacebook(
  //     context: context,
  //     onStart: () => setState(() => _facebookSigninLoading = true),
  //     onComplete: () {
  //       if (mounted) setState(() => _facebookSigninLoading = false);
  //     },
  //   );
  // }

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
              mainAxisAlignment: MainAxisAlignment.center,
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
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Sign in With Your Account',
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.whiteColor,
                      fontFamily: "Eurostile",
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // const Padding(
                //   padding: EdgeInsets.symmetric(vertical: 30),
                //   child: Text(
                //     textAlign: TextAlign.center,
                //     "Trucking 100 is a smart assistant for truck drivers,offering AI-powered trip planning, fuel management,and real-time insights to boost efficiency on the road.",
                //     style: TextStyle(
                //       fontFamily: "Eurostile",
                //       fontSize: 14,
                //       fontWeight: FontWeight.normal,
                //       color: AppColors.greyColor,
                //     ),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
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
                        navigateWithAnimation(context, const SignupScreen());
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
                          navigateWithAnimation(
                            context,
                            const ForgetPassScreen(),
                          );
                        },
                        child: const Text(
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
                              leadingIcon: FontAwesomeIcons.google,
                              loading: _googleSigninLoading,
                              borderRadius: 30,
                              title: 'Sign in with Google',
                              fontSize: 18,
                              onPress: _signInWithGoogle,
                            ),
                            // RoundButton(
                            //   titleColor: AppColors.lightBlueColor,
                            //   bgColor: AppColors.whiteColor,
                            //   // loading: _loading,
                            //   borderRadius: 30,
                            //   loading: _facebookSigninLoading,
                            //   leadingIcon: FontAwesomeIcons.squareFacebook,
                            //   title: 'Sign in with Facebook',
                            //   fontSize: 18,
                            //   onPress: _signInWithFacebook,
                            // ),
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
