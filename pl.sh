#!/bin/bash

# symbols
plsh_symbol_right='\ue0b0'
plsh_symbol_right_alt='\ue0b1'
plsh_symbol_git_branch='\ue0a0'
plsh_symbol_git_unadded='\x2a'
plsh_symbol_git_uncommited='\x2b'
plsh_symbol_git_unpushed='↑'
plsh_symbol_remote='🌐'

# parts
plsh_userhost=' \u@\h '
plsh_prompt_text='🤗 ${plsh_var_prev_code_show:= }\$ '

# colors
plsh_color_bg_remote='deep_purple'
plsh_color_fg_remote='white'
plsh_color_bg_userhost='indigo'
plsh_color_fg_userhost='white'
plsh_color_bg_path='teal'
plsh_color_fg_path='white'
plsh_color_bg_git='deep_orange'
plsh_color_fg_git='white'
plsh_color_bg_prompt='cyan'
plsh_color_fg_prompt='white'
plsh_color_bg_prompt_error='pink'
plsh_color_fg_prompt_error='white'

plsh_fgcolor(){
	echo -n "\[\e[38;$1m\]"
}

plsh_bgcolor(){
	echo -n "\[\e[48;$1m\]"
}

plsh_color(){
    case $1 in
        "red"        ) echo -n "5;203"  ;;
        "pink"       ) echo -n "5;161"  ;;
        "purple"     ) echo -n "5;127" ;;
        "deep_purple") echo -n "5;61" ;;
        "indigo"     ) echo -n "5;61"  ;;
        "blue"       ) echo -n "5;33" ;;
        "light_blue" ) echo -n "5;39"  ;;
        "cyan"       ) echo -n "5;38"  ;;
        "teal"       ) echo -n "5;30"  ;;
        "green"      ) echo -n "5;71"  ;;
        "light_green") echo -n "5;107" ;;
        "lime"       ) echo -n "5;107" ;;
        "yellow"     ) echo -n "5;221" ;;
        "amber"      ) echo -n "5;214"  ;;
        "orange"     ) echo -n "5;208"  ;;
        "deep_orange") echo -n "5;202"  ;;
        "brown"      ) echo -n "5;"  ;;
        "grey"       ) echo -n "5;247";;
        "blue_grey"  ) echo -n "5;66" ;;
        "white"      ) echo -n "5;15";;
        "black"      ) echo -n "5;0";;
    esac
}
# plsh_color(){
#     case $1 in
#         "red"        ) echo -n "2;244;67;54"  ;;
#         "pink"       ) echo -n "2;233;30;99"  ;;
#         "purple"     ) echo -n "2;156;39;176" ;;
#         "deep_purple") echo -n "2;103;58;183" ;;
#         "indigo"     ) echo -n "2;63;81;181"  ;;
#         "blue"       ) echo -n "2;33;150;243" ;;
#         "light_blue" ) echo -n "2;3;169;244"  ;;
#         "cyan"       ) echo -n "2;0;188;212"  ;;
#         "teal"       ) echo -n "2;0;150;136"  ;;
#         "green"      ) echo -n "2;76;175;80"  ;;
#         "light_green") echo -n "2;139;195;74" ;;
#         "lime"       ) echo -n "2;205;220;57" ;;
#         "yellow"     ) echo -n "2;255;235;59" ;;
#         "amber"      ) echo -n "2;255;193;7"  ;;
#         "orange"     ) echo -n "2;255;152;0"  ;;
#         "deep_orange") echo -n "2;255;87;34"  ;;
#         "brown"      ) echo -n "2;121;85;72"  ;;
#         "grey"       ) echo -n "2;158;158;158";;
#         "blue_grey"  ) echo -n "2;96;125;139" ;;
#         "white"      ) echo -n "5;15";;
#         "black"      ) echo -n "5;0";;
#     esac
# }

plsh_resetcolor(){
	echo -n "\[\e[0m\]"
}

plsh_default_bgcolor(){
	echo -n "\[\e[49;24m\]"
}

plsh_bold(){
	echo -n "\[\e[1m\]"
}

plsh_boldoff(){
	echo -n "\[\e[21;24m\]"
}

plsh_git_branch_name(){
	plsh_var_name=`git rev-parse --abbrev-ref HEAD 2>/dev/null`
	if [ $? -eq 0 ];then
		echo -n "$plsh_var_name"
	fi
    unset plsh_var_name
}

plsh_git_branch(){
    plsh_var_cols=`tput cols`
    if [ $plsh_var_cols -gt '50' ];then
        echo -n "$plsh_symbol_git_branch "
    fi
    unset plsh_var_cols
}

plsh_var_git_src="$(plsh_bgcolor `plsh_color $plsh_color_bg_git`)$plsh_symbol_right\
$(plsh_fgcolor `plsh_color $plsh_color_fg_git`) \$(plsh_git_branch)\$(plsh_git_branch_name)\$(plsh_git_status) \
$(plsh_fgcolor `plsh_color $plsh_color_bg_git`)"
plsh_var_git_src_short="$(plsh_bgcolor `plsh_color $plsh_color_bg_git`)$plsh_symbol_right\
$(plsh_fgcolor `plsh_color $plsh_color_fg_git`)\$(plsh_git_status)\
$(plsh_fgcolor `plsh_color $plsh_color_bg_git`)"

