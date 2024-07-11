import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invoice_flutter/Models/LoginModel.dart';
import 'package:invoice_flutter/Models/RegisterModel.dart';
import 'package:invoice_flutter/Utils/BaseURL.dart';
import 'package:invoice_flutter/dashboard/DashboardScreen.dart';
import 'package:invoice_flutter/login/LoginScreen.dart';
import 'package:invoice_flutter/register/RegisterScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      String Firstname = _firstnameController.text;
      String LastName = _lastnameController.text;
      String PhoneNumber = _phonenumberController.text;
      String password = _passwordController.text;

      RegisterModel registerModel = RegisterModel(
        firstname: Firstname,
        lastname: LastName,
        phonenumber: PhoneNumber,
        Password: password,
      );

      print(registerModel.toJson());
      try {
        final Uri url = Uri.parse(BaseURL.USER_REGISTRATION);
        print('URL: ${url.toString()}');
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(registerModel.toJson()),
        );
        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User Created Successfully',
                style: TextStyle(color: Colors.red.shade300, fontSize: 18.0),
              ),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                      controller: _firstnameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your First Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: _lastnameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Last Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: _phonenumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Phone Number';
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
                              'Register',
                              style: TextStyle(color: Colors.white, fontSize: 18.0),
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
