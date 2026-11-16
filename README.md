# Pokémon TCG Companion App

A cross-platform mobile application built with **Flutter and Dart**, designed to support Pokémon Trading Card Game players, judges and tournament organisers.

The application brings together essential tools for competitive play, deck building, card research and tournament management in one convenient mobile companion.

## Features

### 🃏 Pokémon Card Database
- Search Pokémon, Trainer and Energy cards.
- Browse card information and artwork.
- View detailed card information.
- Powered by the [TCGdex API](https://tcgdex.dev/).

### 🧩 Deck Builder
- Build and manage Pokémon TCG decks.
- Search for cards and add them to your deck.
- Track Pokémon, Trainer and Energy card counts.
- Filter cards by category.
- Enforce the standard 60-card deck limit.
- Apply the four-copy rule, with exceptions for Basic Energy.
- Import decklists copied from Limitless and check card matches against TCGdex.

### ⚖️ Judge Desk
- Quick access to useful Pokémon TCG judging resources.
- Links to official Pokémon documentation and references.
- Designed to support judges during organised play.

### 🏆 Tournament Tools
- 50-minute tournament round timer.
- Virtual coin flip.
- Dice roller.
- Judge call notes.

## Technology Stack

- **Flutter** – Cross-platform mobile application framework.
- **Dart** – Application programming language.
- **TCGdex API** – Pokémon TCG card and set information.
- **HTTP** – API communication.
- **Material Design** – User interface components.

## Platforms

- Android
- iOS

## Project Status

**Currently in development.**

The application is being developed incrementally, with a focus on functionality, usability and reliability for competitive Pokémon TCG environments.

Planned improvements include:
- Enhanced deck management and validation.
- Improved Limitless decklist importing.
- Expanded tournament management tools.
- Additional judge resources and references.
- Further interface and usability improvements.

## Disclaimer

This is an independent fan-developed application and is not affiliated with, endorsed by, or sponsored by Nintendo, The Pokémon Company, Creatures Inc. or Game Freak.

Pokémon and Pokémon Trading Card Game are trademarks of their respective owners.

Card information is provided through the TCGdex API.

## Development

This project is built using Flutter.

To run locally:

```bash
flutter pub get
flutter run
```

For more information about Flutter development, visit [flutter.dev](https://flutter.dev/).
