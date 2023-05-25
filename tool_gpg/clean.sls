# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_gpg`` meta-state
    in reverse order.
#}

# @TODO missing clean states

include:
  - .hook.clean
  # - .agent.clean
  - .config.clean
  # - .pinentry_sane.clean
  - .package.clean
