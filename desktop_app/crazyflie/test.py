import sys
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.utils import uri_helper

# Change if needed
uri = uri_helper.uri_from_env(default="udp://192.168.43.42:2390")

HOVER_THRUST = 3000  # Adjust as needed
COMMAND_RATE_HZ = 50  # Setpoint update rate
LOG_RATE_MS = 50  # 20 ms = 50 Hz logging


def log_callback(timestamp, data, logconf):
    print(
        f"{timestamp} | "
        f"roll: {data['stabilizer.roll']:.2f}, "
        f"pitch: {data['stabilizer.pitch']:.2f}, "
        # f"yaw: {data['stabalizer.yaw']:.2f}, "
        f"thrust: {data['stabilizer.thrust']:.2f}"
    )


def run_spin_test(cf):
    print("Motors spinning. Press Ctrl+C to stop.")

    dt = 1.0 / COMMAND_RATE_HZ

    for _ in range(20):
        cf.commander.send_setpoint(0, 0, 0, 0)
        time.sleep(0.02)

    try:
        while True:
            # zero roll, pitch, yaw-rate, constant thrust
            cf.commander.send_setpoint(0, 0, 0, HOVER_THRUST)
            time.sleep(dt)

    except KeyboardInterrupt:
        print("\nStopping motors...")
        cf.commander.send_setpoint(0, 0, 0, 0)
        time.sleep(0.1)


if __name__ == "__main__":
    cflib.crtp.init_drivers()

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache="./cache")) as scf:
        cf = scf.cf

        # ---- Logging Setup ----
        log_config = LogConfig(name="Stab", period_in_ms=LOG_RATE_MS)
        log_config.add_variable("stabilizer.roll", "float")
        log_config.add_variable("stabilizer.pitch", "float")
        # log_config.add_variable("stabalizer.yaw, float")
        log_config.add_variable("stabilizer.thrust", "float")

        cf.log.add_config(log_config)

        if not log_config.valid:
            print("Log configuration invalid")
            sys.exit(1)

        log_config.data_received_cb.add_callback(log_callback)
        log_config.start()

        # ---- Run motors continuously ----
        run_spin_test(cf)

        # Stop logging before exit
        log_config.stop()

    print("Disconnected cleanly.")
