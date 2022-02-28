import 'package:flutter/material.dart';

class FollowersPage extends StatelessWidget {
  List<dynamic> _followers = List.empty(growable: true);
  late String _title;
  FollowersPage(
      {required String title, required List<dynamic> followers, Key? key})
      : super(key: key) {
    _followers = followers;
    _title = title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              _title,
              style: TextStyle(
                  color: Colors.orange.shade900, fontWeight: FontWeight.bold),
            ),
            const Divider(
              height: 10,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView(
                  children: _followers
                      .map((e) =>
                          displayFollower(e["username"], e["profilePic"]))
                      .toList()),
            )
          ],
        ),
      ),
    );
  }

  Container displayFollower(String username, String url) {
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: url == ""
                  ? const Icon(
                      Icons.supervised_user_circle_sharp,
                      size: 75,
                    )
                  : ClipOval(
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        height: 75,
                        width: 75,
                      ),
                    )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 4,
            child: Text(username),
          ),
        ],
      ),
    );
  }
}
