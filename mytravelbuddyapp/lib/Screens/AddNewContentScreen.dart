import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostingScreen extends StatefulWidget {
  late String _username;
  late String _postName;
  late int _postCounter;
  List<dynamic> _contents = List.empty(growable: true);
  List<dynamic> _posts = List.empty(growable: true);
  late int _postIndex;
  PostingScreen(
      {required String username,
      required String postName,
      required int postCounter,
      required List<dynamic> contents,
      required List<dynamic> posts,
      required int postIndex,
      Key? key})
      : super(key: key) {
    this._username = username;
    this._postName = postName;
    this._postCounter = postCounter;
    this._posts = posts;
    this._contents = contents;
    this._postIndex = postIndex;
  }

  @override
  State<PostingScreen> createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  final noteController = TextEditingController();
  bool isChecked = false;
  XFile? _pickedImage;

  void _getPhotoFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final XFile? imageTemporary = XFile(image.path);
    setState(() {
      this._pickedImage = imageTemporary;
    });
  }

  void _getPhotoFromCamera() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final XFile? imageTemporary = XFile(image.path);
    setState(() {
      this._pickedImage = imageTemporary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.teal.shade400,
          title: const Text("Add Content"),
        ),
        body: Center(
            child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Colors.greenAccent.shade100,
                Colors.blueAccent.shade100
              ])),
          child: Column(children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: _pickedImage == null
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      width: 150,
                      child: Icon(Icons.add_a_photo),
                    )
                  : Container(
                      child: Image.file(File(_pickedImage!.path)),
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      padding: const EdgeInsets.all(1),
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  transform: GradientRotation(1),
                                  colors: [
                                    Colors.teal.shade300,
                                    Colors.orange.shade500,
                                    Colors.teal.shade300,
                                  ]),
                              borderRadius: BorderRadius.circular(10)),
                          child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: MaterialButton(
                                  onPressed: _getPhotoFromGallery,
                                  child: const Text("Pick from gallery"))))),
                  Container(
                      padding: const EdgeInsets.all(1),
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                transform: GradientRotation(1),
                                colors: [
                                  Colors.teal.shade300,
                                  Colors.orange.shade500,
                                  Colors.teal.shade300,
                                ]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Material(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: MaterialButton(
                                  onPressed: _getPhotoFromCamera,
                                  child: const Text("Pick from camera"))))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange.shade300,
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange.shade300, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                  ),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32))),
                  labelText: "Add notes to your trip",
                  hintText: "note",
                  alignLabelWithHint: true,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(80, 1, 70, 10),
              child: CheckboxListTile(
                title: const Text("Post with Followers?"),
                checkColor: Colors.black,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 70),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  color: Colors.black,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    child: Material(
                      color: Colors.teal.shade300,
                      borderRadius: BorderRadius.circular(32),
                      child: MaterialButton(
                        onPressed: () async {
                          var ref = FirebaseStorage.instance
                              .ref()
                              .child("contents")
                              .child(widget._username)
                              .child(widget._postName)
                              .child("${widget._postCounter}.PNG");
                          var userRef =
                              FirebaseFirestore.instance.collection("users");
                          if (_pickedImage != null) {
                            await ref.putFile(File(_pickedImage!.path));
                            var url = await ref.getDownloadURL();
                            late String id;
                            await FirebaseFirestore.instance
                                .collection("users")
                                .where("username", isEqualTo: widget._username)
                                .get()
                                .then((QuerySnapshot qs) {
                              qs.docs.forEach((element) {
                                id = element.id;
                              });
                            });
                            widget._contents.add({
                              "picURL": url,
                              "notes": noteController.text,
                              "isPublished": isChecked
                            });
                            widget._posts[widget._postIndex]["Contents"] =
                                widget._contents;
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(id)
                                .set({"posts": widget._posts},
                                    SetOptions(merge: true));
                            Navigator.of(context).pop();
                          } else {
                            late String id;
                            await FirebaseFirestore.instance
                                .collection("users")
                                .where("username", isEqualTo: widget._username)
                                .get()
                                .then((QuerySnapshot qs) {
                              qs.docs.forEach((element) {
                                id = element.id;
                              });
                            });
                            widget._contents.add({
                              "picURL": "",
                              "notes": noteController.text,
                              "isPublished": isChecked
                            });
                            widget._posts[widget._postIndex]["Contents"] =
                                widget._contents;
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(id)
                                .set({"posts": widget._posts},
                                    SetOptions(merge: true));
                            Navigator.of(context).pop();
                          }
                        },
                        minWidth: 200,
                        child: Text("Post",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange.shade900,
                            )),
                      ),
                    ),
                  ),
                ))
          ]),
        )));
  }
}
