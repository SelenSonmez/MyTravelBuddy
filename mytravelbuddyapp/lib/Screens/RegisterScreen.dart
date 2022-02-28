import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mytravelbuddyapp/Screens/LoginScreen.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);
  final nameTextField = TextEditingController();
  final surnameTextField = TextEditingController();
  final usernameTextField = TextEditingController();
  final passwordTextField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const appTitle = "My Travel Buddy";
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(10),
          child: Column(children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 2, 50),
                child: Container(
                  child: Text(appTitle,
                      style: GoogleFonts.parisienne(
                          textStyle: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 40,
                              fontWeight: FontWeight.bold))),
                )),
            Container(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: TextField(
                  controller: nameTextField,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.teal,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange.shade500,
                        width: 2.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange.shade300,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32))),
                    labelText: "Enter name",
                    hintText: "name",
                  ),
                )),
            Container(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: TextField(
                  controller: surnameTextField,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.account_tree_rounded,
                      color: Colors.teal,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange.shade500,
                        width: 2.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange.shade300,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                    ),
                    labelText: "Enter surname",
                    hintText: "surname",
                  ),
                )),
            Container(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: TextField(
                controller: usernameTextField,
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.account_circle, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange.shade500,
                      width: 2.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange.shade300,
                      width: 2.0,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                  ),
                  labelText: "Enter username",
                  hintText: "username123",
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: TextField(
                  obscureText: true,
                  controller: passwordTextField,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password, color: Colors.teal),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange.shade500,
                        width: 2.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange.shade300,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(32)),
                    ),
                    labelText: "Enter password",
                    hintText: "password",
                  ),
                )),
            Container(
                padding: const EdgeInsets.fromLTRB(75, 10, 75, 10),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  color: Colors.black,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    child: Material(
                        elevation: 5,
                        color: Colors.teal.shade300,
                        borderRadius: BorderRadius.circular(32),
                        child: MaterialButton(
                            onPressed: () {
                              addUser(
                                  name: nameTextField.text,
                                  surname: surnameTextField.text,
                                  username: usernameTextField.text,
                                  password: passwordTextField.text);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                            },
                            minWidth: 200.0,
                            height: 45.0,
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.orange.shade900,
                              ),
                            ))),
                  ),
                ))
          ]),
        )));
  }

  addUser(
      {required String name,
      required String surname,
      required String username,
      required String password}) {
    /*FirebaseFirestore.instance
        .collection("users").where("username" ,isEqualTo: username).get().then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty){
     FirebaseFirestore.instance
          .collection("users")
          .add({
            "name": name,
            "surname": surname,
            "username": username,
            "password": password,
            "profilePicURL": "",
            "posts": [],
            "followed": [],
            "followers": []
          })
          .then((value) => debugPrint("Added User"))
          .catchError((error) => debugPrint("Failed to add user : $error"));
          }else{
            debugPrint("Account already Exists");
          }
        });*/
    String hashedPassword = Crypt.sha256(password).toString();
    var users = FirebaseFirestore.instance.collection('users');
    users.where("username", isEqualTo: username).get().then((QuerySnapshot qs) {
      if (qs.docs.isEmpty) {
        FirebaseFirestore.instance
            .collection("users")
            .add({
              "name": name,
              "surname": surname,
              "username": username,
              "password": hashedPassword,
              "profilePicURL": "",
              "posts": [],
              "followed": [],
              "followers": []
            })
            .then((value) => debugPrint("Added User"))
            .catchError((error) => debugPrint("Failed to add user : $error"));
      } else {
        debugPrint("Account already Exists");
      }
    });
  }
}
