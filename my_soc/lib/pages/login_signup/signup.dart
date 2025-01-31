import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_soc/routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name = "";
  bool isLogin = false;
  final _formKey = GlobalKey<FormState>();
  String customMsg = "";

  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  Future<void> createUserAccount(BuildContext context) async {
    try {
      final userCreds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmailController.text.trim(),
        password: userPasswordController.text.trim(),
      );
      customMsg = "Account created successfully!";
      print("Created user account");

      // Jumping onto the Verifying Email stage
      await Future.delayed(const Duration(seconds: 3));
      await Navigator.pushNamed(context, MySocRoutes.emailVerify);

    } on FirebaseAuthException catch (e) {
      // This message is to be displayed on the screen as a popup in case of some errors
      customMsg = e.message.toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: AnimationLimiter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 800),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFFE94560),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE94560).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // FadeInAnimation for "Create Account"
                        FadeInAnimation(
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimationConfiguration.synchronized(
                          duration: const Duration(milliseconds: 1000),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: userEmailController,
                                      enabled: !isLogin,
                                      style: const TextStyle(color: Colors.black), // Changed to black
                                      decoration: InputDecoration(
                                        hintText: isLogin ? name : "Enter Email",
                                        hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5), // Changed to black
                                        ),
                                        labelText: "Email",
                                        labelStyle: const TextStyle(
                                          color: Colors.black, // Changed to black
                                          fontSize: 16,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.email,
                                          color: Color(0xFFE94560),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE94560),
                                            width: 2,
                                          ),
                                        ),
                                        fillColor: Colors.white.withOpacity(0.8), // Added fill color
                                        filled: true, // Added fill
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return "Email cannot be empty";
                                        }
                                        if (!value!.contains('@')) {
                                          return "Please enter a valid email";
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        name = value;
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: userPasswordController,
                                      obscureText: true,
                                      enabled: !isLogin,
                                      style: const TextStyle(color: Colors.black), // Changed to black
                                      decoration: InputDecoration(
                                        hintText: "Enter Password",
                                        hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5), // Changed to black
                                        ),
                                        labelText: "Password",
                                        labelStyle: const TextStyle(
                                          color: Colors.black, // Changed to black
                                          fontSize: 16,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Color(0xFFE94560),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE94560),
                                            width: 2,
                                          ),
                                        ),
                                        fillColor: Colors.white.withOpacity(0.8), // Added fill color
                                        filled: true, // Added fill
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return "Password cannot be empty";
                                        }
                                        if (value!.length < 6) {
                                          return "Password must be at least 6 characters";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await createUserAccount(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFFE94560).withOpacity(0.5),
                          ),
                          child: isLogin
                              ? const Icon(Icons.done, color: Colors.white)
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.white, // Changed to white
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (customMsg.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (customMsg.contains('success')
                                        ? Colors.green
                                        : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (customMsg.contains('success')
                                          ? Colors.green
                                          : Colors.red)
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                customMsg,
                                style: TextStyle(
                                  color: customMsg.contains('success')
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}