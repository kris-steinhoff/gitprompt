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
        git status 2> /dev/null | tail -n1 | grep 'working directory clean' &> /dev/null; rc=$?
        if [ $rc -eq 0 ]; then
            STATE_COLOR=${COLOR_PROMPT_GREEN}
        else
            STATE_COLOR=${COLOR_PROMPT_RED}
        fi
        PS1="${PS1} ${STATE_COLOR}[${INFO}]${COLOR_PROMPT_NONE}"

        for remote in `git remote`; do
            remote_branch=`git remote show -n ${remote} | grep "${BRANCH} *merges with remote" | awk -F" merges with remote " '{print $2}'`
            if [ "x$remote_branch" != "x" ]; then
                PS1="${PS1} ${COLOR_PROMPT_MAGENTA}${remote}/${remote_branch}${COLOR_PROMPT_NONE}"
            fi
        done
    fi

    if test $PREV_RET_VAL -eq 0
    then
        PS1="${PS1}\n${COLOR_PROMPT_GREEN}${PROMPT_CHAR}${COLOR_PROMPT_NONE} "
    else
        PS1="${PS1}\n${COLOR_PROMPT_RED}[${PREV_RET_VAL}] ${PROMPT_CHAR}${COLOR_PROMPT_NONE} "
    fi
}

export PROMPT_COMMAND=gitprompt
