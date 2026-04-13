# Tasveer AI - Folder Structure

```text
.
├── README.md
├── PROJECT_STRUCTURE.md
├── pubspec.yaml
├── assets
│   └── fonts
└── lib
    ├── core
    │   ├── constants
    │   │   └── app_colors.dart
    │   ├── theme
    │   │   └── app_theme.dart
    │   └── utils
    │       └── local_storage_service.dart
    ├── features
    │   ├── export
    │   │   ├── data
    │   │   │   └── services
    │   │   │       └── pdf_generation_service.dart
    │   │   ├── domain
    │   │   │   ├── entities
    │   │   │   │   └── sheet_type.dart
    │   │   │   └── usecases
    │   │   │       └── generate_sheet_pdf_usecase.dart
    │   │   └── presentation
    │   │       └── screens
    │   │           └── export_screen.dart
    │   └── photo
    │       ├── data
    │       │   ├── repositories
    │       │   │   └── photo_repository_impl.dart
    │       │   └── services
    │       │       ├── background_removal_service.dart
    │       │       ├── face_detection_service.dart
    │       │       ├── image_compression_service.dart
    │       │       └── photo_processing_isolate.dart
    │       ├── domain
    │       │   ├── entities
    │       │   │   └── processed_photo.dart
    │       │   ├── repositories
    │       │   │   └── photo_repository.dart
    │       │   └── usecases
    │       │       └── process_photo_usecase.dart
    │       └── presentation
    │           ├── providers
    │           │   ├── photo_workflow_controller.dart
    │           │   └── photo_workflow_state.dart
    │           ├── screens
    │           │   ├── camera_capture_screen.dart
    │           │   ├── home_screen.dart
    │           │   ├── preview_screen.dart
    │           │   └── splash_screen.dart
    │           └── widgets
    │               └── camera_face_overlay.dart
    └── main.dart
```
