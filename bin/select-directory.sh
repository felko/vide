if [ -f "$1" ]; then
    selected=`@brootSelectDirectory@ --cmd ":select $(dirname $1)"`
else
    selected=`@brootSelectDirectory@`
fi
if [ -n "$selected" ]; then
    @kks@ send change-directory "$selected"
else
    @kks@ send echo "no directory selected"
fi
