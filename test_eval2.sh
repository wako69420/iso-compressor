path1="/Users/chris/Downloads/PSP\ FILES/game\ files/Worms\ -\ Open\ Warfare\ 2\ \(USA\) "
path2="'/Users/chris/Downloads/PSP FILES/game files/Worms - Open Warfare 2 (USA)' "
path3="/Users/chris/Downloads/PSP FILES/game files/Worms - Open Warfare 2 (USA)"

clean_path() {
    # Remove surrounding single/double quotes, trailing spaces, and all backslashes
    echo "$1" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' -e 's/\\//g' | awk '{$1=$1};1'
}

echo "1: $(clean_path "$path1")"
echo "2: $(clean_path "$path2")"
echo "3: $(clean_path "$path3")"
