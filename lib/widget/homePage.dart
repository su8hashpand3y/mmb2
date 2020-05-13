import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:mmb2/models/searchResult.dart';
import 'package:mmb2/models/user.dart';
import 'package:mmb2/widget/register.dart';
import 'package:mmb2/widget/login.dart';
import 'package:mmb2/widget/search.dart';
import 'package:mmb2/widget/inbox.dart';
import 'package:mmb2/widget/splash.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
//GoogleSignIn _googleSignIn = GoogleSignIn();
FirebaseUser mainUser;


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String _info = '';
  bool isRegistered = false;

  TabController tabController;
  bool checkingUser = true;

  void setupMainUser() async {
    checkingUser = true;
    var result = await _auth.currentUser();

    if (result?.uid != null) {
      var user = await getRegisteredUser(result?.uid);
      print('got user $user');
      isRegistered = user != null;
    }
    print('changing is anom to ${result?.isAnonymous}');
    setState(() {
      mainUser = result;
      checkingUser = false;
      isRegistered = isRegistered;
    });

    if (mainUser != null && !isRegistered) {
      tabController.animateTo(2);
    }
  }

  Future<User> getRegisteredUser(String uid) async {
    var registeredUser =
        await Firestore.instance.collection('user').document(uid).get();
    if (!registeredUser.exists)
      return null;
    else
      return User.fromJson(registeredUser.data);
  }

  @override
  void initState() {
    super.initState();
    setupMainUser();
    _auth.onAuthStateChanged.listen((event) {
      print(event);
      setupMainUser();
    });
    tabController = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void startSearch() async {
    var searchResult = await Navigator.push<SearchResult>(
        context, MaterialPageRoute(builder: (context) => SearchPage()));

    setState(() {
      _info = searchResult?.searchTerm ?? "";
    });

    if (searchResult?.searchTerm != null) tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    // var a = 1+1==2;
    // if(a == true)
    //   return Login();

    if (mainUser == null) {
      if (checkingUser)
        return Splash();
      else
        return Login();
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Column(children: [
            Text(widget.title),
            mainUser?.isAnonymous == true
                ? RichText(
                    text: TextSpan(
                        text: 'Link account to save progess!!!!!!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                            fontSize: 20)))
                : Container(),
          ]),
          bottom: buildbottomTabBar(tabController),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Inbox(info: _info, context: context),
            Tab(icon: Icon(Icons.home)),
            Register(
                uid: mainUser.uid,
                isAnonymous: mainUser.isAnonymous,
                onUserLinkedOrRegistered: onUserLinkedOrRegistered)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: startSearch,
          tooltip: 'Search',
          child: Icon(Icons.search),
        ),
      ),
    );
  }

  TabBar buildbottomTabBar(TabController controller) {
    return TabBar(
      controller: controller,
      tabs: [
        Tab(icon: Icon(Icons.inbox)),
        Tab(icon: Icon(Icons.send)),
        Tab(
            icon: Icon(
          Icons.verified_user,
          color: Colors.red,
        )),
      ],
    );
  }

  onUserLinkedOrRegistered(int p1) {
    setupMainUser();
  }
}
