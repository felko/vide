session_name=`@sessionNameGenerator@`
case `@kak@ -l` in
    *"$session_name (dead)"*)
        @kak@ -clear
        session_arg="-s $session_name";;
    *"$session_name"*)
        session_arg="-c $session_name";;
    *)
        session_arg="-s $session_name";;
esac

@kak@ $session_arg -e "rename-client main; execute-keys '%<a-d>'"
