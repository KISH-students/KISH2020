import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:kish2019/tool/api_helper.dart';
import 'package:kish2019/widget/DetailedCard.dart';
import 'package:kish2019/widget/dday_card.dart';
import 'package:kish2019/widget/description_text.dart';
import 'package:kish2019/widget/title_text.dart';
import 'package:kish2019/noti_manager.dart';
import 'package:kish2019/kish_api.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin<MainPage>{
  Widget lunchFutureBuilder;
  Widget ddayFutureBuilder;
  String todayDate;
  int sliderIdx = 0;

  Icon ddayNotiIcon = new Icon(Icons.sync);
  Icon lunchNotiIcon = new Icon(Icons.sync);

  @override
  void initState() {
    super.initState();
    List<Widget> list = [];
    Container widget = Container(
        child: new Column(
          children: list,
          crossAxisAlignment: CrossAxisAlignment.start,
        ));

    list.add(YoutubeShimmer());
    list.add(DescriptionText(
      'D-Day - 불러오는 중',
      margin: EdgeInsets.only(left: 25, top: 5),
    ));
    ddayFutureBuilder = widget;

    lunchFutureBuilder = YoutubeShimmer();

    todayDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
    initWidgets();
  }

  Future<void> initWidgets() async {
    if (!this.mounted) {
      await Future<void>.delayed(Duration(milliseconds: 10), () {
        print("재시도");
        initWidgets();
      });
    } else {
      print("시작");
      setState(() {
        loadDdayNotiIcon();
        loadLunchNotiIcon();
      });

      if (NotificationManager.instance.preferences == null) {
        await NotificationManager.instance.loadSharedPreferences();
      }

      lunchFutureBuilder = FutureBuilder(
          future: ApiHelper.getLunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return getLunchWidget(snapshot.data);
              } else {
                return DDayCard(
                  color: Colors.redAccent,
                  content: "불러오지 못했어요",
                );
              }
            } else {
              String cachedJson = NotificationManager.instance.preferences
                  .getString(ApiHelper.getCacheKey(KISHApi.GET_LUNCH, {"date": ApiHelper.getTodayDateForLunch()}));
              if (cachedJson != null) {
                dynamic data;
                try {
                  data = json.decode(cachedJson);
                } catch (e) {
                  print(e);
                  return YoutubeShimmer();
                }

                return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: LinearProgressIndicator(backgroundColor: Colors.orangeAccent),
                      ),
                      getLunchWidget(data),
                    ]);
              }
              return YoutubeShimmer();
            }
          });

      ddayFutureBuilder = FutureBuilder(
        future: ApiHelper.getExamDDay(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return getDdayWidget(snapshot.data);
            } else if (snapshot.hasError) {
              return getDdayWidget(null);
            }
          }

          String cachedJson = NotificationManager.instance.preferences.getString(ApiHelper.getCacheKey(KISHApi.GET_EXAM_DATES, {}));
          if (cachedJson != null) {
            dynamic data;
            try {
              data = json.decode(cachedJson);
            } catch(e) {
              print(e);
              return YoutubeShimmer();
            }
            return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: LinearProgressIndicator(backgroundColor: Colors.orangeAccent),
                  ),
                  getDdayWidget(data[0]),
                ]
            );
          }

          List<Widget> list = [];
          Container widget = Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: new Column(
                children: list,
                crossAxisAlignment: CrossAxisAlignment.start,
              ));

          list.add(YoutubeShimmer());
          list.add(DescriptionText(
            'D-Day - 불러오는 중',
            margin: EdgeInsets.only(left: 25, top: 5),
          ));
          return widget;
        },
      );

      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 17),
            child: Center(
              child: FlatButton(
                onPressed: () { _showAppInfoDialog(context); },
                child: Image(image: AssetImage("images/kish_title_logo.png"), height: 59, width:  MediaQuery.of(context).size.width * 0.3,),
              ),),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 25),
            child: TitleText('오늘의 식단을\n확인하세요', top: 50.0,),
          ),
          /*CarouselSlider(
            options: CarouselOptions(
                aspectRatio: 2 / 1,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 10),
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    sliderIdx = index;
                  });
                }),
            items: sliderItems,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _getIndicator(sliderItems, sliderIdx),
          ),*/
          Center(
              child: Column(
                  children: [
                    Container(
                        alignment: Alignment.topRight,
                        child: FlatButton.icon(onPressed: () { updateDdayNoti(); },
                          icon: ddayNotiIcon,
                          label: const Text("DDay 알림"),)),
                    ddayFutureBuilder,
                  ]
              )
          ),

          Center(
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 30),
                      alignment: Alignment.topRight,
                      child: FlatButton.icon(onPressed: updateLunchNoti,
                        icon: this.lunchNotiIcon,
                        label: const Text("식단 알림"),)),
                  Container(
                      child: lunchFutureBuilder),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget getLunchWidget(List data) {
    if (data != null) {
      Widget menuWidget;

      DateTime tmpDate = DateTime.now();
      DateTime today =
      DateTime(tmpDate.year, tmpDate.month, tmpDate.day);
      int timestamp = (today.millisecondsSinceEpoch / 1000).round();
      int count = 0;
      //print("our : " + today.millisecondsSinceEpoch.toString());

      data.forEach((element) {
        if (count > 0) return;

        Map data = element;
        /*print("-------");
                          print(data["timestamp"] * 1000);
                          print(DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000).toString());*/
        if (timestamp <= data["timestamp"]) {
          menuWidget = DetailedCard(
            bottomTitle: "",
            title: "오늘의 급식",
            description: data["date"],
            content: (data["menu"] as String).replaceAll(",", "\n"),
            icon: Container(),
            descriptionColor: Colors.black87,
            contentTextStyle: const TextStyle(
                fontFamily: "NanumSquareL",
                color: Color.fromARGB(255, 135, 135, 135),
                fontWeight: FontWeight.w600),
          );
          count++;
        }
      });

      return Container(
          child: menuWidget,
          width: MediaQuery.of(context).size.width * 0.9);
    } else {
      return DDayCard(
        color: Colors.redAccent,
        content: "불러올 수 없음",
      );
    }
  }

  Widget getDdayWidget(Map data) {
    List<Widget> list = [];
    Container widget = Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: new Column(
          children: list,
          crossAxisAlignment: CrossAxisAlignment.start,
        ));

    if (data != null) {
      if (data["invalid"] != null) {
        list.add(new DDayCard(content: "정보 없음", color: DDayCard.grey));
        list.add(DescriptionText(
          'D-Day - 정보 없음',
          margin: EdgeInsets.only(left: 25, top: 5),
        ));
        return widget;
      }

      list.add(new DDayCard(
        timestamp: data["timestamp"],
        description: data["label"] + " (" + data["date"] + ")",
      ));
      return widget;
    } else {
      list.add(new DDayCard(
        content: "불러오기 실패",
        color: DDayCard.grey,
      ));
      list.add(DescriptionText(
        'D-Day - 불러올 수 없어요',
        margin: EdgeInsets.only(left: 25, top: 5),
      ));
      return widget;
    }
  }

  void loadDdayNotiIcon() async {
    NotificationManager manager = NotificationManager.getInstance();

    bool enabled = await manager.isDdayEnabled();

    ddayNotiIcon = Icon(
        enabled ? Icons.notifications_active : Icons
            .notifications_active_outlined);
  }

  Future<void> updateDdayNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.toggleDday();

    setState(() {
      ddayNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });

    await manager.updateNotifications();
  }

  void loadLunchNotiIcon() async {
    NotificationManager manager = NotificationManager.getInstance();
    lunchNotiIcon = Icon(await manager.isLunchMenuEnabled() ? Icons.notifications_active : Icons.notifications_active_outlined);
  }

  Future<void> updateLunchNoti() async{
    NotificationManager manager = NotificationManager.getInstance();

    bool result = await manager.toggleLunch();

    setState(() {
      lunchNotiIcon = Icon(result ? Icons.notifications_active : Icons.notifications_active_outlined);
    });

    await manager.updateNotifications();
  }

  List<Widget> _getIndicator(List items, int index) {
    List<Widget> list = [];
    // https://pub.dev/packages/carousel_slider/example - indicator demo
    for (int i = 0; i < items.length; i++) {
      list.add(Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i == index
              ? Color.fromRGBO(0, 0, 0, 0.9)
              : Color.fromRGBO(0, 0, 0, 0.4),
        ),
      ));
    }
    return list;
  }

  @override
  bool get wantKeepAlive => true;
}

Future<void> _showAppInfoDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('KISH'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('개발자', style: TextStyle(fontFamily: "NanumSquareR", fontSize: 20), textAlign: TextAlign.center,),
              Text("유정욱\n이동주\n이찬영\n김태형\n김나현\n조현정\n김재원\n고성준\n김태운\n김경재\n박지민\n김선우"),
              Text("\n개발에 기여 해보세요.\nhttps://github.com/KISH-students"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('뒤로가기'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}