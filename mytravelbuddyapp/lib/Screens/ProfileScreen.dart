import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mytravelbuddyapp/Screens/AlbumScreen.dart';
import 'package:mytravelbuddyapp/Screens/FollowersPage.dart';
import 'package:mytravelbuddyapp/Screens/LoginScreen.dart';
import 'package:mytravelbuddyapp/Screens/NewPostScreen.dart';
import 'package:mytravelbuddyapp/Screens/OtherProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  late String _username;
  late bool _isAccount;
  late bool _isPicExists = false;
  String _picURL = "";
  late List<dynamic> _followers;
  late List<dynamic> _followeds;
  List<dynamic> _posts = List.empty(growable: true);

  ProfileScreen(
      {required List<dynamic> followeds,
      required List<dynamic> followers,
      required List<dynamic> posts,
      required String picURL,
      required bool isPicExists,
      required String username,
      Key? key})
      : super(key: key) {
    _username = username;
    _isPicExists = isPicExists;
    _picURL = picURL;
    _followeds = followeds;
    _followers = followers;
    _posts = posts;
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final _searchTextField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Colors.greenAccent.shade100,
                Colors.blueAccent.shade100,
              ])),
          child: Column(
            children: [
              Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget._isPicExists
                                ? ClipOval(
                                    child: Image.network(
                                      widget._picURL,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.supervised_user_circle_sharp,
                                    size: 75,
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(widget._username)
                          ],
                        ),
                      ),
                      Expanded(
                          child: CupertinoContextMenu(
                        child: const Icon(Icons.more_vert, size: 32),
                        actions: [
                          CupertinoContextMenuAction(
                            trailingIcon: Icons.search,
                            child: const Text("Search Profile"),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Username"),
                                        content: TextField(
                                          autofocus: true,
                                          controller: _searchTextField,
                                          decoration: const InputDecoration(
                                              hintText:
                                                  "Enter username to search"),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .where("username",
                                                        isEqualTo:
                                                            _searchTextField
                                                                .text)
                                                    .get()
                                                    .then((QuerySnapshot
                                                        querySnapshot) {
                                                  if (querySnapshot
                                                      .docs.isEmpty) {
                                                    _searchTextField.text = "";
                                                    Navigator.of(context).pop();
                                                    debugPrint(
                                                        "There is no such an account");
                                                  } else {
                                                    var user =
                                                        querySnapshot.docs[0];
                                                    bool _isPicExists = false;
                                                    String _picURL = "";
                                                    List<dynamic> _followers =
                                                        List.empty(
                                                            growable: true);
                                                    List<dynamic> _followeds =
                                                        List.empty(
                                                            growable: true);
                                                    List<dynamic> _posts =
                                                        List.empty(
                                                            growable: true);
                                                    bool _isFollowed = false;
                                                    _posts = user.get("posts");
                                                    String url = user
                                                        .get("profilePicURL");
                                                    if (url != "") {
                                                      _isPicExists = true;
                                                      _picURL = url;
                                                    }
                                                    _followeds =
                                                        user.get("followed");
                                                    _followers =
                                                        user.get("followers");
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .where("username",
                                                            isEqualTo: widget
                                                                ._username)
                                                        .get()
                                                        .then(
                                                            (QuerySnapshot qs) {
                                                      List<dynamic> followed =
                                                          qs.docs[0]
                                                              .get("followed");
                                                      for (var element
                                                          in followed) {
                                                        if (element[
                                                                "username"] ==
                                                            _searchTextField
                                                                .text) {
                                                          _isFollowed = true;
                                                        }
                                                      }
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (builder) =>
                                                                          OthersProfileScreen(
                                                                            followeds:
                                                                                _followeds,
                                                                            followers:
                                                                                _followers,
                                                                            posts:
                                                                                _posts,
                                                                            picURL:
                                                                                _picURL,
                                                                            isPicExists:
                                                                                _isPicExists,
                                                                            username:
                                                                                _searchTextField.text,
                                                                            isFollowed:
                                                                                _isFollowed,
                                                                            mainAccount:
                                                                                widget._username,
                                                                            mainURL:
                                                                                widget._picURL,
                                                                          )))
                                                          .whenComplete(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .where("username",
                                                                isEqualTo: widget
                                                                    ._username)
                                                            .get()
                                                            .then((QuerySnapshot
                                                                qs) {
                                                          widget._followeds = qs
                                                              .docs[0]
                                                              .get("followed");
                                                          setState(() {});
                                                        });
                                                        _searchTextField.text =
                                                            "";
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    });
                                                  }
                                                });
                                              },
                                              child: const Text("Search"))
                                        ],
                                      ));
                            },
                          ),
                          CupertinoContextMenuAction(
                            trailingIcon: Icons.send_to_mobile_sharp,
                            child: const Text("Log out"),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                          ),
                          CupertinoContextMenuAction(
                            child: const Text("Update profile picture"),
                            trailingIcon: Icons.photo,
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              var ref = firebase_storage
                                  .FirebaseStorage.instance
                                  .ref()
                                  .child("users")
                                  .child("${widget._username}.png");
                              ref
                                  .putFile(File(image!.path))
                                  .whenComplete(() async {
                                var url = await ref.getDownloadURL();
                                String id = "";
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .where("username",
                                        isEqualTo: widget._username)
                                    .get()
                                    .then((QuerySnapshot qs) {
                                  qs.docs.forEach((element) {
                                    id = element.id;
                                  });
                                }).whenComplete(() {
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(id)
                                      .update({"profilePicURL": url});
                                  setState(() {
                                    widget._picURL = "$url";
                                    widget._isPicExists = true;
                                  });
                                });
                              });
                            },
                          ),
                          CupertinoContextMenuAction(
                            child: const Text("Update profile picture"),
                            trailingIcon: Icons.camera,
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                  source: ImageSource.camera);
                              var ref = firebase_storage
                                  .FirebaseStorage.instance
                                  .ref()
                                  .child("users")
                                  .child("${widget._username}.png");

                              ref
                                  .putFile(File(image!.path))
                                  .whenComplete(() async {
                                var url = await ref.getDownloadURL();
                                String id = "";
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .where("username",
                                        isEqualTo: widget._username)
                                    .get()
                                    .then((QuerySnapshot qs) {
                                  qs.docs.forEach((element) {
                                    id = element.id;
                                  });
                                }).whenComplete(() {
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(id)
                                      .update({"profilePicURL": url});
                                  setState(() {
                                    widget._picURL = "$url";
                                    widget._isPicExists = true;
                                  });
                                });
                              });
                            },
                          )
                        ],
                      )),
                    ],
                  )),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    profileButton("Posts", "${widget._posts.length}", () {}),
                    profileButton("Followers", "${widget._followers.length}",
                        () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FollowersPage(
                                title: "Followers",
                                followers: widget._followers,
                              )));
                    }),
                    profileButton("Followed", "${widget._followeds.length}",
                        () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FollowersPage(
                                title: "Followed",
                                followers: widget._followeds,
                              )));
                    })
                  ],
                ),
              ),
              Expanded(
                  flex: 8,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        color: Colors.black,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            child: Expanded(
                              child: GridView.count(
                                  crossAxisCount: 4,
                                  scrollDirection: Axis.horizontal,
                                  mainAxisSpacing: 20,
                                  children: displayPostsWithAddButton()),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Center(
                      child: Text(
                    "My Travel Buddy",
                    style: TextStyle(color: Colors.orange.shade900),
                  )))
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> displayPostsWithAddButton() {
    List<Column> list = widget._posts
        .map((value) => displayPost(value["postTitle"], value["postPic"], () {
              var elementToFindIndex;
              widget._posts.forEach((element) {
                if (element.toString() == value.toString()) {
                  elementToFindIndex = element;
                }
              });
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AlbumScreen(
                        contents: value["Contents"],
                        title: value["postTitle"],
                        isOwner: true,
                        profilePicURL: widget._picURL,
                        postIndex: widget._posts.indexOf(elementToFindIndex),
                        posts: widget._posts,
                        username: widget._username,
                      )));
            }))
        .toList();
    list.add(displayAddButton());
    return list;
  }

  Column displayAddButton() {
    return Column(
      children: [
        const SizedBox(
          height: 1,
        ),
        Material(
            child: Ink(
                decoration: const ShapeDecoration(
                    color: Colors.orange, shape: CircleBorder()),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => PostingScreen(
                                    username: widget._username,
                                    posts: widget._posts,
                                  )))
                          .whenComplete(() {
                        setState(() {
                          FirebaseFirestore.instance
                              .collection("users")
                              .where("username", isEqualTo: widget._username)
                              .get()
                              .then((QuerySnapshot qs) {
                            widget._posts = qs.docs[0].get("posts");
                          });
                        });
                      });
                    },
                    color: Colors.white,
                    iconSize: 36,
                    icon: const Icon(Icons.add)))),
        const SizedBox(height: 15)
      ],
    );
  }

  Column displayPost(
      String title, String postPicURL, void Function() onPressed) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(1),
              child: Container(
                color: Colors.white,
                child: Center(
                    child: postPicURL == ""
                        ? const Icon(Icons.photo, color: Colors.grey)
                        : Image.network(postPicURL, fit: BoxFit.cover)),
              ),
            ),
            onTap: onPressed,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(title),
      ],
    );
  }

  Column profileButton(
      String buttonName, String textNumber, void Function() onPressed) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              gradient: LinearGradient(transform: GradientRotation(1), colors: [
                Colors.teal.shade300,
                Colors.orange.shade500,
                Colors.teal.shade300,
              ]),
              borderRadius: BorderRadius.circular(10)),
          child: Material(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: MaterialButton(
              onPressed: onPressed,
              child: Text(buttonName),
            ),
          ),
        ),
        const SizedBox(
          height: 9,
        ),
        Text(textNumber),
      ],
    );
  }
}
