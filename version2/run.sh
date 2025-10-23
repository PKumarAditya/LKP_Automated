#!/bin/bash

distro=$(cat /etc/os-release | grep ^ID= | cut -d'=' -f2)
user=$(echo $USER)
loc=$(pwd)
installer=""
pip_command=""
STOP_FILE="/tmp/stop_lkp_script"

# Function to check if the stop file exists
check_exit() {
    if [ -f "$STOP_FILE" ]; then
        echo "Stop file detected. Exiting script..."
        exit 0
    fi
}

# Signal handling to allow graceful exit on Ctrl+C
trap "echo 'Caught SIGINT. Exiting...'; exit 0" SIGINT

#finding the package manager available on the system
check_package_manager() {
    if command -v apt &> /dev/null; then
        installer="apt"
    elif command -v apt-get &> /dev/null; then
        installer="apt-get"
    elif command -v dnf &> /dev/null; then
        installer="dnf"
    elif command -v yum &> /dev/null; then
        installer="yum"
    elif command -v pacman &> /dev/null; then
        installer="pacman"
    elif command -v zypper &> /dev/null; then
        installer="zypper"
    elif command -v apk &> /dev/null; then
        installer="apk"
    else
        echo "Package Manager couldn't be recognized. Please contact the maintainer for support."
        exit 1
    fi
}
check_package_manager

check_package_existence() {
	pkg=$1
	if ! command -v $pkg; then
		$installer install -y $pkg &> /dev/null
	fi
}

# Print out the Heading
pip install pyfiglet &> /dev/null || pip3 install pyfiglet &> /dev/null
if command -v python3 &> /dev/null; then
	pip_command="python3"
elif command -v python &> /dev/null; then
	pip_command="python"
else
	echo "LKP TESTS"
fi

$pip_command -m pyfiglet "LKP TESTS"

# Ignore the old sudo entries and capture the new password
export HISTIGNORE='*sudo -S*'


# Get the distribution name
echo " "
echo "/////////////=== To stop this current process of creating LKP, use CTRL+C ===//////////////"
echo " "
echo "DISTRO FOUND: $(cat /etc/os-release | grep -i pretty | sed 's/PRETTY_NAME=//')"
echo "CURRENT USER: $user"
echo "Package Manager Found on the system: $installer"
echo "Current working directory: $loc"

check_package_existence git
check_package_existence make

git clone https://github.com/intel/lkp-tests.git &> /dev/null
mkdir /root/.lkp-tests
mv $loc/lkp-tests/* /root/.lkp-tests/

if command -v lkp; then
	echo "LKP Found on the system in location: $(which lkp)"
	echo "Checking the working of lkp......"
	test_lkp
else
	echo "lkp not found"
	echo "Installing LKP on the system"
	#Installing packages needed by lkp on the system
	$loc/lkp-deps.sh

fi


