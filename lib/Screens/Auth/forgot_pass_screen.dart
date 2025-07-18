import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fuel_route/Component/round_button.dart';
import 'package:fuel_route/Component/round_textfield.dart';
import 'package:fuel_route/Utils/app_colors.dart';
import 'package:fuel_route/Utils/utils.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();
  bool _loading = false;

  Future<void> _sendResetLink() async {
    setState(() => _loading = true);

    final email = emailController.text.trim();
    final dbRef = FirebaseDatabase.instance.ref().child("users");

    try {
      final snapshot = await dbRef.orderByChild("email").equalTo(email).get();

      if (!snapshot.exists) {
        Utils.flushBarErrorMessage('No user found with this email.', context);
        setState(() => _loading = false);
        return;
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        Utils.flushBarErrorMessage(
          'Password reset link sent to your email.',
          context,
          success: true,
        );
        // ✅ Clear email field and dismiss keyboard
        emailController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      debugPrint(e.toString());
      Utils.flushBarErrorMessage(
        'Something went wrong. Please try again.',
        context,
      );
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.whiteColor,
            fontFamily: "Eurostile",
          ),
        ),
        foregroundColor: AppColors.whiteColor,
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.splashBgColor,
      ),

      backgroundColor: AppColors.splashBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Enter your email and will send you instruction on how to reset it",

                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.whiteColor,
                  fontFamily: "Eurostile",
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundTextField(
                      bgColor: AppColors.splashBgColor,
                      label: "Email Address",
                      hint: "Email",
                      inputType: TextInputType.emailAddress,
                      textEditingController: emailController,
                      validatorValue: "Please enter a valid email",
                      focusNode: emailFocusNode,
                    ),
                    const SizedBox(height: 20),
                    RoundButton(
                      title: "Send ",
                      loading: _loading,

                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          _sendResetLink();
                        }
                      },
                      borderRadius: 30,
                      fontSize: 18,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
