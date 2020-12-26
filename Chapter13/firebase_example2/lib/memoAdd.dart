import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'memo.dart';

class MemoAddApp extends StatefulWidget {
  final DatabaseReference reference;

  MemoAddApp(this.reference);

  @override
  State<StatefulWidget> createState() => _MemoAddApp();
}

class _MemoAddApp extends State<MemoAddApp> {
  TextEditingController titleController;
  TextEditingController contentController;

  InterstitialAd fullPageAdvertise = InterstitialAd(
    adUnitId: InterstitialAd.testAdUnitId,
    listener: (MobileAdEvent event) {
      print('$event');
    },
  );

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메모 추가'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText: '제목', fillColor: Colors.blueAccent),
              ),
              Expanded(
                  child: TextField(
                    controller: contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 100,
                    decoration: InputDecoration(labelText: '내용'),
                  )),
              FlatButton(
                onPressed: () {
                  widget.reference
                      .push()
                      .set(Memo(
                      titleController.value.text,
                      contentController.value.text,
                      DateTime.now().toIso8601String())
                      .toJson())
                      .then((_) {
                    Navigator.of(context).pop();
                  });
                  fullPageAdvertise
                    ..load()
                    ..show(
                      anchorType: AnchorType.bottom,
                      anchorOffset: 0.0,
                    );
                },
                child: Text('저장하기'),
                shape:
                OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
