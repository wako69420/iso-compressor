path="/Users/chris/Downloads/PSP\ FILES/game\ files/Worms\ -\ Open\ Warfare\ 2\ \(USA\)"
echo "Original: $path"

# Try eval
# evaluated=$(eval echo $path) # This fails with syntax error near unexpected token `(' if not quoted properly?
evaluated=$(eval echo "$path")
echo "Eval Echo: $evaluated"

# Try sed
sedded=$(echo "$path" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' -e 's/\\//g')
echo "Sedded: $sedded"
