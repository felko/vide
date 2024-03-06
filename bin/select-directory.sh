if [ -f "$3" ]; then
    selected="$(@brootSelectDirectory@ $3)"
else
    selected="$(@brootSelectDirectory@)"
fi
if [ -n "$selected" ]; then
    @kks@ send -s $1 -c $2 change-directory "$selected"
else
    @kks@ send -s $1 -c $2 echo "no directory selected"
fi
