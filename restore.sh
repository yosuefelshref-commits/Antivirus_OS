#!/bin/bash
if [ "$#" -ne 2 ];
then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir="$1"
malicious="$2"

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

echo "Malicious files:"
for i in "${!files[@]}";
do
    echo "$((i + 1)). ${files[$i]}"
done

read -p "Choose a file number:" choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
    echo "Invalid choice."
    exit 1
fi

index=$((choice - 1))
file="${files[$index]}"

echo "1. Restore to $dir"
echo "2. Permanently delete"
echo "3. Leave as-is and return to list"

read -p "Choose an option:" action

case "$action" in
    1)
        mv "$file" "$dir/"
        echo "Restored $file to $dir."
        break
        ;;
    2)
        rm "$file"
        echo "Permanently deleted $file."
        break
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