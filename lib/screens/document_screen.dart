import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/response_model.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/repository/document_repository.dart';
import 'package:google_docs_clone/repository/socket_repository.dart';
import 'package:google_docs_clone/utils/colors.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import '../utils/utils.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  QuillController? contentController = QuillController.basic();
  ResponseModel? response;

  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      contentController?.compose(
          Delta.fromJson(data['delta']),
          contentController?.selection ?? TextSelection.collapsed(offset: 0),
          ChangeSource.REMOTE);
    });

    Timer.periodic(Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': contentController!.document.toDelta(),
        'room': widget.id
      });
    });
  }

  void fetchDocumentData() async {
    response = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (response!.data != null) {
      titleController.text = (response!.data as DocumentModel).title;

      contentController = QuillController(
        document: (response!.data as DocumentModel).content.isEmpty
            ? Document()
            : Document.fromDelta(
                Delta.fromJson((response!.data as DocumentModel).content)),
        selection: TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    contentController!.document.changes.listen((event) {
      if (event.item3 == ChangeSource.LOCAL) {
        Map<String, dynamic> map = {'delta': event.item2, 'room': widget.id};
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    String userToken = ref.read(userProvider)!.token;
    ref
        .watch(documentRepositoryProvider)
        .updateTitle(token: userToken, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: kBlackColor),
          backgroundColor: kWhiteColor,
          elevation: 0,
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                          text:
                              'http://localhost:3000/#/document/${widget.id}'))
                      .then((value) => ScaffoldMessenger.of(context)
                          .showSnackBar(
                              SnackBar(content: Text('Link copied!'))));
                },
                icon: Icon(Icons.lock, color: kWhiteColor),
                label: Text(
                  'Share',
                  style: (TextStyle(color: kWhiteColor)),
                )),
          ],
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                isOnWeb()
                    ? Image.asset(
                        'assets/images/docs-logo.png',
                        height: 40,
                      )
                    : Container(),
                SizedBox(width: 10),
                SizedBox(
                    width: 200,
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: kBlueColor,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(left: 10),
                      ),
                      onSubmitted: (value) => updateTitle(ref, value),
                    ))
              ],
            ),
          ),
          bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: kGrayColor, width: 0.1)),
            ),
            preferredSize: Size.fromHeight(1),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            QuillToolbar.basic(controller: contentController!),
            Expanded(
              child: Card(
                color: kWhiteColor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: QuillEditor.basic(
                    controller: contentController!,
                    readOnly: false,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
