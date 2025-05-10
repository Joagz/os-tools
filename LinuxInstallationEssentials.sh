#!/bin/bash

# Function to handle errors and exit the script gracefully
function handle_error {
    echo "An error occurred. Exiting..."
    exit 1
}

# Install Visual Studio Code
echo "Downloading Visual Studio Code .deb package from https://go.microsoft.com/fwlink/?LinkID=760868"
echo "..."

file_name=$(wget -nv -t 20 --content-disposition "https://go.microsoft.com/fwlink/?LinkID=760868" 2>&1 | cut -d\" -f2) || handle_error

echo "Successfully downloaded $file_name"

sudo apt install ./$file_name || handle_error

echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections || handle_error

sudo apt-get install wget gpg -y || handle_error
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg || handle_error
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg || handle_error
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null || handle_error
rm -f packages.microsoft.gpg

sudo apt install apt-transport-https -y || handle_error
sudo apt update || handle_error
sudo apt install code -y || handle_error  # or code-insiders

echo "\n\nInstalling ROS2 Humble Hawksbill, TexLive, Python3, CMake, Git/GitCli\n\n"

# Set the locale to en_US.UTF-8
locale  # check for UTF-8
sudo apt update && sudo apt install locales -y || handle_error
sudo locale-gen en_US en_US.UTF-8 || handle_error
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 || handle_error
export LANG=en_US.UTF-8

locale  # verify settings

# Install necessary software-properties-common and repositories
sudo apt install software-properties-common -y || handle_error
sudo add-apt-repository universe -y || handle_error

# Install curl and ROS2 keys
sudo apt update && sudo apt install curl -y || handle_error
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg || handle_error

# Add ROS2 repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null || handle_error

# Install ROS2 and other packages
sudo apt update && sudo apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools \
  octave \
  python3 \
  texlive-full \
  build-essential \
  cmake \
  git \
  gh \
  python3-flake8-blind-except \
  python3-flake8-builtins \
  python3-flake8-class-newline \
  python3-flake8-comprehensions \
  python3-flake8-deprecated \
  python3-flake8-import-order \
  python3-flake8-quotes \
  python3-pytest-repeat \
  python3-pytest-rerunfailures || handle_error

# Set up the ROS2 workspace
mkdir -p ~/ros2_humble/src || handle_error
cd ~/ros2_humble || handle_error
vcs import --input https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos src || handle_error

# Perform system upgrade
sudo apt upgrade -y || handle_error

# ROS2 dependencies setup
sudo rosdep init || handle_error
rosdep update || handle_error
rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers" || handle_error

# Add ROS2 setup to .bashrc
echo "source ~/ros2_humble/install/local_setup.bash" >> ~/.bashrc || handle_error

echo "Installations completed successfully!! -- Joaquín"
