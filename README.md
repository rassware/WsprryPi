# WsprryPi

I forked this little piece of software to fix some issues I had with my RaspberryPi 4.

To create a QRPp transmitter out of your Raspi, you need to install some hardware stuff for the GPIO pins

```bash
sudo apt-get install libraspberrypi-dev raspberrypi-kernel-headers
```

To access the GIO pins without root access, you should be in the ```gpio``` group.

```bash
sudo adduser $USER gpio
```

### Update: February 2022

Changed makefile options to properly compile on Raspberry Pi OS Bullseye
Don't know why it was necessary, but without this change the code compiled but did not run on Bullseye
new version:
wspr: mailbox.o nhash.o wspr.cpp mailbox.h
$(CXX) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) $(PI_VERSION) -I/opt/vc/include -L/opt/vc/lib -o wspr mailbox.o nhash.o wspr.cpp -lbcm_host

gpioclk: gpioclk.cpp
$(CXX) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) $(PI_VERSION) -I/opt/vc/include -L/opt/vc/lib -o gpioclk -lbcm_host gpioclk.cpp -lbcm_host

old version:
wspr: mailbox.o nhash.o wspr.cpp mailbox.h
$(CXX) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) $(PI_VERSION) -I/opt/vc/include -L/opt/vc/lib -lbcm_host mailbox.o nhash.o wspr.cpp -o wspr

gpioclk: gpioclk.cpp
$(CXX) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) $(PI_VERSION) -I/opt/vc/include -L/opt/vc/lib -lbcm_host gpioclk.cpp -o gpioclk

Also changed 80m center frequency from 3,594,100 to 3,570,100

### Update: Sept 2020

Removed compiler specific selection macros and used the library <bcm_host.h> to
determine key Pi Specific parameters (F_XTAL, F_PLLD_CLK, and PERI_BASE) within the code.
Once compiled, this code should work on any Pi version.
No longer requires compiling on same the Pi version as it is run.
Removed external routine "getbaseaddr" and "pi_make.sh"

---

Raspberry Pi LF/MF/HF/VHF WSPR transmitter with GPIO control (GPIO 7 -> 11)
The intent of the GPIO control would be to control relays to switch in band specific Low Pass Filters
Modeled after QRP Labs "Ultimate relay-switched LPF kit".

Add "getbaseaddr", an external routine to determine the Pi version based on base address.
Includes "pi_make.sh" (must be made executable) which checks for "getbaseaddr" and
installs it in /usr/local/bin if not there, then runs "make" and "sudo make install"
This application "MUST BE" compiled on the same Pi configuration as you run it.

---

Raspberry Pi bareback LF/MF/HF/VHF WSPR transmitter
NB: This fork of the original software has been modified to run on a Pi-4B with Raspbian Buster.

Makes a very simple WSPR beacon from your RasberryPi by connecting GPIO
port to Antenna (and LPF), operates on LF, MF, HF and VHF bands from
0 to 250 MHz.

Compatible with the original Raspberry Pi, Pi Zero, the Raspberry Pi 2/3, and
the Pi 4.

> [!CAUTION]
> 2017-04-21 Do note that some users have been reporting lockups with recent OS versions. I have not been able to reproduce the problems on my RPI1 and RPI3 running the latest Jessie-Lite. <https://github.com/JamesP6000/WsprryPi/issues/6#issuecomment-296233932>

## Installation / Update

Download and compile code:

```bash
sudo apt-get install git
git clone https://github.com/rassware/WsprryPi.git
cd WsprryPi
make clean
make
sudo make install
```

For uninstall execute:

```bash
sudo make uninstall
```

## Usage (WSPR --help output)

```bash
wspr --help
```


If you specify 6-characters, it will send them (older version alternated)

Note that 'callsign', 'locator', and 'tx_power_dBm' are simply used to fill
in the appropriate fields of the WSPR message. Normally, tx_power_dBm should
be 10, representing the signal power coming out of the Pi. Set this value
appropriately if you are using an external amplifier.

## Radio licensing / RF

