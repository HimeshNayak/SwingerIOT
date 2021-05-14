import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../screens/doctorProfile.dart';
import '../screens/chatScreen.dart';
import '../services/auth.dart';
import '../services/root.dart';
import '../widgets/commonWidgets.dart';
import '../widgets/profileTile.dart';

class HomeUser extends StatefulWidget {
  final Auth auth;
  final UserData user;
  HomeUser({required this.auth, required this.user});
  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              widget.auth.signOutGoogle().whenComplete(() {
                widget.user.getUserDetails().whenComplete(() {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RootPage(auth: widget.auth, user: widget.user)),
                      (route) => false);
                });
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            bgWidget(
              context: context,
              child: Column(
                children: <Widget>[
                  ProfileTile(
                    user: widget.user,
                    function: () {},
                  ),
                  SizedBox(height: 2, child: Container(color: Colors.blueGrey)),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen()));
                    },
                    child: longButton(Colors.redAccent, 'Send SOS message'),
                  ),
                  TextButton(
                    onPressed: null,
                    child: longButton(Colors.greenAccent, 'Open Distance Page'),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                      child: Text(
                        'Your Doctor',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 2, child: Container(color: Colors.blueGrey)),
                  SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.uid)
                          .get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic> userMap =
                              snapshot.data?.data() as Map<String, dynamic>;
                          String doctorUid = userMap['doctorUid'] ?? '';
                          if (doctorUid.isNotEmpty)
                            return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('admins')
                                    .doc(doctorUid)
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snap) {
                                  if (snap.hasData) {
                                    Map<String, dynamic> doctorMap = snap.data
                                        ?.data() as Map<String, dynamic>;
                                    UserData doctorData = new UserData();
                                    doctorData.setFields(doctorMap);
                                    return ProfileTile(
                                      user: doctorData,
                                      function: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DoctorProfile()));
                                      },
                                    );
                                  }
                                  return Center(
                                      child: CircularProgressIndicator());
                                });
                          else
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Text('No doctor added!'),
                                  TextButton(
                                    onPressed: null,
                                    child: longButton(
                                        Colors.greenAccent, 'Add Doctor'),
                                  )
                                ],
                              ),
                            );
                        }
                        return Center(child: CircularProgressIndicator());
                      }),
                ],
              ),
            ),
            overlayProgress(context: context, visible: isLoading),
          ],
        ),
      ),
    );
  }
}
