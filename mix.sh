#!/bin/bash

_mix() {
    local cur
    _get_comp_words_by_ref -n : cur
    if mix --version >/dev/null 2>&1; then
        local cmd
        cmd=$(mix help --names)
        COMPREPLY=($(compgen -W "$cmd" "$cur"))
    else
        COMPREPLY=($(compgen -o default "$cur"))
    fi
}

complete -F _mix mix
