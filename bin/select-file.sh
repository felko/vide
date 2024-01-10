if [ -f "$1" ]; then
    selected=`@brootSelectFile@ --cmd ":focus $(dirname $1);:select $(basename $1)"`
else
    selected=`@brootSelectFile@`
fi
if [ -n "$selected" ]; then
    @kks@ send edit-or-buffer "$selected"
else
    @kks@ send echo "no file selected"
fi
