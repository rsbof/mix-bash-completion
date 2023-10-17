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

is_long_option() {
    [ ${1:0:2} == '--' ]
}

_mix() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    if ! exists_mix; then
        COMPREPLY=($(compgen -o default "$cur"))
        return 0
    fi
    if is_long_option $cur; then
        opts=$(mix help $prev 2>/dev/null |
            grep -oP -- '(?<=`)--.*?(?=`)' |
            sort --unique)
        COMPREPLY=($(compgen -W "$opts" -- "$cur"))
        return 0
    fi
    if ! exists_mix_project; then
        COMPREPLY=($(compgen -W "$(mix help --names)" "$cur"))
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

comp_test() {
    _get_comp_words_by_ref -n : cur prev words cword
    echo ''
    echo "cur: $cur"
    echo "prev: $prev"
    echo "words: ${words[@]}"
    echo "cword: $cword"
}

# complete -F comp_test mix
complete -F _mix mix
