# Security Policy

## Supported Versions

Only the latest stable release of CLUTCH RUN receives security patches.

| Version | Supported |
| :--- | :--- |
| 1.4.x (latest) | ✅ Yes |
| 1.3.x | ❌ No |
| < 1.3 | ❌ No |

---

## Reporting a Vulnerability

If you discover a security vulnerability in this project, **please do not open a public GitHub Issue**.  
Instead, report it privately by emailing the maintainer directly or using [GitHub's private security advisory](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability).

Please include in your report:
- A clear description of the vulnerability.
- Steps to reproduce the issue.
- Potential impact (data exposure, authentication bypass, etc.).
- Any suggested mitigations if known.

We aim to acknowledge all reports within **48 hours** and provide a fix or mitigation plan within **7 days** for critical issues.

---

## Security Best Practices for Deployment

Before deploying CLUTCH RUN to production, ensure:

1. **`DEBUG = False`** — Never run with debug mode enabled in production.
2. **Strong `SECRET_KEY`** — Generate a unique key using:
   ```bash
   python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```
3. **`ALLOWED_HOSTS`** — Restrict to your actual domain(s), not `['*']`.
4. **HTTPS only** — Serve the application exclusively over HTTPS.
5. **Headers** — The `SecurityHeadersMiddleware` in `runner/middleware.py` injects `X-Content-Type-Options`, `X-XSS-Protection`, `Referrer-Policy`, and `X-Frame-Options` automatically.
6. **Database** — For production, migrate from SQLite to PostgreSQL with a strong password and restricted network access.

---

## Known Security Considerations

- The `submit-score` endpoint is CSRF-exempt to allow cross-origin game clients. Ensure the endpoint is rate-limited at the infrastructure level (e.g., Nginx, Cloudflare) to prevent abuse.
- Player usernames are stored as-is (uppercased). The `is_valid_username` validator in `runner/utils.py` restricts inputs to alphanumeric characters and underscores, preventing SQL injection via the username field.
