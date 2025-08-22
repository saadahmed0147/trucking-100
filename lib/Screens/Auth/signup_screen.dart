import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Component/round_textfield.dart';
import 'package:fuel_route/Screens/Auth/login_screen.dart';
import 'package:fuel_route/Services/auth_services.dart';
import 'package:fuel_route/Utils/animated_page_route.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/Utils/utils.dart';
import 'package:fuel_route/main.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passFocusNode = FocusNode();
  FocusNode confirmPassFocusNode = FocusNode();
  FocusNode mobileFocusNode = FocusNode();
  FocusNode buttonFocusNode = FocusNode();
  bool _googleSigninLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // void _signInWithFacebook() {
  //   final authService = AuthService();

  //   authService.signInWithFacebook(
  //     context: context,
  //     onStart: () => setState(() => _googleSigninLoading = true),
  //     onComplete: () {
  //       if (mounted) setState(() => _googleSigninLoading = false);
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

  void onSignUp() {
    if (passwordController.text != confirmPasswordController.text) {
      Utils.flushBarErrorMessage("Passwords do not match", context);
      return;
    }

    AuthService().signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phoneNumber: mobileController.text.trim(),
      context: context,
      onStart: () => setState(() => _loading = true),
      onComplete: () => setState(() => _loading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          foregroundColor: AppColors.whiteColor,
          backgroundColor: AppColors.splashBgColor,
        ),
        backgroundColor: AppColors.splashBgColor,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: mq.height * 0.16,

                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.fill,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 10, right: 30, left: 30),
                    child: Text(
                      textAlign: TextAlign.center,
                      'Signup With A New Account',
                      style: TextStyle(
                        fontSize: 25,
                        color: AppColors.whiteColor,
                        fontFamily: "Eurostile",
                      ),
                    ),
                  ),

                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                        RoundTextField(
                          label: 'Name',
                          hint: 'Name',
                          inputType: TextInputType.name,
                          focusNode: nameFocusNode,
                          bgColor: AppColors.splashBgColor,
                          textEditingController: nameController,
                          validatorValue: 'Please Enter Name',
                          onFieldSubmitted: (_) {
                            Utils.fieldFocusNode(
                              context,
                              nameFocusNode,
                              emailFocusNode,
                            );
                          },
                        ),

                        RoundTextField(
                          label: 'Email',
                          hint: 'Email',
                          bgColor: AppColors.splashBgColor,
                          inputType: TextInputType.emailAddress,

                          textEditingController: emailController,
                          validatorValue: 'Please Enter Email',
                          focusNode: emailFocusNode,
                          onFieldSubmitted: (_) {
                            Utils.fieldFocusNode(
                              context,
                              emailFocusNode,
                              passFocusNode,
                            );
                          },
                        ),

                        RoundTextField(
                          label: 'Create a password',
                          hint: 'Password',
                          inputType: TextInputType.visiblePassword,
                          bgColor: AppColors.splashBgColor,

                          textEditingController: passwordController,
                          isPasswordField: true,
                          validatorValue: 'Please Enter Password',
                          focusNode: passFocusNode,
                          onFieldSubmitted: (_) {
                            Utils.fieldFocusNode(
                              context,
                              passFocusNode,
                              confirmPassFocusNode,
                            );
                          },
                        ),
                        RoundTextField(
                          bgColor: AppColors.splashBgColor,
                          label: 'Confirm Password',
                          hint: 'Re-Password',
                          inputType: TextInputType.visiblePassword,
                          textEditingController: confirmPasswordController,
                          isPasswordField: true,
                          validatorValue: 'Please Confirm Password',
                          focusNode: confirmPassFocusNode,
                          onFieldSubmitted: (_) {
                            Utils.fieldFocusNode(
                              context,
                              confirmPassFocusNode,
                              mobileFocusNode,
                            );
                          },
                        ),
                        RoundTextField(
                          bgColor: AppColors.splashBgColor,
                          label: 'Confirm Password',
                          hint: 'Mobile',
                          inputType: TextInputType.number,
                          textEditingController: mobileController,

                          validatorValue: 'Please Enter Phone Number',
                          focusNode: mobileFocusNode,
                          onFieldSubmitted: (_) {
                            Utils.fieldFocusNode(
                              context,
                              mobileFocusNode,
                              buttonFocusNode,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      spacing: 20,
                      children: [
                        RoundButton(
                          focusNode: buttonFocusNode,
                          loading: _loading,
                          title: 'Sign Up',
                          borderRadius: 30,
                          fontSize: 18,
                          onPress: () {
                            if (_formKey.currentState!.validate()) {
                              onSignUp();
                            }
                          },
                        ),
                        RoundButton(
                          titleColor: AppColors.lightBlueColor,
                          bgColor: AppColors.whiteColor,
                          leadingIcon: FontAwesomeIcons.google,
                          loading: _googleSigninLoading,
                          borderRadius: 30,
                          title: 'Sign up with Google',
                          fontSize: 18,
                          onPress: _signInWithGoogle,
                        ),
                        // RoundButton(
                        //   titleColor: AppColors.lightBlueColor,
                        //   bgColor: AppColors.whiteColor,
                        //   // loading: _loading,
                        //   borderRadius: 30,
                        //   leadingIcon: FontAwesomeIcons.google,
                        //   title: 'Sign up with Facebook',
                        //   fontSize: 18,
                        //   onPress: _signInWithFacebook,
                        // ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: AppColors.greyColor),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () {
                          navigateWithAnimation(context, const LoginScreen());
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: AppColors.lightBlueColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
