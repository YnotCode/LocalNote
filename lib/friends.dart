import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // List of followers (Friends list)
  List<Follower> friends = [];

  // List of users to discover (Find Users list)
  List<Follower> discoverUsers = [];

  Set<String> requestList = {};

  // Current tab selection (0 = Friends, 1 = Find Users)
  int selectedIndex = 0;

  // Search text (for future search functionality)
  String searchQuery = '';

  // Number of pending friend requests
  int friendRequests = 0;

  void loadFriends() {
    SharedPreferences.getInstance().then((prefs) {
      var user_number = prefs.getString("phone-number");
      FirebaseFirestore.instance
          .collection("friendRequests")
          .where("requested", isEqualTo: user_number)
          .get()
          .then((value) {
        setState(() {
          friendRequests = value.docs.length;
        });
      });

      FirebaseFirestore.instance
          .collection("friendRequests")
          .where("requester", isEqualTo: user_number)
          .get()
          .then((value) {
        setState(() {
          value.docs.forEach((element) {
            requestList.add(element.data()['requester']);
          });
        });
      });

      // Load friends list
      FirebaseFirestore.instance.collection("users").where("phoneNumber", isEqualTo: user_number).get().then((value) => {
        setState(() {
          friends.clear();
          value.docs.forEach((doc) {
            // print(doc.data()['friends']);
            doc.data()['friends'].forEach((elt) {
              friends.add(Follower(
                username: elt['name'],
                number: elt['phoneNumber'],
                profileImageUrl: elt.containsKey('avatar') ? elt['avatar'] : 'https://via.placeholder.com/150',
                requested: false,
              ));
            });
         });
        })
      });

      // Load discover users list
      FirebaseFirestore.instance
          .collection("users")
          .where("phoneNumber", isNotEqualTo: user_number)
          .limit(50)
          .get()
          .then((value) {
        setState(() {
          discoverUsers = value.docs
              .map((e) => Follower(
                    username: e.data()['name'],
                    number: e.data()['phoneNumber'],
                    profileImageUrl: e.data().containsKey('avatar') ? e.data()['avatar'] : 'https://via.placeholder.com/150',
                    requested: requestList.contains(e.data()['phoneNumber']),
                  ))
              .toList();
        });
      });
    });
  }
  @override
  void initState() {
    print("initState");
    super.initState();

    // Load friend requests count
    loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Community',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              // Segmented control-style toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentedButton("Friends", 0),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildSegmentedButton("Find Users", 1),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: selectedIndex == 0 ? friends.length + (friendRequests > 0 ? 1 : 0) : discoverUsers.length,
        itemBuilder: (context, index) {
          // Conditionally display the Friend Request tab
          if (selectedIndex == 0 && index == 0 && friendRequests > 0) {
            return ListTile(
              leading: Icon(Icons.person_add, size: 30),
              title: Text(
                "Friend Requests",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '$friendRequests',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestsPage()),
                );

                loadFriends();
              },
            );
          }

          final actualIndex = selectedIndex == 0 && friendRequests > 0 ? index - 1 : index;
          final follower = selectedIndex == 0 ? friends[actualIndex] : discoverUsers[actualIndex];

          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(follower.profileImageUrl),
            ),
            title: Text(
              follower.username,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: selectedIndex == 1
                ? ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      var number = prefs.getString("phone-number");
                      var userName = prefs.getString("name");

                      if (follower.requested) {
                        final query = await FirebaseFirestore.instance
                            .collection("friendRequests")
                            .where("requester", isEqualTo: number)
                            .where("requested", isEqualTo: follower.number)
                            .get();
                        query.docs.forEach((element) {
                          element.reference.delete();
                        });
                      } else {
                        final query = await FirebaseFirestore.instance
                            .collection("friendRequests")
                            .where("requester", isEqualTo: number)
                            .where("requested", isEqualTo: follower.number)
                            .count()
                            .get();
                        var count = query.count;

                        if (count == 0) {
                          FirebaseFirestore.instance.collection("friendRequests").add({
                            "requester": number,
                            "requested": follower.number,
                            "requester_name": prefs.getString("name"),
                          });
                        }
                      }
                      setState(() {
                        follower.requested = !follower.requested;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: follower.requested ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      follower.requested ? "Requested" : "Send Request",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  // Helper method to build segmented button
  Widget _buildSegmentedButton(String text, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? Colors.blue : Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class FriendRequestsPage extends StatefulWidget {
  @override
  _FriendRequestsState createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequestsPage> {
  List<Follower> requestList = [];

  void loadRequests() {
    // Load friend requests
    SharedPreferences.getInstance().then((prefs) {
      var userPhoneNumber = prefs.getString("phone-number");
      FirebaseFirestore.instance
          .collection("friendRequests")
          .where("requested", isEqualTo: userPhoneNumber)
          .get()
          .then((value) {
        setState(() {
          requestList = value.docs
              .map((e) => Follower(
                    username: e.data()['requester_name'],
                    number: e.data()['requester'],
                    profileImageUrl: 'https://via.placeholder.com/150',
                    requested: false,
                  ))
              .toList();
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  // Accept friend request
  void _acceptRequest(Follower follower, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var userPhoneNumber = prefs.getString("phone-number");
    var userName = prefs.getString("name");


    final avatar = await FirebaseFirestore.instance.collection("users").where("phoneNumber", isEqualTo: follower.number).get().then((value) {
      value.docs.forEach((doc) {
        return doc.data().containsKey('avatar') ? doc.data()['avatar'] : 'https://via.placeholder.com/150';
      });
    });
    // Add the requester to the user's friend list
    FirebaseFirestore.instance.collection("users").where("phoneNumber", isEqualTo: follower.number).get().then((value) {
      value.docs.forEach((doc) {
        doc.reference.update({
          "friends": FieldValue.arrayUnion([
            { "phoneNumber": userPhoneNumber,
              "name": userName,
              "avatar": avatar
            }
          ])
        });
      });
    });
    

    FirebaseFirestore.instance.collection("users").where("phoneNumber", isEqualTo: userPhoneNumber).get().then((value) {
     value.docs.forEach((doc) {
        doc.reference.update({
          "friends": FieldValue.arrayUnion([
            { "phoneNumber": follower.number,
              "name": follower.username,
              "avatar": follower.profileImageUrl
            }
          ])
        });
      });
    });

    // Remove the friend request
    FirebaseFirestore.instance
        .collection("friendRequests")
        .where("requester", isEqualTo: follower.number)
        .where("requested", isEqualTo: userPhoneNumber)
        .get()
        .then((value) {
      value.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Accepted ${follower.username}'s request.")),
    );

    loadRequests();
  }

  // Reject friend request
  void _rejectRequest(Follower follower, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var userPhoneNumber = prefs.getString("phone-number");

    // Remove the friend request from Firestore
    FirebaseFirestore.instance
        .collection("friendRequests")
        .where("requester", isEqualTo: follower.number)
        .where("requested", isEqualTo: userPhoneNumber)
        .get()
        .then((value) {
      value.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rejected ${follower.username}'s request.")),
    );

    loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
      ),
      body: ListView.builder(
        itemCount: requestList.length,
        itemBuilder: (context, index) {
          final follower = requestList[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(follower.profileImageUrl),
            ),
            title: Text(
              follower.username,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              follower.number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _acceptRequest(follower, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Accept"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _rejectRequest(follower, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Reject"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Follower {
  final String username;
  final String profileImageUrl;
  bool requested;
  final String number;

  Follower({
    required this.username,
    required this.profileImageUrl,
    required this.requested,
    required this.number,
  });
}


void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: CommunityPage(),
  ));
}
