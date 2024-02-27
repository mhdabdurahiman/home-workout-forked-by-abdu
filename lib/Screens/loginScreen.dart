import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_workout/Screens/home/navigation.dart';
import 'package:home_workout/Screens/signUp_Screens/signup.dart';
import 'package:home_workout/common/toast.dart';
import 'package:home_workout/firebaseimplimantation/firebase_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool obscureText = false;
  bool _isSigning = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkAuthenticationStatus();
  }

  void checkAuthenticationStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool isLoggedIn = sharedPreferences!.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) =>  BottomNavigationBarWorkout()));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Image(image: AssetImage("assets/login.jpg")),
                const Text(
                  'LOGIN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'EMAIL',
                              hintText: 'EMAIL',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            obscureText: obscureText,
                            controller: _passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'PASSWORD',
                              hintText: 'PASSWORD',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                                icon: const Icon(Icons.remove_red_eye_sharp),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _signIn();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Column(
                          children: [
                            const Center(child: Text('OR')),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _signInWithGoogle();
                                  },
                                  icon: const Image(
                                    image: AssetImage('assets/google.png'),
                                    width: 20,
                                  ),
                                  label: const Text(
                                    'Sign-in with Google',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SignUpScreen()));
                              },
                              child: const Text.rich(
                                TextSpan(
                                  text: 'Dont have an account?',
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Signup',
                                      style: TextStyle(color: Colors.purple),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _signIn() async {
    setState(() {
      _isSigning = true;
    });
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    User? user = await _auth.signInWithEmailAndPassword(email, password);
    setState(() {
      _isSigning = false;
    });
    if (user != null) {
      print('successfully created');
      sharedPreferences!.setBool('isLoggedIn', true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => BottomNavigationBarWorkout()));
    } else {
      showToast(message: 'Some error happened');
    }
  }

  _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        sharedPreferences!.setBool('isLoggedIn', true);
        await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=>BottomNavigationBarWorkout()), (route) => false);
      }
    } catch (e) {
      showToast(message: 'Some error happened: $e');
    }
  }
}
