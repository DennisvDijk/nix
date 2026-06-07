---
name: python-best-practices
description: Comprehensive Python development standards including code style, type hints, testing patterns, and project structure. Use when writing, reviewing, or refactoring Python code to ensure best practices, type safety, and maintainability.
---

## What I do
- Enforce PEP 8 style guidelines and modern Python patterns
- Guide type hint usage and mypy compliance
- Review testing strategies (pytest, unittest)
- Suggest project structure improvements
- Recommend modern Python features (3.10+)

## When to use me
Use this skill when:
- Writing new Python code
- Refactoring existing Python
- Code reviewing Python files
- Setting up Python projects
- Debugging Python issues

## Core Principles

### Code Style
- Follow PEP 8 naming conventions
- Use 4 spaces for indentation
- Maximum line length: 88-100 characters (Black compatible)
- Use explicit imports (avoid `from module import *`)

### Type Hints
- Add type hints to all function signatures
- Use `typing` module for complex types
- Prefer built-in generics (list[str] vs List[str]) in Python 3.9+
- Use `Optional` and `Union` appropriately
- Consider `Protocol` for structural typing

### Testing
- Use pytest as the default test runner
- Follow AAA pattern: Arrange, Act, Assert
- Use fixtures for setup/teardown
- Aim for high coverage on critical paths
- Use parametrize for multiple test cases

### Project Structure
```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── modules.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_*.py
├── pyproject.toml
└── README.md
```

## Modern Python Features (3.10+)
- Use match/case for pattern matching
- Prefer `|` for Union types (str | None vs Optional[str])
- Use `typing.Self` for method returns
- Leverage structural pattern matching
- Use `tomllib` for TOML parsing (3.11+)

## Anti-patterns to Avoid
- Don't use mutable default arguments
- Avoid bare except clauses
- Don't use wildcard imports
- Avoid mixing sync and async code carelessly
- Don't ignore type checker warnings
