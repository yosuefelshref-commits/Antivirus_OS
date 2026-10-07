#!/bin/bash
if [ "$#" -ne 3 ]; 
then
    echo "Usage: $0 dir malicious_dir interval-secs"
    exit 1
fi

dir="$1"
malicious="$2"
sec="$3"

if [ ! -d "$dir" ]; 
then
    echo "Error: directory does not exist."
    exit 1
fi

mkdir -p "$malicious"
last="directory-info.last"
new="directory-info.new"

scan_dir() {
    for file in "$dir"/*
    do
        if [ -f "$file" ]; then
            malicious_file=false
            case "$file" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                malicious_file=true;;
            esac

            if grep -qiE 'virus|trojan|malware|worm|ransomware' "$file"; then
                malicious_file=true
            fi

            if [ "$malicious_file" = true ]; then
                echo "$file is malicious and it is DELETED"
                cp "$file" "$malicious/"
                rm "$file"
            fi
        fi
    done
}

while true
do
    ls -l "$dir" > "$new"
    if [ ! -f "$last" ];
    then
        scan_dir
        ls -l "$dir" > "$last"
    fi

    if ! cmp -s "$new" "$last"; 
    then
        scan_dir
        cp "$new" "$last"
    fi
    sleep "$sec"
done