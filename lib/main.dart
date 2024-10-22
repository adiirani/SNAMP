import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:SNAMP/models/cacheprovider.dart';
import 'package:SNAMP/models/innertube.dart';
import 'package:SNAMP/models/musicprovider.dart';
import 'package:SNAMP/models/playlistprovider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:SNAMP/models/searchprovider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'theme/themeprov.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:SNAMP/models/templates/searchModels.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final innertube = InnertubeProto();
final cacher = CacheProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SearchCardAdapter());
  Hive.registerAdapter(SearchPlaylistAdapter());
  
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox('preferences');

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.SNAMP.music.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Themeprov()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider(cacher: cacher)),
        ChangeNotifierProvider(
            create: (context) => MusicProvider(innertube: innertube, cacher: cacher)),
        ChangeNotifierProxyProvider<MusicProvider, SearchProvider>(
          create: (context) => SearchProvider(
            innertube: innertube,
            musicProvider: Provider.of<MusicProvider>(context, listen: false),
          ),
          update: (context, musicProvider, previous) =>
              previous ?? SearchProvider(innertube: innertube, musicProvider: musicProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    if (state == AppLifecycleState.detached) {
      // Stop the audio when app is minimized or closed
      musicProvider.stop();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      theme: Provider.of<Themeprov>(context).themeData,
    );
  }
}
