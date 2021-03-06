# This aspect is WTFPL, see README.md
shrink_path () {
    setopt localoptions
    setopt rc_quotes null_glob

    typeset -i lastfull=0
    typeset -i short=0
    typeset -i tilde=0
    typeset -i named=0

    if zstyle -t ':prompt:shrink_path' fish; then
        lastfull=1
        short=1
        tilde=1
    fi
    if zstyle -t ':prompt:shrink_path' nameddirs; then
        tilde=1
        named=1
    fi
    zstyle -t ':prompt:shrink_path' last && lastfull=1
    zstyle -t ':prompt:shrink_path' short && short=1
    zstyle -t ':prompt:shrink_path' tilde && tilde=1

    while [[ $1 == -* ]]; do
        case $1 in
            -f|--fish)
                lastfull=1
                short=1
                tilde=1
                ;;
            -h|--help)
                print 'Usage: shrink_path [-f -l -s -t] [directory]'
                print ' -f, --fish      fish-simulation, like -l -s -t'
                print ' -l, --last      Print the last directory''s full name'
                print ' -s, --short     Truncate directory names to the first character'
                print ' -t, --tilde     Substitute ~ for the home directory'
                print ' -T, --nameddirs Substitute named directories as well'
                print 'The long options can also be set via zstyle, like'
                print '  zstyle :prompt:shrink_path fish yes'
                return 0
                ;;
            -l|--last) lastfull=1 ;;
            -s|--short) short=1 ;;
            -t|--tilde) tilde=1 ;;
            -T|--nameddirs)
                tilde=1
                named=1
                ;;
        esac
        shift
    done

    typeset -a tree expn
    typeset result part dir=${1-$PWD}
    typeset -i i

    [[ -d $dir ]] || return 0

    if (( named )); then
        for part in ${(k)nameddirs}; do
            [[ $dir == ${nameddirs[$part]}(/*|) ]] && dir=${dir/${nameddirs[$part]}/\~$part}
        done
    fi
    (( tilde )) && dir=${dir/$HOME/\~}
    tree=(${(s:/:)dir})
    (
        if [[ $tree[1] == \~* ]]; then
            cd -q ${~tree[1]}
            result=$tree[1]
            shift tree
        else
            cd -q /
        fi
        for dir in $tree; do
            if (( lastfull && $#tree == 1 )); then 
                result+="/$tree"
                break
            fi
            expn=(a b)
            part=''
            i=0
            until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]]; do
                (( i++ ))
                part+=$dir[$i]
                expn=($(echo ${part}*(-/)))
                (( short )) && {
                    # if dir=hidden then show one character more
                    [ $part = "." ] && part+=$dir[$(( $i + 1 ))]
                    break
                }
            done
            result+="/$part"
            cd -q $dir
            shift tree
        done
        echo ${result:-/}
    )
}

P9K_WS_BLS=$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
P9K_WS_BRS=$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS

P9K_COLORDIR_DIR_BG="blue"
P9K_COLORDIR_DIR_FG="WHITE"
P9K_COLORDIR_BASE_BG="blue"
P9K_COLORDIR_BASE_FG="${DEFAULT_COLOR}"

# colordir+colorbase have to be joined to work (colordir colorbase_joined)

prompt_colordir() {
    POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS="" # disable whitespace for this segment
    POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS=""
    local shrunk=$(shrink_path -f $PWD)
    local segment=${shrunk//$(basename $PWD)/}

    # ~ should be part of base
    [[ $segment == "~" ]] && segment=""

    "$1_prompt_segment" "$0" "$2" "${P9K_COLORDIR_DIR_BG}" "${P9K_COLORDIR_DIR_FG}" " ${segment}" ''
    # ^ kP         icon  ^    ^kP  ^ bg                     ^ fg                     ^ text        ^ icon
}

prompt_colorbase() {
    POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS=$P9K_WS_BLS # set to previous value
    POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS=$P9K_WS_BRS
    local shrinked=$(shrink_path -f $PWD)
    local segment=""
    if [[ $#shrinked -gt 1 ]]; then
        local segment=$(basename $PWD)
    else
        # ~ and / are special
        local segment=$shrinked
    fi
    "$1_prompt_segment" "$0" "$2" "${P9K_COLORDIR_BASE_BG}" "${P9K_COLORDIR_BASE_FG}" "${segment}" ''
    # ^ kP         icon  ^    ^kP  ^ bg                      ^ fg                      ^ text        ^ icon
}
