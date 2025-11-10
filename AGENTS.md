# Repository Guidelines

## Project Structure & Module Organization
Code for the SwiftUI entry point sits in `App/Meteo_IndicatorApp.swift`, while feature logic lives under `Features/Weather` split into `Models`, `ViewModels`, and `Views`. Cross-cutting utilities (design system tokens, DTOs, location services, networking, persistence helpers) are kept in `Core/*`—mirror this layout when adding new modules. Shared assets, colors, and configuration plists reside in `Ressources/Assets`. Place all new verification code in `Tests/`, using the `Meteo-IndicatorTests` target for unit coverage and `Meteo-IndicatorUITests` for UI flows.

## Build, Test, and Development Commands
Open the workspace in Xcode 14+ for day-to-day development:
```bash
open Meteo-Indicator.xcodeproj
```
Run a CI-equivalent build locally with the app scheme:
```bash
xcodebuild -scheme Meteo-Indicator -configuration Debug build
```
Execute the full test suite before publishing a branch:
```bash
xcodebuild test -scheme Meteo-Indicator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Coding Style & Naming Conventions
Follow Swift API Design Guidelines: 4-space indentation, `UpperCamelCase` for types and enums, `lowerCamelCase` for functions, properties, and bindings. Default to `struct` + `final class` for reference types, and keep extensions scoped by protocol or feature. View models should end with `ViewModel`, and assets should mirror their usage names (e.g., `WeatherBackground`). Run Xcode’s “Re-indent” and organize imports before committing; add SwiftLint warnings as inline `// swiftlint:disable` comments only when justified.

## Testing Guidelines
Unit tests rely on the Swift `Testing` module—author new cases with `@Test` functions named `test_<Scenario>_When_<Condition>`. UI automation remains in XCTest and should launch `XCUIApplication()` with clear assertions. Target boundary conditions for networking and localization, and keep mocks under `Tests/Shared` if many suites need them. Aim for meaningful coverage of `Core/` services and critical view models before merging.

## Commit & Pull Request Guidelines
Existing history follows Conventional Commits (`feat:`, `fix:`, `chore:`); continue with imperative mood summaries and concise scopes. Each PR should describe the change, list validation commands, and tag related issues. Include screenshots or screen recordings for UI tweaks, and mention configuration impacts (e.g., new keys in `Config.plist`). Request review from a domain owner when touching shared `Core` utilities.

## Configuration & Secrets
API keys belong in `Ressources/Assets/Config.plist`; do not hard-code secrets. Update `Info.plist` capabilities (location usage strings) alongside features that rely on them, and document simulator setup steps in the PR if new permissions are required.
