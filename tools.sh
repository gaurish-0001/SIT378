# Date 10-08-2024
#Name : Gaurish Bhatia


#!/bin/bash

# Define color codes for formatted output in the terminal
RED='\033[0;31m'          # Red color
GREEN='\033[0;32m'        # Green color
YELLOW='\033[1;33m'       # Yellow color
NC='\033[0m'              # No Color (reset to default)

# Define the log file path where the script logs messages
LOG_FILE="$HOME/security_tools.log"

# Function to display a help menu to guide users on using various security tools
display_help() {
    echo -e "${YELLOW}Interactive Help Menu:${NC}"
    echo "1) osv-scanner: Scan a directory for vulnerabilities"
    echo "   - Download: https://github.com/google/osv-scanner"
    echo "2) snyk cli: Test code locally or monitor for vulnerabilities"
    echo "   - Download: https://snyk.io/download/"
    echo "   - Run code test locally: snyk code test <directory>"
    echo "   - Monitor for vulnerabilities: snyk monitor <directory> --all-projects"
    echo "3) brakeman: Scan a Ruby on Rails application for security vulnerabilities"
    echo "   - Download: https://github.com/presidentbeef/brakeman"
    echo "4) nmap: Network exploration and security auditing tool"
    echo "   - Download: https://nmap.org/download.html"
    echo "5) nikto: Web server scanner"
    echo "   - Download: https://cirt.net/nikto/"
    echo "6) LEGION: Automated web application security scanner"
    echo "   - Download: https://github.com/GoVanguard/legion"
    echo "7) OWASP ZAP: Web application security testing tool"
    echo "   - Download: https://github.com/zaproxy/zaproxy/releases"
    echo "8) Help: Display this help menu"
    echo "9) Exit: Exit the script"
}

# Function to log messages with a timestamp to the log file
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Function to check for updates for the installed security tools
check_updates() {
    log_message "Checking for updates..."
    
    # Update APT package lists if they haven't been updated in the last day
    if [ $(sudo find /var/lib/apt/lists -type f -mtime +1 | wc -l) -gt 0 ]; then
        sudo apt update -qq
    fi
    
    # Update individual tools
    update_brakeman
    update_snyk
    update_owasp_zap
    update_nikto
    update_nmap
}

# Function to update Brakeman (a security scanner for Ruby on Rails applications)
update_brakeman() {
    sudo gem update brakeman > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log_message "Gems already up-to-date: brakeman"
    else
        log_message "Failed to update brakeman"
    fi
}

