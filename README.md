Daily

Daily is a cross-platform social media application built with Flutter, Firebase, and Python Cloud Functions. It enables users to create, edit, and share photo and video content, chat with friends, and interact through comments.

⚡ Features
Authentication: Phone number verification (intl_phone_number_input) and contact syncing.

Content Sharing: Upload photos and videos with automatic compression and thumbnail generation.

Media Editors: In-app image cropping/filters (image_editor_plus) and video trimming (video_editor, video_trimmer).

Social Engagement: Post creation made through the use of a server hosted on a rasberry pi and port forwarding.

Monetization: Integrated Google Mobile Ads and Firebase Analytics.

🛠️ Tech Stack
Frontend: Flutter / Dart

Backend: Firebase (Auth, Firestore, Storage, Realtime DB) & Python 3 (Cloud Functions)

Platforms: iOS, Android, Web, macOS, Windows, Linux

📁 Repository Structure
oskarmos1-contentrep/
├── lib/                      # Core Flutter source code
│   ├── App/                  # UI screens, posting, & media editing
│   ├── backend/              # Data models (User, Content, Message)
│   └── widget_classes/       # Reusable components
├── functions/                # Python Firebase Cloud Functions
├── assets/                   # App images & assets
└── android / ios / web       # Platform configurations
🚀 Quick Start
Prerequisites
Flutter SDK (>=3.22.0)

Firebase CLI

Installation & Run
Clone the repository:

Bash
git clone https://github.com/oskarmos1/oskarmos1-contentrep.git
cd oskarmos1-contentrep
Install dependencies:

Bash
flutter pub get
Run the app:

Bash
flutter run
