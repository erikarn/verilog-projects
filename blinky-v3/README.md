This is a blinky but for the upduino v3 board.


Based on the tutorial from https://blog.idorobots.org/entries/upduino-fpga-tutorial.html .

* I've populated the up5k.pcf
* I've put the PWM version of this into blinky.v

$ apio init -b upduino2 -p .
$ apio verify
$ apio build
$ apio upload

