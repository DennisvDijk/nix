---
name: rust-standards
description: Rust programming best practices including ownership patterns, error handling, async programming, and cargo workspace management. Use when writing, reviewing, or refactoring Rust code.
---

## What I do
- Enforce idiomatic Rust patterns
- Guide ownership and borrowing strategies
- Review error handling approaches
- Suggest performance optimizations
- Recommend crate choices

## When to use me
Use this skill when:
- Writing new Rust code
- Refactoring existing Rust
- Code reviewing .rs files
- Setting up Cargo projects
- Debugging borrow checker issues

## Core Principles

### Ownership and Borrowing
- Prefer borrowing over cloning
- Use `&str` over `String` for function parameters
- Leverage lifetimes for zero-cost abstractions
- Use `Rc/Arc` for shared ownership when needed
- Understand `Copy` vs `Clone` traits

### Error Handling
- Use `Result` for fallible operations
- Create custom error types with `thiserror` or `anyhow`
- Avoid unwrap/expect in production code
- Use `?` operator for early returns
- Provide meaningful error messages

```rust
// Good: Proper error handling
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Configuration error: {0}")]
    Config(String),
}

pub fn read_config(path: &str) -> Result<Config, AppError> {
    let content = std::fs::read_to_string(path)?;
    parse_config(&content)
        .map_err(|e| AppError::Config(e.to_string()))
}
```

### Async Programming
- Use `tokio` as the async runtime
- Prefer `async/await` over raw futures
- Use channels for communication between tasks
- Understand `Send` and `Sync` bounds
- Avoid blocking operations in async context

### Code Organization
```
project/
├── Cargo.toml
├── src/
│   ├── main.rs      # Binary entry point
│   ├── lib.rs       # Library entry point
│   ├── error.rs     # Error types
│   ├── models/      # Data structures
│   └── utils/       # Helper functions
└── tests/           # Integration tests
```

### Cargo Best Practices
- Use workspaces for multi-crate projects
- Pin dependency versions with lock file
- Use `cargo clippy` for linting
- Use `cargo fmt` for formatting
- Keep dependencies minimal

### Testing
- Write unit tests in the same file
- Use `#[cfg(test)]` for test modules
- Write integration tests in tests/ directory
- Use `cargo test -- --nocapture` for output
- Mock external dependencies

### Documentation
- Document all public APIs with `///`
- Include examples in doc comments
- Run `cargo doc` to verify documentation
- Use `cargo test --doc` to test examples

### Performance
- Use `cargo bench` for benchmarking
- Profile before optimizing
- Understand zero-cost abstractions
- Use `&[T]` over `&Vec<T>` for slices
- Consider `Cow<str>` for flexibility

## Common Patterns

### Builder Pattern
```rust
pub struct ConfigBuilder {
    name: Option<String>,
    port: Option<u16>,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        Self {
            name: None,
            port: None,
        }
    }
    
    pub fn name(mut self, name: &str) -> Self {
        self.name = Some(name.to_string());
        self
    }
    
    pub fn build(self) -> Result<Config, String> {
        Ok(Config {
            name: self.name.ok_or("name is required")?,
            port: self.port.unwrap_or(8080),
        })
    }
}
```

## Anti-patterns to Avoid
- Don't use `unsafe` unnecessarily
- Avoid `unwrap()` and `expect()` in library code
- Don't clone in hot paths
- Avoid `String` when `&str` suffices
- Don't ignore warnings from clippy
