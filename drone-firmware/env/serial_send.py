import serial

PORT = "COM9" # TODO: Feed this from qt app - i.e. "connect port" option in app

with serial.Serial(PORT, 115200, timeout=1) as ser:
    ser.write(b'HELLO\n')   # IMPORTANT newline
    while True:
        data = ser.read(128)
        if not data:
            break
        print(data)