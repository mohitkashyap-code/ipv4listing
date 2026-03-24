#!/bin/bash

# ===== Strict Mode =====
set -euo pipefail
SUCCESS=false

# ===== Colors =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===== Temp file =====
TMP_FILE=$(mktemp)
OUTPUT_FILE="ip_list.txt"

# ===== Cleanup =====
cleanup() {
    if [[ "$SUCCESS" = false ]]; then
        [[ -f "$TMP_FILE" ]] && rm -f "$TMP_FILE"
        echo -e "\n${YELLOW}⚠️ Cleaned up temporary data.${NC}"
    fi
}

# ===== Trap signals =====
trap 'echo -e "\n${RED}❌ Interrupted. Exiting safely.${NC}"; cleanup; exit 1' INT
trap cleanup EXIT

# ===== Banner =====
clear
echo -e "${CYAN}"
echo "======================================"
echo "        IPv4 Listing Generator        "
echo "======================================"
echo -e "${NC}"

# ===== Guide =====
echo -e "${YELLOW}Guide:${NC}"
echo "• Enter values between 0–255"
echo "• IPv4 format is A.B.C.D"
echo "• Start must be ≤ End"
echo "• Ctrl+C anytime to cancel safely"
echo ""

# ===== Safe read =====
safe_read() {
    local prompt=$1
    local var
    if ! read -r -p "$prompt -> " var; then
        echo -e "\n${RED}❌ Input cancelled. Exiting.${NC}"
        exit 1
    fi
    echo "$var"
}

# ===== Validation: single octet =====
get_valid_octet() {
    local label=$1
    local value

    while true; do
        value=$(safe_read "$label")

        [[ -z "$value" ]] && {
            echo -e "${RED}❌ Empty input not allowed.${NC}"
            continue
        }

        if ! [[ "$value" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}❌ Must be a number between 0–255.${NC}"
            continue
        fi

        if (( value < 0 || value > 255 )); then
            echo -e "${RED}❌ Must be between 0–255.${NC}"
            continue
        fi

        REPLY=$value
        return
    done
}

# ===== Validation: range =====
get_valid_range() {
    local start_label=$1
    local end_label=$2
    local start end

    while true; do
        get_valid_octet "$start_label"
        start=$REPLY

        get_valid_octet "$end_label"
        end=$REPLY

        if (( end < start )); then
            echo -e "${RED}❌ End must be ≥ Start (${start}).${NC}"
            continue
        fi

        RANGE_START=$start
        RANGE_END=$end
        return
    done
}

# ===== Generate IPs =====
generate_ips() {
    get_valid_range "A-Start" "A-End"
    A_START=$RANGE_START
    A_END=$RANGE_END

    get_valid_range "B-Start" "B-End"
    B_START=$RANGE_START
    B_END=$RANGE_END

    get_valid_range "C-Start" "C-End"
    C_START=$RANGE_START
    C_END=$RANGE_END

    get_valid_range "D-Start" "D-End"
    D_START=$RANGE_START
    D_END=$RANGE_END

    TOTAL=$(( (A_END-A_START+1)*(B_END-B_START+1)*(C_END-C_START+1)*(D_END-D_START+1) ))

    if (( TOTAL > 1000000 )); then
        echo -e "${YELLOW}⚠️ Large output: $TOTAL IPs${NC}"
        confirm=$(safe_read "Continue? (Yes/No)")
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
        [[ "$confirm" =~ ^(y|yes)$ ]] || exit 1
    fi

    echo -e "${CYAN}⚙️ Generating $TOTAL IPs...${NC}"

    {
    for ((a=A_START; a<=A_END; a++)); do
        for ((b=B_START; b<=B_END; b++)); do
            for ((c=C_START; c<=C_END; c++)); do
                for ((d=D_START; d<=D_END; d++)); do
                    printf "%d.%d.%d.%d\n" "$a" "$b" "$c" "$d"
                done
            done
        done
    done
    } >> "$TMP_FILE"

    echo -e "${GREEN}✔ Range added.${NC}"
}

# ===== Main loop =====
while true; do
    generate_ips

    while true; do
        choice=$(safe_read "Add another list (Yes/No)")
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        case "$choice" in
            y|yes)
                break
                ;;
            n|no)
                break 2
                ;;
            *)
                echo -e "${RED}❌ Enter Yes or No.${NC}"
                ;;
        esac
    done
done

# ===== Prevent empty output =====
if [[ ! -s "$TMP_FILE" ]]; then
    echo -e "${RED}❌ No IPs generated. Exiting.${NC}"
    exit 1
fi

# ===== Deduplicate =====
sort -u "$TMP_FILE" -o "$TMP_FILE"

# ===== Output file =====
input_file=$(safe_read "Output file name (default: ip_list.txt)")

if [[ -n "$input_file" ]]; then
    OUTPUT_FILE="$input_file"
fi

# ===== Overwrite protection =====
while true; do
    if [[ ! -e "$OUTPUT_FILE" ]]; then
        break
    fi

    echo -e "${YELLOW}⚠️ File exists: $OUTPUT_FILE${NC}"
    confirm=$(safe_read "Overwrite? (Yes/No)")
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

    case "$confirm" in
        y|yes)
            break
            ;;
        n|no)
            OUTPUT_FILE=$(safe_read "Enter new file name")
            ;;
        *)
            echo -e "${RED}❌ Enter Yes or No.${NC}"
            ;;
    esac
done

mv "$TMP_FILE" "$OUTPUT_FILE"
SUCCESS=true

LINES=$(wc -l < "$OUTPUT_FILE")

echo -e "${GREEN}✅ IP list saved: $OUTPUT_FILE${NC}"
echo -e "${CYAN}📊 Total IPs generated: $LINES${NC}"

# AUTHOR : Mohit Kashyap
