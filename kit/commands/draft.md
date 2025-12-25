# Create branch and PR from local changes (optionally specify target branch)

Stage changes, create a descriptive branch, commit, and open a PR to the target branch. Analyzes the diff to generate smart branch names and PR descriptions.

**Arguments:** Optional target branch (e.g., `/kit:draft main`). Defaults to auto-detecting development/develop/main.

## Steps

1. **Check current state:**
   - Run `git status` to see changes
   - Run `git branch --show-current` to get current branch
   - If no changes exist, print "No changes to create PR from" and stop

2. **Determine target branch:**
   - If argument provided, use it as target branch
   - Otherwise, auto-detect by checking which exists: `development` → `develop` → `main`
   - Run `git branch -a` to find available branches

3. **Handle current branch:**
   - If on the target branch (e.g., on `development` and targeting `development`):
     - Must create a new branch - proceed to step 4
   - If on a different branch that's not target:
     - Use AskUserQuestion: "Use current branch '[branch]' or create a new one?"
     - If user wants current branch, skip to step 5

4. **Create descriptive branch name:**
   - Run `git diff` and `git diff --cached` to analyze all changes
   - Determine the conventional commit type: `feat`, `fix`, `docs`, `refactor`, `chore`, etc.
   - Create branch name format: `<type>/<short-description>` (e.g., `feat/add-user-auth`, `fix/login-validation`)
   - Keep description to 2-4 words, kebab-case, no special characters
   - Run `git checkout -b <branch-name>`

5. **Stage and commit:**
   - Stage relevant changes (files from this conversation, or all if fresh)
   - Run `git diff --cached` to review staged changes
   - Run `git log --oneline -5` to see commit style
   - Generate conventional commit message (same rules as /kit:ship)
   - Execute `git commit -m "<message>"`

6. **Push and create PR:**
   - Run `git push -u origin <branch-name>`
   - Analyze the full diff against target: `git diff <target-branch>...HEAD`
   - Create PR with `gh pr create`:
     - Title: The commit subject line (or summary if multiple commits)
     - Body: 2-3 bullet points summarizing the changes, derived from diff analysis
     - Target: The determined target branch
   - Format:
     ```
     gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'EOF'
     ## Summary
     - <bullet 1>
     - <bullet 2>
     EOF
     )"
     ```

7. **Report result:**
   - Print the PR URL
   - Print summary: branch created, target branch, PR title

Keep PR descriptions concise - focus on what changed, not implementation details.
