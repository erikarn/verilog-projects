
ntsc hacks
==========

This is an NTSC output generator crimed from the NTSC text/graphics
generator from https://github.com/emeb/up5k_basic .

It's designed to be run on the upduino 3.0 board from tinyvision.ai .
It uses the on-board 12MHz oscillator and uses a PLL to step it up
to 16/32MHz.

The resistor DAC is pretty easy:

v3 ---- 390 ohm ----+
                    |
v2 ---- 820 ohm ----+
                    |
v1 ---- 1.8 kohm ---+
                    |
v0 ---- 3.6 kohm ---+
                    +-- composite output

                    +-- ground
                    |
                   GND

Building
--------

"apio build"

Flashing
--------

"apio upload"

PLL calculation
---------------

Clone this: https://github.com/YosysHQ/icestorm/

and build / run icepll to generate the PLL config block!

