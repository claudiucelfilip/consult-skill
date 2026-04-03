# /consult

A Claude Code skill that orchestrates multi-model AI panels. Get opinions from Gemini, Claude, Codex, and Cursor Agent in parallel, then challenge them, iterate, and reach an optimal conclusion.

## How it works

```
You:      /consult Is ASML a good buy at 35x forward P/E?
Claude:   Panel assembled:
          - @gemini-default-bold-falcon (Gemini)
          - @claude-sonnet-calm-otter (Claude Sonnet 4.6)
          [spawns both in background, you keep working]

          @gemini-default-bold-falcon (10s):
          > Structurally sound but tactically aggressive. Wait for 5% pullback.

          @claude-sonnet-calm-otter (12s):
          > Signal decent but not compelling. 35x P/E priced for perfection.

You:      challenge @bold-falcon — what about opportunity cost of NOT buying a monopoly?
Claude:   [re-invokes with full history + challenge]

You:      ok get an optimal conclusion from both
Claude:   [each agent synthesizes independently, considering all views]
```

## Features

- **Multi-model panels** — Gemini, Claude (any variant), Codex, Cursor Agent
- **Non-blocking** — all agents run in the background, you keep working
- **Visual tracking** — each agent gets a task indicator while thinking
- **Whimsical @names** — agents get identifiable names like `@gemini-default-bold-falcon` so you know who you're talking to
- **Challenge & iterate** — address agents by name for follow-ups
- **Optimal conclusion** — each agent synthesizes the best answer from all views
- **History** — full conversation saved for reference

## Install

**One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/claudiucelfilip/consult-skill/main/install.sh | bash
```

**Or clone:**

```bash
git clone https://github.com/claudiucelfilip/consult-skill.git
cd consult-skill
./install.sh
```

**Manual:**

```bash
mkdir -p ~/.claude/skills/consult
cp SKILL.md ~/.claude/skills/consult/
```

## Prerequisites

Claude Code plus at least one other CLI tool:

| Tool | Install |
|------|---------|
| [Claude Code](https://claude.ai/claude-code) | `npm install -g @anthropic-ai/claude-code` |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @anthropic-ai/gemini-cli` |
| [Codex CLI](https://github.com/openai/codex) | `npm install -g @openai/codex` |
| [Cursor Agent](https://docs.cursor.com/agent-cli) | Included with Cursor (paid plan for model selection) |

## Usage

Start a new Claude Code session (skills load at startup), then:

```
/consult [your question or topic]
```

Examples:

```
/consult Review this PR for security issues
/consult Is this database schema normalized correctly?
/consult Compare React vs Svelte for this use case
/consult What do you think about this investment thesis?
```

You can specify which tools:

```
"ask gemini and claude"
"ask gemini, claude sonnet, and claude haiku"
"use all available tools"
```

### Workflow

1. **Ask** — agents analyze in parallel (background, non-blocking)
2. **Challenge** — address agents by @name for follow-ups
3. **Iterate** — agents see full history, build on each other's points
4. **Conclude** — each agent synthesizes an optimal answer from all views

## Performance tips

- Agents respond in ~10-15 seconds when run from `/tmp` (the skill does this automatically)
- Gemini needs "Do NOT use tools or search" in prompts to avoid web research timeouts
- Two Claude instances with the same model may conflict — use different variants (sonnet + haiku)

## Uninstall

```bash
./uninstall.sh
# or manually:
rm -rf ~/.claude/skills/consult
```

## License

MIT
