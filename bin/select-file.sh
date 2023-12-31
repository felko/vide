export KKS_SESSION="$1"
export KKS_CLIENT="$2"
selected=`@brootSelectFile@ --cmd ":focus $3"`
if [ -n "$selected" ]; then
    @kks@ send edit-or-buffer "$selected"
else
    @kks@ send echo "no file selected"
fi
