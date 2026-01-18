# Contributing to AWS SecurityAgent Demo

Thank you for your interest in contributing to this project! This repository is designed to demonstrate AWS Security Agent capabilities through intentional security vulnerabilities.

## Purpose

This project is an educational demonstration of:
- AWS security best practices (by violating them intentionally)
- Infrastructure security assessment
- Security agent capabilities
- Enterprise-scale vulnerability detection

## How to Contribute

### Reporting Issues

If you find issues with the documentation, deployment scripts, or have suggestions for additional security vulnerabilities to demonstrate:

1. Check existing issues to avoid duplicates
2. Open a new issue with a clear description
3. Include relevant context (AWS region, Terraform version, etc.)

### Suggesting Enhancements

We welcome suggestions for:
- Additional security vulnerabilities to demonstrate
- Improved documentation
- Better deployment automation
- Enhanced testing scenarios
- Blog content improvements

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-vulnerability`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear messages (`git commit -m 'Add: New IAM vulnerability scenario'`)
6. Push to your branch (`git push origin feature/amazing-vulnerability`)
7. Open a Pull Request

### Coding Standards

**Terraform:**
- Follow the modular structure in `infrastructure/`
- Add comments explaining intentional vulnerabilities
- Use consistent naming conventions
- Update relevant documentation

**Python (Lambda functions):**
- Python 3.11 compatibility
- Keep functions simple and focused
- Include intentional security issues with comments
- Follow existing code style

**Documentation:**
- Clear, concise writing
- Include code examples where relevant
- Reference official AWS documentation
- Update README.md if adding major features

## What NOT to Contribute

- Security fixes (this project is intentionally vulnerable)
- Production-ready code (defeats the purpose)
- Removal of vulnerabilities without replacement
- Unintentional bugs (report these as issues instead)

## Adding New Vulnerabilities

When adding new security vulnerabilities:

1. Document the vulnerability clearly in code comments
2. Reference relevant AWS security best practices being violated
3. Update `SECURITY_REQUIREMENTS.md` if needed
4. Update `CURRENT_IMPLEMENTATION.md` with the new issue
5. Add to the README.md vulnerability count and categories

## Testing

Before submitting:

1. Run `terraform validate` to check syntax
2. Test deployment in a clean AWS account
3. Verify all endpoints work as expected
4. Ensure documentation is updated
5. Test cleanup with `terraform destroy`

## Code of Conduct

- Be respectful and professional
- Focus on educational value
- Provide constructive feedback
- Help others learn about security

## Questions?

Open an issue with the `question` label, and we'll be happy to help!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Remember**: This project is for educational purposes only. Never deploy intentionally vulnerable infrastructure in production environments.
