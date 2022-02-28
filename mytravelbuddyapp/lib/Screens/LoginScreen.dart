import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:mytravelbuddyapp/Screens/ProfileScreen.dart';
import 'package:mytravelbuddyapp/Screens/RegisterScreen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final usernameTextField = TextEditingController();
  final passwordTextField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32)),
                            color: Colors.teal.shade300),
                        child: const Text(
                          "                      Welcome to my travel buddy                      ",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 100, 51, 1),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      color: Colors.transparent,
                      width: 100,
                      height: 100,
                      child: Image.asset("assets/logo.png"))
                ],
              ),
            ),
            Expanded(
                child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: TextField(
                    controller: usernameTextField,
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelText: "Enter Username",
                        hintText: "Enter Your Username",
                        prefixIcon: Icon(Icons.person, color: Colors.teal)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordTextField,
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelText: "Enter Password",
                        hintText: "Enter Your Password",
                        prefixIcon: Icon(Icons.password, color: Colors.teal)),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      color: Colors.black,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        child: Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          color: Colors.teal.shade300,
                          child: MaterialButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .where("username",
                                      isEqualTo: usernameTextField.text)
                                  .get()
                                  .then((QuerySnapshot querySnapshot) {
                                if (querySnapshot.docs.isEmpty) {
                                  debugPrint("There is no such an account");
                                } else {
                                  var user = querySnapshot.docs[0];
                                  String password = user.get("password");
                                  if (Crypt(password)
                                      .match(passwordTextField.text)) {
                                    CollectionReference users =
                                        FirebaseFirestore.instance
                                            .collection("users");
                                    bool _isPicExists = false;
                                    String _picURL = "";
                                    List<dynamic> _followers =
                                        List.empty(growable: true);
                                    List<dynamic> _followeds =
                                        List.empty(growable: true);
                                    List<dynamic> _posts =
                                        List.empty(growable: true);
                                    users
                                        .where("username",
                                            isEqualTo: usernameTextField.text)
                                        .get()
                                        .then((QuerySnapshot qs) {
                                      String url =
                                          qs.docs[0].get("profilePicURL");
                                      if (url != "") {
                                        _isPicExists = true;
                                        _picURL = url;
                                      }
                                    });
                                    users
                                        .where("username",
                                            isEqualTo: usernameTextField.text)
                                        .get()
                                        .then((QuerySnapshot qs) {
                                      _posts = qs.docs[0].get("posts");
                                    });
                                    users
                                        .where("username",
                                            isEqualTo: usernameTextField.text)
                                        .get()
                                        .then((QuerySnapshot qs) {
                                      _followeds = qs.docs[0].get("followed");
                                    });
                                    users
                                        .where("username",
                                            isEqualTo: usernameTextField.text)
                                        .get()
                                        .then((QuerySnapshot qs) {
                                      _followers = qs.docs[0].get("followers");
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                    username:
                                                        user.get("username"),
                                                    followeds: _followeds,
                                                    followers: _followers,
                                                    isPicExists: _isPicExists,
                                                    picURL: _picURL,
                                                    posts: _posts,
                                                  )));
                                    });
                                  } else {
                                    debugPrint("Password does not match");
                                  }
                                }
                              });
                            },
                            child: const Text(
                              "                Login               ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            textColor: const Color.fromRGBO(255, 100, 51, 1),
                          ),
                        ),
                      ),
                    )),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: const Text(
                    "--------------------------OR--------------------------",
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      color: Colors.black,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        child: Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          color: Colors.teal.shade300,
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RegisterScreen()));
                            },
                            child: const Text(
                              "                Register               ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            textColor: const Color.fromRGBO(255, 100, 51, 1),
                          ),
                        ),
                      ),
                    ))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
