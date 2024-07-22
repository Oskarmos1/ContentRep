import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

String errorMessage = "";

class _signUpState extends State<signUp> {
  String? vId;
  String verificationCode = "";
  Future<bool> completePhoneVerification(String enteredCode) async {
    try {
      // Create the PhoneAuthCredential using the verification ID and entered code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId:
            vId!, // Access the verificationId from the global variable or parameter
        smsCode: enteredCode,
      );

      // Sign in with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // User is now authenticated
      User user = userCredential.user!;
      print("Authentication successful for user: ${user.uid}");
      // Code is valid
      return true;
    } catch (e) {
      // Handle authentication errors
      print("Error occurred during authentication: $e");
      // Code is invalid or an error occurred during authentication
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  bool canSubmit = false;
  bool isValid = false;
  String phoneNumber = "";
  double buttonOpacity = 0;
  double verificationOpacity = 0;
  double instructionOpacity = 0;
  double waitingOpacity = 0;
  @override
  Widget build(BuildContext context) {
    if (canSubmit == true) {
      verificationOpacity = 1;
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                phoneNumber = number.phoneNumber!;
              },
              onInputValidated: (dynamic value) {
                isValid = value;
                setState(() {
                  if (value == false) {
                    setState(() {
                      buttonOpacity = 0;
                    });
                  } else {
                    setState(() {
                      buttonOpacity = 1;
                    });
                  }
                });
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              inputBorder: const OutlineInputBorder(),
            ),
            Opacity(
              opacity: buttonOpacity,
              child: TextButton(
                  child: Text("Send verification to: $phoneNumber"),
                  onPressed: () async {
                    if (isValid == true) {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: phoneNumber,
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException e) {
                          setState(() {
                            errorMessage =
                                "$e Please restart the application and if the issue persists, please try again later.";
                          });
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          setState(() {
                            waitingOpacity = 1;
                          });
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {
                          setState(() {
                            vId = verificationId;
                            canSubmit = true;
                            waitingOpacity = 0;
                          });
                        },
                      );
                    }
                  }),
            ),
            Opacity(
              opacity: waitingOpacity,
              child: const Text("Please wait."),
            ),
            Opacity(
              opacity: verificationOpacity,
              child: TextField(
                //controller: _controller,
                onChanged: (text) {
                  if (canSubmit == true) {
                    setState(() {
                      verificationCode = text;
                    });
                  }
                },
              ),
            ),
            Opacity(
                opacity: verificationOpacity,
                child: TextButton(
                    child: Text(
                        "Check your verification code is: $verificationCode"),
                    onPressed: () async {
                      if (mounted) {
                        if (canSubmit == true) {
                          bool isCodeValid =
                              await completePhoneVerification(verificationCode);
                          if (isCodeValid == true) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('phoneNumber', phoneNumber);
                            Navigator.pushReplacementNamed(
                                context, '/userName');
                          } else {
                            setState(() {
                              canSubmit = false;
                              verificationOpacity = 0;
                              errorMessage =
                                  "The verification process has not worked. Please check you have put in the correct phone number (your phone number) and then press to get a new verification code.";
                            });
                          }
                        }
                      }
                    })),
            Text(errorMessage),
          ],
        ),
      ),
    );
  }
}