# Function to update OWASP ZAP (a web application security scanner)
update_owasp_zap() {
    if ! command -v zaproxy &> /dev/null; then
        sudo apt install -y zaproxy > /dev/null 2>&1
        log_message "OWASP ZAP installed"
    else
        # Check the installed version against the latest available version
        current_version=$(dpkg -s zaproxy | grep '^Version:' | awk '{print $2}')
        latest_version=$(apt-cache policy zaproxy | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y zaproxy > /dev/null 2>&1
            log_message "OWASP ZAP updated to version $latest_version"
        else
            log_message "OWASP ZAP is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Nikto (a web server scanner)
update_nikto() {
    if ! command -v nikto &> /dev/null; then
        sudo apt install -y nikto > /dev/null 2>&1
        log_message "Nikto installed"
    else
        # If Nikto is already installed, update it by cloning the latest version from GitHub
        cd /tmp
        if [ -d "nikto" ]; then
            sudo rm -rf nikto
        fi
        git clone https://github.com/sullo/nikto.git > /dev/null 2>&1
        cd nikto/program
        sudo cp nikto.pl /usr/local/bin/nikto > /dev/null 2>&1
        sudo chmod +x /usr/local/bin/nikto
        log_message "Nikto updated"
    fi
}

# Function to update Nmap (a network exploration and security auditing tool)
update_nmap() {
    if ! command -v nmap &> /dev/null; then
        sudo apt install -y nmap > /dev/null 2>&1
        log_message "Nmap installed"
    else
        # Check the installed version against the latest available version
        current_version=$(nmap --version | head -n 1 | awk '{print $3}')
        latest_version=$(apt-cache policy nmap | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y nmap > /dev/null 2>&1
            log_message "Nmap updated to version $latest_version"
        else
            log_message "Nmap is up-to-date (version $current_version)"
        fi
    fi
}

# Function to install Go (programming language) if not already installed
install_go() {
    echo -e "${YELLOW}Installing Go...${NC}"
    sudo apt update && sudo apt install -y golang-go
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Go installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install Go.${NC}"
        exit 1
    fi
}

# Function to install npm (Node.js package manager) if not already installed
install_npm() {
    echo -e "${YELLOW}Installing npm...${NC}"
    sudo apt update && sudo apt install -y npm
    if [ $? -eq 0 ]; then
        sudo chown -R $(whoami) ~/.npm
        echo -e "${GREEN}npm installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install npm.${NC}"
        exit 1
    fi
}

# Function to install Snyk CLI (a vulnerability scanner) if not already installed
install_snyk_cli() {
    if ! command -v npm &> /dev/null; then
        install_npm
    fi
    if ! command -v snyk &> /dev/null; then
        echo -e "${YELLOW}Installing snyk cli...${NC}"
        sudo npm install -g snyk
        echo -e "${GREEN}Snyk cli installed successfully!${NC}"
        echo -e "${YELLOW}Authenticating snyk...${NC}"
        echo -e "${RED}Please authenticate by clicking 'Authenticate' in the browser to continue.${NC}"
        snyk auth
    else
        echo -e "${GREEN}snyk cli is already installed.${NC}"
    fi
}

# Function to install Brakeman if not already installed
install_brakeman() {
    if ! command -v brakeman &> /dev/null; then
        echo -e "${YELLOW}Installing brakeman...${NC}"
        sudo gem install brakeman
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Brakeman installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install brakeman.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}brakeman is already installed.${NC}"
    fi
}

# Function to install osv-scanner (a vulnerability scanner) if not already installed
install_osv_scanner() {
    if ! command -v osv-scanner &> /dev/null; then
        echo -e "${YELLOW}Installing osv-scanner...${NC}"
        go install github.com/google/osv-scanner/cmd/osv-scanner@v1
        echo -e "${GREEN}osv-scanner installed successfully!${NC}"
        # Add osv-scanner to the user's PATH
        echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc
        source ~/.bashrc
    else
        echo -e "${GREEN}osv-scanner is already installed.${NC}"
    fi
}

# Function to install Nmap if not already installed
install_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${YELLOW}Installing nmap...${NC}"
        sudo apt update && sudo apt install -y nmap
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}nmap installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install nmap.${NC}"
            exit 1
        fi
    else
# Display message if nmap is already installed
echo -e "${GREEN}nmap is already installed.${NC}"
    fi
}

# Function to install nikto
install_nikto() {
    # Check if nikto is not installed
    if ! command -v nikto &> /dev/null; then
        # Display message indicating nikto installation
        echo -e "${YELLOW}Installing nikto...${NC}"
        # Update package list and install nikto
        sudo apt update && sudo apt install -y nikto
        # Check if the installation was successful
        if [ $? -eq 0 ]; then
            # Display success message
            echo -e "${GREEN}nikto installed successfully!${NC}"
        else
            # Display failure message and exit script
            echo -e "${RED}Failed to install nikto.${NC}"
            exit 1
        fi
    else
        # Display message if nikto is already installed
        echo -e "${GREEN}nikto is already installed.${NC}"
    fi
}

# Function to install LEGION
install_legion() {
    # Check if legion is not installed
    if ! command -v legion &> /dev/null; then
        # Display message indicating LEGION installation
        echo -e "${YELLOW}Installing LEGION...${NC}"
        # Update package list
        sudo apt update
        # Install legion
        sudo apt install -y legion
        # Check if the installation was successful
        if [ $? -eq 0 ]; then
            # Display success message
            echo -e "${GREEN}LEGION installed successfully!${NC}"
        else
            # Display failure message and exit script
            echo -e "${RED}Failed to install LEGION.${NC}"
            exit 1
        fi
    else
        # Display message if LEGION is already installed
        echo -e "${GREEN}LEGION is already installed.${NC}"
    fi
}

