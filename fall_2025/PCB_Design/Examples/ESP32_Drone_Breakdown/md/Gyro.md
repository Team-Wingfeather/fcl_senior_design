## Components
- **MPU6050 IMU**
## Connections
- 3.3VC is the regulated power supply
- Pin AD0 determines address
- Pin CLKIN is for an external oscillator - unneeded since the chip has an internal oscillator.
- FSYNC ties sensor sampling to an external input signal - not required
- REGOUT is used by the chip - needs a 0.1 µF capacitor to GND
- CPOUT is similar to REGOUT - needs a 0.22 µF capacitor to GND
- VLOGIC is tied to the I2C voltage that the ESP32 expects
- The I2C lines have pull-up resistors on the end - check chip specs for sizes.
## Notes
- Something maybe not considered in this model is the fact that we want the gyro at the center of gravity.
- Keep the I2C wires as short as possible