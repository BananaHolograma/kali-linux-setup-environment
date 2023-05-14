##Colors
#
#( fg
red='\e[31m'
lred='\e[91m'
green='\e[32m'
lgreen='\e[92m'
yellow='\e[33m'
lyellow='\e[93m'
blue='\e[34m'
lblue='\e[94m'
magenta='\e[35m'
lmagenta='\e[95m'
cyan='\e[36m'
lcyan='\e[96m'
grey='\e[90m'
lgrey='\e[37m'
white='\e[97m'
black='\e[30m'
##)
#( bg
b_red='\e[41m'
b_lred='\e[101m'
b_green='\e[42m'
b_lgreen='\e[102m'
b_yellow='\e[43m'
b_lyellow='\e[103m'
b_blue='\e[44m'
b_lblue='\e[104m'
b_magenta='\e[45m'
b_lmagenta='\e[105m'
b_cyan='\e[46m'
b_lcyan='\e[106m'
b_grey='\e[100m'
b_lgrey='\e[47m'
b_white='\e[107m'
b_black='\e[40m'
##)
#( special
reset='\e[0;0m'
bold='\e[01m'
italic='\e[03m'
underline='\e[04m'
inverse='\e[07m'
conceil='\e[08m'
crossedout='\e[09m'
bold_off='\e[22m'
italic_off='\e[23m'
underline_off='\e[24m'
inverse_off='\e[27m'
conceil_off='\e[28m'
crossedout_off='\e[29m'
##)
#)




#ASCII TO CHAR 
chr() {
    [ "$1" -lt 256 ] || return 1
    printf "\\$(printf '%03o' "$1")"
} 

#CHAR TO ASCII
ord() {
    LC_CTYPE=C printf '%d' "'$1"
}

command_exists() {
    local command=$1

    [[ -n "$(command -v "$command")" ]]
}

extractPortsFromNmapNormal() {
    local file=$1

    if  [ ! $# -eq 0 ] && [ -f $file ] && [ -s $file ]; then
        ! command_exists && sudo apt install xclip
        grep -E '[0-9]{1,5}/(tcp|udp)' $file | sed -r 's/\/(tcp|udp)//g' | awk '{print $1}' | xargs | tr ' ' ',' | tr -d '\n' | xclip -sel clip 
        echo -e "[*] Ports copied to clipboard\n"  >> extractPortsFromNmapNormal.tmp
        cat extractPortsFromNmapNormal.tmp; rm extractPortsFromNmapNormal.tmp   
    else 
        echo -e "The file passed as parameter does not exists or is not valid"
    fi
}

extractPortsFromNmapGrepable() {
    ! command_exists && sudo apt install xclip

    ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"

    echo -e "\n[*] Extracting information...\n" > extractPortsFromNmapGrepable.tmp
    echo -e "\t[*] IP Address: $ip_address"  >> extractPortsFromNmapGrepable.tmp
    echo -e "\t[*] Open ports: $ports\n"  >> extractPortsFromNmapGrepable.tmp

    echo $ports | tr -d '\n' | xclip -sel clip

    echo -e "[*] Ports copied to clipboard\n"  >> extractPortsFromNmapGrepable.tmp
    cat extractPortsFromNmapGrepable.tmp; rm extractPortsFromNmapGrepable.tmp
}
