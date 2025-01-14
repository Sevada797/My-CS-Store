#!/bin/bash

<<comment
"
This Sub-domain enumeration script includes these tools
1. Sub-finder
2. assetfinder
3. findomain
4. crtsh
5. Chaos
"
comment

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# Check if the user provided a filename argument
if [ $# -eq 0 ]; then
    echo "+ Usage: $0 <filename>"
    echo "+ Required Tools :
           1. Sub-finder  : https://github.com/Findomain/Findomain?tab=readme-ov-file
           2. assetfinder : https://github.com/tomnomnom/assetfinder
           3. Findomain   : https://github.com/Findomain/Findomain?tab=readme-ov-file
           4. crtsh       : https://github.com/Raunaksplanet/My-CS-Store/blob/main/Bug%20Bounty/Custom%20Tools/CRTsh"
    exit 1
elif [ ! -f "$1" ]; then
    echo "File '$1' does not exist."
    exit 1
fi

file_path="$PWD/$1"

# Sub-finder
echo -e "${RED}1. Sub-Finder${NC}"
subfinder -dL "$file_path" -silent -all -recursive | anew 1;

# assetfinder
echo -e "${GREEN}2. Asset-Finder${NC}"
cat "$file_path" | assetfinder -subs-only | anew 2;

# findomain
echo -e "${YELLOW}3. Findomain${NC}"
findomain  -f "$file_path" | grep -oE '([a-zA-Z0-9]+\.){1,}[a-zA-Z]{2,}' | anew 3;

# crtsh
echo -e "${BLUE}4. CRTsh${NC}"
crtsh -f "$file_path" | tee 4;

# chaos
echo -e "${PURPLE}5. Chaos${NC}"
echo "Enter program name or press enter to skip chaos tool: "
read user_input

# Store the input in a variable
program_name="$user_input"

if [ -n "$user_input" ]; then
    if [ ! -d "Chos-subdomains" ]; then
        mkdir Chos-subdomains
    fi

    if [ -d "Chos-subdomains" ]; then
        wget "https://chaos-data.projectdiscovery.io/index.json" && \
        cat index.json | grep "URL" | sed 's/"URL": "//;s/",//' | grep "$program_name" | \
        while read host; do
            wget -P Chos-subdomains "$host"
        done && \
        cd Chos-subdomains && \
        for i in $(ls -1 | grep .zip$); do
            unzip "$i"
        done && \
        rm *.zip && \
        cat *.txt >> alltargets.txt
    else
        echo "Failed to create directory Chos-subdomains"
    fi
else
    echo "No input provided."
fi

cat 1 2 3 4 | anew sub.txt;
rm -r 1 2 3 4;

echo -e "${CYAN}6. Htppx{NC}"
httpx -probe -sc -title -location -td -nc -l sub.txt  -o httpx-response1.txt;
cat httpx-response1.txt | grep -v '\[FAILED\]'  | anew httpx-response.txt;
rm httpx-response1.txt;
