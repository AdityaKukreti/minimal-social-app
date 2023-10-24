import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimal_social_app/components/my_drawer.dart';
import 'package:minimal_social_app/components/my_list_tile.dart';
import 'package:minimal_social_app/components/my_post_button.dart';
import 'package:minimal_social_app/components/my_textfield.dart';
import 'package:minimal_social_app/database/firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      database.addPost(newPostController.text);
    }
    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: const Text("W A L L"),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                      hintText: "Say something...",
                      obscureText: false,
                      controller: newPostController),
                ),
                PostButton(onTap: postMessage)
              ],
            ),
          ),
          StreamBuilder(
              stream: database.getPostStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final posts = snapshot.data!.docs;

                if (snapshot.data == null || posts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No posts... Post something!"),
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      String message = post['PostMessage'];
                      String userEmail = post['UserEmail'];
                      Timestamp timestamp = post['TimeStamp'];

                      return MyListTile(title: message, subTitle: userEmail);
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
