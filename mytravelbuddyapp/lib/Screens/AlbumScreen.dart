import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mytravelbuddyapp/Screens/AddNewContentScreen.dart';

class AlbumScreen extends StatefulWidget {
  late List<dynamic> _contents;
  late String _title;
  late bool _isOwner;
  late String _profilePicURL;
  late String _username;
  late List<dynamic> _posts;
  late int _postIndex;

  AlbumScreen({
    required List<dynamic> contents,
    required String title,
    required bool isOwner,
    required String profilePicURL,
    required String username,
    required List<dynamic> posts,
    required int postIndex,
    Key? key,
  }) : super(key: key) {
    this._contents = contents;
    this._title = title;
    this._isOwner = isOwner;
    this._profilePicURL = profilePicURL;
    this._username = username;
    this._posts = posts;
    this._postIndex = postIndex;
  }

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber.shade50,
        appBar: AppBar(
          title: Text(this.widget._title),
          backgroundColor: Colors.teal.shade400,
          actions: widget._isOwner
              ? [
                  Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        child: Icon(Icons.add_a_photo),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => PostingScreen(
                                      username: widget._username,
                                      postName: widget._title,
                                      postCounter: widget._contents.length,
                                      contents: widget._contents,
                                      posts: widget._posts,
                                      postIndex: widget._postIndex)))
                              .whenComplete(() {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .where("username",
                                      isEqualTo: widget._username)
                                  .get()
                                  .then((QuerySnapshot qs) {
                                widget._posts = qs.docs[0].get("posts");
                                widget._contents = widget
                                    ._posts[widget._postIndex]["Contents"];
                              });
                            });
                          });
                        },
                      ))
                ]
              : [],
        ),
        body: Center(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Column(
                    children: [
                      widget._profilePicURL == ""
                          ? const Icon(
                              Icons.supervised_user_circle_sharp,
                              size: 75,
                            )
                          : ClipOval(
                              child: Image.network(
                                widget._profilePicURL,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
                child: GridView.count(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              crossAxisCount: 1,
              scrollDirection: Axis.vertical,
              mainAxisSpacing: 20,
              crossAxisSpacing: 30,
              children: widget._contents.isEmpty
                  ? [Center(child: Text("There is no content to show"))]
                  : widget._contents
                      .map((e) =>
                          displayPost(e["picURL"], widget._contents.indexOf(e)))
                      .toList(),
            ))
          ],
        )));
  }

  Container displayPost(String postPicURL, int index) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(transform: const GradientRotation(1), colors: [
          Colors.teal.shade300,
          Colors.orange.shade500,
          Colors.teal.shade300,
        ]),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(55),
        child: CupertinoContextMenu(
          child: postPicURL == ""
              ? const Icon(
                  Icons.photo_album,
                  size: 55,
                )
              : Image.network(postPicURL),
          actions: [
            CupertinoContextMenuAction(
              child: Text(widget._contents[index]["notes"]),
            )
          ],
        ),
      ),
    );
  }
}
