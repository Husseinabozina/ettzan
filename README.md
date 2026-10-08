<p align="center">
  <img src="docs/showcase/assets/readme-cover.jpg" alt="Etzan — خطوات صغيرة، حياة أكثر اتزانًا" width="100%">
</p>

<h1 align="center">Etzan · اتزان</h1>

<p align="center">
  <strong>Personal growth, one step at a time.</strong><br>
  An Arabic-first Flutter app for coaching discovery, goals, habits, and daily reflection.
</p>

<p align="center">
  <a href="https://husseinabozina.github.io/ettzan/"><strong>Explore the showcase ↗</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/Husseinabozina/ettzan/releases/download/v1.1.0-showcase/etzan-1.1.0-showcase.apk"><strong>Download Android APK ↓</strong></a>
  &nbsp;·&nbsp;
  <a href="#screenshots">Screenshots</a>
  &nbsp;·&nbsp;
  <a href="#under-the-hood">Under the hood</a>
</p>

---

## Meet Etzan

Etzan brings the everyday parts of personal development into one mobile experience: discover coaches, organize goals and habits, plan your day, and reflect on your progress.

The experience is designed **Arabic-first**, with English localization, right-to-left and left-to-right layouts, and a visual system built to feel clear and calm.

<div dir="rtl">
<strong>اتزان</strong> تطبيق يساعدك ترتّب خطواتك في تطوير ذاتك: استكشف المدربين والمحتوى، حدّد أهدافك، تابع عاداتك وخطتك اليومية، ودوّن أفكارك وتقدّمك — في تجربة عربية بسيطة ومترابطة.
</div>

## Screenshots

Actual Etzan screens captured on an **iPhone 16e Simulator**, presented in branded frames. Select any image to view its original, full-size screenshot.

<table>
  <tr>
    <td align="center" width="25%"><a href="docs/showcase/assets/screens/splash.png"><img src="docs/showcase/assets/posters/01-splash.jpg" width="195" alt="Etzan splash screen"></a><br><strong>Splash</strong><br>البداية</td>
    <td align="center" width="25%"><a href="docs/showcase/assets/screens/onboarding.png"><img src="docs/showcase/assets/posters/02-onboarding.jpg" width="195" alt="Etzan onboarding screen"></a><br><strong>Onboarding</strong><br>التهيئة</td>
    <td align="center" width="25%"><a href="docs/showcase/assets/screens/signup.png"><img src="docs/showcase/assets/posters/03-signup.jpg" width="195" alt="Etzan create account screen"></a><br><strong>Create account</strong><br>إنشاء حساب</td>
    <td align="center" width="25%"><a href="docs/showcase/assets/screens/guest-home.png"><img src="docs/showcase/assets/posters/04-guest-home.jpg" width="195" alt="Etzan guest home screen"></a><br><strong>Guest home</strong><br>الرئيسية كضيف</td>
  </tr>
  <tr>
    <td align="center"><a href="docs/showcase/assets/screens/coaches.png"><img src="docs/showcase/assets/posters/05-coaches.jpg" width="195" alt="Etzan coach discovery screen"></a><br><strong>Discover coaches</strong><br>المدربون</td>
    <td align="center"><a href="docs/showcase/assets/screens/profile.png"><img src="docs/showcase/assets/posters/06-profile.jpg" width="195" alt="Etzan profile screen"></a><br><strong>Profile</strong><br>الملف الشخصي</td>
    <td align="center"><a href="docs/showcase/assets/screens/goals.png"><img src="docs/showcase/assets/posters/07-goals.jpg" width="195" alt="Etzan goals screen"></a><br><strong>Goals</strong><br>الأهداف</td>
    <td align="center"><a href="docs/showcase/assets/screens/dashboard.png"><img src="docs/showcase/assets/posters/08-dashboard.jpg" width="195" alt="Etzan signed-in dashboard screen"></a><br><strong>Dashboard</strong><br>لوحة المتابعة</td>
  </tr>
</table>

<p align="center">
  <a href="https://husseinabozina.github.io/ettzan/"><strong>View the complete interactive showcase →</strong></a>
</p>

## The experience

| Explore | Grow | Reflect |
| :--- | :--- | :--- |
| Onboarding and guest browsing | Goals, milestones, and habits | Journaling and mood selection |
| Coach search and profiles | Daily plan and calendar | Personal dashboard and progress views |
| Booking, session, and chat interfaces | Completed goals and achievements | Profile, notifications, and resources |

The mobile app includes authentication and account-based flows. Some experiences depend on the configured Supabase backend, so the presence of a screen does not imply an independently deployed service.

## Under the hood

Etzan is a **Flutter / Dart** project with an emphasis on reusable UI, clear feature boundaries, and localization.

