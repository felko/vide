export KKS_SESSION="$1"
export KKS_CLIENT="$2"
selected=`@brootSelectDirectory@ --only-folders --cmd ":focus $3"`
if [ -n "$selected" ]; then
    @kks@ send change-directory "$selected"
else
    @kks@ send echo "no directory selected"
fi
