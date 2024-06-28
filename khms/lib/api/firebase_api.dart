import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "khms-d556a",
      "private_key_id": "1042221b71a19b3e65791040e0f72efd9001b8e4",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC21KleBD4RJIjD\nFxpLePWHevR3Q8eIT+QiocSMRSuBaTA5c774iQou9iSp7BfucxTrKKx2mvxy9egY\nPpeFW6NRhP1WHIjKOcOfARigDzbDlW2ZJbu9uYZymM95vJ/cJpbeayX1Fn9KlnYz\nJ4Vpjl+ZjqugMcIbjESdNKFUcAKPa5sHROSWA9aMmDw734uddKI9bEUi5PwOYbLo\n3BcJYpNAxJzyUZNeoel5HzO2qgazhqzAMiajVyYa2FyJPWV0B7HosLIZumwYGV0L\nDvalxtCYl5xLYBATbZfSEHOO9h4B8hMTgTUG6FOO4F0mzft2rdMuQZimES274lA5\nhrKcCALDAgMBAAECggEAHPYsDCIU6OdGKM1Ik4sKLddq0VexzGSHaXsBpQyx+xJ8\nGqW8qyceL1k7bpVhJxsgxa2QQEuF0PomNWz42J2vDdNIxDLJ8mrbE517VqOCU9Ig\nZeGlz0SLySxutUSNeDS+smX7wcq6CEk0WR8aEaIFf9ArXLl1G6MJHXQAWF1T8n7e\n5ojDljZlAimhnXeTiNrbzc7YrdyzdnagwW+bMUjeVrG89z2deNEnNN20/miu+00X\nzHctkeETsWgfDu0k/R7ufEdqGspKPKxN2Czci4YBHOmHbtPPb9WRnc66FOjiBNWk\nl54IDMp6gLEZI41G66Je4Z8RAiHPwAfZ7/PZFaDKHQKBgQDsIe6WOqcQyQr17N6G\ncT4+ldWlmueHyLTpefsUl/aIkzmcHi17b5v8BZ4jX3UzS8NFctXn4vSPrIDOjAjS\n0owU8hrQWVq8uwH/Yag8eKdum79MX4DaG+YrpZ8dSFjWd/Bw0vIGY7sNMele3hM5\nx4Iz/zbao4892U0sbRBtsMc0zQKBgQDGNqjGpTFRRazeXhDpvbE83I1/42R8H0Ds\nAPngDvTGMpcOwv0NetaIKbBWzTV1El3ROXxNIF4cNTYLKIOrXqur4Hsd+gRx82BF\nP+Q/7k1LgCCXnyanizm1y/3vOLHyFuScliLcv5iPXNbK4NFIkpIhQvF5wqtRdAuE\ncXAKth2VzwKBgQCXB1jvc1I5tSyygK8PNE0IgJMmmb4updu4XVGPKWcAkZHOXarf\ngVI2Tm2H2F1A0ttxhvJzn0CmyEGWWhCmrw3zs6ocypnzjnTHn/GXw9/rKeif85GZ\nbzC3h/YOJ6DSg+Igd3tfRNh1pw/JoqaPVSDdGwY9r1FF0L/Ag313exLenQKBgEfB\nT9YhxTnDvHH/oaXMexYqTbtHaYAZnFoTfGHlaC078T1xz0QK/RDr7p9tyHVqQbZV\nVi9hkVAq3zao4wmtyv381PUkJmnODkLjf1C5hxfW+XWKMuciWrD6eSIZ5ylZqkcZ\nfuNlJOh5VnS5cGoSTX5nCp3moDhrhyPaIRJvnUQ3AoGBAKJDUuWBsVBmCNm2kPIA\naJyrtTbMWYdl5k7Qk+/uvQt9G3Uj9L3cS46Isxuye39OgMTKFZWu5mzTLUwqu3jM\nW5RWeV6SCUyB4WqRN+7A5O47KmP8IJ/6e0tS/cB3EizCGtFuK71NNboVh7swclHq\n9B+ek7Vo9vp7llYU2Ykhc8Yv\n-----END PRIVATE KEY-----\n",
      "client_email": "khms-71@khms-d556a.iam.gserviceaccount.com",
      "client_id": "113062560835247354576",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/khms-71%40khms-d556a.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

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
