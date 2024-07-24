import 'dart:async';
import 'dart:typed_data';

import 'package:daily/App/mainApplication/post_content.dart';
import 'package:daily/App/serverCommunication/client_get_info.dart';
import 'package:daily/App/serverCommunication/client_post_info.dart';
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
  late Timer _periodicTimer;
  Future<void> trial() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber')!;
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

    MobileAds.instance.initialize();
    _innerNestedScrollController = ScrollController();
    _outerNestedScrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    trial();
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bigBoi.isEmpty == true && canGetInitialInfo == true) {
        getInfo(phoneNumber);
      }
    });
  }

  Future<void> getInfo(phoneNumber) async {
    if (phoneNumber != null) {
      x = await cGI.getContent(phoneNumber);
      //bannerAds.add(BannerAd(
      //  size: AdSize.fullBanner,
      // adUnitId: AdMobService.bannerAdUnitId!,
      //listener: AdMobService.bannerListener,
      // request: const AdRequest())
      //..load());

      if (x?.isEmpty == false) {
        canGetInitialInfo = false;
        await Future.forEach(x!, (item) async {
          String type = item["file"]["Type"];
          if (type == "IMAGE") {
            bigBoi.add(ImageWidget(
              recievedContent: item,
              location: "view_content",
              myData: [phoneNumber, myInformation[0]],
            ));
          } else if (type == "VIDEO") {
            try {
              bigBoi.add(VideoWidget(
                  recievedContent: item,
                  location: "view_content",
                  myData: [phoneNumber, myInformation[0]],
                  updateOtherVideoWidgets: updateAllVideoWidgetStates));
            } catch (e) {}
          } else {
            print("UNRECOGNISED FILE TYPE");
          }
          canGetNewInfo = true;
        });
        setState(() {});
      } else {
        setState(() {
          //bigBoi.add(Text("Looks like you've reached the bottom."));
        });
      }
    }
  }

  @override
  void dispose() {
    _innerNestedScrollController.dispose();
    _outerNestedScrollController.dispose();
    for (BannerAd bannerAd in bannerAds) {
      bannerAd.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (ModalRoute.of(context)!.isCurrent == true) {
      canBeExited = true;
    }

    if (canBeExited == true) {
      if (state != AppLifecycleState.resumed) {
        if (mounted) {
          print("QUIT IN VIEWCONTENT");
          Navigator.pushReplacementNamed(context, '/');
          updateAllVideoWidgetStates();
          await cPI.exitApp(phoneNumber, myInformation[0]);
        }
      }
    }
    //}
  }

  int _calculateCurrentIndex(double scrollOffset, double itemExtent) {
    return (scrollOffset / itemExtent).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: <Widget>[
          TextButton(
              onPressed: () async {
                if (mounted) {
                  setState(() {
                    canBeExited = false;
                  });
                  updateAllVideoWidgetStates();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => postContent(
                        username: myInformation[0],
                      ),
                    ),
                  );
                }
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
                            getInfo(phoneNumber);
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
                        itemCount: bigBoi.length + 1,
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
                            return bigBoi[i - 1];
                          }
                        },
                      );
                    },
                  ))),
          Text("$currentIndex ${bigBoi.length}"),
        ],
      ),
    ));
  }
}

//1 for posts and viewing content, 2 for making posts/ content, 3 for texting, 4 for profile info and settings