In order to transmit legally, a HAM Radio License is REQUIRED for running
this experiment. The output is a square wave so a low pass filter is REQUIRED.
Connect a low-pass filter (via decoupling C) to GPIO4 (GPCLK0) and Ground pin
of your Raspberry Pi, connect an antenna to the LPF. The GPIO4 and GND pins
are found on header P1 pin 7 and 9 respectively, the pin closest to P1 label
is pin 1 and its 3rd and 4th neighbour is pin 7 and 9 respectively. See this
link for pin layout: <http://elinux.org/RPi_Low-level_peripherals>

Examples of low-pass filters can be found here:
<http://www.gqrp.com/harmonic_filters.pdf>
TAPR makes a very nice shield for the Raspberry Pi that is pre-assembled,
performs the appropriate filtering for the 20m band, and also increases
the power output to 20dBm! Just connect your antenna and you're good-to-go!
<https://www.tapr.org/kits_20M-wspr-pi.html>

The expected power output is 10mW (+10dBm) in a 50 Ohm load. This looks
neglible, but when connected to a simple dipole antenna this may result in
reception reports ranging up to several thousands of kilometers.

As the Raspberry Pi does not attenuate ripple and noise components from the
5V USB power supply, it is RECOMMENDED to use a regulated supply that has
sufficient ripple supression. Supply ripple might be seen as mixing products
products centered around the transmit carrier typically at 100/120Hz.

DO NOT expose GPIO4 to voltages or currents that are above the specified
Absolute Maximum limits. GPIO4 outputs a digital clock in 3V3 logic, with a
maximum current of 16mA. As there is no current protection available and a DC
component of 1.6V, DO NOT short-circuit or place a resistive (dummy) load
straight on the GPIO4 pin, as it may draw too much current. Instead, use a
decoupling capacitor to remove DC component when connecting the output dummy
loads, transformers, antennas, etc. DO NOT expose GPIO4 to electro- static
voltages or voltages exceeding the 0 to 3.3V logic range; connecting an
antenna directly to GPIO4 may damage your RPi due to transient voltages such
as lightning or static buildup as well as RF from other transmitters
operating into nearby antennas. Therefore it is RECOMMENDED to add some form
of isolation, e.g. by using a RF transformer, a simple buffer/driver/PA
stage, two schottky small signal diodes back to back.

## TX Timing

This software is using system time to determine the start of WSPR
transmissions, so keep the system time synchronised within 1sec precision,
i.e. use NTP network time synchronisation or set time manually with date
command. A WSPR broadcast starts on an even minute and takes 2 minutes for
WSPR-2 or starts at :00,:15,:30,:45 and takes 15 minutes for WSPR-15. It
contains a callsign, 4-digit Maidenhead square locator and transmission
power.  Reception reports can be viewed on Weak Signal Propagation Reporter
Network at: <http://wsprnet.org/drupal/wsprnet/spots>

## Calibration

As of 2017-02, NTP calibration is enabled by default and produces a
frequency error of about 0.1 PPM after the Pi has temperature stabilized
and the NTP loop has converged.

Frequency calibration is REQUIRED to ensure that the WSPR-2 transmission
occurs within the narrow 200 Hz band. The reference crystal on your RPi might
have an frequency error (which in addition is temp. dependent -1.3Hz/degC
@10MHz). To calibrate, the frequency might be manually corrected on the
command line or a PPM correction could be specified on the command line.

NTP calibration:
NTP automatically tracks and calculates a PPM frequency correction. If you
are running NTP on your Pi, you can use the --self-calibration option to
have this program querry NTP for the latest frequency correction before
each WSPR transmission. Some residual frequency error may still be present
due to delays in the NTP measurement loop and this method works best if your
Pi has been on for a long time, the crystal's temperature has stabilized,
and the NTP control loop has converged.

AM calibration:
A practical way to calibrate is to tune the transmitter on the same frequency
of a medium wave AM broadcast station; keep tuning until zero beat (the
constant audio tone disappears when the transmitter is exactly on the same
frequency as the broadcast station), and determine the frequency difference
with the broadcast station. This is the frequency error that can be applied
for correction while tuning on a WSPR frequency.

Suppose your local AM radio station is at 780kHz. Use the --test-tone option
to produce different tones around 780kHz (eg 780100 Hz) until you can
successfully zero beat the AM station. If the zero beat tone specified on the
command line is F, calculate the PPM correction required as:
ppm=(F/780000-1)*1e6 In the future, specify this value as the argument to the
\--ppm option on the comman line. You can verify that the ppm value has been
set correction by specifying --test-tone 780000 --ppm <ppm> on the command
line and confirming that the Pi is still zero beating the AM station.

