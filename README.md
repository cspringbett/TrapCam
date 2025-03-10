# TrapCam
The TrapCam repository contains instructions and software to construct a TrapCam.

This version works with WittyPi 4. Please clone branch implement_picamera, NOT main, for proper function.

# Initial set up
#
The Raspberry Pi uses a microSD card as it's "internal" drive, on which
the Linux-based Raspbian OS will be installed. I recommend using the
"Lite" version of the OS - which lacks the GUI - but the TrapCam
software should also work with the GUI version of the OS. If you are technologically challenged, use the full GUI version.

Firstly, you need to format your microSD as FAT or FAT32. Next, use
BlenaEtcher to flash the most recent Raspbian OS image to the microSD card. 32 bit will work with any Raspberry Pi, while 64 bit is for Raspbery Pi 4s and newer. Once flashed,
remove the microSD from your computer and insert it into the rPi while
it's unplugged.

Plug in a keyboard and a monitor, and then plug in the rPi. Be sure the
monitor is on before you plug in the rPi, otherwise the rPi won't output
to the screen.


# Configure the rPI
You'll probably be asked to log in upon first boot. Username = pi,
Password = raspberry

Once logged in, run "sudo raspi-config" to access the configuration
tool, and alter these settings:
1. Change User Password
	* Change the password from the default
2. Network Options
	* Change hostname to "trapcam" (if you are building more than one,
	  it might be useful to number them sequentially, i.e., "trapcam1", "trapcam2", etc.)
3. Boot Options
    * Desktop/CLI - set to "Console autologin"
    * Wait for network at boot: No
4. Localisation Options (skip if you used GUI version of Raspbian, as you set this up already):
    * Change timezone to your timezone
    * Change keyboard layout to the keyboard you are using (likely standard US English)
5. Interface Options
    * Enable Camera Interface: No
    * Using the Python API to the camera requires the legacy camera stack to be deactivated.

Use the right arrow to select "Finish", and reboot.

Once rebooted, run "sudo apt update", then sudo apt upgrade" to update
packages. After updating/upgrading, you'll need to re-run "sudo raspi-config" and reset
the rPi to boot to "Console autologin" again (#3 above) and reboot.

Once up-to-date, you need to install a few packages and add-ons that the TrapCam
software depends on. Run "sudo apt install git" to install Git (this is just in case, as git should come installed already), and "sudo apt install fbi"
to install framebuffer, and then reboot (I know, I know, it's a lot of rebooting...)

Next, install WiringPi using git. In your home directory (if you're unsure of where that
is or worry that you aren't there, simply "cd $HOME" or "cd ~"), clone WiringPi by
running "git clone https://github.com/WiringPi/WiringPi.git". That will download the
WiringPi toolset into a WiringPi directory in your $HOME directory. Move into the
WiringPi directory ("cd WiringPi/"), and run "./build" to compile the WiringPi tools.

To control rPi's duty cycle, we'll use the WittyPi 4 HAT, but first we need to install
the WittyPi software. DO NOT ATTACH THE WITTY PI BEFORE INSTALLING THE SOFTWARE. Move
back into $HOME, and run  "wget http://www.uugear.com/repo/WittyPi4/install.sh"
to download the installer. Run "sudo sh install.sh" to install the software, and
reboot yet again. Once the software is installed, you can power off the rPi and attach
the WittyPi. If you'd like, you can "sudo rm install.sh" to keep your $HOME
directory clean.

Finally, you need to install the TrapCam software using git. Move into $HOME, and run
"git clone https://github.com/cspringbett/TrapCam" to clone the software from the TrapCam
directory. Move into the TrapCam directory ("cd TrapCam/"), and run "sudo bash
installTrapCam.sh". This installer will copy the configs, services, and scripts to their
correct locations.

# Configuring Witty Pi
Turn off your raspberry pi by running "poweroff". Remove power source from pi and connect it to the WittyPi instead. If it doesn't power on immediately, click the button on the WittyPi. Once TrapCam is on, type "cd wittypi" to enter the wittypi directory. From there, run "sh wittypi.sh" to bring up the WittyPi configuration tool. If the WittyPi is not detected, ensure you have a coin cell battery installed in the board, reboot, and try again. Once WittyPi is detected, edit the following settings:

1. Syncronize network time. Do this once while Pi is connected to internet via ethernet. RTC should take of timekeeping after that.
2. Set over/below temperature action to disabled. You don't want it shutting off becasue it gets hot/cold.
3. Set low voltage threshold to 0 or disabled for same reason.
   
In "View/change other settings"

4. Set default state to "ON" (This will ensure the camera turns on when power is connected, very important)
5. Set dummy load duration to "15." This is optional, but its a good way of ensuring the Pi is continuing to draw power from the battery bank.

These settings should be saved after they are initially set, so Witty should be good to go after that.

# Schedule Scripts

The TrapCam software comes with default schedule scripts that duty cycle the rPi. The
first schedule (TrapCam_duty_cycle.wpi) turns the rPi on during the day between the hours of
05:00 and 20:00 and then turns it off. Videos are recorded in 5 minute video files. This is an update
from the jack-butler version, as the constant cycling on/off on 5 minute intervals can eventually 
result in the camera missing its wake up.

You can also swap to the original 5 minutes on the 10s schedule -
that is, at :00, :10, :20 minutes, etc. past the hour, 24 hours a day. Simply switch set 
continuous = 0 in the .bashrc file, un-comment the original TrapCam_duty_cycle.wpi schedule
and comment out the new instructions. Reboot and check the wittypi.sh to ensure schedules were
copied correctly.

The other schedule (TrapCam_8AM_wakeup.wpi) is used once battery limitations preclude 
using underwater lights, and runs the rPi on the same duty cycle above, just between the hours 
of 7AM and 7PM.

These schedule scripts provide good temporal coverage throughout the day, but users can
create their own schedule scripts if they so choose. The WittyPi user's manual can be
found at http://www.uugear.com/doc/WittyPi_UserManual.pdf and provides good info on how
to create unique schedule scripts. As long as the script is named "TrapCam_duty_cycle.wpi",
the TrapCam script will copy it to the correct location and load that duty cycle.

# Lighting for nighttime video

Light control has been modified from the jack-butler version. Light control is found in the TrapCam.sh script, and is run off a simple if/else statement. Do modify light operating hours, simply change the numbers in the if else statement. For example, 
# -----------------------------------------------------------------------
# Turn on lights, if necessary
# -----------------------------------------------------------------------
if [ $(date +%H) -ge **19** ] || [ $(date +%H) -lt **7** ]; then
	echo "Time is between 19:00 and 07:00. Turning on lights..." |& tee -a "${rf}"

	gpio mode 25 out
	gpio write 25 1

else
	echo "It's daytime; no need for lights..." |& tee -a "${rf}"

	gpio mode 25 out
	gpio write 25 0 # for good measure

This turns the light on between 19:00 (7PM) and 07:00 (7AM) and turns them off outside those hours.


