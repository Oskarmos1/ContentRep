import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import '../../widget_classes/display_video_content_class.dart';
import 'package:daily/widget_classes/display_image_content_class.dart';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/App/serverCommunication/client_get_info.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:daily/widget_classes/ad_state.dart';

class viewContent extends StatefulWidget {
  const viewContent({super.key});

  @override
  State<viewContent> createState() => _viewContentState();
}

class _viewContentState extends State<viewContent> with WidgetsBindingObserver {
  //adUnitId: 'ca-app-pub-7471100637488619/7198587992',
  List<BannerAd> bannerAds = [];
  //BannerAd? myBannerAd;
  String? phoneNumber;
  String? username;
  dynamic z;
  bool canGetInitialInfo = true;
  List? x;
  List bigBoi = [];
  List displayList = [];

  dynamic display = Placeholder();
  List myInformation = [];
  bool canBeExited = true;
  late Uint8List bytes;
  late ScrollController _innerNestedScrollController;
  late ScrollController _outerNestedScrollController;
  int currentIndex = 0;
  bool canGetNewInfo = true;
  ClientPostInfo cPI = ClientPostInfo();
  ClientGetInfo cGI = ClientGetInfo();
  Future<void> trial() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');

    myInformation =
        await cGI.getMyCurrentInfo("http://192.168.0.19:400", phoneNumber);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    trial();
    MobileAds.instance.initialize();
    _innerNestedScrollController = ScrollController();
    _outerNestedScrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> getInfo() async {
    x = await cGI.getContent("http://192.168.0.19:400", phoneNumber);
    bannerAds.add(BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerListener,
        request: const AdRequest())
      ..load());
    try {
      if (x?.isEmpty == false) {
        setState(() {
          for (int i = 0; i < x!.length; i++) {
            String type = x?[i]["file"]["Type"];
            if (type == "IMAGE") {
              bigBoi.add(ImageWidget(recievedContent: x?[i]));
            } else if (type == "VIDEO") {
              bigBoi.add(VideoWidget(recievedContent: x?[i]));
            } else {
              print("UNRECOGNISED FILE TYPE");
            }

            canGetNewInfo = true;
          }
        });
      }
    } catch (e) {
      print("$e  _______________________________________________");
    }
  }

  @override
  void dispose() {
    _innerNestedScrollController.dispose();
    _outerNestedScrollController.dispose();
    for (BannerAd bannerAd in bannerAds) {
      bannerAd.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (canBeExited == true) {
      if (state != AppLifecycleState.resumed) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
          cPI.exitApp("http://192.168.0.19:400", phoneNumber, username);
        }
      }
    }
  }

  int _calculateCurrentIndex(double scrollOffset, double itemExtent) {
    return (scrollOffset / itemExtent).floor();
  }

  @override
  Widget build(BuildContext context) {
    if (canGetInitialInfo == true) {
      canBeExited = true;
      getInfo();
      canGetInitialInfo = false;
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          TextButton(
              onPressed: () {
                canBeExited = false;
                Navigator.pushReplacementNamed(context, '/postContent',
                    arguments: [phoneNumber, username, displayList]);
              },
              child: Text("POST SOME INFORMATION TO THE SERVER")),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("${myInformation.toString()}"),
              ],
            ),
          ),
          Expanded(
              child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      if (displayList.isEmpty == false) {
                        print("object___________________");
                      }

                      if (currentIndex > (bigBoi.length - 10) ||
                          currentIndex == bigBoi.length) {
                        if (canGetNewInfo == true) {
                          try {
                            //getInfo();
                          } catch (e) {
                            print(e);
                          }

                          canGetNewInfo = false;
                        }
                      }
                      setState(() {
                        currentIndex = _calculateCurrentIndex(
                            _outerNestedScrollController.offset,
                            notification.metrics.maxScrollExtent /
                                bigBoi.length);
                      });
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _outerNestedScrollController,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return ListView.builder(
                        controller: _innerNestedScrollController,
                        itemCount: bigBoi.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int i) {
                          if ((i % 10) == 0) {
                            return Column(
                              children: <Widget>[
                                Text("AN AD SHOULD BE HERE:"),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: bannerAds.isEmpty
                                      ? Container()
                                      : Container(
                                          child: AdWidget(
                                              ad: bannerAds[
                                                  bannerAds.length - 1]),
                                        ),
                                )
                              ],
                            );
                          } else {
                            return bigBoi[i];
                          }
                        },
                      );
                    },
                  ))),
          Text("$currentIndex ${bigBoi.length}"),
        ],
      ),
    );
  }
}

//1 for posts and viewing content, 2 for making posts/ content, 3 for texting, 4 for profile info and settings
