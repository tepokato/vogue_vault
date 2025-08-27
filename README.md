Vogue Vault

Vogue Vault is a productivity app designed for mobile and freelance beauty professionals such as hairdressers, barbers, tattoo artists, and nail technicians. The app helps professionals organize and manage their work on the go — keeping appointments, customer info, and service details all in one place.

This app is not for customers; it is built exclusively for professionals to simplify their day-to-day workflow.

---

Features

Appointments Management

Register new appointments quickly.

Save important details like customer name, service type, and location.

Support for one-time addresses or saved favorites like "Home" or "Salon".

Customer Handling

Add regular customers by name.

Offer guest checkout for one-time or occasional clients.

Calendar & Notifications

View all scheduled appointments in a calendar format.

Receive notifications and reminders for upcoming services.

Fully customizable notification settings.

Service Catalog

Save your frequently offered services for faster appointment creation.

---

Tech Stack

- **Flutter** — cross-platform UI toolkit
- **Provider** — app-wide state management
- **Hive** & **hive_flutter** — local NoSQL storage
- **intl** — internationalization and formatting utilities
- **table_calendar** — calendar UI for appointment views
- **flutter_local_notifications** — local reminders and alerts

---

Who This App Is Not For

Vogue Vault is not meant for customers. Clients cannot browse, book, or interact with the app directly — it’s built specifically as a tool for professionals only.

---

Installation

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) 3.3 or later
- A device or emulator for your target platforms

### Run locally
```bash
flutter pub get
flutter run
```

### Build for release
**Mobile**
```bash
flutter build apk          # Android
flutter build ios          # iOS
```

**Web**
```bash
flutter run -d chrome      # Development
flutter build web          # Release bundle in build/web
```

**Desktop (macOS/Windows/Linux)**
Enable once:
```bash
flutter config --enable-macos-desktop --enable-windows-desktop --enable-linux-desktop
```
Then run or build:
```bash
flutter run -d windows     # or macos / linux
flutter build windows      # or macos / linux
```

---

License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
