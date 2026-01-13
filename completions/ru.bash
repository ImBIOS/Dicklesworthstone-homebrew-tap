# Bash completion for ru (Repo Updater)
# Generated for homebrew-tap distribution

_ru_completions() {
    local cur prev words cword
    _init_completion || return

    local commands="sync status init add remove list doctor self-update config prune import review"
    local global_opts="-h --help -v --version --json -q --quiet --verbose --non-interactive"

    case "${prev}" in
        ru)
            COMPREPLY=($(compgen -W "${commands} ${global_opts}" -- "${cur}"))
            return
            ;;
        sync)
            local sync_opts="--clone-only --pull-only --autostash --rebase --dry-run --dir --parallel -j --resume --restart --timeout"
            COMPREPLY=($(compgen -W "${sync_opts} ${global_opts}" -- "${cur}"))
            return
            ;;
        status)
            local status_opts="--fetch --no-fetch"
            COMPREPLY=($(compgen -W "${status_opts} ${global_opts}" -- "${cur}"))
            return
            ;;
        init)
            local init_opts="--example"
            COMPREPLY=($(compgen -W "${init_opts} ${global_opts}" -- "${cur}"))
            return
            ;;
        add)
            local add_opts="--private"
            COMPREPLY=($(compgen -W "${add_opts} ${global_opts}" -- "${cur}"))
            return
            ;;
        remove|list|doctor|self-update|config|prune)
            COMPREPLY=($(compgen -W "${global_opts}" -- "${cur}"))
            return
            ;;
        import)
            # Complete with files
            COMPREPLY=($(compgen -f -- "${cur}"))
            return
            ;;
        review)
            local review_opts="--plan --apply --dry-run --mode --max-repos --repos --skip-days --parallel --push"
            COMPREPLY=($(compgen -W "${review_opts} ${global_opts}" -- "${cur}"))
            return
            ;;
        --dir|--parallel|-j|--timeout|--max-repos|--skip-days)
            # These take arguments, no completion
            return
            ;;
        --mode)
            COMPREPLY=($(compgen -W "local ntm" -- "${cur}"))
            return
            ;;
    esac

    # Default: show commands and global options
    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${commands} ${global_opts}" -- "${cur}"))
    fi
}

complete -F _ru_completions ru
