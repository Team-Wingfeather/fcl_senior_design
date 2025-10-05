## Components
- The resistors on the right step down the battery voltage so that it can be measured by the ADC
## Connections
- We'll likely need a step-down of the battery voltage for use by the Microcontroller ADC to tell when to stop flight. Additionally, we could display this information to the user with an LED on a different GPIO.
## Notes
- We need some way to see when the battery on the drone is low and communicate with the user about calibration and things...does this require a dedicated GPIO pin? I think that may be the best solution instead of a buzzer.