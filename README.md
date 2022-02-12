# GnuPG Formula
Sets up, configures and updates Gnu Privacy Guard.

## Usage
Applying `tool-gpg` will make sure `gpg` is configured as specified.

## Shell Environment
Since GnuPG 2.1, [the agent runs with a fixed socket and is started on demand](https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart). This obsoletes most of the examples of how to setup your shell environment for gpg (including the zsh prezto plugin). Currently, it's only necessary to `export GPG_TTY=$(tty)` in your shell runcom. Invoking `gpg-connect-agent /bye` starts the agent and is what would be needed if some application does not start it on demand. A prime example is OpenSSH.
### SSH Integration
Most applications start gpg-agent on demand, OpenSSH does not. Therefore, it needs to be started by the user (or his shellrc) before running `ssh`:
```bash
gpg-connect-agent /bye
```
This method comes with a problem though: When using a manually started gpg-agent in place of ssh-agent, it does not know the current tty, only the one it was started with. If it is configured to use a terminal-based pinentry program, password prompts show up in the tty where it was started first. This is a problem especially in terminal multiplexers.

The fix for both problems is to teach OpenSSH to autostart gpg-agent in its config file: [[1](https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9)]
```
Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
```
So just before every single connection, OpenSSH updates the gpg-agent default tty to the current one. If the agent was not running already, it is started as well. This workaround needs `GPG_TTY=$(tty)` to succeed.

### Sane Pinentry
GnuPG will typically generally use a graphical pinentry if `$DISPLAY` is set, even if invoked from a terminal. This can cause problems (e.g. while connected through SSH) and breaks the flow. This formula contains a script called `pinentry-sane` that acts as a shim. If `PINENTRY_USER_DATA="USE_CURSES=1"` is set, it will invoke `pinentry-tty` or `pinentry-curses` depending on formula configuration, otherwise `pinentry-mac` or `pinentry-x11` depending on the system. This emulates the behavior of `pinentry-mac` for Linux and on MacOS provides the user with the choice of which terminal-based pinentry to use.

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-gpg` pillar configuration. Namespace it to `tool:users` and/or `tool:gpg:users`.
```yaml
user:
  xdg: true                       # force xdg dirs
  # sync this user's config from a dotfiles repo available as
  # salt://dotconfig/<user>/gpg or salt://dotconfig/gpg
  dotconfig:              # can be bool or mapping
    file_mode: '0600'     # default: keep destination or salt umask (new)
    dir_mode: '0700'      # default: 0700
    clean: false          # delete files in target. default: false
  persistenv: '.config/zsh/zshenv' # persist pipx env vars to use xdg dirs permanently (will be appended to file relative to $HOME)
  rchook: '.bashrc'               # add runcom hooks to this file (will be appended to file relative to $HOME)
  gpg:
    pinentry_update_rc: true
    agent:
      sshrc: .ssh/myconfig        # add hook to ssh conf relative to $HOME to autoreset TTY to current one on ssh launch
      config:                     # gpg-agent.conf configuration options for this user
        default-cache-ttl: 10
    config:                       # gpg.conf configuration options for this user
      charset: utf-8
```

#### Formula-specific
```yaml
tool:
  gpg:
    # insert shim that switches pinentry program depending on env (terminal -> tty/curses, gui -> x11/pinentry-mac)
    pinentry_sane:                # set to true to use defaults, don't specify or false to disable
      terminal: tty               # when using pinentry-sane, use pinentry-tty as default interface. also possible: curses
      path: /some/path            # save pinentry-sane somewhere else, not /usr/local/bin

    # default formula configuration for all users
    defaults:
      pinentry_sane: true         # update gpg-agent.conf to use pinentry-sane
      pinentry_update_rc: false   # automatically insert 'export PINENTRY_USER_DATA="USE_CURSES=1"' into shell rc to make shim functional
      agent:
        sshrc: .ssh/config        # add hook to ssh to autoreset TTY to current one on ssh launch
        sshcontrol: []            # populate sshcontrol file (keys gpg-agent uses for ssh connections)
        config:
          enable-ssh-support: ''  # set keys to empty values for the string without config value
          default-cache-ttl: 60
          max-cache-ttl: 120
      config:
        use-agent: ''
        no-greeting: ''
        keyid-format: 0xlong
        with-fingerprint: ''
```

### Dotfiles
`tool-gpg.configsync` will recursively apply templates from 

- `salt://dotconfig/<user>/gnupg` or
- `salt://dotconfig/gnupg`

to the user's config dir for every user that has it enabled (see `user.dotconfig`). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

## References
- https://web.archive.org/web/20211103123114/https://kevinlocke.name/bits/2019/07/31/prefer-terminal-for-gpg-pinentry/
- https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
- https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
