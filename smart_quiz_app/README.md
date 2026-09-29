# Smart Quiz App (CLI)

Minor Project 01 — a command-line quiz application built with Dart.

## What the app does

Smart Quiz loads multiple-choice questions from a JSON file, lets a player
answer them in the terminal, calculates the final score, and stores each result
in a local score-history file. The menu also includes a short explanation of
the project for demonstration purposes.

## Project structure

```text
smart_quiz_app/
├── bin/
│   └── smart_quiz.dart          # Application entry point
├── data/
│   ├── questions.json           # Question bank loaded at runtime
│   └── score_history.json       # Saved quiz results
├── lib/
│   ├── smart_quiz.dart          # Public library exports
│   └── src/
│       ├── models/              # Quiz questions and result models
│       ├── repositories/        # JSON file reading and writing
│       ├── services/            # Quiz session and score logic
│       └── ui/                  # Interactive terminal menu
├── test/
│   └── quiz_test.dart           # Automated unit tests
└── pubspec.yaml
```

## How to run

From the `smart_quiz_app` folder:

```bash
dart pub get
dart run bin/smart_quiz.dart
```

To run the tests:

```bash
dart test
```

## Concepts demonstrated

- **Dart fundamentals:** variables, collections, functions, constructors, and
  null safety.
- **OOP:** `QuizItem` is an abstract contract, while
  `MultipleChoiceQuestion` provides a concrete implementation. Private fields
  demonstrate encapsulation, and the repository interfaces demonstrate
  abstraction and polymorphism.
- **Async/await:** question and score files are read and written through
  asynchronous `Future` methods.
- **File I/O:** the app reads `questions.json` and writes score history without
  needing a database.
- **JSON handling:** `jsonDecode` maps stored question data into objects, and
  `jsonEncode` stores results in a structured format.

## Adding your own questions

Add another object to `data/questions.json` using the same fields:

```json
{
  "id": "unique-id",
  "question": "Your question here?",
  "category": "Dart Basics",
  "difficulty": "Easy",
  "options": ["First option", "Second option"],
  "correctOption": 0
}
```

`correctOption` is zero-based: `0` means the first option, `1` means the
second option, and so on.