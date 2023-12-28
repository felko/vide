define-command vide-select-file %{
    evaluate-commands %sh{
        zellij run --close-on-exit --floating --cwd $(dirname "$kak_buffile") --name select -- @selectFile@ $kak_session $kak_client
    }
}

map -docstring "Select file" global file f ': vide-select-file<ret>'

set-option window modelinefmt '%val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}}'
