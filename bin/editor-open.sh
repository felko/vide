export KKS_SESSION=`eval "$SESSION_NAME_GENERATOR"`
@kks@ send edit-or-buffer $@
@zellij@ action go-to-tab-name edit
