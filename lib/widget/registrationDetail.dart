import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mmb2/models/globals.dart';
import 'package:mmb2/models/mode.dart';

class RegistrationDetail extends StatefulWidget {
  RegistrationDetail({Key key, @required this.uid}) : super(key: key);

  final String uid;

  @override
  _RegistrationDetailState createState() => _RegistrationDetailState();
}

class _RegistrationDetailState extends State<RegistrationDetail> {
  final _formKey = GlobalKey<FormState>();
  final nameTextField = TextEditingController();
  final uniqueIdTextField = TextEditingController();
  //final nameTextField = TextEditingController();

  //_RegistrationDetailState({@required this.uid});

  String avatarUrl;
  StorageReference storageReference;
  Mode mode = Mode.Read;

  @override
  void initState() {
    super.initState();
    storageReference = FirebaseStorage().ref().child("gs://${widget.uid}");

    storageReference.getDownloadURL().then((value) => setState(() {
          avatarUrl = value;
        }));
  }

  File avatarFile;

  @override
  void dispose() {
    nameTextField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(35.0, 5.0, 35.0, 0),
          child: Column(children: [
            avatarFile != null
                ?  CircleAvatar(
                  radius: 100,
                backgroundImage: FileImage(
                    avatarFile,
                  ),
                  )
                : avatarUrl == null
                    ? Text("Checking Any uploaded image")
                    :  CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(
                        avatarUrl,
                      )
                    ),
            mode == Mode.Write ? FlatButton(
              child: Icon(
                Icons.file_upload,
                size: 40,
              ),
              onPressed: uploadAvatar,
            ) : Container(),
            Text("Upload your avatar picture"),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(35.0, 5.0, 35.0, 0),
          child: TextFormField(
            controller: nameTextField,
            readOnly: mode == Mode.Read,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                hintStyle: const TextStyle(color: Colors.grey),
                hintText: "Name",
                fillColor: Colors.white70),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(35.0, 5.0, 35.0, 0),
          child: TextFormField(
            controller: uniqueIdTextField,
             readOnly: mode == Mode.Read,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your Unique Id';
              }
              return null;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                hintStyle: const TextStyle(color: Colors.grey),
                hintText: "Unique Id",
                fillColor: Colors.white70),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(35.0, 5.0, 35.0, 0),
          child :mode == Mode.Write ?  RaisedButton(
            onPressed: () async {
              setState(() {
                isBusy = true;
              });
              // Validate returns true if the form is valid, otherwise false.
              if (_formKey.currentState.validate()) {
                if (await isUniqueId(widget.uid, uniqueIdTextField.text)) {
                  final FirebaseMessaging _firebaseMessaging =
                      new FirebaseMessaging();
                  var deviceId = await _firebaseMessaging.getToken();
                  await Firestore.instance
                      .collection('user')
                      .document(widget.uid)
                      .setData({
                    'uid': widget.uid,
                    'name': nameTextField.text,
                    'imageUrl': avatarUrl,
                    'deviceId': deviceId

                  });

                  setState(() {
                    mode = Mode.Write;
                  });
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content:
                          Text('This Unique Id is already taken try other')));
                }
                setState(() {
                  isBusy = false;
                });
              }
            },
            child: Text('Register'),
          ) : Text('Registering......'),
        ),
      ]),
    );
  }

  Future<bool> isUniqueId(String uid, String uniqueId) async {
    var uniqueIdDoc = await Firestore.instance
        .collection('uniqueId')
        .document(uniqueId)
        .get();
    if (!uniqueIdDoc.exists)
      await Firestore.instance
          .collection('uniqueId')
          .document(uniqueId)
          .setData({'uid': uid});
    uniqueIdDoc = await Firestore.instance
        .collection('uniqueId')
        .document(uniqueId)
        .get();
    return uniqueIdDoc["uid"] == uid;
  }

  void uploadAvatar() async {
    avatarFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 50);
    if (avatarFile != null)
      await storageReference.putFile(avatarFile).onComplete;
    storageReference.getDownloadURL().then((value) => setState(() {
          avatarUrl = value;
        }));
  }
}
