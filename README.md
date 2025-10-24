# Chat App

Flutter Chat App

## Overview
This is a cross-platform message board app, in which users can log in and post messages to a global board. All messages are deleted every 24 hours and midnight UTC starts a fresh board. Users must verify their email prior to being allowed to post. 

This project builds on to previous foundational mobile app concepts, including page navigation and state management, and adds a backend database using Firebase's FireStore, Storage, Authentication, Messaging, and Functions services.

## Skills
- **FireStore** to manage chats and user details
- Firebase **Authentication** to create new accounts, verify email addresses, and log users in to access restricted app features
- Firebase **Messaging** to manage **push notifications**
- Firebase **Storage** to store user-uploaded profile pictures
- Server-side **Functions** to manage chat and user cleanup, and to push notifications when new chat messages are posted. 

## 🔐 Firebase Setup

**IMPORTANT**: Firebase configuration files are not included in version control.

### Setup Steps:
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`
3. Download `GoogleService-Info.plist` from Firebase Console
4. Place in `ios/Runner/GoogleService-Info.plist`
5. Run `flutterfire configure` to generate `firebase_options.dart`

**Never commit these files to Git!**