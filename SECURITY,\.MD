# Security Policy

## 🔒 Supported Versions

We release patches for security vulnerabilities only in the latest branch of **QUATUMNOS — Creation-Triad**. Older branches may not be maintained.

| Version    | Supported       |
| ---------- | --------------- |
| `main`     | ✅ Full support  |
| < others > | ❌ Not supported |

---

## 🛡 Reporting a Vulnerability

If you discover a security vulnerability in this project:

1. **Do not open a public issue.**
2. Instead, please email the maintainer at:

   * 📧 **[security@quantumnos.dev](mailto:security@quantumnos.dev)** *(placeholder — update with your actual contact)*
3. Provide as much detail as possible:

   * Steps to reproduce
   * Affected components
   * Potential impact
   * Suggested mitigation (if any)

We aim to respond within **7 business days** and provide a fix or mitigation timeline.

---

## ⚠️ Security Best Practices for Users

* **Never commit credentials** (API keys, tokens) into the repository.
* Use `.env` files or environment variables for sensitive configuration.
* Keep dependencies updated (`pip install -U -r requirements.txt`).
* Prefer running experiments inside **virtual environments** or **containers**.
* Validate external contributions before integrating into production environments.

---

## 🔐 Responsible Disclosure

We appreciate responsible disclosure of security issues. By following this policy, you help keep the ecosystem safe and stable.

---

## 📜 License & Legal

This repository is licensed under **Business Source License (BSL-1.0)**. Security researchers are welcome to audit and report vulnerabilities, provided disclosures follow the guidelines above.

---

*Last updated: September 2025*
