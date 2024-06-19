import network
import time
import socket
import os

def connect_wifi(ssid, password):
    print("Connecting to WiFi")

    # Initialize the WiFi interface
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)

    # Connect to the network
    wlan.connect(ssid, password)

    # Wait for connection with a timeout
    max_wait = 20
    start_time = time.time()
    while not wlan.isconnected() and time.time() - start_time < max_wait:
        print("Waiting for connection...")
        time.sleep(1)

    if wlan.isconnected():
        # Connection successful
        print("Connected to WiFi")
        print("My MAC addr:", ':'.join(['{:02x}'.format(x) for x in wlan.config('mac')]))
        print("My IP address is", wlan.ifconfig()[0])
    else:
        # Connection failed
        print("Failed to connect to WiFi")
    
    
# def send_audio_data(server_ip, server_port, audio_data):
#     addr = socket.getaddrinfo(server_ip, server_port)[0][-1]
#     s = socket.socket()
#     try:
#         s.connect(addr)
# 
#         # Send data in chunks
#         chunk_size = 512
#         start = 0
#         while start < len(audio_data):
#             end = min(start + chunk_size, len(audio_data))
#             s.sendall(audio_data[start:end])
#             start = end
# 
#         # Wait briefly to ensure data is sent
#         time.sleep(1)
# 
#     finally:
#         s.close()
# 
