# interface
set-option global modelinefmt '%val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}}'
set-option global startup_info_version 20250101
set-option global ui_options \
    terminal_assistant=clippy \
    terminal_status_on_top=false \
    terminal_set_title=false \
    terminal_enable_mouse=true \
    terminal_change_colors=true \
    terminal_padding_char=
source @theme@

add-highlighter global/ number-lines -relative

# editing options
set-option global tabstop 2
set-option global scrolloff 5,10


# general commands

define-command edit-or-buffer -params 0.. %{
   evaluate-commands %sh{
        if [ -n "$1" ]; then
            if [ -e "$2" ] || [ $2 -eq 0 ]; then
                for buf in "$kak_buflist"; do
                    if [ "$buf" == "$1" ]; then
                        echo buffer "$1"
                        exit
                    fi
                done
                echo edit "$1"
            else
                echo edit "$1" "$2"
            fi
        fi
   }
}

# user modes
declare-user-mode file
declare-user-mode buffer
map -docstring "file" global user f ': enter-user-mode file<ret>'
map -docstring "buffer" global user b ': enter-user-mode buffer<ret>'


## file

define-command -docstring 'Select a file to open' file-select %{
    evaluate-commands %sh{
        zellij run --close-on-exit --floating --cwd $(dirname "$kak_buffile") --name select -- @selectFile@ $kak_session $kak_client
    }
}

define-command -docstring 'Select a directory in which to cd' file-select-directory %{
    evaluate-commands %sh{
        zellij run --close-on-exit --floating --cwd $(dirname "$kak_buffile") --name select -- @selectDirectory@ $kak_session $kak_client
    }
}

map -docstring "select" global file f ': file-select<ret>'
map -docstring "cd" global file d ': file-select-directory<ret>'


## buffer

define-command -docstring 'Select a buffer to open' buffer-select %{
    evaluate-commands %sh{
        zellij run --close-on-exit --floating --name select -- @selectBuffer@ $kak_session $kak_client
    }
}

map -docstring "select" global buffer b ': buffer-select<ret>'
map -docstring "delete" global buffer q ': delete-buffer<ret>'
map -docstring "scratch" global buffer s ': edit -scratch<ret>'
map -docstring "debug" global buffer d ': edit -debug<ret>'

