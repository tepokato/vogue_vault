# Vogue Vault

Vogue Vault is a scheduling platform for barbers, hairdressers, nail technicians, tattoo artists, and other beauty professionals and their clients. Salon owners, barbers, stylists, nail techs, tattoo artists, and makeup artists can showcase services, manage calendars, and coordinate appointments in one place.

## Setup

This project targets **Flutter 3.19.x**. Verify your environment with:

```bash
flutter --version
```

Install dependencies:

```bash
flutter pub get
```

### Run on each platform

- **Android:** `flutter run -d android`
- **iOS:** `flutter run -d ios`
- **Web:** `flutter run -d chrome`
- **Windows:** `flutter run -d windows`
- **macOS:** `flutter run -d macos`
- **Linux:** `flutter run -d linux`

### Build release binaries

- Android: `flutter build apk`
- iOS: `flutter build ios`
- Web: `flutter build web`
- Windows: `flutter build windows`
- macOS: `flutter build macos`
- Linux: `flutter build linux`

## Core Features

- Browse profiles and services for barbers, hairdressers, nail technicians, tattoo artists, and other beauty professionals
- Book, reschedule, and cancel appointments across all service types
- Manage professional calendars and time slots
- Local data persistence with Hive
- State management using Provider

### Example Services

- Barber cuts
- Hair styling and coloring
- Manicures and pedicures
- Tattoo design and application
- Makeup application

## Roadmap

- In‑app payments and invoicing
- Calendar sync with Google or Apple
- Push notifications and reminders
- Ratings and reviews for stylists
- Advanced analytics for salon performance

## Project Architecture

The app follows a feature-driven structure under `lib/`:

- `models/` contains data classes such as `Appointment` and `Client`.
- `services/` holds the service layer. For example, `AppointmentService` uses Hive for local persistence and exposes CRUD operations while notifying listeners via `ChangeNotifier`.
- `screens/` provides the UI widgets for each page.
- `utils/` includes shared helpers and constants.
- `main.dart` wires everything together and registers providers.

## Running Tests

Run the full test suite, including unit and widget tests, with:

```bash
flutter test
```

## Contribution Guidelines

1. Format code: `dart format .`
2. Lint and analyze: `flutter analyze`
3. Run tests: `flutter test`
4. Commit changes and open a pull request.
