# SafeNet AI - AI-Powered Digital Safety Assistant

SafeNet AI is a production-quality Flutter application designed for a cyber-security hackathon. It functions as an AI-driven digital safety guardian, helping users identify online scams (phishing texts, fake jobs, payment frauds, website clones) and providing deep analysis explanations of why a particular input is suspicious rather than just labelling it.

---

## Technical Stack
- **Framework:** Flutter (latest stable, Material 3)
- **State Management & DI:** Riverpod (`flutter_riverpod`)
- **Routing & Navigation:** GoRouter (`go_router`)
- **Network Client:** Dio (`dio`)
- **Local Caching:** Hive (`hive`, `hive_flutter`)
- **QR Code Scanning:** Mobile Scanner (`mobile_scanner`)
- **OCR Pipeline:** Google ML Kit Text Recognition (`google_mlkit_text_recognition`)
- **PDF Generation:** PDF (`pdf`)
- **Charts:** FL Chart (`fl_chart`)
- **System Plugins:** `url_launcher`, `share_plus`, `permission_handler`, `connectivity_plus`, `flutter_secure_storage`

---

## Design System (Fidelity to Stitch AI)
SafeNet AI matches the exact visual theme and typography guidelines of the Stitch AI design templates:
- **Primary Color:** Deep Blue (`#1E3A8A`) for branding, text titles, and verification structures.
- **Secondary Color:** Cyan (`#06B6D4`) for glowing buttons, indicators, active status highlights, and progress bars.
- **System States:** Success Green (`#22C55E`), Warning Amber (`#F59E0B`), and Danger Red (`#EF4444`).
- **Typography:** Google Fonts Outfit (headings, scores) and Inter (body copy, descriptions).
- **Cards & Elements:** Rounded 18px borders (`BorderRadius.circular(18)`), soft gradients, and low-opacity drop shadows for a premium fintech feel.
- **Bottom Navigation Bar:** Custom floating row holding active tab highlight capsules (light cyan) and an oversized glowing circular button for the central Scan trigger.

---

## Architecture Layout
The project follows **Clean Architecture** conventions:
- **Core (`lib/core/`):** Global theme styling, routing configurations, utility tools (such as PDF generators), and shared database services.
- **Features (`lib/features/`):** Self-contained modular feature directories (Authentication, Dashboard, Scan, Analysis, Chat, History, Learn, Settings).
  - Each feature houses its own `models/` (Dara objects), `repositories/` (API data layers), `providers/` (state managers), `screens/` (views), and `widgets/` (reusable UI).

---

## Key Features & User Interface Flow

### 1. Authentication Screen
- Login options: Email Sign-In, Google Sign-In, Anonymous Guest Mode, and Password resets.
- Integrates a custom vector-drawn glowing Cyber Shield Brain logo matching branding templates.

### 2. Home Dashboard Screen
- User greeting and Safety Score dial (a custom concentric gauge drawing solid background tracks, dashed decoration borders, and animated progress arcs).
- Quick Action Grid containing 6 scanning entrypoints (Screenshots, Texts, Emails, Websites, QR Codes, Job Ads).
- Community scam warnings panel with border badges.
- Robot floating action button launching the conversational AI.

### 3. Scan & OCR Pipeline
- File uploads and image picking flows.
- OCR service utilizing ML Kit Text Recognition to extract text from screenshots. Includes a try-catch simulator fallback to extract scam scripts during emulator/simulator testing.
- An editor screen showing image previews and an editable text block to edit OCR text before sending it to the AI.
- website URL checker and website analysis inputs.

### 4. AI loading Screen
- Animated rotating dotted scanning radar.
- Step-by-step loading descriptions ("phishing checks...", "comparing blacklist databases...").
- Matrix grids displaying scan details (URL origin hostnames, redirect link counts, and real-time threat probability percentages).
- Outlined abort button to cancel scans.

### 5. Threat Result Dashboard
- Color-coded threat banner (red gradient card for high risk, green card for safe content).
- Scrolled recommended action cards ("Don't Click", "Don't Pay", "Block Sender").
- Expandable analysis insights tiles containing threat descriptions and severity levels.
- Scam DNA bar profiles displaying animated threat vectors (Urgency, Money Demand, Fear, Identity Theft, Brand Mimicry).
- Save Report button exporting a high-fidelity vector PDF.

### 6. AI chatbot Screen
- Conversational chat bubbles.
- AI typing loader.
- Prepopulated chip suggestions above the input bar.
- Keyword parsing to automatically highlight scam warning terms (scam, fraud, otp, phishing) in red bold text.
- Hive message history sync for offline session restoration.

### 7. Scans History
- Database storage for past threat scans.
- Search queries and status pill toggles (All, Safe, Suspicious, Dangerous).
- Toggles to star favorite alerts or wipe specific log entries.

### 8. School & Interactive Quiz
- Multi-category scam lessons (UPI tricks, deepfake synthesizers).
- Interactive card swiping quiz testing scam scenario safety.
- Awards digital badges ("Scam Buster Badge") for flawless quiz scores.

---

## Getting Started

### Prerequisites
Make sure you have Flutter installed and on your system path.
```bash
flutter --version
```

### Install Dependencies
Navigate to the root directory and run:
```bash
flutter pub get
```

### Run static code analyze
Verify code quality and compilation checks:
```bash
flutter analyze
```

### Execute Tests
Run widget smoke tests:
```bash
flutter test
```

### Launch Application
Build and run the project:
```bash
flutter run
```
