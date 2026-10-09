# SafePulse – Smart Personal Safety

SafePulse is a Flutter-based Android application designed to help users alert their trusted emergency contacts during an emergency.

## Features

- **User Authentication:** Register and log in using Firebase Authentication.
- **Emergency Contacts:** Save and manage trusted contacts using Cloud Firestore.
- **GPS Location:** Obtain the device's current location.
- **SOS Alert:** Send an emergency SMS directly from the Android device.
- **Google Maps Link:** Include a location link in the SOS message.
- **Simple Interface:** Access SOS, Emergency Contacts, and My Location from the home screen.

## Technology Stack

- Flutter and Dart
- Firebase Authentication
- Cloud Firestore
- Kotlin and Android SmsManager
- Geolocator
- Google Maps

## How It Works

1. Register or log in to SafePulse.
2. Add trusted emergency contacts.
3. Activate the SOS feature when needed.
4. Allow the app to access the required permissions.
5. The app obtains the current location and sends an SOS SMS with a Google Maps link to saved contacts.

## Setup

1. Install Flutter and the Android development tools.
2. Clone this repository.
3. Run `flutter pub get`.
4. Configure your own Firebase project and Android app settings.
5. Connect an Android device and run `flutter run`.

## Important Notes

- Location and SMS functionality require the appropriate Android permissions.
- SMS delivery depends on device permissions, SIM availability, mobile network, and carrier support.
- Do not upload private keys, service-account credentials, signing credentials, or other secrets to GitHub.

## Project Status

Core features, including authentication, emergency contact storage, GPS location, and direct SOS SMS, have been implemented and tested on an Android device.

## Developed By

- Vaishnavi Sawant
- Sneha Shinde
- Nupur Sugdare
