import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mmb2/widget/homePage.dart';
import 'package:mmb2/widget/registrationDetail.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
GoogleSignIn _googleSignIn = GoogleSignIn();

class Register extends StatefulWidget {
  Register(
      {Key key,
      @required this.uid,
      @required this.isAnonymous,
      @required this.onUserLinkedOrRegistered})
      : super(key: key);

  final String uid;
  bool isAnonymous;
  final Function(int) onUserLinkedOrRegistered;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  void _linkWithGoogleAccount() async {
    final GoogleSignInAccount gsa = await _googleSignIn.signIn();
    final GoogleSignInAuthentication gsauth = await gsa.authentication;
    final AuthCredential ac = GoogleAuthProvider.getCredential(
        idToken: gsauth.idToken, accessToken: gsauth.accessToken);
    final currentUser = await _auth.currentUser();
    try {
      await currentUser.linkWithCredential(ac).then((value) => () {
            setState(() {
              widget.isAnonymous = value.user.isAnonymous;
            });
          });
    } on PlatformException catch (e) {
      if (e.code == 'ERROR_CREDENTIAL_ALREADY_IN_USE')
        print("Already associated");
    }

    widget.onUserLinkedOrRegistered(1);
  }

  void signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView (
          child: Center(
          child: Column(
        children: <Widget>[
          getLinkWidget(),
          Text('${widget.uid}${widget.isAnonymous}'),
          Tab(icon: Icon(Icons.threesixty)),
        ],
      )),
    );
  }

  Widget getLinkWidget() {
    if (widget.isAnonymous)
      return Column(
        children: [
          Text("Link"),
          FlatButton(
            child: Text("Link With Google"),
            onPressed: _linkWithGoogleAccount,
          ),
        ],
      );
    else
      return RegistrationDetail(uid: mainUser.uid,);
  }
}
