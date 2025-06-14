#!/bin/sh

echo "=== [1/7] Install Python and pip ==="
opkg update
opkg install python3 python3-pip

echo "=== [2/7] Install Python libraries ==="
pip3 install pyserial paho-mqtt

echo "=== [3/7] Create /usr/bin/querybatteryinfo.py ==="
cat << 'EOF' > /usr/bin/querybatteryinfo.py
#!/usr/bin/env python3
import serial
import time
import binascii
import paho.mqtt.publish as publish

PORT = "/dev/ttyRS485"
BAUD = 57600
TIMEOUT = 2
MQTT_BROKER = "cloud.lightsol.net"
cmd_bytes = bytes.fromhex("41160F0100003A0A0B0B0402021221B92B")

def get_device_id():
    try:
        with open('/proc/sys/kernel/hostname') as f:
            return f.read().strip()
    except Exception:
        return "UNKNOWN"

def query_battery():
    device_id = get_device_id()
    MQTT_TOPIC = f'battery/info/{device_id}'
    try:
        with serial.Serial(PORT, BAUD, bytesize=8, parity='N', stopbits=1, timeout=TIMEOUT) as ser:
            ser.reset_input_buffer()
            ser.write(cmd_bytes)
            time.sleep(0.5)
            response = ser.read(54)
            hex_response = binascii.hexlify(response).decode()
            publish.single(MQTT_TOPIC, hex_response, hostname=MQTT_BROKER)
    except Exception as e:
        print(f"[ERROR] {e}")

if __name__ == "__main__":
    while True:
        query_battery()
        time.sleep(60)
EOF

chmod +x /usr/bin/querybatteryinfo.py

echo "=== [4/7] Create /etc/init.d/mybmsread ==="
cat << 'EOF' > /etc/init.d/mybmsread
#!/bin/sh /etc/rc.common

START=98
STOP=10
USE_PROCD=1

start_service() {
    procd_open_instance mybmsread
    procd_set_param command /usr/bin/python3 /usr/bin/querybatteryinfo.py
    procd_set_param respawn 60 10 0
    procd_close_instance
}
EOF

chmod +x /etc/init.d/mybmsread

echo "=== [5/7] Stop and disable old spregread (if exists) ==="
if [ -f /etc/init.d/spregread ]; then
  /etc/init.d/spregread stop
  /etc/init.d/spregread disable
fi

echo "=== [6/7] Enable and start new mybmsread service ==="
/etc/init.d/mybmsread enable
/etc/init.d/mybmsread start

echo "=== [7/7] Service Status ==="
/etc/init.d/mybmsread status
