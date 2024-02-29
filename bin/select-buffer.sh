selected=`@kks@ get %val{buflist} | @fzf@`
if [ -n "$selected" ]; then
    @kks@ send -s $1 -c $2 buffer "$selected"
else
    @kks@ send -s $1 -c $2 echo "no buffer selected"
fi
