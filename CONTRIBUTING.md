# Contributing to CLUTCH RUN

Thank you for considering contributing to CLUTCH RUN! 🎮  
Below are the guidelines to ensure a smooth collaboration process.

---

## 🛠️ Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/fakerun.git
   cd fakerun
   ```
3. **Set up your environment**:
   ```bash
   cp .env.example .env
   # Fill in your local values in .env
   pip install -r requirements.txt
   python manage.py migrate
   python manage.py collectstatic --noinput
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feat/your-feature-name
   ```

---

## 📋 Code Standards

### Python / Django
- Follow [PEP 8](https://pep8.org/) style guidelines.
- All new API views must include a docstring describing purpose, expected input, and response format.
- Any new model fields or properties should include inline comments.
- Use `select_related` or `prefetch_related` to avoid N+1 query issues on queryset views.

### HTML / CSS / JavaScript
- Keep inline styles minimal — prefer TailwindCSS utility classes.
- Avoid committing debug `console.log` statements.
- Ensure all interactive elements have unique `id` attributes for testability.

---

## ✅ Running Tests

Run the full test suite before opening a Pull Request:
```bash
python manage.py test runner
```

All tests must pass. New features should include corresponding test coverage in `runner/tests.py`.

---

## 📝 Commit Messages

Use the [Conventional Commits](https://www.conventionalcommits.org/) format:

| Prefix | When to use |
| :--- | :--- |
| `feat:` | A new feature |
| `fix:` | A bug fix |
| `docs:` | Documentation changes only |
| `style:` | Cosmetic / formatting changes (no logic) |
| `refactor:` | Code restructuring without changing behavior |
| `test:` | Adding or updating tests |
| `chore:` | Build process, dependency, or config changes |

**Example:**
```
feat: add player stats API endpoint with best score and total runs
```

---

## 🔀 Pull Request Process

1. Ensure all tests pass (`python manage.py test runner`).
2. Update `CHANGELOG.md` under the `[Unreleased]` section with a brief description of your change.
3. Open a Pull Request against the `main` branch.
4. Fill in the PR template, explaining **what** you changed and **why**.
5. A maintainer will review your PR within 2–3 business days.

---

## 🐛 Reporting Bugs

Open a GitHub Issue and include:
- A clear, descriptive title.
- Steps to reproduce the bug.
- Expected vs. actual behavior.
- Browser/OS/Python version if applicable.

---

## 💬 Questions?

Feel free to open a [Discussion](https://github.com/arjun906130/fakerun/discussions) for any questions or ideas.  
We appreciate every contribution, no matter how small! 🚀
