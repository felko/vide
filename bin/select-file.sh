if [ -f "$3" ]; then
    selected="$(@brootSelectFile@ --cmd :close_preview $3)"
else
    selected="$(@brootSelectFile@)"
fi
if [ -n "$selected" ]; then
    @kks@ send -s $1 -c $2 edit-or-buffer "$selected"
else
    @kks@ send -s $1 -c $2 echo "no file selected"
fi
