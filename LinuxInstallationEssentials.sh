#!/bin/bash

# Function to handle errors and exit the script gracefully
function handle_error {
    echo "An error occurred during installation..."
}

# Function to ask yes/no questions
function ask_question {
    while true; do
        read -p "$1 (y/n): " choice
        case "$choice" in
            [Yy]*) echo "yes"; return ;;
            [Nn]*) echo "no"; return ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# ==============================
# User Prompts
# ==============================
echo "Ubuntu 22.04 Installation essentials -- Joaquín Gómez"
echo "Select which components to install:"
INSTALL_VSCODE=$(ask_question "1. Install Visual Studio Code?")
INSTALL_LATEX=$(ask_question "2. Install LaTeX (texlive-full)?")
INSTALL_CMAKE_GIT=$(ask_question "4. Install CMake, Git, and GitHub CLI?")
INSTALL_ROS2=$(ask_question "5. Install ROS2 Humble Hawksbill?")
INSTALL_DOCKER=$(ask_question "5. Install Docker and Docker Desktop?")

echo "=============================="
echo "INSTALLING: Python3 and Related Tools"
echo "=============================="
sudo apt update || handle_error
sudo apt install python3 python3-pip -y || handle_error
sudo apt install python3-flake8-docstrings \
    python3-pytest-cov \
    python3-flake8-blind-except \
    python3-flake8-builtins \
    python3-flake8-class-newline \
    python3-flake8-comprehensions \
    python3-flake8-deprecated \
    python3-flake8-import-order \
    python3-flake8-quotes \
    python3-pytest-repeat \
    python3-pytest-rerunfailures -y || handle_error

# ==============================

# ==============================
# Install Docker & Docker Desktop
# ==============================
if [ "$INSTALL_DOCKER" == "yes" ]; then

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Checking docker is successfully running"
sudo docker run hello-world
fi


# ==============================
# Install Visual Studio Code
# ==============================
if [ "$INSTALL_VSCODE" == "yes" ]; then
    echo "=============================="
    echo "INSTALLING: Visual Studio Code"
    echo "=============================="
    echo "Downloading Visual Studio Code .deb package..."
    file_name=$(wget -nv -t 20 --content-disposition "https://go.microsoft.com/fwlink/?LinkID=760868" 2>&1 | cut -d\" -f2) || handle_error

    echo "Installing $file_name..."
    sudo apt install ./$file_name || handle_error

    echo "Setting up Microsoft repo..."
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections || handle_error

    sudo apt-get install wget gpg -y || handle_error
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg || handle_error
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg || handle_error
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null || handle_error
    rm -f packages.microsoft.gpg

    sudo apt install apt-transport-https -y || handle_error
    sudo apt update || handle_error
    sudo apt install code -y || handle_error
fi

# ==============================
# Install LaTeX
# ==============================
if [ "$INSTALL_LATEX" == "yes" ]; then
    echo "=============================="
    echo "INSTALLING: TeX Live (Full)"
    echo "=============================="
    sudo apt update || handle_error
    sudo apt install texlive-full -y || handle_error
fi

# Install CMake, Git, GitHub CLI
# ==============================
if [ "$INSTALL_CMAKE_GIT" == "yes" ]; then
    echo "=============================="
    echo "INSTALLING: CMake, Git, GitHub CLI"
    echo "=============================="
    sudo apt update || handle_error
    sudo apt install build-essential cmake git gh -y || handle_error
fi

# ==============================
# Install ROS2 Humble Hawksbill
# ==============================
if [ "$INSTALL_ROS2" == "yes" ]; then
    echo "=============================="
    echo "INSTALLING: ROS2 Humble Hawksbill"
    echo "=============================="

    # Locale setup
    sudo apt update && sudo apt install locales -y || handle_error
    sudo locale-gen en_US en_US.UTF-8 || handle_error
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 || handle_error
    export LANG=en_US.UTF-8

    # Add necessary repos and keys
    sudo apt install software-properties-common -y || handle_error
    sudo add-apt-repository universe -y || handle_error
    sudo apt update && sudo apt install curl -y || handle_error
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg || handle_error

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
    sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null || handle_error

    # Install ROS2
    sudo apt update && sudo apt upgrade

    sudo apt install ros-humble-desktop -y
    sudo apt install ros-humble-ros-base -y
    sudo apt install ros-dev-tools -y
    
    # Add to .bashrc
    echo "source /opt/ros/humble/setup.sh" >> ~/.bashrc || handle_error
fi

echo -e "\nAll selected installations completed successfully! -- Joaquín"

