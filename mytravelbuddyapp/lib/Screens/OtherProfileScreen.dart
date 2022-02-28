import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mytravelbuddyapp/Screens/AlbumScreen.dart';

import 'FollowersPage.dart';

class OthersProfileScreen extends StatefulWidget {
  late String _username;
  late bool _isPicExists = false;
  late bool _isFollowed = false;
  String _picURL = "";
  late List<dynamic> _followers;
  late List<dynamic> _followeds;
  List<dynamic> _posts = List.empty(growable: true);
  late String _mainAccount;
  late String _mainURL;
  late int _followercount;

  OthersProfileScreen(
      {required List<dynamic> followeds,
      required List<dynamic> followers,
      required List<dynamic> posts,
      required String picURL,
      required bool isPicExists,
      required String username,
      required bool isFollowed,
      required String mainAccount,
      required String mainURL,
      Key? key})
      : super(key: key) {
    _username = username;
    _isPicExists = isPicExists;
    _picURL = picURL;
    _followeds = followeds;
    _followers = followers;
    _posts = posts;
    _isFollowed = isFollowed;
    _mainAccount = mainAccount;
    _mainURL = mainURL;
    _followercount = _followers.length;
  }

  @override
  State<OthersProfileScreen> createState() => _OthersProfileScreenState();
}

class _OthersProfileScreenState extends State<OthersProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent.shade100,
        title: Text(widget._username),
      ),
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
                              : Icon(
                                  Icons.supervised_user_circle_sharp,
                                  size: 75,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)),
                                color: Colors.black,
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  child: Material(
                                    color: widget._isFollowed
                                        ? Colors.red.shade200
                                        : Colors.orange.shade200,
                                    borderRadius: BorderRadius.circular(32),
                                    child: MaterialButton(
                                      onPressed: () {
                                        widget._isFollowed =
                                            !widget._isFollowed;
                                        late QueryDocumentSnapshot mainuser;
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .where("username",
                                                isEqualTo: widget._mainAccount)
                                            .get()
                                            .then((QuerySnapshot qs) {
                                          mainuser = qs.docs[0];
                                        });
                                        late QueryDocumentSnapshot user;
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .where("username",
                                                isEqualTo: widget._username)
                                            .get()
                                            .then((QuerySnapshot qs) async {
                                          user = qs.docs[0];
                                          if (widget._isFollowed) {
                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(user.id)
                                                .update({
                                              "followers":
                                                  FieldValue.arrayUnion([
                                                {
                                                  "username":
                                                      widget._mainAccount,
                                                  "profilePic": widget._mainURL
                                                }
                                              ])
                                            });

                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(mainuser.id)
                                                .update({
                                              "followed":
                                                  FieldValue.arrayUnion([
                                                {
                                                  "username": widget._username,
                                                  "profilePic": widget._picURL
                                                }
                                              ])
                                            });
                                            setState(() {
                                              widget._followers.add({
                                                "username": widget._username,
                                                "profilePic": widget._picURL
                                              });
                                              widget._followercount++;
                                            });
                                          } else {
                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(user.id)
                                                .update({
                                              "followers":
                                                  FieldValue.arrayRemove([
                                                {
                                                  "username":
                                                      widget._mainAccount,
                                                  "profilePic": widget._mainURL
                                                }
                                              ])
                                            });
                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(mainuser.id)
                                                .update({
                                              "followed":
                                                  FieldValue.arrayRemove([
                                                {
                                                  "username": widget._username,
                                                  "profilePic": widget._picURL
                                                }
                                              ])
                                            });
                                            setState(() {
                                              var elementToDelete;
                                              widget._followers
                                                  .forEach((element) {
                                                if (element.toString() ==
                                                    {
                                                      "username":
                                                          widget._username,
                                                      "profilePic":
                                                          widget._picURL
                                                    }.toString()) {
                                                  elementToDelete = element;
                                                }
                                              });
                                              widget._followers
                                                  .remove(elementToDelete);
                                              widget._followercount--;
                                            });
                                          }
                                        });
                                      },
                                      child: Text(
                                        widget._isFollowed
                                            ? "Unfollow"
                                            : "Follow",
                                      ),
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  profileButton("Posts", "${widget._posts.length}", () {}),
                  profileButton("Followers", "${widget._followercount}", () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FollowersPage(
                            title: "Followers", followers: widget._followers)));
                  }),
                  profileButton("Followed", "${widget._followeds.length}", () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FollowersPage(
                            title: "Followed", followers: widget._followeds)));
                  })
                ],
              ),
            ),
            Expanded(
                flex: 8,
                child: Container(
                    child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    padding: EdgeInsets.all(1),
                    color: Colors.black,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(5),
                      child: Container(
                        child: Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            scrollDirection: Axis.horizontal,
                            mainAxisSpacing: 20,
                            children: widget._posts
                                .map((e) => displayPost(
                                        e['postTitle'], e['postPic'], () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => AlbumScreen(
                                                    contents: e["Contents"],
                                                    title: e["postTitle"],
                                                    isOwner: false,
                                                    profilePicURL:
                                                        widget._picURL,
                                                    postIndex: widget._posts
                                                        .indexOf(e),
                                                    posts: widget._posts,
                                                    username: widget._username,
                                                  )));
                                    }, e["isPublished"]))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ))),
            Expanded(
                flex: 1,
                child: Center(
                    child: Text(
                  "My Travel Buddy",
                  style: TextStyle(color: Colors.orange.shade900),
                )))
          ],
        ),
      )),
    );
  }

  Column displayPost(String title, String postPicURL, void Function() onPressed,
      bool isShared) {
    if (!isShared) {
      return Column();
    }
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
