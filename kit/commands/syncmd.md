# Sync documentation with codebase

Scan the codebase with subagents and update AGENTS.md (+ other docs) to reflect current state.

## Steps

1. **Ensure AGENTS.md is the source file (first subagent):**
   - Launch a Task with subagent_type='Explore' to check the current state:
     - Is `CLAUDE.md` a symlink pointing to `AGENTS.md`?
     - Or is `AGENTS.md` missing / `CLAUDE.md` the real file?
   - If not properly set up:
     - If `CLAUDE.md` exists and is a real file, move its content to `AGENTS.md`
     - Remove `CLAUDE.md` if it's not a symlink
     - Create symlink: `ln -s AGENTS.md CLAUDE.md`
   - Wait for this subagent to complete before continuing

2. **Update AGENTS.md first (second subagent):**
   - Launch a Task with subagent_type='Explore' to:
     - Thoroughly explore the entire codebase structure and functionality
     - Read current `AGENTS.md` content
     - Identify outdated, missing, or incorrect information
     - Return a detailed report of what needs updating
   - Update `AGENTS.md` based on the report
   - **Complete this step before moving to other files**

3. **Find other documentation files:**
   - Use Glob to find `README.md` and other `.md` documentation files
   - Exclude `AGENTS.md` and `CLAUDE.md` from the list (already handled)
   - Check `.claude/` directories for instruction files

4. **Spawn one subagent per remaining markdown file:**
   - For EACH markdown file found, launch a separate Task with subagent_type='Explore'
   - Each subagent should:
     - Read the specific markdown file
     - Explore the relevant parts of the codebase it documents
     - Identify any outdated, missing, or incorrect information
     - Return a report of what needs updating
   - Run these subagents in parallel (multiple Task tool calls in a single message)

5. **Ask clarifying questions:**
   - Use the AskUserQuestion tool if you're unsure about:
     - The intended audience for documentation
     - Whether certain implementation details should be documented
     - Preferred documentation style or level of detail

6. **Update remaining documentation:**
   - Based on subagent reports, update each file as needed
   - Fix inaccuracies, add missing features, remove stale references
   - Keep documentation concise and actionable

Focus on making documentation useful for both humans and AI assistants.
