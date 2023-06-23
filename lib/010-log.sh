log_warning() { echo -e "[\e[33mWARN\e[0m]:  \e[1m$*\e[0m"; }
log_error()  { echo -e "[\e[31mERROR\e[0m]: \e[1m$*\e[0m"; }
log_info() { echo -e "[\e[96mINFO\e[0m]:  \e[1m$*\e[0m"; }

export -f log_info log_error log_warning
