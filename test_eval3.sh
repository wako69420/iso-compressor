clean_path() {
    local p=$(echo "$1" | sed -e 's/[[:space:]]*$//')
    p=$(echo "$p" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//')
    p=$(echo "$p" | sed -e 's/\\//g')
    echo "$p"
}

path1="/Users/chris/Downloads/PSP\ FILES/game\ files/Worms\ -\ Open\ Warfare\ 2\ \(USA\) "
path2="'/Users/chris/Downloads/PSP FILES/game files/Worms - Open Warfare 2 (USA)' "
path3="/Users/chris/Downloads/PSP FILES/game files/Worms - Open Warfare 2 (USA)"

echo "1: $(clean_path "$path1")"
echo "2: $(clean_path "$path2")"
echo "3: $(clean_path "$path3")"
