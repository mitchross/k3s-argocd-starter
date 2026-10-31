

## Git workflow

This block is the same in every repo. Other rules in this file may add to it, never relax it.

- Work on a feature branch and open a pull request. Never push to the default branch.
- Never merge a pull request. The owner merges after review.
- Keep one writer per checkout. A lone agent may use the main checkout on a feature branch. When another agent or task uses that checkout, work in a worktree.
- Use your tool's own worktree feature: Claude Code `--worktree` (`.claude/worktrees/`), Hermes `-w` or `/worktree new` (`.worktrees/`), Codex app worktrees (`$CODEX_HOME/worktrees`). Cloud agents use their own sandbox and coordinate only through branches and pull requests.
- Create a worktree by hand only under `~/.local/share/agent-worktrees/<repo>/<task>/`, never as a sibling folder next to the repo.
- Reuse the task's worktree for follow-ups. Before you resume an old worktree, check its branch and PR state, and read the repo's `AGENTS.md` from the default branch (`git show origin/HEAD:AGENTS.md`).
- When the PR is merged or closed, remove your worktree with the tool's exit prompt or `git worktree remove <path>`. Keep and report a worktree that has uncommitted, untracked or unpushed work.
- Never run `git worktree remove --force`, `git reset --hard`, `git clean` or `rm -rf` on a checkout, and never delete a branch, unless the owner asks. Never force-push a branch another agent or person works on.