| Area | Implementation |
| :--- | :--- |
| **State management** | Flutter Bloc / Cubit and Equatable |
| **Dependency injection** | GetIt |
| **Backend integration** | Supabase Auth, database, Storage, and realtime integration code |
| **Localization** | Easy Localization, Arabic / English, RTL / LTR |
| **Visual system** | Shared components, themes, spacing and typography tokens |
| **Adaptive layouts** | Responsive grids, constrained content widths, adaptive navigation |
| **Testing** | Mapper, widget, and smoke-test sources in `test/` |

### Architecture

The codebase groups features under `lib/features/` and shared concerns under `lib/core/`. Auth, Dashboard, and Notifications contain layered presentation, domain, and data code; shared backend access supports other journeys.

```text
lib/
├── app/                 App bootstrap and routing
├── core/                Design system, DI, navigation, localization, data
└── features/            Auth, dashboard, coaching, growth,
                        journal, notifications, account

docs/showcase/           Static portfolio website
supabase/                Backend notes and supporting SQL
test/                    Automated test sources
```

Read more: [Architecture](docs/ARCHITECTURE.md) · [Design system](docs/DESIGN_SYSTEM.md) · [API contracts](docs/API_CONTRACTS.md)

## Try Etzan on Android

**[Download Etzan v1.1.0 (APK) ↓](https://github.com/Husseinabozina/ettzan/releases/download/v1.1.0-showcase/etzan-1.1.0-showcase.apk)** &nbsp;·&nbsp; [Release notes and checksum](https://github.com/Husseinabozina/ettzan/releases/tag/v1.1.0-showcase)

- **Android 7.0+** · version **1.1.0 (build 2)** · approximately **64.8 MB**.
- This is a **portfolio preview build**, not a Play Store release. It is release-mode but **signed with a debug certificate**; do not treat it as a production-signed package.
- Android may ask you to allow installation from your browser or file manager. Features connected to the backend require an internet connection and an available service.

The website linked above is a **project showcase**, not a browser version of the Flutter app. iOS source is included in the repository, but no iOS installation download is provided here.

## Run locally

You'll need a compatible Flutter SDK, Android emulator / device or an iOS development environment. The project specifies **Dart >=3.6.0 <4.0.0** (Flutter 3.38.5 / Dart 3.10.4 were used during local preparation).

```bash
git clone https://github.com/Husseinabozina/ettzan.git
cd ettzan
flutter pub get
flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Replace the placeholders with credentials for your own **Supabase project**. OAuth and deep links may also require `SUPABASE_AUTH_REDIRECT_URL`. The [environment settings](lib/core/config/app_environment.dart) contain client-side defaults, but a separate deployment needs its own backend configuration.

Account-based flows expect specific tables, RPCs, storage buckets, and access policies. The SQL in this repository is supporting material, **not a complete one-command database setup**. See [backend setup](supabase/README.md).

Run the test suite with:

```bash
flutter test
```

> Never embed a Supabase service-role or other server-side secret in a mobile app.

## Project status

Etzan is a **personal-development / life-coaching portfolio project**, not a clinical treatment product. Coaching, account, and subscription interfaces are represented in the codebase; some flows depend on configured backend services, and **payment-provider integration is not implemented**. Screenshots reflect the UI at capture time rather than guaranteed live data or performance results.

## More documentation

[Localization and project structure (Arabic)](docs/LOCALIZATION_AND_STRUCTURE_AR.md) · [Backend notes](supabase/README.md) · [Screenshot and asset provenance](docs/showcase/assets/PROVENANCE.md)

<details>
<summary><strong>Showcase website — local preview and asset exports</strong></summary>

The public [showcase website](https://husseinabozina.github.io/ettzan/) is a static site stored in `docs/showcase/`, separate from the Flutter app.

To preview the website **on your own computer**, run this command from the repository root:

```bash
python3 -m http.server 4174 --directory docs/showcase
```

Then open `http://localhost:4174` on that computer. This is a **local-only address**, not the public demo URL.

After updating the source screenshots, macOS developers can regenerate the branded poster images and README cover with the optional Swift/AppKit script:

```bash
swift tools/generate-showcase.swift
```

Neither command is required to run the Flutter application. The [GitHub Pages workflow](.github/workflows/showcase-pages.yml) publishes `docs/showcase/` when that directory changes on `main`.

</details>

---

<p align="center">
  Designed and developed by <a href="https://github.com/Husseinabozina"><strong>Hussein Abozina</strong></a><br>
  <a href="https://husseinabozina.github.io/ettzan/">Explore Etzan</a> · <a href="https://github.com/Husseinabozina/ettzan">Source code</a>
</p>
