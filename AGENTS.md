# Black Atom Industries

Nik Brunner's org: the Black Atom themes for developer tools, and the terminal and Neovim tools around them. Sessions under
`~/repos/black-atom-industries` load this file. Each repo's README says what it is.

## How the repos relate

Find the current repos with these:

```sh
find ~/repos/black-atom-industries -maxdepth 2 -name .git -type d | sed 's#/.git$##'
gh repo list black-atom-industries --no-archived
```

- `black-atom` holds the themes, their adapters and Livery.
- `helm`, `helm.herdr` and `helm.tmux` are one idea per multiplexer: a popup to reach every session. `helm.tmux` owns
  `~/.local/bin/helm`, which `dots pull` and `dots push` call.
- `iter.nvim` defines highlight groups that `black-atom/adapters/nvim` overrides, so a highlight change can involve both.

## Across repos

- A repo's issue goes in that repo. An issue spanning repos goes in `.github`.
- Labels come from `.github/src/labels`, so change them there and sync.
- New tooling starts on Node.
