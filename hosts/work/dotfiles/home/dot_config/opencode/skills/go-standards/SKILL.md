---
name: go-standards
description: Go programming best practices including idiomatic patterns, error handling, concurrency, and project structure. Use when writing, reviewing, or refactoring Go code.
---

## What I do
- Enforce idiomatic Go patterns (gofmt, go vet)
- Guide error handling strategies
- Review concurrency patterns
- Suggest testing approaches
- Recommend project structure

## When to use me
Use this skill when:
- Writing new Go code
- Refactoring existing Go
- Code reviewing .go files
- Setting up Go modules
- Designing Go APIs

## Core Principles

### Code Style
- Always run `gofmt` before committing
- Use `go vet` to catch common mistakes
- Follow effective Go guidelines
- Keep lines under 120 characters when possible
- Use camelCase (exported) or camelCase (unexported)

### Error Handling
- Always check errors explicitly
- Return errors rather than logging
- Wrap errors with context using `fmt.Errorf` with `%w`
- Create sentinel errors for specific cases
- Don't panic in library code

```go
// Good: Proper error handling
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return fmt.Errorf("opening file %s: %w", path, err)
    }
    defer f.Close()
    
    // Process file...
    return nil
}

// Sentinel error
var ErrNotFound = errors.New("not found")

func findUser(id string) (*User, error) {
    // ...
    if user == nil {
        return nil, ErrNotFound
    }
    return user, nil
}
```

### Concurrency
- Use goroutines liberally
- Use channels for communication
- Prefer `context` for cancellation
- Use `sync.WaitGroup` for coordinating goroutines
- Protect shared state with `sync.Mutex` or channels

```go
// Good: Concurrent processing with proper synchronization
func processItems(items []Item) []Result {
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    
    results := make([]Result, len(items))
    var wg sync.WaitGroup
    
    for i, item := range items {
        wg.Add(1)
        go func(index int, it Item) {
            defer wg.Done()
            results[index] = process(ctx, it)
        }(i, item)
    }
    
    wg.Wait()
    return results
}
```

### Project Structure
```
project/
├── cmd/
│   └── app/
│       └── main.go          # Application entry point
├── pkg/
│   └── package/             # Public packages
│       └── package.go
├── internal/
│   └── private/             # Private packages
│       └── private.go
├── api/
│   └── proto/               # API definitions
├── configs/
│   └── config.yaml
├── go.mod
├── go.sum
└── README.md
```

### Interfaces
- Keep interfaces small (1-3 methods ideal)
- Define interfaces where they're used, not implemented
- Accept interfaces, return concrete types
- Use embedding for interface composition

```go
// Good: Small, focused interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type ReadWriter interface {
    Reader
    Writer
}
```

### Testing
- Use `testing` package for unit tests
- Name tests with `TestXxx` pattern
- Use table-driven tests
- Use `testify/assert` for cleaner assertions
- Mock dependencies with interfaces

```go
func TestCalculateTotal(t *testing.T) {
    tests := []struct {
        name     string
        items    []Item
        expected float64
    }{
        {
            name:     "empty cart",
            items:    []Item{},
            expected: 0,
        },
        {
            name:     "single item",
            items:    []Item{{Price: 10.00}},
            expected: 10.00,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := CalculateTotal(tt.items)
            if result != tt.expected {
                t.Errorf("got %v, want %v", result, tt.expected)
            }
        })
    }
}
```

### Modules
- Use semantic versioning for modules
- Keep module paths clean and meaningful
- Vendor dependencies for reproducible builds
- Use `go mod tidy` to clean up dependencies
- Pin to specific versions in production

### Documentation
- Document all exported functions, types, and packages
- Start with the function/type name
- Include usage examples for complex functions
- Use `godoc` to preview documentation

## Common Patterns

### Functional Options
```go
type ServerOption func(*Server)

func WithPort(port int) ServerOption {
    return func(s *Server) {
        s.port = port
    }
}

func NewServer(opts ...ServerOption) *Server {
    s := &Server{port: 8080}
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage
srv := NewServer(WithPort(9090))
```

## Anti-patterns to Avoid
- Don't use `interface{}` unnecessarily (use generics in Go 1.18+)
- Avoid `panic` in production code
- Don't ignore errors with `_`
- Avoid global state when possible
- Don't use reflection unnecessarily
- Avoid premature optimization
