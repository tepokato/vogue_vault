# Vogue Vault

Vogue Vault is an open-source Flutter application for scheduling appointments between beauty professionals and their clients. Barbers, hairdressers, nail technicians, tattoo artists and others can showcase their skills, manage availability and coordinate bookings in one place.

> This repository contains software only; it does not provide or broker any professional services.

## Requirements

- Flutter 3.19.x

Check your environment:

```bash
flutter --version
```

Install dependencies:

```bash
flutter pub get
```

## Run

Launch the app on your target platform:

```bash
flutter run -d <platform>
```

Supported platforms include Android, iOS, Web, Windows, macOS and Linux.

## Build

Create release binaries:

```bash
flutter build <platform>
```

## Features

- Browse professional profiles and their offerings
- Book, reschedule and cancel appointments
- Manage calendars and availability
- Local persistence with Hive
- State management with Provider

## Project Layout

```
lib/
  models/        # data classes such as Appointment and Client
  services/      # service layer and persistence
  screens/       # UI pages
  utils/         # helpers and constants
  main.dart      # app entry point
```

## Testing

Run unit and widget tests with:

```bash
flutter test
```

## Contributing

1. Format code: `dart format .`
2. Lint and analyze: `flutter analyze`
3. Run tests: `flutter test`
4. Commit changes and open a pull request.
