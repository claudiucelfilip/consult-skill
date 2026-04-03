---
name: consult
description: Get opinions from multiple AI tools on a topic, then challenge and iterate. Use when the user wants a second opinion, multi-tool review, panel discussion, or to compare model outputs.
argument-hint: [topic or question]
---

# Multi-Tool Consultation

You are orchestrating a panel of AI agents. You are the **admin** — all agents respond to you, not to each other. It should feel like a moderated panel discussion.

## Available Tools

| Tool | Command | Notes |
|------|---------|-------|
| Gemini | `gemini -p "prompt"` | Do NOT use `-m` flag (causes tool-use timeouts). Default model only. |
| Claude | `claude -p "prompt" --output-format text` | Use `--model` to select variant: `claude-sonnet-4-6`, `claude-haiku-4-5-20251001` |
| Codex | `codex exec "prompt"` | Uses stdin redirect (`< file`), not pipe. May be rate-limited. |
| Cursor Agent | `agent -p --trust "prompt" --model X` | Models: `claude-4.6-sonnet-medium`, `gemini-3.1-pro`, `gpt-5.3-codex`, etc. Requires paid plan. |

## Critical: Performance Rules

1. **Always `cd /tmp &&`** before invoking any tool. This skips project directory scanning and cuts response time from 60s+ to ~10s.
2. **Always `run_in_background: true`** on every Bash invocation. Never block the conversation.
3. **Always `timeout 45`** wrapper on every invocation.
4. **Always `2>/dev/null`** to suppress CLI startup noise.
5. **Always create a Task** per agent before spawning, update to "done" or "timed out" when complete.
6. **Gemini**: always include "Do NOT use tools or search — analyze only what's given." in the prompt. Without this, Gemini tries web research and times out.

## Agent Naming

Each agent gets a name: `@tool-model-adjective-animal`. Examples:

```
@gemini-default-bold-falcon
@claude-sonnet-calm-otter
@claude-haiku-swift-heron
@codex-gpt5-keen-wolf
```

The user can address agents by full name or just the animal: "@bold-falcon" or "@calm-otter".

The user specifies which tools. Examples:
- "ask gemini and claude" → 2 agents
- "ask gemini, claude sonnet, and claude haiku" → 3 agents
- "ask 3 claudes with different models" → 3 agents

**Present the roster** when starting:
> Panel assembled:
> - @gemini-default-bold-falcon (Gemini)
> - @claude-sonnet-calm-otter (Claude Sonnet 4.6)

## Workflow

### Step 1: Prepare Context

Write the user's document/question to `/tmp/consult-context.md`. Include the panel roster at the top.

### Step 2: Invoke Agents

Create a Task per agent (activeForm: "@name is thinking"), then spawn all in parallel as background commands:

```bash
cd /tmp && cat consult-context.md | timeout 45 gemini -p "You are @gemini-default-bold-falcon. [question]. Under 150 words. Do NOT use tools or search — analyze only what's given." 2>/dev/null
```

```bash
cd /tmp && cat consult-context.md | timeout 45 claude -p "You are @claude-sonnet-calm-otter. [question]. Under 150 words. Do NOT use tools." --output-format text --model claude-sonnet-4-6 2>/dev/null
```

For Codex (uses stdin redirect, not pipe):
```bash
cd /tmp && timeout 45 codex exec "You are @codex-gpt5-keen-wolf. [question]. Under 150 words." < consult-context.md 2>/dev/null
```

### Step 3: Collect Responses

As each background task completes:
1. Read the output file
2. Update the agent's Task to "done" (or "timed out" on exit 124)
3. Show the response labeled with @name
4. When ALL agents are done, provide a brief synthesis: agreements, disagreements, unique insights

### Step 4: Handle Timeouts

If an agent times out (exit code 124):
1. Mark the Task as timed out
2. Auto-retry ONCE with a shorter, more direct prompt: "Answer in 2-3 sentences. Do NOT use any tools."
3. If retry also fails, report it and move on

### Step 5: Follow-ups / Challenges

The user addresses agents by name:
- "challenge @bold-falcon on the risk section"
- "@calm-otter, what about opportunity cost?"
- "ask @bold-falcon and @calm-otter to respond to each other's points"

For each follow-up:
1. Update `/tmp/consult-context.md` with the full history so far + new question
2. Create a Task for the targeted agent(s)
3. Spawn background command(s) with the updated context
4. Report response when done

### Step 6: Optimal Conclusion

When the user asks for a final answer or best version:
1. Update context file with complete discussion history
2. Ask EACH agent independently: "You've seen the full panel discussion. Synthesize an OPTIMAL final recommendation taking the best ideas from all panelists. Where another panelist had a better point, adopt it. Be specific."
3. Present each agent's optimal conclusion
4. Provide your own meta-synthesis of convergence points and remaining disagreements

### Step 7: Save History

After the consultation, save the full history to `/tmp/consult-history-{topic-slug}.md` so it can be referenced or resumed later.

## Context File Format

```markdown
# Consultation: {topic}

## Panel
- @gemini-default-bold-falcon (Gemini)
- @claude-sonnet-calm-otter (Claude Sonnet 4.6)

## Document
{original content}

## Round 1: Initial Opinions

### @gemini-default-bold-falcon
{response}

### @claude-sonnet-calm-otter
{response}

### Admin Synthesis
{your synthesis of agreements/disagreements}

## Round 2: Challenge to @bold-falcon
Q: {user's challenge}

### @gemini-default-bold-falcon
{response}

## Current Question
{the latest question to answer}
```

## Rules

- **Background**: EVERY invocation uses `run_in_background: true`. Never block the conversation.
- **Parallel**: Invoke all agents simultaneously in a single message with multiple Bash calls.
- **Tasks**: Create a Task per agent before spawning. Update when done/timed out. This gives the user visual tracking.
- **Names**: Always use @name labels. After roster is set, never use bare tool names.
- **cd /tmp**: ALWAYS run CLI tools from /tmp to skip project scanning.
- **History**: Accumulate all rounds in the context file so agents have full history for follow-ups.
- **No chatter**: Agents don't talk to each other. Everything goes through you.
- **User drives**: Only invoke agents when the user asks. Don't auto-invoke extra rounds.
- **Concise**: Tell agents 150 words unless user asks for detail.
- **Offer next steps**: After each round, briefly suggest what the user can do next (challenge, ask follow-up, get optimal conclusion).

## Known Limitations

- **Gemini model selection**: The `-m` flag causes Gemini to attempt tool use and timeout. Use default model only until this is resolved.
- **Parallel Claude instances**: Two `claude -p` calls with the same model may conflict. Use different models (sonnet + haiku) for parallel Claude agents.
- **Codex credits**: Codex may be rate-limited or out of credits. Handle gracefully.

## Topic

$ARGUMENTS
