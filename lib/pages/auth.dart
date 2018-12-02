import 'package:flutter/material.dart';
import '../scoped-models/main_scoped_model.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() {
    return new _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.LOGIN;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation =
        //Its like moved up twice its height at the beginning.
        Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
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
              child: Container(
                width: targetWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      _buildEmailTextField(),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildPasswordTextField(),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildPasswordConfirmTextField(),
                      _buildAcceptConditionSwitch(),
                      SizedBox(
                        height: 10.0,
                      ),
                      FlatButton(
                        child: Text(
                            'Switch to ${_authMode == AuthMode.LOGIN
                                ? 'SignUp'
                                : 'Login'}'),
                        onPressed: () {
                          if (_authMode == AuthMode.LOGIN) {
                            setState(() {
                              _authMode = AuthMode.SIGNUP;
                            });
                            _controller.forward();
                          } else {
                            setState(() {
                              _authMode = AuthMode.LOGIN;
                            });
                            _controller.reverse();
                          }
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      ScopedModelDescendant(
                        builder: (context, widget, MainScopedModel model) {
                          return model.isLoading
                              ? CircularProgressIndicator()
                              : RaisedButton(
                            textColor: Colors.white,
                            child: Text(_authMode == AuthMode.LOGIN
                                ? "LOGIN"
                                : "SIGNUP"),
                            onPressed: () =>
                                submitForm(model.authenticate),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        colorFilter:
        ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
        //dstATop means, we are putting our color (Colors.black.withOpacity(0.5)), on top of the image.
        image: AssetImage('assets/background.jpg'),
        fit: BoxFit.cover);
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Email', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Invalid password';
        }
      },
      onSaved: (value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          decoration: InputDecoration(
              labelText: 'Confirm Password',
              filled: true,
              fillColor: Colors.white),
          obscureText: true,
          validator: (String value) {
            if (_passwordTextController.text != value &&
                _authMode == AuthMode.SIGNUP) {
              return 'Passwords do not match';
            }
          },
        ),
      ),
    );
  }

  Widget _buildAcceptConditionSwitch() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Accept T&C'),
    );
  }

  void submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInfo;
    successInfo = await authenticate(
        _formData['email'], _formData['password'], _authMode);

    if (successInfo['success']) {
//      Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('ERROR'),
              content: Text(successInfo['message']),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK')),
              ],
            );
          });
    }
  }
}
