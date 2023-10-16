#!/bin/bash

declare -A mix_cache

exists_mix() {
    [ $(command -v mix) ]
}

exists_mix_project() {
    [ -f './mix.exs' ]
}

is_initialized() {
    [ ${#mix_cache[@]} -gt 0 ]
}

full_time() {
    # HH:MM:SS
    ls -l --time-style=+%T $1 | awk '{print $6}'
}

_mix() {
    local cur
    _get_comp_words_by_ref -n : cur
    if ! exists_mix || ! exists_mix_project; then
        COMPREPLY=($(compgen -o default "$cur"))
        return 0
    fi
    # TODO create options cache
    if [ "$cur" == '--' ]; then
        return 0
    fi
    if is_initialized; then
        if [ "${mix_cache['lastModified']}" == "$(full_time ./mix.exs)" ]; then
            COMPREPLY=($(compgen -W "${mix_cache['cmd']}" "$cur"))
            return 0
        fi
    fi
    mix_cache['lastModified']=$(full_time ./mix.exs)
    mix_cache['cmd']=$(mix help --names)
    COMPREPLY=($(compgen -W "${mix_cache['cmd']}" "$cur"))
    return 0
}

complete -F _mix mix
