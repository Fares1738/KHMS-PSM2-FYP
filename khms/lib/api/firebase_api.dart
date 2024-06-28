import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  static Future<String> getAccessToken() async {
    await dotenv.load(fileName: ".env");

    final privateKey = dotenv.env['SA_PRIVATE_KEY']!
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\u003d', '=')
        .replaceAll(r'\u003c', '<')
        .replaceAll(r'\u003e', '>')
        .replaceAll(r'\u0026', '&');

    final serviceAccountJson = {
      "type": dotenv.env['SA_TYPE'],
      "project_id": dotenv.env['SA_PROJECT_ID'],
      "private_key_id": dotenv.env['SA_PRIVATE_KEY_ID'],
      "private_key": privateKey,
      "client_email": dotenv.env['SA_CLIENT_EMAIL'],
      "client_id": dotenv.env['SA_CLIENT_ID'],
      "auth_uri": dotenv.env['SA_AUTH_URI'],
      "token_uri": dotenv.env['SA_TOKEN_URI'],
      "auth_provider_x509_cert_url": dotenv.env['SA_AUTH_PROVIDER_CERT_URL'],
      "client_x509_cert_url": dotenv.env['SA_CLIENT_CERT_URL'],
      "universe_domain": dotenv.env['SA_UNIVERSE_DOMAIN'],
    };

    print(dotenv.env['SA_PRIVATE_KEY']!.length);

    List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(
      String collectionName, String documentId, String title, String body,
      {String? subCollectionName}) async {
    final accessToken = await getAccessToken();

    DocumentReference docRef;

    if (subCollectionName != null) {
      docRef = FirebaseFirestore.instance
          .collection('Facilities')
          .doc(subCollectionName)
          .collection('Applications')
          .doc(documentId);
    } else {
      docRef =
          FirebaseFirestore.instance.collection(collectionName).doc(documentId);
    }

    DocumentSnapshot doc = await docRef.get();

    if (!doc.exists) {
      print('$collectionName document not found.');
      return;
    }

    String studentId = doc['studentId'];

    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('Students')
        .doc(studentId)
        .get();
    if (!studentDoc.exists) {
      print('Student document not found.');
      return;
    }

    String fcmToken = studentDoc['fcmToken'];

    final Map<String, dynamic> message = {
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    };

    final http.Response response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/khms-d556a/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
