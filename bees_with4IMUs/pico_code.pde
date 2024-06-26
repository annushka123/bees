
int[] prevX = new int[4];
int[] prevY = new int[4];
int[] prevZ = new int[4];

void receive(byte[] data) {
  if (data.length == 28) {  // 7 integers * 4 bytes each = 28 bytes
    ByteBuffer buffer = ByteBuffer.wrap(data);
    buffer.order(ByteOrder.BIG_ENDIAN);  // or ByteOrder.LITTLE_ENDIAN if necessary

    int imuId = buffer.getInt();  // Extract the IMU ID
    if (imuId >= 0 && imuId < 4) {  // Ensure imuId is within the valid range
      x[imuId] = buffer.getInt();  // Update x position for the given imuId
      y[imuId] = buffer.getInt();  // Update y position for the given imuId
      z[imuId] = buffer.getInt();  // Update z position for the given imuId
      accelX[imuId] = buffer.getInt();  // Update accelX for the given imuId
      accelY[imuId] = buffer.getInt();  // Update accelY for the given imuId
      accelZ[imuId] = buffer.getInt();  // Update accelZ for the given imuId
      //println("imu1", x[1], x[1]);
      // Map raw acceleration values to a smaller range
      mappedAccelX[imuId] = map(accelX[imuId], -10000, 10000, -1.5, 1.5);
      println(accelX[3]);
      mappedAccelY[imuId] = map(accelY[imuId], -8000, 8000, -0.5, 0.5);
      mappedAccelZ[imuId] = map(accelZ[imuId], -8000, 8000, -0.5, 0.5);

      // Map x and y values to screen coordinates, adjust range to better cover the canvas
      mappedX[imuId] = constrain(map(x[imuId], -30, 90, 0, width), 0, width);  // Adjusted range and constrained
      mappedY[imuId] = constrain(map(y[imuId], -250, 280, 0, height), 0, height); // Adjusted range and constrained
      mappedZ[imuId] = map(z[imuId], -120, 120, 0.01, 0.1);
      
      for(int i=0; i < 4; i++) {
        
      //println("mappedX; ", mappedX[i], "mappedY; ", mappedY[i], "mappedZ", mappedZ[i]);
      }
      // Update state based on new IMU data
      updateState(imuId);

      // Map acceleration values to a smaller range for additional rotation speed
      float additionalRotationSpeed = mappedAccelX[3];
      flowers.get(0).updateAdditionalRotation(additionalRotationSpeed);
    } else {
      println("Unexpected IMU ID: " + imuId);
    }
  } else {
    println("Unexpected data length: " + data.length);
    printRawBytes(data);
  }
}

void updateState(int imuId) {
  // Calculate the changes in x and y
  int deltaX = abs(x[imuId] - prevX[imuId]);
  int deltaY = abs(y[imuId] - prevY[imuId]);

  // Update previous values for next comparison
  prevX[imuId] = x[imuId];
  prevY[imuId] = y[imuId];

  // Check if the changes are less than the threshold
  if (deltaX < 5 && deltaY < 5) {
    //println("IMU " + imuId + " resting - deltaX: " + deltaX + ", deltaY: " + deltaY);
    state[imuId] = 1;  // Resting state
  } else {
    //println("IMU " + imuId + " moving - deltaX: " + deltaX + ", deltaY: " + deltaY);
    state[imuId] = 2;  // Moving state
    //println("imu1", state[1]);
  }
}

void printRawBytes(byte[] data) {
  StringBuilder sb = new StringBuilder("Raw bytes: ");
  for (byte b : data) {
    sb.append(String.format("%02X ", b));
  }
  println(sb.toString());
}
