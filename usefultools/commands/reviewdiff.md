---
name: reviewdiff
description: Review all git changes and suggest what you would have done differently
---

Review the current git changes thoroughly using subagents:

1. **Explore the git diff** - Use the Task tool with subagent_type='Explore' to examine:
   - All staged changes (`git diff --cached`)
   - All unstaged changes (`git diff`)
   - All untracked files (`git status`)

2. **Explore the surrounding code context** - Use subagents to understand the codebase and how these changes fit into the larger architecture.

3. **Provide your assessment** - After gathering context:
   - Is the approach good? What works well?
   - What would you have done differently?
   - Are there alternative approaches worth considering?
   - Any potential issues, edge cases, or improvements?

4. **Ask clarifying questions** - Use the AskUserQuestion tool if you're unsure about:
   - The intent behind specific changes
   - Whether certain trade-offs are acceptable
   - Clarification on requirements or context

Be direct and specific. Focus on meaningful suggestions, not nitpicks.
