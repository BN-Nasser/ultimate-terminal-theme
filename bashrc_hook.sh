# WezTerm & Starship Dynamic Theme Configuration
# This ensures Starship and the dynamic colors only run inside WezTerm
if [ -n "$WEZTERM_PANE" ]; then
    function _update_random_arrow() {
        # Deep, non-neon colors (Red, Green, Yellow, Blue, Purple, Aqua, Orange)
        local colors=("204;36;29" "152;151;26" "215;153;33" "69;133;136" "177;98;134" "104;157;106" "214;93;14")
        local c=${colors[$RANDOM % 7]}
        export STARSHIP_RANDOM_ARROW=$(printf "\\033[1;38;2;%sm╰─❯\\033[0m" "$c")
    }
    
    # Prepend our function to PROMPT_COMMAND so it runs before Starship draws the prompt
    PROMPT_COMMAND="_update_random_arrow; ${PROMPT_COMMAND:-}"
    
    # Initialize Starship
    eval "$(starship init bash)"
fi
