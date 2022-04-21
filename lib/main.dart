// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:overlay_support/overlay_support.dart';
//
// import 'push_notification.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return OverlaySupport(
//       child: MaterialApp(
//         title: 'Notify',
//         theme: ThemeData(
//           primarySwatch: Colors.deepPurple,
//         ),
//         debugShowCheckedModeBanner: false,
//         home: HomePage(),
//       ),
//
//     );
//   }
// }
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State {
//   late int _totalNotifications = 0;
//   late final FirebaseMessaging _messaging;
//   PushNotification? _notificationInfo;
//   @override
//   void initState() {
//     registerNotification();
//     checkForInitialMessage();
//     FirebaseMessaging.onMessage.listen((event) {
//       var message = event;
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       var message = event;
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       PushNotification notification = PushNotification(
//         title: message.notification?.title,
//         body: message.notification?.body,
//         dataTitle: message.data['title'],
//         dataBody: message.data['body'],
//
//       );
//       setState(() {
//         _notificationInfo = notification;
//         _totalNotifications++;
//       });
//     });
//
//     super.initState();
//   }
//
//   checkForInitialMessage() async {
//     await Firebase.initializeApp();
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//
//     if (initialMessage != null) {
//       PushNotification notification = PushNotification(
//         title: initialMessage.notification?.title,
//         body: initialMessage.notification?.body,
//       );
//       setState(() {
//         _notificationInfo = notification;
//         _totalNotifications++;
//       });
//     }
//   }
//
//   void registerNotification() async {
//     // 1. Initialize the Firebase app
//     await Firebase.initializeApp();
//     _messaging = FirebaseMessaging.instance;
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     FirebaseMessaging.instance.getToken().then((token) {
//       print('FCM TOKEN:');
//       print(token);
//       print('END');
//     });
//     // 3. On iOS, this helps to take the user permissions
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//
//       // For handling the received notifications
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // Parse the message received
//         PushNotification notification = PushNotification(
//           title: message.notification?.title,
//           body: message.notification?.body,
//           dataTitle: message.data['title'],
//           dataBody: message.data['body'],
//
//         );
//
//         setState(() {
//           _notificationInfo = notification;
//           _totalNotifications++;
//         });
//         if (_notificationInfo != null) {
//           // For displaying the notification as an overlay
//           showSimpleNotification(
//             Text(_notificationInfo!.title!),
//             leading: NotificationBadge(totalNotifications: _totalNotifications),
//             subtitle: Text(_notificationInfo!.body!),
//             background: Colors.cyan.shade700,
//             duration: Duration(seconds: 2),
//           );
//         }
//       });
//     } else {
//       print('User declined or has not accepted permission');
//     }
//   }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notify/push_notification.dart';
import 'package:overlay_support/overlay_support.dart';
import 'dart:io' show Platform;

import 'notification_badge.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Demo Notification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _totalNotifications = 0;
  List<PushNotification> lstNotification = [];
  // late final FirebaseMessaging _messaging;

  PushNotification? _notificationInfo;

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    FirebaseMessaging.instance.getToken().then((token) {
      print('FCM TOKEN:');
      print(token);
      print('END');
    });


    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var notification = PushNotification();
      notification.title = message.notification?.title ?? "TITLE";
      notification.body = message.notification?.body ?? "BODY";
      lstNotification.add(notification);

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });

      if (_notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(_notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: _totalNotifications),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: Duration(seconds: 2),
        );
      }
    });
  }

  openedApp(){
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      lstNotification.add(notification);

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    registerNotification();

    openedApp();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              lstNotification = [];
            });
          }, icon: Icon(Icons.delete))
        ],

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: lstNotification.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                          child: ListTile(
                            title: Text(lstNotification[index].title.toString()),
                            subtitle: Text(lstNotification[index].body.toString()),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 20.0,
                                color: Colors.brown[900],
                              ),
                              onPressed: () {
                                setState(() {
                                  lstNotification.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                  }),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
