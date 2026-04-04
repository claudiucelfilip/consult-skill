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

- **Multi-model panels** — Gemini, Claude, Codex, Grok, and more via Cursor Agent
- **Host participates** — the orchestrating Claude gives its own opinion, not just a summary
- **Non-blocking** — all external agents run in the background, you keep working
- **Visual tracking** — each agent gets a task indicator while thinking
- **Whimsical @names** — agents get identifiable names like `@gemini-pro-calm-otter` so you know who you're talking to
- **Challenge & iterate** — address agents by @name for follow-ups
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

**Recommended:** Add `consult-*.md` to your global gitignore so consultation artifacts don't pollute repos:

```bash
echo 'consult-*.md' >> ~/.gitignore
git config --global core.excludesFile ~/.gitignore
```

## Prerequisites

Claude Code plus at least one other CLI tool:

| Tool | Install | Models |
|------|---------|--------|
| [Claude Code](https://claude.ai/claude-code) | `npm install -g @anthropic-ai/claude-code` | Anthropic (Sonnet, Opus, Haiku) |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @google/gemini-cli` | Google (Gemini Pro, Flash) |
| [Codex CLI](https://github.com/openai/codex) | `npm install -g @openai/codex` | OpenAI (GPT-5.x) |
| [Cursor Agent](https://docs.cursor.com/agent-cli) | Included with Cursor | All of the above + Grok via one binary (requires Pro plan) |

You need Claude Code (the orchestrator) plus at least one other tool for the panel. The orchestrating Claude instance also participates as a panelist — so even with one external tool, you get two opinions.

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

- Agents respond in ~5-10 seconds via Cursor Agent, ~10-15s via native CLIs
- All agents run from the working directory — no `cd /tmp` tricks that lose repo context
- With Cursor Agent, all models run in parallel with no conflicts
- With native CLIs: Gemini needs "Do NOT use tools or search" to avoid timeouts, and two Claude instances with the same model may conflict
- Consultation history is saved as `consult-{topic}.md` in your working directory — future sessions can pick up where you left off

## Uninstall

```bash
./uninstall.sh
# or manually:
rm -rf ~/.claude/skills/consult
```

## License

MIT
