S56CM - K56CM-MB
================

Patches for hackintosh - Asus-S56CM, K56CM motherboard.

Installation
============

1.  Download Yosemite from the Appstore. You can use an already existing installation or virtual machine. I used a virtual machine in VMWare.

    Open DiskUtility. Format an 8GB+ USB to Mac-OSX (Journalled)
    a. Make the USB partition GUUID.
    b. Change the name of the partition to "INSTALL" without quotes.
    c. Click apply and it will begin formatting it.

2. Open terminal and type: sudo /Applications/Install\ OS\ X\ Yosemite.app/Contents/Resources/createinstallmedia --volume /Volumes/INSTALL --applicationpath /Applications/Install\ OS\ X\ Yosemite.app --nointeraction

    Wait until it is finished installing it to your USB.

3. Install clover to the USB and an EFI partition will mount. Go to the EFI partition and copy the EFI folder from this github to it.

4. Restart the computer and keep pressing the escape button. Choose the "Setup" option to get into the BIOS.
    a. Disable VTd
    b. Disable FastBoot and Enable CSM.
    c. Disable Secure Boot.
    d. Go to USB Configuration and change disable XHCI.
    e. Save the changed by pressing F10 and selecting "Yes".

5. Keep pressing escape button and select your USB. You should now see the installation screen.
    a. Click continue ONCE.
    b. Open Disk Utility and format a hard-drive (one that you want to install Yosemite on).
    c. Name it "OSX" and set it to GUUID format.
    d. When it finishes formatting the drive, continue the installation.

6. Once the installation is finished, boot back into the USB.
    a. Mount the USB's EFI partition by using the following commands: mkdir /Volumes/EFI then use sudo mount -t msdos /dev/disk0s1 /Volumes/EFI to mount it.
    b. Copy the EFI partition to your desktop and Eject the USB.
    c. Install Clover onto the Yosemite HardDrive.
    d. Copy the EFI folder from the desktop to the clover EFI partition.
    e. Copy the /EFI/System/Library/Extensions kexts to /System/Library/Extensions.
    e. Reboot into the Yosemite HardDrive and you should now have a fully working Yosemite installation.

7. Go into your BIOS and restore default settings. Then disable SecureBoot. Now your computer is back to normal and you can boot Yosemite as well.
    a. You should have audio, wifi (AR9285), graphics, HDMI, usb 3.0, bluetooth (AR3011), etc.. working..
    b. You can now clean up the installation files and delete whatever you don't need.
