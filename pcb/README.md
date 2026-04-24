# Printed Circuit Board Files

## Board Version 2 Changes
Board version 1 is out of date in a few areas (the current working prototype has or needs these changes). 
- The current power regulator ([TPS63070](C109322-TPS63070RNMR.pdf)) is weak and burns out. This component will need to be replaced in the next version of the board, potentially by a [HT7533-1](https://jlcpcb.com/partdetail/HoltekSemicon-HT75331/C14289) LDO. This is comparable to what is currently soldered onto the board. Note: there are multiple capacitors, resistors, and inductors that are used only by this component and will also need to be removed. See the [datasheet](C109322-TPS63070RNMR.pdf) and EasyEDA files.
- The bottom ToF sensor leaves little room for a velcro strap, so it could be moved, or the frame CAD file could be modified to accommodate.
- The green LED is painfully bright and could use a larger resistor to dim it.
- Resistor 13 on the board has been halved by a soldered-on parallel resistor of equal value. This creates a 1/3 voltage divider, bringing the 2C 7.4V battery voltage into a readable range for the ESP32. Thus, on board version 2, R13 should be replaced with a 50K Ohm resistor.
Some other optional changes include:
- Connecting the ToF interrupt pins to the ESP32 for marginally faster sensor response.
- Moving the MPU6050 IMU to its own I2C line.
- Switching GPIO 23 to GPIO 16. The motor 4 PWM pin failed in testing and was swapped to pin 16. This should likely be made a permanent hardware change. See [this commit](https://github.com/Team-Wingfeather/fcl_senior_design/commit/29bd241f75058da32211addb992e50635beb5c23) that patches the software.

## Board Files

The `Gerber`, `CPL`, and `BOM` files can be used to order board version 1 from [JLCPCB](https://cart.jlcpcb.com/quote) (probably don't). To modify the design, use the files in the `EasyEDA` directory and set up an account with [EasyEDA](https://easyeda.com/). The current board revision is `PCB_FCL_Drone_v0.0.13_FAB`.

## Resources

Datasheets for many of the current components can be found in `resources/datasheets` and examples of drones that Wingfeather is based on are located in `resources/hardware_examples`.