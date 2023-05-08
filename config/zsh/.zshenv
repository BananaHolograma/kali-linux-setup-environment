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