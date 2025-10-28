## IMU #complete
### Component
- [MPU-6050](https://jlcpcb.com/partdetail/TDKInvenSense-MPU6050/C24112)
	- JLCPCB Part #: C24112
### Connections
- 2 serial connections to the Microcontroller (IO47,IO48), (IO10, IO11)? 10k pull-up resistors to 3.3V on each
- VLOGIC needs to be tied directly high (3.3V, **NOT 5V**). LiteWing has denoising 100nF and 10nF caps here.
- CLKIN is grounded
- AD0 either grounded or grounded through a resistor
- REGOUT grounded through a 100nF cap
- FSYNC grounded
- VDD is tied to 3.3V. Litewing has it connected to the same denoising circuit as VLOGIC
- GND is grounded
- CPOUT is grounded through a 2.2nF cap
- LiteWing uses INT, but I think it's likely we won't
- The MINI CAM DRONE grounds EP, but LiteWing doesn't
- THIS IS ALL OF THE CONNECTIONS FOR THE MPU6050
### Considerations
- Keep it at the center of gravity
- Keep the I2C wires as short as possible

## Microcontroller #complete
- ESP32
- [ESP32_WROOM_32N4](https://jlcpcb.com/partdetail/EspressifSystems-ESP32_WROOM_32N4/C82899)
	- Currently using this one - probably good enough
	- JLCPCB Part #: C82899
- [ESP32_WROOM_32EN4](https://jlcpcb.com/partdetail/EspressifSystems-ESP32_WROOM_32EN4/C701341)
	- JLCPCB Part #: C701341
- [ESP32_WROOM_32EN16](https://jlcpcb.com/partdetail/EspressifSystems-ESP32_WROOM_32EN16/C701343)
	- JLCPCB Part #: C701343
- [ESP32_WROOM_32EN8](https://jlcpcb.com/partdetail/EspressifSystems-ESP32_WROOM_32EN8/C701342)
	- JLCPCB Part #: C701342

## UART Interface #complete
- CH340? - Extended part only
	- JLCPCB Part #: C968586
- There are no basic parts, so roll with the CH340.

## MOSFETs (for motors) #complete
- [AO3400A???](https://jlcpcb.com/partdetail/Alpha_OmegaSemicon-AO3400A/C20917)
	- Dr. Kohl said it looked pretty good, is a basic part
	- USE THE BASIC PART!!!
	- JLCPCB Part #: C20917
- LiteWing: IRLML6344TRPBF-HXY
	- JLCPCB Part #: C6285738
- MINI CAM DRONE: SI2302A-TP
	- JLCPCB Part #: C668996

## Freewheel diodes (for motors) #complete
- [SS14?](https://jlcpcb.com/partdetail/MDD_Microdiode_Semiconductor-SS14/C2480)
	- Dr. Kohl said this is better than the other one
	- JLCPCB Part #: C2480
- SS12 is what the MINI CAM DRONE uses, but this is not a basic part.
	- JLCPCB Part #: C432149
- 1N4148W is what LiteWing uses - THIS IS A BASIC PART!!!
	- JLCPCB Part #: C81598

## Capacitors (for motors) #complete
- Dr. Kohl said we need fast switching, probably ceramic capacitors
- LiteWing uses 1uF caps
	- JLCPCB Part #: C15849
	- Not Rocket science - go with this

## Buzzer #complete
- Unfortunately, no basic buzzers.
- [KLJ-7525-3627](https://jlcpcb.com/partdetail/KELIKING-KLJ_75253627/C189208) (MINI CAM DRONE)
	- JLPCB Part #: C189208
	- Make sure it's connected to a PWM pin!!!
	- Connect it to a MOSFET/BJT
- SAFETOWN (go with this)
	- JLCPCB #: C417430
	- Use MOSFET (see image) S8050
		- JLCPCB Part #:  C2146

## LEDs #complete
- Under the **Optoelectronics** section, there are 6 basic LEDs in various colors, one of which is sure to work
	- Green on when power is applied at all times - 3.3V, not bright - maybe a 2K$\Omega$
	- A couple other colors just for you - red, yellow 20mA is way too much - maybe 1mA. (2mA or less!)
	- Like 300-1k resistors

## C16 Pin connector #complete
- [TYPE-C16PIN?](https://jlcpcb.com/partdetail/SHOUHAN-TYPEC16PIN/C393939)
- Dr. Kohl likes this one
	- JLCPCB Part #: C393939

## Power Regulator #complete
- XC6220B331PR-G is extended (MINI CAM DRONE)
	- JLCPCB Part #: C3013658
- SPX3819M5-L-3-3/TR is extended (LiteWing)
	- JLCPCB Part #: C9055
- There are 6 basic components under **Voltage Regulators - Linear, Low Drop Out (LDO) Regulators** - hopefully one of these will work
	- C5446 - ChatGPT Recommended, but seems to have a lower current rating - USE THIS ONE!! - Dr. Kohl likes it. We will probably need around 150mA total
	- C6186
	- C14289

## ToF Sensors #complete
- [VL53L1CXV0FY/1](https://jlcpcb.com/partdetail/STMicroelectronics-VL53L1CXV0FY1/C190004)

## Battery Voltage Divider Resistors #complete
- 100k$\Omega$?
- Don't go less than 402
- 603s are fixable

## ESD Protection Array (From MINI CAM DRONE) #complete
- JLCPCB Part #: C7519


## Buttons #complete
- If you have the space, the little gold buttons are nice (basic). The other basic buttons will also work
- Dr. Kohl recommends having a switch for power
- [SK12D07VG5](https://jlcpcb.com/partdetail/SHOUHAN-SK12D07VG5/C431548)
- At least 500mA (absolute min of 200mA)
- Have the LED close to the switch. Use the switch to cut the positive terminal of the battery
- LiteWing has 2 little buttons - use the little gold ones and make the buttons

## Barometer??
- BMP280??
## Other
- Likely do not need the DTR/RTS connections on the UART Bridge
- Research how it's done on the breakout board for the ESP32
- Motor MOSFET close to the motors
- Thick traces for the battery
- 