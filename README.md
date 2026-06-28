# AEM Energy Solution

Flutter implementation of the AEM Energy mobile technical assessment. The app reproduces the provided login, dashboard, info, and settings flows while integrating with the supplied authentication and dashboard APIs.

## Features

- Login with API-backed authentication
- Secure bearer-token persistence
- Dashboard with bar and donut charts
- Employee directory with search
- Settings screen with notification and dark mode toggles
- Logout flow that clears the stored token

## Tech Stack

- Flutter
- `flutter_bloc` for state management
- `http` for networking, chosen to keep the API layer lightweight for the small number of endpoints used in this assessment
- `shared_preferences` for non-sensitive local preferences
- `flutter_secure_storage` for secure token storage

## Setup

1. Install Flutter for your platform.
2. From the project root, install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

No additional environment variables or local configuration files are required. The app connects directly to the provided assessment API.

## Test Credentials

- Email: `user@aemenersol.com`
- Password: `Test@123`

## API Notes

- Base URL: `http://test-demo.aemenersol.com/api`
- Login endpoint: `POST /account/login`
- Dashboard endpoint: `GET /dashboard`
- The dashboard request uses `Authorization: Bearer <token>`
- Authentication and dashboard data are API-backed
- Profile editing, notification preferences, dark mode preferences, and employee-detail content are local/UI-only for this assessment

## Architecture

The codebase is organized by feature and uses a lightweight layered approach:

- `core/`
  - shared infrastructure such as theme, storage, constants, networking, and reusable widgets
- `features/auth/`
  - login UI, auth bloc, and authentication repository
- `features/dashboard/`
  - dashboard models, repository, bloc, charts, home screen, and shell navigation host
- `features/info/`
  - employee directory UI, employee model, and search cubit
- `features/settings/`
  - settings screen and preference cubit
- `features/navigation/`
  - bottom-tab index state

App bootstrap is intentionally kept explicit:

- `main.dart` initializes shared preferences, secure storage usage, API client, and repositories before calling `runApp`
- `app.dart` provides dependency injection, restores auth state, applies theme mode, and switches between the login flow and authenticated shell

### State Management

- `AuthBloc` controls bootstrapping, login, and logout state.
- `DashboardBloc` fetches and exposes chart and employee data.
- `NavigationCubit` drives bottom tab changes.
- `InfoCubit` manages employee search text.
- `SettingsCubit` manages notification and dark mode preferences.

### Data Flow

1. The app starts and restores preferences plus any saved secure token.
2. `AuthBloc` determines whether to show the login screen or the main shell.
3. After login, the bearer token is stored securely and used to fetch dashboard data.
4. Dashboard API data feeds:
   - bar chart
   - donut chart
   - employee directory list
5. Settings changes are persisted locally.

## Project Notes

- Notification and dark mode toggles are local-only, as requested.
- Profile editing is UI-only.
- Employee avatars and role/department labels are intentionally hardcoded to match the assessment brief.

## Verification

Useful local commands:

```bash
dart analyze
flutter test
flutter run
```

`dart analyze` and `flutter test` were used as the main local verification steps, while `flutter run` was used to verify the final UI and interaction flow manually.
