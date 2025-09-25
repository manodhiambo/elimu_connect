# ElimuConnect - Educational Platform for Kenya

A comprehensive educational platform built with Flutter and Dart, designed specifically for Kenya's educational landscape.

## Project Structure

This is a monorepo managed by Melos containing multiple packages:

- **packages/app** - Flutter mobile/web/desktop application
- **packages/backend** - Dart backend API server
- **packages/shared** - Shared models and utilities
- **packages/web_admin** - Flutter web admin dashboard
- **packages/design_system** - UI components and theming

## Quick Start

1. Install Melos: `dart pub global activate melos`
2. Bootstrap the monorepo: `melos bootstrap`
3. Setup development environment: `melos run setup:dev`
4. Generate code: `melos run gen`
5. Run the app: `cd packages/app && flutter run`

## Development Commands

- `melos run analyze` - Run analysis on all packages
- `melos run test` - Run all tests
- `melos run build:app` - Build Flutter applications
- `melos run build:backend` - Build backend executable
- `melos run clean:deep` - Deep clean all packages

## Registration System

Users can register with different roles:
- **Admin**: Requires special code ``
- **Teacher**: TSC number and school credentials required
- **Student**: Admission number and school details required  
- **Parent**: National ID and children's admission numbers required

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) for development guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
