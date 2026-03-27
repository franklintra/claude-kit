# Deep security audit of the entire codebase

Perform a thorough security review of the repository, modeled on professional audit methodologies (OWASP, Trail of Bits, NCC Group).

## Steps

1. **Explore the codebase structure** - Use the Agent tool with subagent_type='Explore' to understand:
   - Languages, frameworks, and tech stack in use
   - Entry points: HTTP routes, CLI handlers, message consumers, cron jobs
   - Data flow: where user input enters and where it reaches sinks (DB, OS, network, DOM)
   - Authentication and authorization architecture
   - Infrastructure files: Dockerfiles, CI/CD configs, IaC (Terraform, CloudFormation)

2. **Spawn parallel security review agents** - Use the Agent tool to launch these 6 subagents IN PARALLEL (all in a single message). Each agent must search the actual code using Grep/Glob and report concrete findings with file paths and line numbers:

   - **Secrets & Credentials**: Scan for hardcoded secrets, API keys, private keys, tokens, and credentials in source code, config files, and environment files. Search for patterns like `AKIA[0-9A-Z]{16}` (AWS), `ghp_[a-zA-Z0-9]{36}` (GitHub), `sk-[a-zA-Z0-9]{48}` (OpenAI), `sk_live_` (Stripe), `xox[bpras]-` (Slack), `BEGIN.*PRIVATE KEY`, database connection strings with embedded passwords, and generic patterns like `(password|secret|token|api_key)\s*[:=]\s*['"][^'"]+['"]`. Check `.env` files committed to the repo, `*.pem`/`*.key` files, `*.tfstate` files, and `docker-compose*.yml` for exposed secrets.

   - **Injection & Input Validation**: Search for SQL injection (string concatenation in queries, `f"SELECT`, `.raw(`, ORM raw queries), XSS (`innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `|safe`, `html_safe`), command injection (`os.system`, `subprocess.*shell=True`, `child_process.exec`, `exec(`, `eval(`), path traversal (`../` handling, `path.join` with user input), template injection (`render_template_string`), deserialization (`pickle.loads`, `yaml.load` without SafeLoader, `unserialize`, `ObjectInputStream`), and SSRF (user-controlled URLs passed to HTTP clients). Also check for ReDoS patterns (nested quantifiers in regex with user input).

   - **Authentication & Authorization**: Review auth middleware and decorators — find routes/endpoints missing auth checks. Check session management (cookie flags: `Secure`, `HttpOnly`, `SameSite`; session regeneration on login; session timeout). Review JWT implementation (signature verification, `alg:none` acceptance, expiration claims, secret storage). Check password hashing (must be bcrypt/scrypt/argon2, not MD5/SHA). Look for IDOR (user IDs from request used without ownership validation), broken access control (missing `WHERE user_id =` in queries), privilege escalation (role modification by users), mass assignment (`Model.create(req.body)`, `**request.json`), and CORS misconfig (`Access-Control-Allow-Origin: *` with `credentials: true`).

   - **Cryptography & Data Protection**: Check for weak algorithms (MD5, SHA1, DES, RC4, ECB mode), insecure random (`Math.random`, `random.random`, `rand()` for security), insufficient key lengths (RSA < 2048, AES < 128), hardcoded IVs/nonces, disabled TLS verification (`verify=False`, `InsecureSkipVerify`, `NODE_TLS_REJECT_UNAUTHORIZED=0`), weak TLS versions (1.0/1.1), sensitive data in logs (PII, passwords, tokens logged), sensitive data in URLs, missing encryption at rest, and floating-point arithmetic for financial calculations.

   - **Supply Chain & Dependencies**: Check lock file presence and integrity. Run or simulate dependency audit (look for known vulnerable versions in lock files). Search for dependency confusion risks (private package names claimable on public registries). Check for typosquatting. Review `postinstall`/`preinstall` scripts in `package.json`. Check CI/CD for unpinned actions (`uses: actions/*@main` instead of SHA-pinned), secret exposure in workflow files (`echo ${{ secrets.* }}`), script injection via event data (`${{ github.event.pull_request.title }}` in `run:` steps), and `pull_request_target` with PR code checkout.

   - **Infrastructure & Configuration**: Review Dockerfiles for running as root (missing `USER`), `FROM:latest`, secrets in `ENV`/`ARG`/`COPY .env`, and missing multi-stage builds. Check for debug mode in production (`DEBUG=True`, `NODE_ENV=development`). Review security headers (CSP, HSTS, X-Frame-Options, X-Content-Type-Options). Check for overly permissive file permissions (`chmod 777`). Review Kubernetes/Docker Compose for privileged containers, host network, missing resource limits. Check Terraform/IaC for public S3 buckets, open security groups (`0.0.0.0/0`), disabled encryption. Look for missing rate limiting on auth endpoints and missing request size limits.

3. **Compile and prioritize findings** - Organize all findings into a single report:

   - **Critical** (exploit now): RCE, SQL injection with confirmed sink, hardcoded production secrets, auth bypass, deserialization of untrusted data
   - **High** (likely exploitable): XSS with confirmed sink, SSRF, IDOR, broken access control, weak password hashing in use, known CVEs in dependencies
   - **Medium** (conditional/defense-in-depth): CORS misconfiguration, missing security headers, overly permissive CSRF, verbose error messages, missing rate limiting, debug mode enabled
   - **Low** (hardening): Information disclosure, missing `HttpOnly`/`Secure` flags, unpinned CI dependencies, missing CSP, unnecessary ports exposed

   For each finding include: severity, category (OWASP A01-A10 where applicable), file path and line number, code snippet, explanation of the risk, and a concrete remediation suggestion.

4. **Ask user questions** - Use the AskUserQuestion tool to:
   - Clarify which findings are known/accepted risks
   - Determine which issues to fix vs. document
   - Understand deployment environment constraints
   - Confirm before making any changes

5. **Offer to remediate** - After discussion, offer to:
   - Fix critical and high findings immediately
   - Add security-related TODO comments for medium/low items
   - Create or update `.gitignore` to exclude secrets/sensitive files
   - Add security linting config (e.g., eslint-plugin-security, bandit, gosec)
   - Document accepted risks

Be thorough and evidence-based. Every finding must reference actual code, not hypothetical risks. Do not report false positives — verify that user input actually reaches the dangerous sink before flagging injection issues.
