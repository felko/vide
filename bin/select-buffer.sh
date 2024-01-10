selected=`@kks@ get %val{buflist} | @fzf@`
if [ -n "$selected" ]; then
    @kks@ send buffer "$selected"
else
    @kks@ send echo "no buffer selected"
fi
