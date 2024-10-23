import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_shark/DatabaseHelper.dart';
import 'package:loan_shark/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();
  late final db;

  void initialiseDB() async {
    db = await dbHelper.database;
    // final user=User(userName: 'admin', password: 'admin', displayName: 'VAZIR');
    // dbHelper.insertUser(user.toMap());
  }

  @override
  void initState() {
    initialiseDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children:[ Center(
          child: SingleChildScrollView(
            // For keyboard avoidance
            child: Padding(
              padding: EdgeInsets.all(height * 0.020),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: width * 0.30),
                elevation: 15,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(height * 0.030),
                  child: FocusScope(
                    onKey: (FocusNode node, RawKeyEvent event) {
                      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                        // Submit the form
                        if (_formKey.currentState!.validate()) {
                          // ... (your authentication logic) ...
                          login(_usernameController.text, _passwordController.text);
                        }
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Logo or Name (Optional)
                          // Image.asset('assets/logo.png'),
                          // SizedBox(height: 20),
                          Text(
                            'VAZIR FINANCE LTD',
                            style: TextStyle(
                              fontSize: height * 0.030,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.030),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: height * 0.020),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: height * 0.030),
                          ElevatedButton(
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                                final username = _usernameController.text;
                                final password = _passwordController.text;

                                // Authenticate user
                               login(username, password);
                               }
                            },
                            style: ElevatedButton.styleFrom(
                              //backgroundColor: Colors.blue, // Accent color
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.050,
                                vertical: height * 0.015,
                              ),
                              textStyle: TextStyle(fontSize: height * 0.018),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Login'),
                          ),
                          SizedBox(height: height * 0.015),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Navigate to forgot password screen
                                _showChangePasswordDialog(context);
                              },
                              child: const Text('Change Password?'),
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
          Positioned( // Position the watermark
            bottom: height * 0.02, // Adjust position as needed
            right: width * 0.02, // Adjust position as needed
            child: Text(
              'Async IT',
              style: TextStyle(
                fontSize: height * 0.025,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.5), // Adjust opacity
              ),
            ),
          ),
        ]
      ),
    );
  }

  void login(String userName, String password) async{
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Authenticate user
    try {
      final user = await dbHelper.getUser(username);
      if (user != null &&
          user.password ==
              password) {
        // Login successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Login Successfully')),
        );
        // Navigate to home screen or perform other actions
        print("Login SUCCESSFULLY");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Login failed
        // Display error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Invalid username or password')),
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('${e.toString()}')));
    }

  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
      final newPasswordController = TextEditingController();
      final oldPasswordController = TextEditingController();
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Theme( // Apply custom dialog theme
            data: Theme.of(context).copyWith(
              dialogTheme: DialogTheme(
                backgroundColor: Colors.white,
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                contentTextStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder( // Add rounded corners
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Row( // Add icon to title
                children: [
                  const Icon(Icons.lock),
                  SizedBox(width: width*0.080),
                  const Text('Change Password'),
                ],
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: width*0.020,vertical: height*0.020), // Add padding
              actionsPadding: EdgeInsets.symmetric(horizontal: width*0.016),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Old Password'),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'New Password'),
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton( // Use ElevatedButton with custom style
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Colors.blue,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Colors.blue,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  child: const Text('Update'),
                  onPressed: () async{
                    final oldPassword = oldPasswordController.text;
                    final newPassword = newPasswordController.text;
                    final username = _usernameController.text; // Get username from login screen

                    final user = await dbHelper.getUser(username);

                    if(user==null){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please Enter Username')),
                      );
                    }

                    if (user != null && user.password == oldPassword) {
                      // Old password is correct, update password in database
                      await dbHelper.updateUserPassword(username, newPassword);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated successfully')),
                      );
                    } else {
                      // Incorrect old password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect old password')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );

  }
}
