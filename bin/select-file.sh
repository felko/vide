path=`realpath $3`
if [ -f "$path" ]; then
    selected=`@brootSelectFile@ --cmd ":select $(basename $path)" "$(dirname $path)"`
else
    selected=`@brootSelectFile@`
fi
if [ -n "$selected" ]; then
    @kks@ send -s $1 -c $2 edit-or-buffer "$selected"
else
    @kks@ send -s $1 -c $2 echo "no file selected"
fi
