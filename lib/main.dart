import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:guille/audio_description.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'NBA Calvo Player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String directory = '';
  List file = [];
  List<AudioDescription> audioDescriptionList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();
    _initAudioDescriptionList();
  }

  Future<String> loadAudioDescriptionFromJson() async {
    return await rootBundle.loadString('assets/data/description.json');
  }

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

  void _listofFiles() async {
    _initImages();
  }

  Future _initImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('audios/'))
        .where((String key) => key.contains('.mp3'))
        .toList();

    setState(() {
      file = imagePaths;
      print(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsAudioPlayer = AssetsAudioPlayer();

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("NBA Sounds"),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: file.length,
              itemBuilder: (BuildContext context, int index) {
                var audioDescriptionitem = audioDescriptionList.firstWhere(
                    (element) => element.audioName == _getFileName(file[index]),
                    orElse: () => new AudioDescription("WIP", "WIP", "WIP"));
                return Container(
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(audioDescriptionitem.title),
                      Text(audioDescriptionitem.description),
                      FloatingActionButton(
                        child: Icon(Icons.play_arrow),
                        onPressed: () => assetsAudioPlayer.open(
                          Audio(file[index]),
                        ),
                      ),
                    ],
                  ),
                );
              })),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _getFileName(String filename) {
    List<String> splittedFilename = filename.split("/");
    return splittedFilename[2].split('.')[0];
  }

  Future<void> _initAudioDescriptionList() async {
    String audioDescriptionItem = await loadAudioDescriptionFromJson();
    List audioDescriptionItemList = json.decode(audioDescriptionItem)["audios"];
    audioDescriptionList = audioDescriptionItemList
        .map((e) =>
            new AudioDescription(e["audioName"], e["title"], e["description"]))
        .toList();
  }
}
