import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/response_model.dart';
import 'package:http/http.dart';

import '../utils/constants.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;

  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ResponseModel> createDocument(String token) async {
    ResponseModel response =
        ResponseModel(error: 'Some unexpected error occured', data: null);
    try {
      Response res = await _client.post(Uri.parse('$baseUrl/doc/create'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
          body: jsonEncode({
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          }));

      switch (res.statusCode) {
        case 200:
          print(res.body);
          final document = DocumentModel.fromJson(jsonDecode(res.body));
          response = ResponseModel(error: null, data: document);
          break;
        default:
          response = ResponseModel(error: res.body, data: null);
          break;
      }
    } catch (e) {
      return ResponseModel(error: e.toString(), data: null);
    }
    return response;
  }

  void updateTitle(
      {required String token,
      required String id,
      required String title}) async {
    await _client.post(Uri.parse('$baseUrl/doc/title'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'id': id,
          'title': title,
        }));
  }

  Future<ResponseModel> getDocuments(String token) async {
    ResponseModel response =
        ResponseModel(error: 'Some unexpected error occured', data: null);
    try {
      Response res = await _client.get(Uri.parse('$baseUrl/docs/me'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token});

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];

          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(DocumentModel.fromJson(jsonDecode(res.body)[i]));
          }
          response = ResponseModel(error: null, data: documents);
          break;
        default:
          response = ResponseModel(error: res.body, data: null);
          break;
      }
    } catch (e) {
      return ResponseModel(error: e.toString(), data: null);
    }
    return response;
  }

  Future<ResponseModel> getDocumentById(String token, String id) async {
    ResponseModel response =
        ResponseModel(error: 'Some unexpected error occured', data: null);
    try {
      Response res = await _client.get(Uri.parse('$baseUrl/doc/$id'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token});

      switch (res.statusCode) {
        case 200:
          DocumentModel document = DocumentModel.fromJson(jsonDecode(res.body));
          response = ResponseModel(error: null, data: document);
          break;
        default:
          throw 'This document does not exist, please create a new one';
      }
    } catch (e) {
      return ResponseModel(error: e.toString(), data: null);
    }
    return response;
  }
}
