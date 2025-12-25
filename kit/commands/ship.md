# Stage, commit, and push changes

Stage, commit, and push in one step. Stages only files changed in this conversation (or all if fresh), auto-generates a conventional commit message, and pushes.

## Steps

1. **Determine what to commit:**
   - Check if you (Claude) have made changes in this conversation (edited/created files)
   - **If changes were made in this conversation:**
     - Only add the specific files you modified or created
     - Use `git add <file1> <file2> ...` for just those files
     - Ignore other unrelated changes in the working directory
   - **If this is a fresh conversation (no prior edits):**
     - Run `git status` to check for all modified, staged, or untracked files
     - Run `git add -A` to stage everything
   - If no relevant changes exist, print "No changes to commit" and stop

2. **Review what's being committed:**
   - Run `git diff --cached` to see staged changes
   - Run `git log --oneline -5` to see recent commit style

3. **Generate and create commit:**
   - Determine the Conventional Commit type: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`
   - Optionally infer a scope if clearly relevant
   - Format: `<type>(<scope>): <subject>` (subject ≤50 chars, imperative mood)
   - Add an optional body wrapped at 72 characters
   - DO NOT include any co-author lines or any mention of "Claude", "co-author", or "AI"
   - Execute: `git commit -m "<message>"`

4. **Push to remote:**
   - Run `git push`
   - If no upstream is set, use `git push -u origin <current-branch>`

Report success or failure at each step.
