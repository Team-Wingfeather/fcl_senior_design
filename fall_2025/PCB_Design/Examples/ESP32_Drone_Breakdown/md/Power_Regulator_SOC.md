## Components
- **XC6220B331PR-G Linear Voltage Regulator**
- NEEDS WORK: Capacitors and stuff
## Connections
- Vout is the voltage directly off of the battery, as far as I can tell. We need to make sure the battery we are using is voltage compatible with the regulator we choose.
- Vout is connected to ground with a 10uF capacitor to filter off high-freq spikes. This is done in multiple places (see Battery Input and Switch)...not sure if this is necessary
- 3.3VC is filtered in the same way and is the 3.3V output for the entire drone.