## PWM Peripheral

The code uses the RPi PWM peripheral to time the frequency transitions
of the output clock. This peripheral is also used by the RPi sound system
and hence any sound events that occur during a WSPR transmission will
interfere with WSPR transmissions. Sound can be permanently disabled
by editing /etc/modules and commenting out the snd-bcm2835 device.

## Example usage:

Brief help screen

```bash
 wspr --help
```

Transmit a constant test tone at 780 kHz.

```bash
sudo wspr --test-tone 780e3
```

Using callsign N9NNN, locator EM10, and TX power 33 dBm, transmit a single WSPR transmission on the 20m band using NTP based frequency offset calibration.

```bash
sudo wspr N9NNN EM10 33 20m
```

The same as above, but without NTP calibration:

```bash
sudo wspr --free-running N9NNN EM10 33 20m
```

Specify a 6 character Maidenhead grid locator with TX power 20 dBm on 20m:

```bash
sudo wspr K0WBG DM65rc 20 20m
```

Transmit a WSPR transmission slightly off-center on 30m every 10 minutes for a total of 7 transmissions, and using a fixed PPM correction value.

```bash
sudo wspr --repeat --terminate 7 --ppm 43.17 N9NNN EM10 33 10140210 0 0 0 0
```

Transmit repeatedly on 40m, use NTP based frequency offset calibration, and add a random frequency offset to each transmission to minimize collisions with other transmitters.

```bash
sudo wspr --repeat --offset --self-calibration N9NNN EM10 33 40m
```

## Reference documentation:

- <http://www.raspberrypi.org/wp-content/uploads/2012/02/BCM2835-ARM-Peripherals.pdf>
- <http://www.scribd.com/doc/127599939/BCM2835-Audio-clocks>
- <http://www.scribd.com/doc/101830961/GPIO-Pads-Control2>
- <https://github.com/mgottschlag/vctools/blob/master/vcdb/cm.yaml>
- <https://www.kernel.org/doc/Documentation/vm/pagemap.txt>
- <https://physics.princeton.edu/pulsar/k1jt/WSPR_2.0_User.pdf> (specifically Appendix B)

## Credits

Credits goes to Oliver Mattos and Oskar Weigl who implemented PiFM [1]
based on the idea of exploiting RPi DPLL as FM transmitter.

Dan MD1CLV combined this effort with WSPR encoding algorithm from F8CHK,
resulting in WsprryPi a WSPR beacon for LF and MF bands.

Guido PE1NNZ [pe1nnz@amsat.org](mailto:pe1nnz@amsat.org) extended this effort with DMA based PWM
modulation of fractional divider that was part of PiFM, allowing to operate
the WSPR beacon also on HF and VHF bands.  In addition time-synchronisation
and double amount of power output was implemented.

James Peroulas [james@peroulas.com](mailto:james@peroulas.com) added several command line options, a
makefile, improved frequency generation precision so as to be able to
precisely generate a tone at a fraction of a Hz, and added a self calibration
feature where the code attempts to derrive frequency calibration information
from an installed NTP deamon.  Furthermore, the TX length of the WSPR symbols
is more precise and does not vary based on system load or PWM clock
frequency.

Michael Tatarinov for adding a patch to get PPM info directly from the
kernel.

Retzler András (HA7ILM) for the massive changes that were required to
incorporate the mailbox code so that the RPi2 and RPi3 could be supported.

Mathias Gibbens (K0WBG) added support for sending 6 character Maidenhead grid
locators to the program as well as performing some code cleanup.

 1. [PiFM code from](http://www.icrobotics.co.uk/wiki/index.php/Turning_the_Raspberry_Pi_Into_an_FM_Transmitter)
 2. [Original WSPR Pi transmitter code by Dan](https://github.com/DanAnkers/WsprryPi)
 3. [Fork created by Guido](https://github.com/threeme3/WsprryPi)
 4. [This fork created by James](https://github.com/JamesP6000/WsprryPi)
 5. [This fork created by Corrie](https://github.com/griffc/WsprryPi)
 6. [This fork created by Rob](https://github.com/kb8rco/WspryPi)

