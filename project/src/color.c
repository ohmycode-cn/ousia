/* project/src/color.c */
#include "color.h"

const struct COLOR color = {
    .RESET = "\033[0;0m",
    .DARK = "\033[0;30m",
    .RED = "\033[0;31m",
    .GREEN = "\033[0;32m",
    .YELLOW = "\033[0;33m",
    .BLUE = "\033[0;34m",
    .PURPLE = "\033[0;35m",
    .CYAN = "\033[0;36m",
    .WHITE = "\033[0;37m",
};

const struct BKCLR bkclr1 = {
    .RESET = "\033[0;0m",
    .DARK = "\033[0;100m",
    .RED = "\033[0;101m",
    .GREEN = "\033[0;102m",
    .YELLOW = "\033[0;103m",
    .BLUE = "\033[0;104m",
    .PURPLE = "\033[0;105m",
    .CYAN = "\033[0;106m",
    .WHITE = "\033[0;107m",
};

const struct BKCLR bkclr = {
    .RESET = "\033[0;0m",
    .DARK = "\033[0;40m",
    .RED = "\033[0;41m",
    .GREEN = "\033[0;42m",
    .YELLOW = "\033[0;43m",
    .BLUE = "\033[0;44m",
    .PURPLE = "\033[0;45m",
    .CYAN = "\033[0;46m",
    .WHITE = "\033[0;47m",
};
