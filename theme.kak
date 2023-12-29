evaluate-commands %sh{
# All colors
export black="rgb:20063b"
export white="rgb:f8f9fa"
export whitedim="rgb:eedcd2"
export blue="rgb:306a88"
export red="rgb:ba3b46"
export orange="rgb:ff882d"
export green="rgb:4f9216"
export gray="rgb:888888"
export purple="rgb:89489d"

export sel="rgba:508aa8"
export sel2="rgba:508aa8"
export sel_cursor="rgba:508aa8"
export sel_cursor_eol="rgba:508aa8"

printf "%s\n" "
# Code
set-face global title              default,default+bu
set-face global header             default,default+b
set-face global bold               default,default+b
set-face global italic             default,default+i
set-face global mono               default,default
set-face global block              default,default
set-face global link               default,default+u
set-face global bullet             default,default
set-face global list               default,default
# Markup
set-face global value              $purple,default
set-face global type               default,default
set-face global variable           default,default
set-face global module             default,default
set-face global function           default,default
set-face global string             $green,default
set-face global keyword            default,default+b
set-face global operator           $orange,default+d
set-face global attribute          default,default+i
set-face global comment            $gray,default
set-face global documentation      $green,default
set-face global meta               $red,default
set-face global builtin            $blue,default
# Deprecated?
set-face global error              $red,default+c
set-face global identifier         default,default
# Interface

set-face global Default            $black,$white
set-face global PrimarySelection   default,${sel}44
set-face global SecondarySelection default,${sel2}44
set-face global PrimaryCursor      ${bg},${sel_cursor}44+fg
set-face global SecondaryCursor    ${bg},${sel_cursor}44+fg
set-face global PrimaryCursorEol   ${black},${sel_cursor_eol}44+fg
set-face global SecondaryCursorEol ${black},${sel_cursor_eol}44+fg
set-face global MenuBackground     default,${whitedim}
set-face global MenuForeground     +r@MenuBackground
set-face global MenuInfo           Information
set-face global Information        $black,$white
set-face global Error              $red,default
set-face global DiagnosticError    $red,default+c
set-face global DiagnosticWarning  $orange,default+c
set-face global StatusLine         default,default
set-face global StatusLineMode     default,default
set-face global StatusLineInfo     default,default
set-face global StatusLineValue    default,default
set-face global StatusCursor       ${bg},${sel_cursor}44+fg
set-face global Prompt             default,default
set-face global BufferPadding      default,default
set-face global Builtin            default,default
set-face global LineNumbers        $gray,default
set-face global LineNumberCursor   $red,default+r
set-face global LineNumbersWrapped $white,default
set-face global MatchingChar       default,default+u
set-face global Whitespace         $gray,default+d
set-face global WrapMarker         $gray,default+d
set-face global Markup             default,default
"
}
