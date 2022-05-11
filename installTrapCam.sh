#! /bin/bash

# installTrapCam.sh

# Author: Jack Butler
# Created: March 2019
# Last Edit: J Butler Apr 2020
# Comments: Fixes wittypi 3 directory changes

# Installs TrapCam dependencies, shell scripts, and configs

# ----------------------------------------------------------
# Get users home dir, not roots
# ----------------------------------------------------------
uhome="$(getent passed $SUDO_USER | cut -d: -f6)"
user=$SUDO_USER

# ----------------------------------------------------------
# Check whether git and fbi are installed
# ----------------------------------------------------------
git --version
if [ $? -ne 0 ]; then
	echo "Git is not installed. Please install git, reboot and try again."
	echo "Exiting TrapCam install..."
	exit 1
fi

fbi --version
if [ $? -ne 0 ]; then
	echo "fbi package is not currently installed."
	echo "Installing fbi package now..."
	apt update
	echo "y" | apt install fbi
fi

# ----------------------------------------------------------
# Install TrapCam Software
# ----------------------------------------------------------
clear
echo ' .___________..______          ___      .______     ______     ___      .___  ___. '
echo ' |           ||   _  \        /   \     |   _  \   /      |   /   \     |   \/   | '
echo ' `---|  |----`|  |_)  |      /  ^  \    |  |_)  | |  ,----   /  ^  \    |  \  /  | '
echo '     |  |     |      /      /  /_\  \   |   ___/  |  |      /  /_\  \   |  |\/|  | '
echo '     |  |     |  |\  \----./  _____  \  |  |      |  `----./  _____  \  |  |  |  | '
echo '     |__|     | _| `._____/__/     \__\ | _|       \______/__/     \__\ |__|  |__| '

# ----------------------------------------------------------
# Copy configs
# ----------------------------------------------------------
echo "Copying config files. Previous cmdline, config, bashrc, and rclocal files are stored as .old"

cp /boot/cmdline.txt /boot/cmdline.txt.old
echo "$(cat /boot/cmdline.txt) logo.nologo quiet splash loglevel=0" > /boot/cmdline.txt
cp /boot/config.txt /boot/config.txt.old
cp $uhome/TrapCam/configs/config.txt /boot/config.txt

cp $uhome/.bashrc $uhome/.bashrc.old
cp $uhome/TrapCam/configs/.bashrc /home/pi/

cp /etc/rc.local /etc/rc.local.old
cp $uhome/TrapCam/configs/rc.local /etc/rc.local

echo "Done copying configs"
# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------
echo "Copying and installing services..."

cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old
cp $uhome/TrapCam/services/autologin@.service /etc/systemd/system/autologin@.service

cp $uhome/TrapCam/services/image_on_shutdown.service /etc/systemd/system/image_on_shutdown.service
cp $uhome/TrapCam/services/splashscreen.service /etc/systemd/system/splashscreen.service

systemctl enable splashscreen.service
systemctl start splashscreen.service

systemctl enable image_on_shutdown.service
systemctl start image_on_shutdown.service

echo "Done creating boot and shutdown services"
# ----------------------------------------------------------
# Copy schedule scripts
# ----------------------------------------------------------
echo "Copying wittyPi schedule scripts..."

cd $uhome/wittypi/schedules

cp $uhome/TrapCam/schedules/TrapCam_* .

cd $uhome
cp $uhome/wittypi/schedules/TrapCam_duty_cycle.wpi $uhome/wittypi/schedule.wpi

echo "Done copying schedules..."
# ----------------------------------------------------------
# Copy shell scripts
# ----------------------------------------------------------
echo "Copying TrapCam shell scripts..."

cp $uhome/TrapCam/scripts/TrapCam.sh .
cp $uhome/TrapCam/scripts/schedule_duty_cycle.sh .

chmod +x TrapCam.sh
chmod +x schedule_duty_cycle.sh

echo "Done"
# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
cp $uhome/TrapCam/splash.png /etc/splash.png

# ----------------------------------------------------------
# Make USB mount location
# ----------------------------------------------------------
echo "Creating USB mount directory..."
cd /media

if [ ! -d "DATA" ]; then
	mkdir DATA
	chown -R $user:$user /media/DATA
else
	echo "Mount directory already exists"
fi

# ----------------------------------------------------------
# Finish install
# ----------------------------------------------------------
cd $uhome
echo ""
echo "-------------------------------------------------------------------------------"
echo ""
echo "TrapCam software has been installed and will start upon reboot"
echo ""
echo "-------------------------------------------------------------------------------"

exit 0
