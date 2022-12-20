import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _shareScreenshot(
      BuildContext context, ScreenshotController controller) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    await controller
        .capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: pixelRatio,
    )
        .then(
      (Uint8List? image) async {
        if (image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/image.png').create();
          await imagePath.writeAsBytes(image);

          await Share.shareFiles([imagePath.path]);
        }
      },
    );
  }

  bool _isBannerAdReady = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // test banner id
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {
          _isBannerAdReady = true;
        }),
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    // If load method is commented out then screenshot package will start working again
    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenshotController screenshotController = ScreenshotController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ads + Screenshot'),
        actions: [
          InkWell(
            onTap: () => _shareScreenshot(context, screenshotController),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.share),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Screenshot(
              controller: screenshotController,
              child: Card(
                margin: const EdgeInsets.all(32.0),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: const [
                      Text('Ads + Screenshot'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isBannerAdReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
