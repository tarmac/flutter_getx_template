import 'package:flutter/material.dart';
import 'package:flutter_getx_template/app/data/models/post.dart';
import 'package:flutter_getx_template/app/modules/post/views/new_post.dart';
import 'package:flutter_getx_template/app/modules/post/widgets/post_card_item.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/post_controller.dart';

class PostView extends GetView<PostController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        title: Text('ScreetWall App'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.black54,
                context: context,
                builder: (ctx) => NewPostPage(),
              );
            },
            icon: Icon(Icons.add),
            tooltip: 'Insert new post',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadPosts,
        child: Obx(
          () => ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(10),
            itemCount: controller.posts.length,
            itemBuilder: (context, i) {
              Post post = controller.posts[i];
              return PostCardItem(
                id: post.id.toString(),
                text: post.text,
                createdAt:
                    DateFormat.yMd().add_Hms().format(post.createdAtDatetime),
              );
            },
          ),
        ),
      ),
    );
  }
}