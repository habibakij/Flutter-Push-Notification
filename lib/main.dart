import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


const AndroidNotificationChannel channel= AndroidNotificationChannel(
  "high_importance_id", /// id
  "High Importance Notification", /// channel
  description: "High Importance Notification Description",
  importance: Importance.high,
  playSound: true);

final FlutterLocalNotificationsPlugin plugin= FlutterLocalNotificationsPlugin();

Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

  await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );


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
      home: const MyHomePage(title: 'Firebase Notification'),
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


  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      RemoteNotification? notification= message.notification;
      AndroidNotification? androidNotification= message.notification?.android;
      if(notification != null && androidNotification != null){
        plugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: "channel.des",
              color: Colors.grey,
              playSound: true,
              icon: '@mipmap/ic_launcher'
            ),
          )
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      RemoteNotification? notification= message.notification;
      AndroidNotification? androidNotification= message.notification?.android;
      if(notification != null && androidNotification != null){
        showDialog(context: context, builder: (_){
          return AlertDialog(
            title: Text(notification.title.toString()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(notification.body.toString())
                ],
              ),
            ),
          );
        });
      }
    });

  }

  void getNotification(){
    int id= 0;
    print("id_ $id");
    setState(() {
      id= Random().nextInt(100);
    });
    plugin.show(
      0,
      "Akij Notify: $id",
      "You have new Notification",
      NotificationDetails(
        android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: "channel.des",
            color: Colors.grey,
            playSound: true,
            icon: '@mipmap/ic_launcher'
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[






          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
