WIP: Work In Progress

# Querier

Querier is a dynamic dashboard builder and database management system built with Flutter and .NET Core. It allows users to create, customize and manage interactive dashboards with various types of cards (charts, tables, metrics, etc.) while providing a robust database connection management system.

## Features

- **Dynamic Dashboard Builder**
  - Drag and drop interface
  - Customizable layouts with rows and cards
  - Multiple card types (tables, charts, metrics)
  - Responsive design

- **User Management**
  - Role-based access control
  - User authentication
  - Profile management

- **Database Management**
  - Multiple database type support (MySQL, PostgreSQL, SQL Server)
  - Connection string management
  - Automatic API generation for stored procedures

- **Internationalization**
  - Multi-language support (English, French)
  - Translatable interface elements

## Tech Stack

### Frontend
- Flutter
- Bloc pattern for state management
- Provider for dependency injection
- Material Design

### Backend
- .NET Core 8.0
- Entity Framework Core
- JWT Authentication
- Swagger/OpenAPI
- SQLite (default database)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- .NET Core SDK 8.0
- IDE (VS Code, Android Studio, or Visual Studio)

### Installation

1. Clone the repository

bash
git clone https://github.com/yourusername/querier.git

2. Backend setup

bash
cd Querier.Api
dotnet restore
dotnet run

3. Frontend setup

bash
cd querier
flutter pub get
flutter run

## Project Structure

querier/
├── lib/
│ ├── api/ # API client and endpoints
│ ├── blocs/ # Global blocs
│ ├── models/ # Data models
│ ├── pages/ # Application screens
│ ├── providers/ # Provider classes
│ ├── widgets/ # Reusable widgets
│ └── main.dart # Application entry point
│
Querier.Api/
├── Controllers/ # API endpoints
├── Domain/ # Domain models and interfaces
├── Infrastructure/ # Implementation of domain interfaces
└── Application/ # Application services and DTOs


## Architecture

### Frontend
The Flutter application follows the BLoC (Business Logic Component) pattern:
- **Models**: Data classes representing the domain entities
- **BLoCs**: Handle business logic and state management
- **Widgets**: Reusable UI components
- **Pages**: Application screens composed of widgets
- **Providers**: Handle dependency injection and global state

### Backend
The .NET Core application follows Clean Architecture principles:
- **Domain Layer**: Contains business entities and interfaces
- **Application Layer**: Contains business logic and service interfaces
- **Infrastructure Layer**: Implements interfaces defined in the domain layer
- **API Layer**: Handles HTTP requests and responses

## Development

### Adding a New Card Type
1. Define the card type in `lib/models/card_type.dart`
2. Create a new widget in `lib/widgets/cards/`
3. Add configuration options in `lib/widgets/cards/common_card_config_form.dart`
4. Update the card factory in `lib/widgets/cards/dynamic_card_widget.dart`

### Adding a New Language
1. Add new translations in `lib/l10n/app_*.arb`
2. Update supported locales in `lib/main.dart`
3. Regenerate localizations using `flutter gen-l10n`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- .NET team for the robust backend framework
- All contributors who have helped shape this project