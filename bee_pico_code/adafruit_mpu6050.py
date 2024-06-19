import ustruct
from machine import I2C

class MPU6050:
    def __init__(self, i2c, addr=0x68):
        self.i2c = i2c
        self.addr = addr
        self.i2c.writeto_mem(self.addr, 0x6B, b'\x00')  # Wake up the MPU-6050
        self.i2c.writeto_mem(self.addr, 0x1B, b'\x00')  # Set gyroscope full-scale range to ±250 dps

        # Initialize buffers for moving average
        self.accel_buffer = {'x': [], 'y': [], 'z': []}
        self.gyro_buffer = {'x': [], 'y': [], 'z': []}
        self.buffer_size = 10  # Change this to adjust the smoothing level

    def read_data(self, reg):
        high = self.i2c.readfrom_mem(self.addr, reg, 1)
        low = self.i2c.readfrom_mem(self.addr, reg + 1, 1)
        value = ustruct.unpack('>h', high + low)[0]
        return value

    def _update_buffer(self, buffer, new_data):
        for key in buffer:
            buffer[key].append(new_data[key])
            if len(buffer[key]) > self.buffer_size:
                buffer[key].pop(0)

    def _calculate_average(self, buffer):
        return {key: sum(buffer[key]) / len(buffer[key]) for key in buffer}

    def get_accel(self):
        accel_data = {
            'x': self.read_data(0x3B) / 16384.0,
            'y': self.read_data(0x3D) / 16384.0,
            'z': self.read_data(0x3F) / 16384.0
        }
        self._update_buffer(self.accel_buffer, accel_data)
        return self._calculate_average(self.accel_buffer)

    def get_gyro(self):
        gyro_data = {
            'x': self.read_data(0x43) / 131.0,
            'y': self.read_data(0x45) / 131.0,
            'z': self.read_data(0x47) / 131.0
        }
        self._update_buffer(self.gyro_buffer, gyro_data)
        return self._calculate_average(self.gyro_buffer)

    def get_temp(self):
        temp = self.read_data(0x41)
        return temp / 340.0 + 36.53

