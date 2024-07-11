import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invoice_flutter/Models/LoginModel.dart';
import 'package:invoice_flutter/Utils/BaseURL.dart';
import 'package:invoice_flutter/dashboard/DashboardScreen.dart';
import 'package:invoice_flutter/register/RegisterScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      String username = _usernameController.text;
      String password = _passwordController.text;

      LoginModel loginModel = LoginModel(
        Username: username,
        Password: password,
      );

      print(loginModel.toJson());
      try {
        final Uri url = Uri.parse(BaseURL.LOGIN);
        print('URL: ${url.toString()}');
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(loginModel.toJson()),
        );
        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final Map<String, dynamic> responseData = json.decode(response.body);

          prefs.setString("UserID", responseData['pid'].toString());
          prefs.setString("Password", password);
          prefs.setString("FNAME", responseData['fname'].toString());
          prefs.setString("LNAME", responseData['lname'].toString());
          prefs.setString("PHONE", responseData['phone'].toString());

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid username or password',
                style: TextStyle(color: Colors.red.shade300, fontSize: 18.0),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 100.0,
                child: Image.asset('assets/images/logo.png'),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                       onPressed: _loading ? null : _submitForm,
                      
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 86, 141, 218),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 50.0),
                        ),
                      ),
                      child: _loading
                          ? CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                            ),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Dont have an account? Register',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
