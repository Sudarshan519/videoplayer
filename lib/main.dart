import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

var videos = [
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
      'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
];
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
  var _disposed = false;
  var index = 0;
  var _progress = 0.0;
  var _isPlayingIndex = 0;
  bool _isPlaying = false;
  var _duration;
  var _onUpdateControllerTime;
  Duration _position = Duration(seconds: 0);
  _onControllerUpdate() async {
    if (_disposed) {
      return;
    }
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final controller = _controller;
    if (controller == null) {
      debugPrint("controller is null");
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint("controller can not be initialized");
      return;
    }
    final position = await controller.position;
    _position = position!;
    print(position);

    final playing = controller.value.isPlaying;
    if (playing) {
      if (_disposed) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble();
      });
    }
    _isPlaying = playing;
  }

  var videoUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";
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

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo(videos[0]);
  }

  _initializeVideo(videoUrl) {
    final controller = VideoPlayerController.network(videoUrl);
    _controller = controller;
    final old = _controller;

    if (old != null) {
      old.removeListener(_onControllerUpdate);
      old.pause();
    }
    setState(() {});
    // ignore: avoid_single_cascade_in_expression_statements
    controller
      ..initialize().then((_) {
        // old.dispose();

        controller.addListener(_onControllerUpdate);
        controller.play();

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
  void dispose() {
    _disposed = true;
    // _controller?.pause();
    // _controller?.dispose();
    // _controller == null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container()),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: LinearProgressIndicator(
              color: Colors.red,
              value: _progress,
              backgroundColor: Colors.white,
            ),
          ),
          _controlView(context),
          ...List.generate(
              videos.length,
              (index) => ListTile(
                    title: Text(
                      videos[index],
                    ),
                    onTap: () {
                      _initializeVideo(videos[index]);
                    },
                  )),

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
          FloatingActionButton(
            onPressed: () {
              _initializeVideo(videoUrl);
              // download(videoUrl, "video1");
              // setState(() {
              //   _controller.value.isPlaying
              //       ? _controller.pause()
              //       : _controller.play();
              // });
            },
            child: Icon(
              Icons.download,
            ),
          ),
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

  _controlView(BuildContext context) {
    final noMute = (_controller.value.volume) > 0;
    final duration = _duration?.inSeconds ?? 0;

    final head = _position.inSeconds;
    final reamined = max(0, duration - head) ?? 0;

    final mins = convertTwo(reamined ~/ 60);
    final secs = convertTwo(reamined % 60);
    return Row(
      children: [
        IconButton(icon: Icon(Icons.volume_down), onPressed: () {}),
        IconButton(
            icon: Icon(
              Icons.fast_rewind,
            ),
            onPressed: () {}),
        IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
              setState(() {});
            }),
        IconButton(icon: Icon(Icons.fast_forward), onPressed: () {}),
        Text(_position.toString() + ":" + secs.toString())
      ],
    );
  }

  max(int i, int param1) {
    return i > param1 ? i : param1;
  }
}
