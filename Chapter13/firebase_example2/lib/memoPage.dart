import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'memo.dart';
import 'memoAdd.dart';
import 'memoDetail.dart';

class MemoApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MemoApp();
}

class _MemoApp extends State<MemoApp> {
  FirebaseDatabase _database;
  DatabaseReference reference;
  String _databaseURL = '### 데이터베이스 URL 넣기 ###';
  List<Memo> memos = List();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  BannerAd bannerAd = BannerAd(
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.banner,
    listener: (MobileAdEvent event) {
      print('$event');
    },
  );

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: '### 애드몹 앱 ID ###');
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database.reference().child('memo');
    bannerAd
      ..load()
      ..show(
        anchorOffset: 0,
        anchorType: AnchorType.bottom,
      );

    reference.onChildAdded.listen((event) {
      print(event.snapshot.value.toString());
      setState(() {
        memos.add(Memo.fromSnapshot(event.snapshot));
      });
    });

    _firebaseMessaging.getToken().then((value) {
      // 개인 토큰 값
      print(value);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['data']['title']),
              subtitle: Text(message['data']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['data']['title']),
              subtitle: Text(message['data']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메모 앱'),
      ),
      body: Container(
        child: Center(
          child: memos.length == 0
              ? CircularProgressIndicator()
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return Card(
                      child: GridTile(
                        child: Container(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: SizedBox(
                            child: GestureDetector(
                              onTap: () async {
                                Memo memo = await Navigator.of(context).push(
                                    MaterialPageRoute<Memo>(
                                        builder: (BuildContext context) =>
                                            MemoDetailPage(
                                                reference, memos[index])));
                                if (memo != null) {
                                  setState(() {
                                    memos[index].title = memo.title;
                                    memos[index].content = memo.content;
                                  });
                                }
                              },
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(memos[index].title),
                                        content: Text('삭제하시겠습니까?'),
                                        actions: <Widget>[
                                          FlatButton(
                                              onPressed: () {
                                                reference
                                                    .child(memos[index].key)
                                                    .remove()
                                                    .then((_) {
                                                  setState(() {
                                                    memos.removeAt(index);
                                                    Navigator.of(context).pop();
                                                  });
                                                });
                                              },
                                              child: Text('예')),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('아니요')),
                                        ],
                                      );
                                    });
                              },
                              child: Text(memos[index].content),
                            ),
                          ),
                        ),
                        header: Text(memos[index].title),
                        footer: Text(memos[index].createTime.substring(0, 10)),
                      ),
                    );
                  },
                  itemCount: memos.length,
                ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MemoAddApp(reference)));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

