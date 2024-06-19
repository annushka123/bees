import time
import network
import socket
import struct
import machine
import neopixel
from machine import I2C, Pin
from mpu6050 import MPU6050


np = neopixel.NeoPixel(machine.Pin(12), 1)

def connect_wifi(ssid, password):
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid, password)
    
    print("Connecting to WiFi...")
    while not wlan.isconnected():
        time.sleep(1)
    print("Connected to WiFi")
    print("IP:", wlan.ifconfig()[0])


# Connect to WiFi
connect_wifi('RockstarPrincess', 'tootsandbutts')

# Initialize I2C
print("Initializing I2C...")
i2c = I2C(0, scl=Pin(5), sda=Pin(4))

# Initialize MPU6050
print("Initializing MPU6050...")
mpu = MPU6050(i2c)

# Set accelerometer range to ±8G
mpu.i2c.writeto_mem(mpu.addr, 0x1C, bytearray([0x10]))  # ACCEL_CONFIG register

# Set gyroscope range to ±500 deg/s
mpu.i2c.writeto_mem(mpu.addr, 0x1B, bytearray([0x08]))  # GYRO_CONFIG register

# UDP setup
udp_ip = "192.168.50.179"  # IP address of the receiving machine
udp_port = 5005            # Port to send the data to
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Define the IMU ID
imu_id = 0  # Change this for each different IMU

print("Entering main loop...")
# Main loop
while True:
    # Read accelerometer and gyroscope data from MPU6050
    accel = mpu.get_accel()
    gyro = mpu.get_gyro()
    temp = mpu.get_temp()

    # Scale the data to integers
    accel_x = int(accel['x'] * 1000)
    accel_y = int(accel['y'] * 1000)
    accel_z = int(accel['z'] * 1000)
    gyro_x = int(gyro['x'] * 1000)
    gyro_y = int(gyro['y'] * 1000)
    gyro_z = int(gyro['z'] * 1000)

    # Print sensor data to console
    print("Acceleration: X={:.2f} m/s^2, Y={:.2f} m/s^2, Z={:.2f} m/s^2".format(accel['x'], accel['y'], accel['z']))
    print("Gyro: X={:.2f} rad/s, Y={:.2f} rad/s, Z={:.2f} rad/s".format(gyro['x'], gyro['y'], gyro['z']))
    print("Temperature: {:.2f} C".format(temp))
    print("")
    
    # Pack data into bytes including IMU ID
    message = struct.pack('!iiiiiii', imu_id, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z)
    sock.sendto(message, (udp_ip, udp_port))

    time.sleep(1)




