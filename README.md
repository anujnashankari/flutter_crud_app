# Flutter CRUD App

A full-stack CRUD (Create, Read, Update, Delete) module built with Flutter that allows users to manage tasks with both local storage and API integration.

## Features

- Create, read, update, and delete tasks
- Offline-first functionality with local SQLite database
- Sync with remote API when online
- Search and filter tasks
- Responsive UI for different screen sizes
- BLoC pattern for state management
- Clean architecture implementation

## Architecture

The application follows a clean architecture approach with three main layers:

### Data Layer
- Models: Data representations of entities
- Data Sources: Local (SQLite) and Remote (API) data sources
- Repositories: Implementation of domain repositories

### Domain Layer
- Entities: Core business objects
- Repositories: Abstract definitions of data operations
- Use Cases: Business logic operations

### Presentation Layer
- BLoCs: Business Logic Components for state management
- Screens: UI screens for user interaction
- Widgets: Reusable UI components

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Update the API base URL in `lib/core/di/service_locator.dart` to point to your backend
4. Run the app with `flutter run`

## API Endpoints

The application expects the following REST API endpoints:

- `GET /tasks` - Retrieve all tasks
- `GET /tasks/{id}` - Retrieve a specific task
- `POST /tasks` - Create a new task
- `PUT /tasks/{id}` - Update an existing task
- `DELETE /tasks/{id}` - Delete a task

## Local Storage

The application uses SQLite for local storage with the following schema:

\`\`\`sql
CREATE TABLE tasks(
  id TEXT PRIMARY KEY,
  title TEXT,
  description TEXT,
  status TEXT,
  priority TEXT,
  createdAt TEXT,
  updatedAt TEXT,
  syncStatus TEXT
)
\`\`\`

## Offline Sync

Tasks are stored locally first and then synced with the server when online:

- `syncStatus: 'synced'` - Task is in sync with the server
- `syncStatus: 'pending_create'` - Task needs to be created on the server
- `syncStatus: 'pending_update'` - Task needs to be updated on the server
- `syncStatus: 'pending_delete'` - Task needs to be deleted from the server

## Testing

Run tests with:

\`\`\`
flutter test
\`\`\`

## Dependencies

- flutter_bloc: State management
- sqflite: Local database
- dio: HTTP client
- get_it: Dependency injection
- dartz: Functional programming
- equatable: Value equality
- connectivity_plus: Network connectivity
- flutter_secure_storage: Secure storage
- uuid: Unique ID generation
- intl: Internationalization and formatting
