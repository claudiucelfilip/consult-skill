---
name: consult
description: Get opinions from multiple AI tools on a topic, then challenge and iterate. Use when the user wants a second opinion, multi-tool review, panel discussion, or to compare model outputs.
argument-hint: [topic or question]
---

# Multi-Tool Consultation

You are orchestrating a panel of AI agents. You are the **admin** — all agents respond to you, not to each other. It should feel like a moderated panel discussion.

## Available Tools

**Preferred: Cursor Agent** — one binary, all models, fast (~5-10s):

```bash
agent -p --trust "prompt" --model MODEL_ID
```

Key models:
| Model ID | Provider |
|----------|----------|
| `claude-4.6-sonnet-medium` | Anthropic Claude Sonnet 4.6 |
| `claude-4.6-opus-high` | Anthropic Claude Opus 4.6 |
| `claude-4.5-sonnet` | Anthropic Claude Sonnet 4.5 |
| `gemini-3.1-pro` | Google Gemini 3.1 Pro |
| `gpt-5.3-codex` | OpenAI GPT-5.3 Codex |
| `gpt-5.3-codex-fast` | OpenAI GPT-5.3 Codex (fast) |
| `composer-2-fast` | Cursor Composer 2 (default) |

Run `agent models` to see all available models.

**Fallback tools** (if `agent` is unavailable):

| Tool | Command | Notes |
|------|---------|-------|
| Gemini | `gemini -p "prompt"` | Do NOT use `-m` flag (causes timeouts). Default model only. |
| Claude | `claude -p "prompt" --output-format text` | Use `--model` for variants. |
| Codex | `codex exec "prompt"` | Uses stdin redirect (`< file`), not pipe. |

## Critical: Performance Rules

1. **Always `cd /tmp &&`** before invoking any tool. This skips project directory scanning and cuts response time from 60s+ to ~10s.
2. **Always `run_in_background: true`** on every Bash invocation. Never block the conversation.
3. **Always `timeout 45`** wrapper on every invocation.
4. **Always `2>/dev/null`** to suppress CLI startup noise.
5. **Always create a Task** per agent before spawning, update to "done" or "timed out" when complete.
6. **Context via prompt, not stdin.** Pass the full context directly in the prompt string. Do NOT pipe via stdin — `agent` ignores stdin.
7. For long context (reports, documents), write to `/tmp/consult-context.md` and include in the prompt: "Read the file /tmp/consult-context.md and analyze it."

## Agent Naming

Each agent gets a name: `@tool-model-adjective-animal`. Examples:

```
@claude-sonnet-bold-falcon
@gemini-pro-calm-otter
@gpt5-codex-swift-heron
@claude-opus-keen-wolf
```

The user can address agents by full name or just the animal: "@bold-falcon" or "@calm-otter".

The user specifies which tools. Examples:
- "ask gemini and claude" → 2 agents
- "ask gemini pro, claude sonnet, and gpt-5" → 3 agents
- "ask all available models" → spawn one per major model

**Present the roster** when starting:
> Panel assembled:
> - @claude-sonnet-bold-falcon (Claude Sonnet 4.6)
> - @gemini-pro-calm-otter (Gemini 3.1 Pro)
> - @gpt5-codex-swift-heron (GPT-5.3 Codex)

## Workflow

### Step 1: Prepare Context

If the user provides a long document, write it to `/tmp/consult-context.md`. For shorter questions, include directly in the prompt.

### Step 2: Invoke Agents

Create a Task per agent (activeForm: "@name is thinking"), then spawn all in parallel as background commands:

For short context (fits in prompt):
```bash
cd /tmp && timeout 45 agent -p --trust "You are @claude-sonnet-bold-falcon on a review panel. [question + context]. Be specific, under 150 words." --model claude-4.6-sonnet-medium 2>/dev/null
```

For long context (written to file):
```bash
cd /tmp && timeout 45 agent -p --trust "You are @claude-sonnet-bold-falcon on a review panel. Read /tmp/consult-context.md and analyze it. [question]. Be specific, under 150 words." --model claude-4.6-sonnet-medium 2>/dev/null
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
2. Auto-retry ONCE with a shorter prompt: "Answer in 2-3 sentences."
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
- @claude-sonnet-bold-falcon (Claude Sonnet 4.6)
- @gemini-pro-calm-otter (Gemini 3.1 Pro)

## Document
{original content}

## Round 1: Initial Opinions

### @claude-sonnet-bold-falcon
{response}

### @gemini-pro-calm-otter
{response}

### Admin Synthesis
{your synthesis of agreements/disagreements}

## Round 2: Challenge to @bold-falcon
Q: {user's challenge}

### @claude-sonnet-bold-falcon
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

- **Parallel Claude via `agent`**: Multiple `agent` calls with different models run fine in parallel.
- **Fallback CLIs**: If `agent` is not available, use `claude -p`, `gemini -p`, `codex exec` directly. Gemini's `-m` flag causes timeouts — use default model only.
- **Stdin**: `agent` ignores piped stdin. Pass context in the prompt or reference a file path.
- **Codex credits**: Codex may be rate-limited or out of credits. Handle gracefully.

## Topic

$ARGUMENTS
