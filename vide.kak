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
# user modes
declare-user-mode file

map global user f ': enter-user-mode file<ret>

# file
define-command vide-select-file %{
    evaluate-commands %sh{
        zellij run --close-on-exit --floating --cwd $(dirname "$kak_buffile") --name select -- @selectFile@ $kak_session $kak_client
    }
}

map -docstring "Select file" global file f ': vide-select-file<ret>'


