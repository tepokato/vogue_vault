# Privacy Policy

Vogue Vault is built for independent beauty professionals (hair, barbering, nails, tattoo, etc.). This policy describes what data the app handles, where it lives, and when it leaves your device.

## Data you enter in the app

The app stores information you provide locally on your device, including:

- Account email and password (password is hashed; see Security)
- Professional profile, service catalog, and optional profile photo
- Appointments (times, services, prices, locations, guest or saved customer details)
- Saved customers and address labels
- Theme, language, and reminder timing preferences

There is no Vogue Vault-operated cloud database. Routine use does not send this content to our servers (we do not run a backend for the app).

## Optional Google Drive backup

If you use **Settings → Back up to Google Drive**, the app uploads an **encrypted** snapshot of your business data (appointments, customers, provider profiles, addresses) into your Google account’s **app data folder** for Drive. Google’s infrastructure processes that file under [Google’s privacy policy](https://policies.google.com/privacy). The file is encrypted with a key stored on your device (same family of key as local database encryption); **restoring on a new device is not implemented in the app today** and would require a future release that can decrypt using your device key or an export you control.

## Permissions

- **Camera** — optional, to take a profile photo.
- **Photos / media (read)** — optional, to pick an existing image for your profile.
- **Notifications** — to show appointment reminders at the time you configure.
- **Exact alarms (Android)** — so reminders can fire at the scheduled time where the OS allows it.

## Security on your device

- Sign-in credentials are stored in an encrypted Hive box; password hashes use PBKDF2.
- Appointments, customers, addresses, and provider profiles are stored in encrypted Hive boxes using a key held in the device’s secure storage.
- Anyone with unlocked access to your device or your Google account (if you use Drive backup) could potentially access corresponding data.

Uninstalling the app removes local app data from that device (subject to OS behavior). It does not delete copies already in your Google Drive.

## Analytics and ads

The app does not include analytics SDKs or advertising identifiers as part of this project.

## Contact

For questions about this policy, open an issue on the project’s GitHub repository.

## Hosting

This file can be published (e.g. GitHub Pages) for store listings. Adjust the repository URL in your Play Console or App Store privacy fields to match where you host this document.
