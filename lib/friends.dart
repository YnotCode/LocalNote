import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowersPage extends StatefulWidget {
  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  // List of followers (Friends list)
  List<Follower> friends = List.generate(
    20, // Increased to demonstrate scrollability
    (index) => Follower(
      username: 'friend_$index',
      profileImageUrl: 'https://via.placeholder.com/150',
      isFollowing: true,
    ),
  );

  // List of users to discover (Find Users list)
  List<Follower> discoverUsers = List.generate(
    20,
    (index) => Follower(
      username: 'discover_user_$index',
      profileImageUrl: 'https://via.placeholder.com/150',
      isFollowing: false,
    ),
  );

  // Current tab selection (0 = Friends, 1 = Find Users)
  int selectedIndex = 0;

  // Search text (for future search functionality)
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          selectedIndex == 0 ? "Friends" : "Find Users",
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
              // Beautiful segmented control-style toggle
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
              // Small, clean search bar
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
        itemCount: selectedIndex == 0 ? friends.length : discoverUsers.length,
        itemBuilder: (context, index) {
          final follower = selectedIndex == 0 ? friends[index] : discoverUsers[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25, // Slightly bigger avatar for aesthetics
              backgroundImage: CachedNetworkImageProvider(follower.profileImageUrl),
            ),
            title: Text(
              follower.username,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            // Show Follow button only if in "Find Users" section
            trailing: selectedIndex == 1
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        follower.isFollowing = !follower.isFollowing;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: follower.isFollowing ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      follower.isFollowing ? "Following" : "Follow",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : null, // No trailing button for Friends
          );
        },
      ),
    );
  }

  // Helper method to build a beautiful segmented button
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

class Follower {
  final String username;
  final String profileImageUrl;
  bool isFollowing;

  Follower({
    required this.username,
    required this.profileImageUrl,
    required this.isFollowing,
  });
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: FollowersPage(),
  ));
}
