# Global test hook — `run_tests.py`

Background reference for the test-runner hook registered in `~/.claude/settings.json`. The rule-level guidance ("respect the hook, fix the code not the test") lives in `~/.claude/CLAUDE.md` — this file is only for understanding or configuring the hook itself.

## What the hook does

- Triggers on every `Edit` and `Write` tool use (via the `PostToolUse` matcher in `settings.json`).
- Walks up from the edited file to find the project root by detecting one of the project markers below.
- Picks the right runner from those markers:
  - `uv.lock` → `uv run pytest`
  - `package.json` `scripts.test` → `npm test` / `pnpm test` / `yarn test` / `bun test`, depending on the lockfile present.
  - `Cargo.toml` → `cargo test`
  - `go.mod` → `go test ./...`
- Runs the suite synchronously (timeout 130s by default — see `settings.json`).
- Surfaces failures on stderr with exit code `2`, which Claude Code presents to the agent as a tool error.

## Configuring per-project behavior

Per-project overrides go in `<project>/.claude/settings.json`, never in the global file. Common patterns:

**Disable for this project entirely:**
```json
{ "hooks": { "PostToolUse": [] } }
```

**Replace the runner:**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command", "command": "pytest -m 'not slow'" }]
    }]
  }
}
```

**Layer on a pre-commit gate** (block commits when tests are red):
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "python ~/.claude/hooks/run_tests.py --gate-on git-commit" }]
    }]
  }
}
```

## When the hook isn't installed

If a session opens in a repo where `~/.claude/hooks/run_tests.py` doesn't exist on the machine (fresh checkout, different machine), the agent should surface that once at session start: *"test enforcement is rule-based rather than structural — I'll run tests after each change but it's on me to remember."* Then proceed under the rule-level guidance.

## When the hook misbehaves

Symptoms: timeout on a slow suite, false positive on a generated file, wrong runner detected.

**Do not edit `run_tests.py` mid-task.** Surface the misbehavior to the user, propose a project-local override, and proceed under the rule-level guidance. Changes to the global hook are their own work, separate from whatever the agent was doing when the failure surfaced.

## Related

- Rule-level guidance: `~/.claude/CLAUDE.md` (Testing section)
- Settings: `~/.claude/settings.json` (`PostToolUse` block)
- Hook source: `~/.claude/hooks/run_tests.py`