# Function to install OWASP ZAP
install_owasp_zap() {
    # Check if OWASP ZAP is not installed by checking its directory
    if [ ! -d "/opt/owasp-zap/" ]; then
        # Display message indicating OWASP ZAP installation
        echo -e "${YELLOW}Installing OWASP ZAP...${NC}"
        
        # Download OWASP ZAP tar file to /tmp directory
        wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -P /tmp
        # Check if the download was successful
        if [ $? -eq 0 ]; then
            # Create directory for OWASP ZAP in /opt
            sudo mkdir -p /opt/owasp-zap
            # Change ownership of the OWASP ZAP directory to the current user
            sudo chown -R $(whoami):$(whoami) /opt/owasp-zap
            # Extract the downloaded tar file to the OWASP ZAP directory
            tar -xf /tmp/ZAP_2.15.0_Linux.tar.gz -C /opt/owasp-zap/
            
            # Create a symbolic link for the OWASP ZAP executable in /usr/local/bin
            sudo ln -s /opt/owasp-zap/ZAP_2.15.0/zap.sh /usr/local/bin/zap

            # Check if the symbolic link creation was successful
            if [ $? -eq 0 ]; then
                # Display success message
                echo -e "${GREEN}OWASP ZAP installed successfully!${NC}"
            else
                # Display failure message and exit script
                echo -e "${RED}Failed to move OWASP ZAP.${NC}"
                exit 1
            fi
        else
            # Display failure message if download failed and exit script
            echo -e "${RED}Failed to download OWASP ZAP.${NC}"
            exit 1
        fi
    else
        # Display message if OWASP ZAP is already installed
        echo -e "${GREEN}OWASP ZAP is already installed.${NC}"
    fi
}

# Function to check for updates for various tools
check_updates() {
    # Prompt user to check for updates
    read -p "Do you want to check for updates? (y/n): " check_updates
    # If the user agrees to check for updates
    if [[ "$check_updates" == "y" ]]; then
        # Log message indicating update check
        log_message "Checking for updates..."
        # Update brakeman
        update_brakeman
        # Update OWASP ZAP
        update_owasp_zap
        # Update nikto
        update_nikto
        # Update nmap
        update_nmap
        # Display success message
        echo -e "${GREEN}Updates checked successfully.${NC}"
    else
        # Display message indicating skipping of updates check
        echo -e "${YELLOW}Skipping updates check.${NC}"
    fi
}

