import 'dart:async';
import 'dart:typed_data';

import 'package:daily/App/mainApplication/post_content.dart';
import 'package:daily/App/serverCommunication/client_get_info.dart';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/widget_classes/ad_state.dart';
import 'package:daily/widget_classes/display_image_content_class.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget_classes/display_video_content_class.dart';

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
  dynamic z;
  bool canGetInitialInfo = true;
  List? x;
  List bigBoi = [];
  GlobalKey<_viewContentState> viewContentKey = GlobalKey<_viewContentState>();
  dynamic display = const Placeholder();
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

    myInformation = await cGI.getMyCurrentInfo(phoneNumber);
    setState(() {});
  }

  void updateAllVideoWidgetStates() {
    if (bigBoi.isNotEmpty) {
      for (int i = 0; i < bigBoi.length; i++) {
        if (bigBoi[i].recievedContent["file"]["Type"] == "VIDEO") {
          bigBoi[i].disposeVideoWidget();
        }
      }
    }
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
    x = await cGI.getContent(phoneNumber);
    bannerAds.add(BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerListener,
        request: const AdRequest())
      ..load());

    if (x?.isEmpty == false) {
      setState(() {
        for (int i = 0; i < x!.length; i++) {
          String type = x?[i]["file"]["Type"];
          if (type == "IMAGE") {
            bigBoi.add(ImageWidget(recievedContent: x?[i]));
          } else if (type == "VIDEO") {
            try {
              bigBoi.add(VideoWidget(
                  recievedContent: x?[i],
                  updateOtherVideoWidgets: updateAllVideoWidgetStates));
            } catch (e) {}
          } else {
            print("UNRECOGNISED FILE TYPE");
          }
          canGetNewInfo = true;
        }
      });
    } else {
      setState(() {
        //bigBoi.add(Text("Looks like you've reached the bottom."));
      });
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
          cPI.exitApp(phoneNumber, myInformation[0]);
        }
      }
    }
  }

  int _calculateCurrentIndex(double scrollOffset, double itemExtent) {
    return (scrollOffset / itemExtent).floor();
  }

  @override
  Widget build(BuildContext context) {
    //[[phoneNumber, username, bigBoi],"location"]
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
                print("USERNAME IN VIEWCONTENT: ${myInformation[0]} ");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => postContent(
                      username: myInformation[0],
                    ),
                  ),
                );
              },
              child: const Text("POST SOME INFORMATION TO THE SERVER")),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(myInformation.toString()),
              ],
            ),
          ),
          Expanded(
              child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      if (currentIndex > (bigBoi.length - 10) ||
                          currentIndex == bigBoi.length) {
                        if (canGetNewInfo == true) {
                          try {
                            getInfo();
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
                                const Text("AN AD SHOULD BE HERE:"),
                                SizedBox(
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


//Issue: when taking pictures from my gallery just says invalid