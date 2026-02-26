import serial
import time

PORT = "COM9"
BAUD = 115200
FILE_PATH = "commands.txt"
EXPECTED_BYTES = 1024  # ESP always sends 1024 bytes

def read_exact(ser, size):
    data = b''
    while len(data) < size:
        chunk = ser.read(size - len(data))
        if not chunk:
            raise TimeoutError("Serial timeout while waiting for data")
        data += chunk
    return data

with serial.Serial(PORT, BAUD, timeout=5) as ser:

    time.sleep(2)  # allow ESP reset

    with open(FILE_PATH, "rb") as f:
        file_data = f.read()

    print(f"Sending {len(file_data)} bytes...")
    ser.write(file_data)
    ser.flush()

    print(f"Waiting for {EXPECTED_BYTES} bytes back...")

    response = read_exact(ser, EXPECTED_BYTES)

    # Strip zero padding
    response = response.rstrip(b'\x00')

    print("Received file contents:\n")
    print(response.decode("utf-8", errors="ignore"))