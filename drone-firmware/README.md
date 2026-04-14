# Wingfeather Firmware

## IDE and Compiler Setup

The current framework for developing firmware for the Wing Feather is [ESP-IDF v5.5.4](https://docs.espressif.com/projects/esp-idf/en/v5.5.4/esp32/get-started/index.html). Espressif has recently released IDF v6 and the project could be upgraded to v6 if desired. An installation guide can be found by following that link.

For ease of use, you can develop in VSCode with the [ESP-IDF Extension](https://github.com/espressif/vscode-esp-idf-extension/blob/master/README.md). If you have a preferred code editor though, the command line experience is very easy.

## Development Resources

This project is built on top of a project that is built on top of another project. This is an adaption of the [Esp-Drone](https://github.com/espressif/esp-drone) from Espressif. Esp-drone does some unique things, but it is mostly an adaption of [Crazyflie](https://github.com/bitcraze/crazyflie-firmware) from Bitcraze. Since Crazyflie was build for STM32 based drones, Esp-Drone creates and abstraction layer to so it can run on an ESP32.

Relevant resources can be found from those projects.

> **When using the cflib Python library for wireless communication, use [this fork](https://github.com/leeebo/crazyflie-lib-python) for ESP32 support.**
