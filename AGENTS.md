# AGENTS.md

Guidance for AI coding agents (and human contributors) working in this repository.

This repo automates the setup of developer machines on Fedora (Linux) and macOS
using Ansible. Keep changes minimal, correct, and consistent with the existing style.

## Repository layout

- `site-linux.yml` / `site-mac.yml` — top-level playbooks, one per OS. A role belongs
  to a playbook only if it is listed there.
- `roles/<name>/` — each role follows the standard layout:
  `tasks/`, `defaults/main.yml`, optional `handlers/`, `vars/`, `templates/`.
- `group_vars/all` — cross-group variables (e.g. `ansible_python_interpreter`).
- `inventory.example.yml` — the only versioned inventory; `inventory.localhost.yml`
  and `inventory.local.yml` are gitignored and user-created.
- `bootstrap_local.sh` — local bootstrap (Linux); `test/` — Docker-based tests.

## Conventions to follow

- **Roles are the unit of work.** Add a capability by editing the relevant role's
  `tasks/main.yml` (or split into `include_tasks` files, as `common`, `zsh`, `cpp`,
  and `kubernetes` do), and expose config via `defaults/main.yml`.
- **Cross-platform roles must branch on OS**, not assume one. Guard Linux/macOS
  tasks with `when: ansible_facts['os_family'] == 'RedHat'` / `'Darwin'`. See
  `roles/cpp`, `roles/go`, `roles/java`, `roles/zsh` for the established pattern.
  Do not add Linux-only primitives (`dnf`, `akmods`, `systemd`, `/opt/...`) to a
  role without a guard, and do not label such a role "cross-platform".
- **User home paths must branch on OS** (`/home` vs `/Users`). Never hardcode
  `/home/...` in a role that may run on macOS. See `roles/python` for the pattern.
- **Config over code.** Prefer a new variable in `defaults/main.yml` with a
  sensible default over hardcoding. Users override via `vars.json` (`--extra-vars`),
  which has the highest precedence.
- **Prefer modules over `shell`/`command`.** Use `ansible.builtin.dnf`,
  `community.general.homebrew`, `community.general.flatpak`, `ansible.builtin.file`,
  etc. If you must use `command`/`shell`, set `changed_when` honestly — do not mark
  a state-changing command as `changed_when: false` just to keep runs "clean".
- **FQCN.** Use fully-qualified collection names (`ansible.builtin.dnf`,
  `community.general.homebrew`, `ansible.posix.sysctl`).
- **Tags.** Every play and every role entry in the playbooks carries a tag. When
  adding a role, tag it consistently so `--tags`/`--skip-tags` keep working.
- **YAML style.** Two-space indent, lists with `- `, strings unquoted where
  possible, single quotes for literal values that need quoting (e.g. versions).
  Start task files with `---`.

## Do not

- Do not add new Python/pip dependencies to `requirements.txt` unless required by a
  new Ansible collection or the bootstrap script.
- Do not commit `vars.json`, inventories other than `inventory.example.yml`, or
  any user-specific data. They are gitignored on purpose.
- Do not hand-edit generated/derived outputs.
- Do not add code comments unless a non-obvious `when:`/`changed_when:` truly
  needs explanation; the existing tasks are comment-free by convention.

## Testing before you finish

- `sh test/test.sh 43 all` — runs the Fedora playbook in a Docker container.
- The GitHub Actions workflow (`.github/workflows/main.yml`) runs a subset of tags
  on Fedora and macOS runners; keep your change compatible with both.
- If a role is Linux-only, verify it is only in `site-linux.yml`; if cross-platform,
  verify it runs on both playbooks and is exercised (or at least not broken) in CI.
- Run `ansible-lint` and `yamllint` if available; the `ansible` role installs both.

## Commits

- Use the existing prefix style: `[Feature]`, `[Fix]`, `[Docs]`, etc.
- One focused change per commit. Keep the diff to the smallest correct change.
