# Changelog
## [2.2.0] - 2025-06-09

### Added
- **New `add-usecase` command** - Add individual use cases to existing features without recreating the entire structure
- Automatic updates to repository interfaces, implementations, and data sources when adding new use cases
- Enhanced CLI with `--feature` and `--usecase` flags for the new command
- Comprehensive documentation and examples for the new functionality

### Features
- `feature_generator add-usecase --feature=auth --usecase=resetPassword` - Add new use cases to existing features
- Automatic file updates maintain clean architecture structure
- Validates existing feature structure before adding new use cases
- Generates complete use case files with proper imports and exports

## [2.1.0] - 2025-05-15
- Added automatic PATH configuration post-install
- Support for Bash/Zsh/Fish shells

## [2.0.1] - 2025-05-15

### Fixed
- Added missing `utils` directory creation during installation
- Fixed service locator file generation path error
- Improved core folder structure initialization reliability

### Changed
- Core folder structure now includes:



## [2.0.0] - 2025-05-14

### Breaking Changes
- **Core folders** are no longer created during feature generation
- Removed `--install-deps` flag from `create` command

### Added
- New `install` command for dependency setup
- Automatic creation of `lib/core/service_locator.dart`
- Added `get_it` and `injectable` as dependencies

### Changed
- Core folders (`errors/`, `use_cases/`) now only created via `install` command
- Separated dependency installation from feature creation
- Improved service locator setup

## [1.0.6] - 2025-05-12

- Make a core files created only at fist time with installing dependencies
- Modify readme.md 
