import 'dart:io';

import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_getx_template/app/data/models/post.dart';
import 'package:flutter_getx_template/app/repositories/post_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/handlers/request_handler.dart';

import '../../fixtures/fixture.dart';

void main() {
  group('Test Repository', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late PostRepository repository;

    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter();
      dio.httpClientAdapter = dioAdapter;
      repository = PostRepository(dio);
    });

    test('should return list of posts', () async {
      final List<dynamic> payload = fixture('post_items.json') as List<dynamic>;
      dioAdapter.onGet(
        '/posts',
        (RequestHandler<dynamic> request) =>
            request.reply(HttpStatus.ok, payload),
      );

      final List<Post> result = await repository.getAll();
      expect(result, isA<List<Post>>());
      expect(result.length, payload.length);
    });

    test('should return exception in list of posts', () async {
      dioAdapter.onGet(
        '/posts',
        (RequestHandler<dynamic> request) =>
            request.reply(HttpStatus.notFound, <String, dynamic>{}),
      );

      expect(() async => repository.getAll(), throwsException);
    });

    test('should return add new post and return post with id', () async {
      const int id = 1;
      final String text = Faker().randomGenerator.string(50, min: 10);
      final int createdAt = Faker().date.dateTime().millisecondsSinceEpoch;
      final Map<String, dynamic> data = <String, dynamic>{
        'id': id,
        'text': text,
        'createdAt': createdAt,
      };
      dioAdapter.onPost(
        '/posts',
        (RequestHandler<dynamic> request) => request.reply(HttpStatus.ok, data),
        data: data,
      );

      final Post result =
          await repository.add(text: text, createdAt: createdAt);
      expect(result, isA<Post>());
      expect(result.text, text);
      expect(result.createdAt, createdAt);
      expect(result.id, id);
    });

    test('should return updated post content', () async {
      const int id = 1;
      final String text = Faker().randomGenerator.string(50, min: 10);
      final int createdAt = Faker().date.dateTime().millisecondsSinceEpoch;
      final Map<String, dynamic> data = <String, dynamic>{
        'id': id,
        'text': text,
        'createdAt': createdAt,
      };
      final Post post = Post.fromJson(data);
      post.text = Faker().randomGenerator.string(100, min: 51);

      dioAdapter.onPut(
        '/posts/${post.id}',
        (RequestHandler<dynamic> request) =>
            request.reply(HttpStatus.ok, post.toJson()),
        data: post.toJson(),
      );

      final Post result = await repository.edit(post);
      expect(result, isA<Post>());
      expect(result.text, post.text);
      expect(result.createdAt, post.createdAt);
      expect(result.id, post.id);
    });

    test('shouldn return true when delete one post', () async {
      const int id = 1;
      dioAdapter.onDelete(
        '/posts/$id',
        (RequestHandler<dynamic> request) =>
            request.reply(HttpStatus.ok, <String, dynamic>{}),
      );

      final bool result = await repository.delete(1);
      expect(result, true);
    });
  });
}
