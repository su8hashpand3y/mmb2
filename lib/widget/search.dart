//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmb2/models/mode.dart';
import 'package:mmb2/models/user.dart';
import '../models/searchResult.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Mode mode = Mode.Write;
  String searchTerm = '';
  final searchTextField = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<User> user = new List<User>();

  void sendResult() {
    Navigator.pop(context, SearchResult(searchTerm: "Hello Ji"));
  }

  void sendNonResult() {
    Navigator.pop(context, SearchResult());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("jio"),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: 
            
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(35.0, 5.0, 35.0, 0),
                      child: TextFormField(
                        controller: searchTextField,
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
                  ),
                // RaisedButton(child: Text("Sarch"), onPressed: startSearch,)
          
        ));
  }

  void startSearch() {
    setState(() {
      searchTerm = searchTextField.text;
    });
  }
}