plsh_git(){
    git status -s &>/dev/null
    if [ "$?" == '0' ];then
        plsh_var_cols=`tput cols`
        if [ $plsh_var_cols -gt '50' ];then
            evaled=`eval "echo \"$plsh_var_git_src"\"`
            echo -n "$evaled"
        else
            evaled=`eval "echo \"$plsh_var_git_src_short"\"`
            echo -n "$evaled"
        fi
    fi
    unset plsh_var_cols
}

plsh_git_status(){
    plsh_not_added=`git status -s | grep -e "^.\S"`
    plsh_not_commited=`git status -s | grep -e "^[^? ]"`
    plsh_not_pushed_count=`git cherry 2>/dev/null | wc -l`

    if [ "$plsh_not_added" ];then
        echo -n "$plsh_symbol_git_unadded"
    fi

    if [ "$plsh_not_commited" ];then
        echo -n "$plsh_symbol_git_uncommited"
    fi

    if [ "$plsh_not_pushed_count" != '0' ];then
        echo -n " $plsh_symbol_git_unpushed$plsh_not_pushed_count"
    fi

    unset plsh_not_added
    unset plsh_not_commited
    unset plsh_not_pushed_count
}

plsh_dir(){
    plsh_var_dir_src=`pwd | sed "s|$HOME|~|"`
    plsh_var_cols=`tput cols`
    if [ $plsh_var_cols -gt '70' ];then
        plsh_var_dir=${plsh_var_dir_src#/}
        plsh_var_dir=${plsh_var_dir//\// $plsh_symbol_right_alt }

        if [ `echo "$plsh_var_dir_src" | head -c 1` == '/' ];then
            if [ `echo -n "$plsh_var_dir_src" | tail -c 1` != '/' ];then
                plsh_var_dir="/ $plsh_symbol_right_alt $plsh_var_dir"
            else
                plsh_var_dir="/"
            fi
        fi
        echo "$plsh_var_dir"
        unset plsh_var_dir
    elif [ $plsh_var_cols -gt '60' ];then
        echo "$plsh_var_dir_src"
    elif [ $plsh_var_cols -gt '50' ];then
        evaled=$(echo -n "$plsh_var_dir_src" | sed -E 's|/(.)[^/]*|/\1|g' | head -c -1)$(basename "$plsh_var_dir_src")
        echo "$evaled"
    else
        echo "`basename $plsh_var_dir_src`"
    fi
    unset plsh_var_dir_src
    unset plsh_var_cols
}

plsh_remote_src="$(plsh_bgcolor `plsh_color $plsh_color_bg_remote`)\
$(plsh_fgcolor `plsh_color $plsh_color_fg_remote`) $plsh_symbol_remote\
$(plsh_fgcolor `plsh_color $plsh_color_bg_remote`)\
$(plsh_bgcolor `plsh_color $plsh_color_bg_userhost`)$plsh_symbol_right"

plsh_no_remort_src="$(plsh_bgcolor `plsh_color $plsh_color_bg_userhost`)"

plsh_remote(){
    if [ "$SSH_TTY" ];then
        evaled=`eval "echo \"$plsh_remote_src"\"`
    else
        evaled=`eval "echo \"$plsh_no_remort_src"\"`
    fi
    echo -n "$evaled"
}

plsh_prompt_src="$(plsh_fgcolor `plsh_color $plsh_color_fg_prompt`)$(plsh_bgcolor `plsh_color $plsh_color_bg_prompt`)$plsh_prompt_text\
$(plsh_resetcolor)$(plsh_fgcolor `plsh_color $plsh_color_bg_prompt`)$plsh_symbol_right"
plsh_prompt_error_src="$(plsh_fgcolor `plsh_color $plsh_color_fg_prompt_error`)$(plsh_bgcolor `plsh_color $plsh_color_bg_prompt_error`)$plsh_prompt_text\
$(plsh_resetcolor)$(plsh_fgcolor `plsh_color $plsh_color_bg_prompt_error`)$plsh_symbol_right"

plsh_prompt(){
    if [ "$plsh_var_prev_code" == '0' ];then
        evaled=`eval "echo \"$plsh_prompt_src\""`
    else
        plsh_var_prev_code_show="$plsh_var_prev_code "
        evaled=`eval "echo \"$plsh_prompt_error_src\""`
    fi
    echo -n "$evaled"
}

plsh_var_ps1_src="\
\$(plsh_remote)\
$(plsh_fgcolor `plsh_color $plsh_color_fg_userhost`)$plsh_userhost\
$(plsh_fgcolor `plsh_color $plsh_color_bg_userhost`)\
\
$(plsh_bgcolor `plsh_color $plsh_color_bg_path`)$plsh_symbol_right\
$(plsh_fgcolor `plsh_color $plsh_color_fg_path`) \$(plsh_dir) \
$(plsh_fgcolor `plsh_color $plsh_color_bg_path`)\
\
\$(plsh_git)\
$(plsh_default_bgcolor)$plsh_symbol_right\
\
$(plsh_resetcolor)\n\
\$(plsh_prompt)\
$(plsh_resetcolor) "

plsh_create_ps1(){
    plsh_var_prev_code=$?
    PS1=$(eval "echo -en \"$plsh_var_ps1_src\"")
}

unset plsh_userhost

unset plsh_color_bg_userhost
unset plsh_color_fg_userhost
unset plsh_color_bg_path
unset plsh_color_fg_path
unset plsh_color_bg_git
unset plsh_color_fg_git
unset plsh_color_bg_prompt
unset plsh_color_fg_prompt

unset plsh_fgcolor
unset plsh_bgcolor
unset plsh_color
unset plsh_resetcolor
unset plsh_default_bgcolor
unset plsh_bold
unset plsh_boldoff
