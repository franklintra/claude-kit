# Review entire codebase for patterns and issues

Analyze the whole repository for code quality issues, anti-patterns, and improvement opportunities.

## Steps

1. **Explore the codebase structure** - Use the Task tool with subagent_type='Explore' to understand:
   - Overall project structure and architecture
   - Main entry points and key modules
   - Dependencies and their usage

2. **Spawn parallel review agents** - Use the Task tool to launch these 4 subagents IN PARALLEL (all in a single message):
   - **Security**: Hardcoded secrets, injection risks, auth flaws, insecure dependencies
   - **Performance**: N+1 queries, inefficient algorithms, missing indexes, memory issues
   - **Anti-patterns**: God objects, circular dependencies, deep nesting, code duplication
   - **Maintainability**: Dead code, inconsistent naming, missing error handling, tech debt

3. **Present findings** - Create a prioritized list:
   - **Critical**: Security vulnerabilities, data loss risks
   - **High**: Performance bottlenecks, major anti-patterns
   - **Medium**: Maintainability issues, inconsistencies
   - **Low**: Style issues, minor improvements

4. **Ask user questions** - Use the AskUserQuestion tool to:
   - Clarify which issues are intentional trade-offs
   - Prioritize what to address first
   - Understand constraints (time, backwards compatibility, etc.)
   - Confirm before making any changes

5. **Offer to fix** - After discussion, offer to:
   - Fix specific issues the user wants addressed
   - Create a TODO list of improvements
   - Document known issues for future work

Be thorough but practical. Focus on impactful issues, not style nitpicks. Respect existing patterns unless they're clearly problematic.
