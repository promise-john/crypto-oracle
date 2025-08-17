# Contributing to CryptoOracle

Thank you for your interest in contributing to CryptoOracle! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use issue templates** when available
3. **Provide detailed information** including:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Clarinet version, etc.)
   - Relevant code snippets or logs

### Suggesting Features

1. **Check the roadmap** and existing feature requests
2. **Open a discussion** before implementing large features
3. **Provide detailed specifications** including:
   - Use case description
   - Proposed implementation approach
   - Potential impact on existing functionality

## 🔧 Development Setup

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v16+
- [Git](https://git-scm.com/)

### Local Setup

1. **Fork and clone the repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/crypto-oracle.git
   cd crypto-oracle
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify setup**

   ```bash
   clarinet check
   npm test
   ```

## 📋 Development Guidelines

### Code Style

#### Clarity Contracts

- Use descriptive variable and function names
- Include comprehensive comments for complex logic
- Follow consistent indentation (2 spaces)
- Group related functions together
- Use meaningful error codes and messages

Example:

```clarity
;; GOOD: Descriptive function with clear purpose
(define-public (create-prediction-market 
    (bitcoin-start-price uint)
    (market-duration-blocks uint)
  )
  ;; Validate input parameters
  (asserts! (> bitcoin-start-price u0) ERR-INVALID-PRICE)
  (asserts! (> market-duration-blocks u0) ERR-INVALID-DURATION)
  
  ;; Implementation...
)

;; AVOID: Unclear naming and purpose
(define-public (create (p uint) (d uint))
  ;; Implementation without validation...
)
```

#### TypeScript Tests

- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Test both success and failure scenarios
- Use meaningful variable names

Example:

```typescript
// GOOD: Clear test structure and naming
describe("Market Creation", () => {
  test("should create market with valid parameters", () => {
    // Arrange
    const startPrice = 50000_000000; // $50,000 in micro-units
    const durationBlocks = 1000;
    
    // Act
    const result = createMarket(startPrice, durationBlocks);
    
    // Assert
    expect(result).toBeOk();
    expect(result.value).toBeUint(0); // First market ID
  });
});
```

### Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `test`: Test additions or modifications
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

#### Examples

```bash
feat(oracle): add price validation mechanism
fix(rewards): correct proportional payout calculation
docs(readme): update installation instructions
test(markets): add edge case testing for market closure
```

## 🧪 Testing Requirements

### Contract Testing

All smart contract changes must include comprehensive tests:

1. **Unit tests** for individual functions
2. **Integration tests** for function interactions
3. **Edge case testing** for boundary conditions
4. **Error handling tests** for all error paths

### Test Coverage

- Aim for >90% code coverage
- Test both success and failure scenarios
- Include gas cost analysis for major functions
- Validate state changes and side effects

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch

# Run specific test file
npx vitest tests/crypto-oracle.test.ts
```

## 📝 Documentation Standards

### Code Documentation

- **Function documentation**: Include purpose, parameters, return values, and error conditions
- **Complex logic**: Add inline comments explaining the reasoning
- **Constants**: Document the purpose and impact of configuration values

### README Updates

- Update relevant sections when adding features
- Include usage examples for new functionality
- Update API documentation for interface changes

## 🔍 Review Process

### Pull Request Guidelines

1. **Create focused PRs** addressing single concerns
2. **Provide clear descriptions** explaining changes and rationale
3. **Include relevant tests** for all changes
4. **Update documentation** as needed
5. **Ensure CI passes** before requesting review

### PR Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Added/updated unit tests
- [ ] Added/updated integration tests
- [ ] Verified gas cost implications
- [ ] Tested on local devnet

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Criteria

Reviewers will evaluate:

1. **Correctness**: Does the code work as intended?
2. **Security**: Are there potential vulnerabilities?
3. **Performance**: Are there gas optimization opportunities?
4. **Maintainability**: Is the code clear and well-structured?
5. **Testing**: Is test coverage adequate?

## 🚀 Release Process

### Version Management

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality additions
- **PATCH**: Backwards-compatible bug fixes

### Release Checklist

1. Update version numbers
2. Update CHANGELOG.md
3. Create release branch
4. Run full test suite
5. Deploy to testnet for verification
6. Create GitHub release with detailed notes

## 🛡️ Security Considerations

### Security Best Practices

1. **Input validation**: Always validate function parameters
2. **Access controls**: Verify caller permissions
3. **State management**: Prevent invalid state transitions
4. **Reentrancy protection**: Use proper guards where needed
5. **Integer overflow**: Use safe arithmetic operations

### Reporting Security Issues

Please report security vulnerabilities privately to:

- Email: [security@crypto-oracle.com](mailto:security@crypto-oracle.com)
- GitHub Security Advisory

Do not open public issues for security vulnerabilities.

## 📞 Getting Help

### Resources

- [Clarity Documentation](https://docs.stacks.co/clarity/)
- [Clarinet Guide](https://docs.hiro.so/clarinet/)
- [Stacks Community Discord](https://discord.gg/stacks)

### Contact

- **GitHub Discussions**: For general questions and ideas
- **GitHub Issues**: For bug reports and feature requests
- **Discord**: For real-time community support

## 🎉 Recognition

Contributors are recognized in:

- CONTRIBUTORS.md file
- Release notes for significant contributions
- Special recognition for security improvements

Thank you for contributing to CryptoOracle! 🚀
