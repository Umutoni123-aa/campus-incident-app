# Campus Incident Reporter

Campus Incident Reporter lets students report problems on campus and lets
staff track and update them.

## Features

- Create an account and sign in with an ALU email.
- Submit an incident with a category, location, description, and optional photo.
- Search and filter reports.
- See report status and a simple status timeline.
- Staff can update status and manage reports.
- Students can see their own reports.

## Tech stack

- Flutter
- Firebase Auth
- Cloud Firestore
- Provider

## Folder structure

```text
lib/
  models/       Data models
  services/     Firebase access
  providers/    App state
  screens/      App screens
  widgets/      Shared UI widgets
  utils/        Shared helpers and validators
```

## How to run

1. Install Flutter and an emulator or connect a device.
2. Clone the project:

   ```text
   https://github.com/Umutoni123-aa/campus-incident-app
   ```

3. Run `flutter pub get`.
4. Add Firebase configuration for the target platform.
5. Run `flutter run`.

## Firebase setup

1. Create a Firebase project.
2. Add the Android, iOS, or web app to the project.
3. Generate `firebase_options.dart` with the FlutterFire CLI.
4. Enable Email/Password sign-in in Firebase Authentication.
5. Create a Cloud Firestore database.
6. Publish the rules from `firestore.rules`.

## User roles

New users are students. A trusted administrator can set a user's Firestore
role to `staff`. Staff can update report status and delete reports.

## Firestore data structure

The `users/{uid}` document contains:

- `name`
- `email`
- `role`
- `createdAt`

The `incidents/{id}` document contains:

- `title`
- `description`
- `category`
- `location`
- `imageBase64`
- `status`
- `reporterId`
- `reporterName`
- `createdAt`

## Limitations

Photos are stored as compressed base64 in Firestore because Firebase Storage
needs a paid plan.

## Author 
Umutoni Nada
