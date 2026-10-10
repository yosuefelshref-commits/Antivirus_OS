#!/bin/bash
if [ "$#" -ne 2 ];
then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir="$1"
malicious="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
whitelist="$script_dir/whitelist.txt"
touch "$whitelist"

if [ ! -d "$dir" ]; then
    echo "Error: directory does not exist."
    exit 1
fi

if [ ! -d "$malicious" ]; then
    echo "Error: malicious directory does not exist."
    exit 1
fi

while true
do
shopt -s nullglob
files=("$malicious"/*)

if [ "${#files[@]}" -eq 0 ]; then
    echo "No malicious files to review."
    exit 0
fi

echo "Choose a file:"
for i in "${!files[@]}";
do
    echo "$((i + 1)): ${files[$i]}"
done

read -p "Choose a file number:" choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
    echo "Invalid choice."
    exit 1
fi

index=$((choice - 1))
file="${files[$index]}"

echo "For $(basename "$file"):"
echo "1: Restore this file back into dir (it was a false positive)"
echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
echo "3: Go back"

read -p "Choose an option:" action

case "$action" in
    1)
        filename=$(basename "$file")
        if mv "$file" "$dir/";
        then
            if ! grep -Fxq "$filename" "$whitelist";
            then
            echo "$filename" >> "$whitelist"
            fi
            echo "Restored $filename to $dir."
        fi
    ;;
    2)
        filename=$(basename "$file")
        rm "$file"
        echo "$filename permanently deleted."
        ;;
    3)
        echo "Leaving file as-is."
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
done