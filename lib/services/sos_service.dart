import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const MethodChannel _smsChannel =
      MethodChannel('safepulse/sms');

  Future<int> sendSosAlert({
    required double latitude,
    required double longitude,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // Get emergency contacts from Firestore
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('emergencyContacts')
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No emergency contacts found.');
    }

    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    final message =
        'SafePulse SOS ALERT!\n'
        'Emergency assistance required.\n'
        'My current location:\n'
        '$mapsUrl';

    int sentCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final phoneValue = data['phone'];

      if (phoneValue == null) {
        continue;
      }

      String phone = phoneValue.toString().trim();

      if (phone.isEmpty) {
        continue;
      }

      if (!phone.startsWith('+') && phone.length == 10) {
        phone = '+91$phone';
      }

      try {
        final result = await _smsChannel.invokeMethod<bool>(
          'sendSms',
          {
            'phone': phone,
            'message': message,
          },
        );

        if (result == true) {
          sentCount++;
        }
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_DENIED') {
          throw Exception(
            'SMS permission is required. Please allow SMS permission.',
          );
        }

        throw Exception(
          'SMS failed for $phone: ${e.message}',
        );
      }
    }

    if (sentCount == 0) {
      throw Exception(
        'Unable to send SOS SMS to any emergency contact.',
      );
    }

    return sentCount;
  }
}