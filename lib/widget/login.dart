import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
GoogleSignIn _googleSignIn = GoogleSignIn();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void _signInWithGoogle() async {
    await _auth.signOut();

    final GoogleSignInAccount gsa = await _googleSignIn.signIn();
    final GoogleSignInAuthentication gsauth = await gsa.authentication;
    final AuthCredential ac = GoogleAuthProvider.getCredential(
        idToken: gsauth.idToken, accessToken: gsauth.accessToken);
    await _auth.signInWithCredential(ac);
  }

  Future<bool> _showcontent() async {
    return await showDialog<bool>(
      context: context, barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Data will not be saved'),
          content: new SingleChildScrollView(
            child: RichText(
                text: TextSpan(
                    text: 'We cant save like this link later to save Progress',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red))),
          ),
          actions: [
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _signInAnonymously() async {
    if (await _showcontent()) {
      await _auth.signOut();
      await _auth.signInAnonymously();
    }
  }

  void _linkWithGoogleAccount() async {
    final GoogleSignInAccount gsa = await _googleSignIn.signIn();
    final GoogleSignInAuthentication gsauth = await gsa.authentication;
    final AuthCredential ac = GoogleAuthProvider.getCredential(
        idToken: gsauth.idToken, accessToken: gsauth.accessToken);
    final currentUser = await _auth.currentUser();
    currentUser.linkWithCredential(ac);
  }

  void signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text("Login First Please"),
          RaisedButton(
            onPressed: _signInWithGoogle,
            child: Text("Sign in with Google"),
          ),
          RaisedButton(
            onPressed: _signInAnonymously,
            child: Text("Sign in Anonymously"),
          ),
          RaisedButton(
            onPressed: _linkWithGoogleAccount,
            child: Text("Link with Google"),
          ),
          RaisedButton(
            onPressed: signOut,
            child: Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}
