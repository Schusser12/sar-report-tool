#!/bin/bash

# --- Color codes ---
txtred='\e[0;31m'  # Red
txtwht='\e[0;37m'  # White
txtcyn='\e[0;36m'  # Cyan
txtylw='\e[0;33m'  # Yellow

outfile=""
run_all=false

print_header() {
    echo -e "\n===== $1 =====\n"
}

print_or_log() {
    if [[ -n "$outfile" ]]; then
        echo -e "$1" >> "$outfile"
    else
        echo -e "$1"
    fi
}

# --- Load Average ---
section_q() {
    print_or_log "$(print_header "LOAD AVERAGE")"
    print_or_log "$(printf "%-10s %-8s %-8s %-8s %-8s %-8s %-8s" "Label" "runq-sz" "plist-sz" "ldavg-1" "ldavg-5" "ldavg-15" "blocked")"
    for i in $(ls -ct /var/log/sa | grep sar | cut -d 'r' -f 2); do
        sar -q -f /var/log/sa/sa$i | awk 'NR>3 {printf "%-10s %-8s %-8s %-8s %-8s %-8s %-8s\n", $1, $2, $3, $4, $5, $6, $7}' | grep -i average >> "${outfile:-/dev/stdout}"
    done
}

# --- CPU Usage ---
section_u() {
    print_or_log "$(print_header "CPU USAGE")"
    print_or_log "$(printf "%-10s %-9s %-8s %-8s %-10s %-10s %-9s %-8s" "Label" "CPU" "%user" "%nice" "%system" "%iowait" "%steal" "%idle")"
    for i in $(ls -ct /var/log/sa | grep sar | cut -d 'r' -f 2); do
        sar -u -f /var/log/sa/sa$i | awk '{printf "%-10s %-9s %-8s %-8s %-10s %-10s %-9s %-8s\n", $1, $2, $3, $4, $5, $6, $7, $8}' | grep -i average >> "${outfile:-/dev/stdout}"
    done
}

# --- Memory Usage ---
section_r() {
    print_or_log "$(print_header "MEMORY USAGE")"
    print_or_log "$(printf "%-10s %-10s %-10s %-11s %-11s %-10s %-10s %-10s %-10s %-10s %-9s" "Label" "kbmemfree" "kbmemused" "%memused" "kbbuffers" "kbcached" "kbcommit" "%commit" "kbactive" "kbinact" "others")"
    for i in $(ls -ct /var/log/sa | grep sar | cut -d 'r' -f 2); do
        sar -r -f /var/log/sa/sa$i | awk '{printf "%-10s %-10s %-10s %-11s %-11s %-10s %-10s %-10s %-10s %-10s %-9s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11}' | grep -i average >> "${outfile:-/dev/stdout}"
    done
}

# --- Network Stats ---
section_n() {
    print_or_log "$(print_header "NETWORK STATS")"
    print_or_log "$(printf "%-10s %-10s %-15s %-15s %-10s %-10s" "Label" "IFACE" "rxpck/s" "txpck/s" "rxkB/s" "txkB/s")"
    for i in $(ls -ct /var/log/sa | grep sar | cut -d 'r' -f 2); do
        sar -n DEV -f /var/log/sa/sa$i | awk '{printf "%-10s %-10s %-15s %-15s %-10s %-10s\n", $1, $2, $3, $4, $5, $6}' | grep -i average >> "${outfile:-/dev/stdout}"
    done
}

# --- Disk I/O Stats ---
section_d() {
    print_or_log "$(print_header "DISK I/O STATS")"
    print_or_log "$(printf "%-10s %-10s %-10s %-10s %-10s %-10s" "Label" "DEV" "tps" "rd_sec/s" "wr_sec/s" "%util")"
    for i in $(ls -ct /var/log/sa | grep sar | cut -d 'r' -f 2); do
        sar -d -f /var/log/sa/sa$i | awk '{printf "%-10s %-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5, $9}' | grep -i average >> "${outfile:-/dev/stdout}"
    done
}

# --- Help Message ---
print_help() {
    echo -e "${txtwht}Usage: ${txtcyn}$0 [options]${txtwht}"
    echo ""
    echo -e "${txtwht}Flags:"
    echo -e "  ${txtcyn}-q${txtwht}        Show load averages"
    echo -e "  ${txtcyn}-u${txtwht}        Show CPU usage"
    echo -e "  ${txtcyn}-r${txtwht}        Show memory usage"
    echo -e "  ${txtcyn}-n${txtwht}        Show network interface statistics"
    echo -e "  ${txtcyn}-d${txtwht}        Show disk I/O statistics"
    echo -e "  ${txtcyn}-a${txtwht}        Run all sections and save to a report"
    echo -e "  ${txtcyn}-f <file>${txtwht} Specify output file (used with -a or any section)"
    echo -e "  ${txtcyn}-h${txtwht}        Show this help message"
    echo ""
    echo -e "${txtylw}Examples:"
    echo -e "  $0 -a                         Run all sections and save to ~/server_report-<timestamp>.txt"
    echo -e "  $0 -r                         Show memory usage only"
    echo -e "  $0 -a -f /tmp/my_report.txt  Run all and save to custom location${txtwht}"
    exit 0
}

# --- Argument Parser ---
while getopts 'qurndaf:h' opt; do
    case "$opt" in
        q) section_q ;;
        u) section_u ;;
        r) section_r ;;
        n) section_n ;;
        d) section_d ;;
        a) run_all=true ;;
        f) outfile="$OPTARG" ;;
        h) print_help ;;
        \?)
            echo -e "${txtred}Error: Invalid option${txtwht}"
            echo "Use -h to see available options."
            exit 1
            ;;
    esac
done

# If no flags were passed at all
if [[ $OPTIND -eq 1 ]]; then
    echo -e "${txtred}[!] No flags provided. Use ${txtcyn}-h${txtred} for help.${txtwht}"
    exit 1
fi

# --- Run All Sections ---
if $run_all; then
    outfile="${outfile:-$HOME/server_report-$(date +%F_%H%M).txt}"
    section_q
    section_u
    section_r
    section_n
    section_d
    echo -e "${txtwht}Report saved to: $outfile"
fi
