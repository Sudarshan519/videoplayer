import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late VideoPlayerController _controller;
  var playbackSpeed = 1.0;
  var _duration = Duration(seconds: 0);
  var videoUrl =
      "https://videos-fms.jwpsrv.com/0_62399925_0xb24496f12221790cf2c743704601560a930e9604/content/conversions/s5njzvyx/videos/gf5Gwppt-33263179.mp4";
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) async {
        _duration = (await _controller.position)!;
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  getPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
      // Either the permission was already granted before or the user just granted it.
    } else {
      if (await Permission.storage.isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
      }
    }
  }

  getDirectory() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    return tempPath;
  }

  download(String url, String filename) async {
    var response = await http.get(Uri.parse(url));
    var length = response.contentLength;
    var tempPath = await getTemporaryDirectory();
    File file = File('$tempPath/$filename.ddr');

    await file.writeAsBytes(response.bodyBytes);
    var received = await file.length();
    Future.doWhile(() async {
      print("${(received / length!) * 100} %");
      return received != length;
    });

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container()),
          _controlView(context)
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     FloatingActionButton(
          //       onPressed: () {
          //         setState(() {
          //           setState(() {
          //             _controller.setPlaybackSpeed(playbackSpeed / 2);
          //           });
          //         });
          //       },
          //       child: const Icon(
          //         Icons.fast_rewind,
          //       ),
          //     ),
          //     FloatingActionButton(
          //       onPressed: () {
          //         setState(() {
          //           _controller.value.isPlaying
          //               ? _controller.pause()
          //               : _controller.play();
          //         });
          //       },
          //       child: Icon(
          //         _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          //       ),
          //     ),
          //     FloatingActionButton(
          //       onPressed: () {
          //         setState(() {
          //           _controller.setPlaybackSpeed(playbackSpeed * 2);
          //         });
          //       },
          //       child: Icon(
          //         Icons.fast_forward,
          //       ),
          //     ),
          //     FloatingActionButton(
          //       onPressed: () {
          //         download(videoUrl, "video1");
          //         // setState(() {
          //         //   _controller.value.isPlaying
          //         //       ? _controller.pause()
          //         //       : _controller.play();
          //         // });
          //       },
          //       child: Icon(
          //         Icons.download,
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _controlView(BuildContext context) {
    final noMute = (_controller.value.volume ?? 0) > 0;
    final duration = _duration?.inSeconds ?? 0;
    return Container();
  }
}