# Function to save vulnerabilities found by various tools to a file
save_vulnerabilities() {
    # Set the tool name to the first argument
    local tool=$1
    # Set the output file name based on the tool name
    local output_file="$tool-vulnerabilities.txt"
    # Determine the command to run based on the tool name
    case $tool in
        "osv-scanner")
            # Scan the directory using osv-scanner and save output to the file
            osv-scanner scan "./$directory" > "$output_file"
            ;;
        "snyk")
            # Run snyk code scan and save output to the file
            snyk code scan > "$output_file"
            ;;
        "brakeman")
            # Run brakeman scan and save output to the file
            sudo brakeman --force"$output_file"
            ;;
        "nmap")
            # Run nmap scan and save output to the file
            nmap -v -A "$url" > "$output_file"
            ;;
        "nikto")
            # Run nikto scan and save output to the file
            nikto -h "$url" > "$output_file"
            ;;
        "legion")
            # Run legion scan and save output to the file
            legion "$url" > "$output_file"
            ;;
    esac
    # Display the found vulnerabilities
    echo -e "${GREEN}Vulnerabilities found:${NC}"
    cat "$output_file"
    # Prompt user to save the vulnerabilities to a file
    read -p "Do you want to save the vulnerabilities to a file? (y/n) " save_to_file
    # If the user agrees to save the file
    if [[ "$save_to_file" == "y" ]]; then
        # Display message indicating the file has been saved
        echo -e "${GREEN}Vulnerabilities saved to $output_file${NC}"
    else
        # Display message indicating the file was not saved
        echo -e "${GREEN}Vulnerabilities not saved to a file.${NC}"
    fi
}    
# Main function to check and install tools
main() {
 
   # Initialize log file by clearing its contents
    echo "" > "$LOG_FILE"
    
    # Check if npm is installed; if not, install it
    if ! command -v npm &> /dev/null; then
        install_npm
    fi

    # Check if Go is installed; if not, install it
    if ! command -v go &> /dev/null; then
        install_go
    fi

    # Check and install osv-scanner
    install_osv_scanner

    # Check and install snyk CLI
    install_snyk_cli

    # Check and install brakeman
    install_brakeman

    # Check and install nmap
    install_nmap

    # Check and install nikto
    install_nikto

    # Check and install legion
    install_legion

    # Check and install OWASP ZAP
    install_owasp_zap
    
    # Check for updates for the installed tools
    check_updates

    # Display the help menu
    display_help
    
    # Start an infinite loop to keep the script running until the user exits
    while true; do
        # Display the help menu to the user
        display_help

        # Prompt the user to choose an option from the menu
        read -p "Choose an option (9 for help): " choice
        
        output=""
        # If the choice is not legion, ZAP, or help, ask the user if they want to save the results to a text file
        if [[ "$choice" -ne 6 && "$choice" -ne "9" && "$choice" -ne "7" ]]; then
            read -p "Do you want to output the results to a text file? Results are saved to /home/kali (y/n): " output_to_file
            if [[ "$output_to_file" == "y" ]]; then
                case $choice in
                    1) output="/home/kali/osv-scanner-results.txt" ;;  # Set the output file for osv-scanner
                    2) output="/home/kali/snyk-results.txt" ;;         # Set the output file for snyk
                    3) output="/home/kali/brakeman-results.txt" ;;     # Set the output file for brakeman
                    4) output="/home/kali/nmap-results.txt" ;;         # Set the output file for nmap
                    5) output="/home/kali/nikto-results.txt" ;;        # Set the output file for nikto
                esac
            fi
        fi

        # Handle the user's choice
        case $choice in
            1)
                # Run osv-scanner on the specified directory
                read -p "Enter directory to scan: " directory
                source ~/.bashrc
                if [[ "$output_to_file" == "y" ]]; then
                    osv-scanner --format table --output "$output" -r "$directory"
                else
                    osv-scanner --recursive "$directory"
                fi
                ;;
            2)
                # Run Snyk tests based on the user's choice
                read -p "Select Snyk option:
                1) Run code test locally
                2) Monitor for vulnerabilities and see results in Snyk UI
                Enter your choice (1/2): " snyk_option
                case $snyk_option in
                    1)
                        if [[ "$output_to_file" == "y" ]]; then
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk code test $directory > $output
                        else
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk code test $directory
                        fi
                        ;;
                    2)
                        if [[ "$output_to_file" == "y" ]]; then
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk monitor $directory --all-projects > $output
                        else
                            snyk monitor $directory --all-projects
                        fi
                        ;;
                    *)
                        # Handle invalid Snyk option choice
                        echo -e "${RED}Invalid choice!${NC}"
                        ;;
                esac
                ;;
            3)
                # Run Brakeman on the specified directory
                read -p "Enter directory to scan (current directory ./): " directory
                if [[ "$output_to_file" == "y" ]]; then
                    sudo brakeman "$directory" --force -o "$output"
                else
                    sudo brakeman "$directory" --force
                fi
                ;;
            4)
                # Run Nmap on the specified URL or IP address
                read -p "Enter URL or IP address to scan: " url
                if [[ "$output_to_file" == "y" ]]; then
                    nmap -oN "$output" "$url"
                else
                    nmap "$url"
                fi
                ;;
            5)
                # Run Nikto on the specified URL and port
                read -p "Enter URL and port to scan (Example: http://localhost:4200): " url
                if [[ "$output_to_file" == "y" ]]; then
                    nikto -h "$url" -o "$output"
                else
                    nikto -h "$url"
                fi
                ;;
            6)
                # Launch Legion
                sudo legion
                ;;
            7)
                # Run OWASP ZAP on the specified URL
                read -p "Enter URL and port to scan (Example: http://localhost:4200): " url
                zap -quickurl $url
                ;;
            8)
                # Display help menu
                display_help
                ;;
            9)
                # Exit the script
                echo -e "${YELLOW}Exiting...${NC}"
                exit 0
                ;;
            10)
                # Check for updates for the installed tools
                check_updates
                ;;
            11)
                # Exit the script with a log message
                echo -e "${YELLOW}Exiting...${NC}"
                log_message "Script ended"
                exit 0
                ;;
            12)
                # Handle invalid user input
                echo -e "${RED}Invalid choice, please try again.${NC}"
                log_message "Invalid user input"
                ;;
        esac
    done
}

# Execute the main function to start the script
main

