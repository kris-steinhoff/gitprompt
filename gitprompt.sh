COLOR_PROMPT_RED="\[\e[31m\]"
COLOR_PROMPT_GREEN="\[\e[32m\]"
COLOR_PROMPT_YELLOW="\[\e[33m\]"
COLOR_PROMPT_BLUE="\[\e[34m\]"
COLOR_PROMPT_MAGENTA="\[\e[35m\]"
COLOR_PROMPT_CYAN="\[\e[36m\]"

COLOR_PROMPT_RED_BOLD="\[\e[31;0m\]"
COLOR_PROMPT_GREEN_BOLD="\[\e[32;0m\]"
COLOR_PROMPT_YELLOW_BOLD="\[\e[33;0m\]"
COLOR_PROMPT_BLUE_BOLD="\[\e[34;0m\]"
COLOR_PROMPT_MAGENTA_BOLD="\[\e[35;0m\]"
COLOR_PROMPT_CYAN_BOLD="\[\e[36;0m\]"

COLOR_PROMPT_NONE="\[\e[0m\]"

if [ $UID -eq 0 ]; then
    export PROMPT_CHAR="#"
else
    export PROMPT_CHAR="$"
fi

gitprompt()
{
    PREV_RET_VAL=$?;

    PS1=""

    PS1="${PS1}${COLOR_PROMPT_YELLOW}\u${COLOR_PROMPT_NONE}"
    PS1="${PS1}@${COLOR_PROMPT_RED}\h${COLOR_PROMPT_NONE}:${COLOR_PROMPT_YELLOW}\w${COLOR_PROMPT_NONE} ${COLOR_PROMPT_CYAN}\t${COLOR_PROMPT_NONE}"

    git branch &> /dev/null; rc=$?;
    if [ $rc -eq 0 ]; then
        BRANCH=`git branch --no-color 2> /dev/null | grep ^\* | sed s/\*\ //g`
        if [ "x${BRANCH}" = "x" ]; then
            INFO="(no branch found)"
        else
            INFO="${BRANCH}:"
        fi
        COMMIT=`git log -1 2> /dev/null | head -1 | awk '{print $2}' | cut -c 1-7`
        INFO=${INFO}${COMMIT};
        STATE_COLOR=${COLOR_PROMPT_RED}

        GIT_ST="/tmp/GIT_ST_${USER}_${$}"
        git status 2> /dev/null 1> $GIT_ST

        cat $GIT_ST | tail -n1 | grep 'working directory clean' &> /dev/null; rc=$?
        if [ $rc -eq 0 ]; then
            STATE_COLOR=${COLOR_PROMPT_GREEN}
        fi

        cat $GIT_ST | grep 'Changes to be committed' &> /dev/null; rc=$?
        if [ $rc -eq 0 ]; then
            STATE_COLOR=${COLOR_PROMPT_YELLOW}
        fi

        cat $GIT_ST | grep 'Changed but not updated' &> /dev/null; rc=$?
        if [ $rc -eq 0 ]; then
            STATE_COLOR=${COLOR_PROMPT_RED}
        fi

        cat $GIT_ST | grep 'Untracked files' &> /dev/null; rc=$?
        if [ $rc -eq 0 ]; then
            STATE_COLOR=${COLOR_PROMPT_RED}
        fi

        if [ "$BRANCH" = "(no branch)" ]; then
            STATE_COLOR=${COLOR_PROMPT_CYAN}
        fi

        PS1="${PS1} ${STATE_COLOR}[${INFO}]${COLOR_PROMPT_NONE}"

        git_version=`git --version | awk '{print $3}' | awk -F. '{print $1"."$2}'`
        case $git_version in
            "1.5"|"1.6")
            for remote in `git remote`; do
                remote_branch=`git remote show -n $remote | grep -A1 "while on branch ${BRANCH}" | grep '^    .*$' | sed 's/^[ \t]*//;s/[ \t]*$//'`
                if [ "x$remote_branch" != "x" ]; then
                    PS1="${PS1} ${COLOR_PROMPT_MAGENTA}${remote}/${remote_branch}${COLOR_PROMPT_NONE}"
                fi
            done
            ;;

            "1.7")
            for remote in `git remote`; do
                remote_branch=`git remote show -n ${remote} | grep "${BRANCH} * merges with remote" | awk -F" merges with remote " '{print $2}'`
                if [ "x$remote_branch" != "x" ]; then
                    PS1="${PS1} ${COLOR_PROMPT_MAGENTA}${remote}/${remote_branch}${COLOR_PROMPT_NONE}"
                fi
            done
            ;;
        esac
    fi

    if [ "x" != "x$VIRTUAL_ENV" ]; then
        PS1="${PS1} ${COLOR_PROMPT_BLUE}(`basename ${VIRTUAL_ENV}`)${COLOR_PROMPT_NONE}"
    fi

    if test $PREV_RET_VAL -eq 0
    then
        PS1="${PS1}\n${COLOR_PROMPT_GREEN}${PROMPT_CHAR}${COLOR_PROMPT_NONE} "
    else
        PS1="${PS1}\n${COLOR_PROMPT_RED}[${PREV_RET_VAL}] ${PROMPT_CHAR}${COLOR_PROMPT_NONE} "
    fi

    if [ ! ${HOST} ]; then
        HOST=`hostname`
    fi
    TITLE=${HOST}:${PWD}

    echo -ne "\033]0;${TITLE}\007"

}

export PROMPT_COMMAND=gitprompt
