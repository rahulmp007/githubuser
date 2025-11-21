import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: FindUser(),
    );
  }
}

class FindUser extends StatefulWidget {
  const FindUser({super.key});

  @override
  State<FindUser> createState() => _FindUserState();
}

class _FindUserState extends State<FindUser> {
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  final bool _isLoading = false;

  //   {
  //   "login": "rahulmp007",
  //   "id": 82996000,
  //   "node_id": "MDQ6VXNlcjgyOTk2MDAw",
  //   "avatar_url": "https://avatars.githubusercontent.com/u/82996000?v=4",
  //   "gravatar_id": "",
  //   "url": "https://api.github.com/users/rahulmp007",
  //   "html_url": "https://github.com/rahulmp007",
  //   "followers_url": "https://api.github.com/users/rahulmp007/followers",
  //   "following_url": "https://api.github.com/users/rahulmp007/following{/other_user}",
  //   "gists_url": "https://api.github.com/users/rahulmp007/gists{/gist_id}",
  //   "starred_url": "https://api.github.com/users/rahulmp007/starred{/owner}{/repo}",
  //   "subscriptions_url": "https://api.github.com/users/rahulmp007/subscriptions",
  //   "organizations_url": "https://api.github.com/users/rahulmp007/orgs",
  //   "repos_url": "https://api.github.com/users/rahulmp007/repos",
  //   "events_url": "https://api.github.com/users/rahulmp007/events{/privacy}",
  //   "received_events_url": "https://api.github.com/users/rahulmp007/received_events",
  //   "type": "User",
  //   "user_view_type": "public",
  //   "site_admin": false,
  //   "name": "rahulmp",
  //   "company": null,
  //   "blog": "",
  //   "location": null,
  //   "email": null,
  //   "hireable": null,
  //   "bio": null,
  //   "twitter_username": null,
  //   "public_repos": 20,
  //   "public_gists": 0,
  //   "followers": 0,
  //   "following": 0,
  //   "created_at": "2021-04-22T05:37:37Z",
  //   "updated_at": "2025-08-13T11:45:48Z"
  // }

  Future<User?> _getUserInfo({required String username}) async {
    String url = 'https://api.github.com/users/$username';
    final http.Response httpResponse = await http.get(Uri.parse(url));

    log(httpResponse.body);

    if (httpResponse.statusCode == 200) {
      return User.fromJson(json.decode(httpResponse.body));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Search user?'),
              ),
              TextButton(
                onPressed: () async {
                  final user = await _getUserInfo(
                    username: controller.text.trim(),
                  );

                  log('user : $user');
                  if (user != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserInfo(user: user),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User for found for the search query'),
                      ),
                    );
                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Find User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final User user;
  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,

          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(user.avatar ?? "")),
              SizedBox(height: 10),
              Text('Name : ${user.name}'),
              SizedBox(height: 6),
              Text('Bio : ${user.bio}'),
              SizedBox(height: 6),
              Text('Public Repo : ${user.noOfPublicRepo}'),
            ],
          ),
        ),
      ),
    );
  }
}

class User {
  final String? avatar;
  final String? name;
  final String? bio;
  final int? noOfPublicRepo;

  User({
    required this.avatar,
    required this.name,
    required this.bio,
    required this.noOfPublicRepo,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    avatar: json['avatar_url'],
    name: json['name'],
    bio: json['bio'],
    noOfPublicRepo: json['public_repos'],
  );

  @override
  String toString() {
    return 'User(avatar: $avatar, name: $name, bio: $bio, noOfPublicRepo: $noOfPublicRepo)';
  }
}
