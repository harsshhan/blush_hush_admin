# Blush Hush Admin

Blush Hush Admin is a comprehensive administrative dashboard designed to streamline collaboration between clients and project managers. This application empowers administrators to oversee every aspect of project management — from client onboarding to daily status updates — ensuring transparency and efficiency throughout the project lifecycle.

## 🚀 Project Overview

The core objective of **Blush Hush Admin** is to bridge the gap between clients and project managers by providing a centralized platform for communication, project tracking, and management oversight. Administrators can create projects, assign managers, monitor progress, and ensure that clients are kept up to date with daily status reports. This fosters trust, accountability, and smooth project delivery.

## ✨ Key Features

- **Client Management:** Add, edit, and manage client profiles and access.  
- **Project Management:** Create new projects, assign managers, and set deadlines.  
- **Manager Assignment:** Efficiently allocate managers to projects based on expertise and availability.  
- **Daily Status Updates:** Managers upload daily progress reports, instantly visible to clients and admins.  
- **Comprehensive Dashboard:** Admins have a bird’s-eye view of all ongoing projects, client interactions, and manager activities.  
- **Notifications:** Automated notifications keep all stakeholders informed about milestones and updates.  
- **Role-Based Access:** Separate applications for Admin, Manager, and Client ensure tailored experiences and security.  

## 🗂️ File Architecture
```
blush_hush_admin/
├── lib/                          # Core application code
├── assets/                       # Images, icons, and static assets
├── test/                         # Unit and widget tests
├── android/                      # Android-specific configuration
├── ios/                          # iOS-specific configuration
├── web/                          # Web-specific configuration
├── windows/                      # Windows-specific configuration
├── linux/                        # Linux-specific configuration
├── macos/                        # macOS-specific configuration
├── constants/
│   ├── styles.dart              # App-wide styles and themes
│   ├── helper/                  # Helper utilities
│   ├── pdf_download.dart        # PDF generation utilities
│   └── pdf_screen.dart          # PDF viewing functionality
├── models/                       # Data models (User, Project, Manager, etc.)
├── provider/                     # State management
│   ├── client_provider.dart
│   ├── manager_provider.dart
│   ├── nav_provider.dart
│   └── project_provider.dart
├── screens/                      # UI screens
│   ├── client/
│   │   ├── add_client_dialog.dart
│   │   └── client_screen.dart
│   └── project_screens/
│       ├── add_project_screen.dart
│       ├── project_detail_screen.dart
│       └── project_screen.dart
├── services/                     # Business logic and API integrations
│   ├── auth_services.dart
│   ├── client_service.dart
│   ├── function_service.dart
│   ├── manager_service.dart
│   └── project_service.dart
├── widgets/                      # Reusable UI components
│   ├── add_manager_widget.dart
│   ├── client_search_dialog.dart
│   ├── dashboard_widget.dart
│   ├── image_viewer_page.dart
│   ├── input_container.dart
│   ├── loading_dialog.dart
│   ├── name_card_widget.dart
│   ├── project_updates_timeline.dart
│   ├── recent_activity_list.dart
│   ├── search_bar_widget.dart
│   └── firebase_options.dart
├── home_scaffold.dart           # Main scaffold/navigation
├── home.dart                    # Home screen
├── login_screen.dart            # Authentication screen
├── splash_screen.dart           # App splash screen
├── main.dart                    # Entry point
├── .firebaserc                  # Firebase configuration
├── .gitignore
├── .metadata
└── README.md                    # Project documentation
```



## Development Status

Blush Hush Admin is nearing completion, with only minor enhancements and refinements remaining before public release. In addition to the admin app, dedicated applications for managers and clients are also under active development, ensuring a seamless and role-specific experience for all users.

