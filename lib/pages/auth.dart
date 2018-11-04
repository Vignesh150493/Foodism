import 'package:flutter/material.dart';
import 'home.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() {
    return new _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String _email;
  String _password;
  bool _acceptTerms = false;

//  9444957235 - Jai cable n/w
  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
        //dstATop means, we are putting our color (Colors.black.withOpacity(0.5)), on top of the image.
        image: AssetImage('assets/background.jpg'),
        fit: BoxFit.cover);
  }

  Widget _buildEmailTextField() {
    return TextField(
      decoration: InputDecoration(
          labelText: 'Email', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          _email = value;
        });
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      onChanged: (value) {
        setState(() {
          _password = value;
        });
      },
    );
  }

  Widget _buildAcceptConditionSwitch() {
    return SwitchListTile(
      value: _acceptTerms,
      onChanged: (value) {
        setState(() {
          _acceptTerms = value;
        });
      },
      title: Text('Accept T&C'),
    );
  }

  void submitForm() {
    print(_email);
    print(_password);
    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
          ),
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildEmailTextField(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _buildPasswordTextField(),
                  _buildAcceptConditionSwitch(),
                  SizedBox(
                    height: 10.0,
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text("LOGIN"),
                    onPressed: submitForm,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
