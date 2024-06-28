import java.util.ArrayList;
import java.util.List;
import hypermedia.net.UDP;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

UDP udp;
String receivedData = "";
List<HexagonGrid> grids;
PGraphics honeycombLayer;
ArrayList<Vehicle> vehicles;
ArrayList<PVector> centers = new ArrayList<PVector>();
ArrayList<Flower> flowers = new ArrayList<Flower>();
int maxAttempts = 100;

int[] x = new int[4];
int[] y = new int[4];
int[] z = new int[4];
float[] mappedX = new float[4];
float[] mappedY = new float[4];
float[] mappedZ = new float[4];
int[] state = new int[4];  // Initialize the state variable for each swarm
int[] accelX = new int[4]; // Initialize the acceleration arrays
int[] accelY = new int[4];
int[] accelZ = new int[4];
float[] mappedAccelX = new float[4];
float[] mappedAccelY = new float[4];
float[] mappedAccelZ = new float[4];
int imuId;

float[] easedX = new float[4];
float[] easedY = new float[4];

PImage bgImage;
PVector[] flowerPositions;

ArrayList<HoneyCombBee> honeyCombBees; 



float beeThreshold = 0.5;  // Threshold for bees
float flowerThreshold = 0.5;  // Threshold for flowers







void setup() {
    //size(1920, 1080);
    fullScreen(2);
    bgImage = loadImage("hive.png");

    // Resize the image to fit the screen
    bgImage.resize(width, height);

    // Apply a blur filter
    bgImage.filter(BLUR, 5);
    //grids = new ArrayList<HexagonGrid>();
    //grids.add(new HexagonGrid(7, 60, 10, 30));
    //grids.add(new HexagonGrid(10, 30, width * 0.7, height / 2));
    //grids.add(new HexagonGrid(10, 15, width * 0.5, height * 0.1));
    grids = new ArrayList<HexagonGrid>();
    grids.add(new HexagonGrid(7, 60, 10, 30));
    grids.add(new HexagonGrid(10, 30, width * 0.7, height / 2));
    grids.add(new HexagonGrid(10, 15, width * 0.5, height * 0.1));

    flowerPositions = new PVector[3];
    flowerPositions[0] = new PVector(width * 0.85, height * 0.25);
    flowerPositions[1] = new PVector(width - width * 0.44, height * 0.55);
    flowerPositions[2] = new PVector(width - width * 0.7, height * 0.75);

    flowers.add(new Flower(flowerPositions[0].x, flowerPositions[0].y, 0));
    flowers.add(new Flower(flowerPositions[1].x, flowerPositions[1].y, 1));
    flowers.add(new Flower(flowerPositions[2].x, flowerPositions[2].y, 2));

    vehicles = new ArrayList<Vehicle>();
    for (int i = 0; i < 800; i++) {
        int swarm = i % 3;
        vehicles.add(new Vehicle(random(width), random(height), swarm));
    }

    for (int i = 0; i < state.length; i++) {
        state[i] = 1;  // Initialize all states to 1
    }

    udp = new UDP(this, 5005);
    udp.listen(true);
    //println("UDP socket opened on port 5005");

    udp.log(false);  // Enable logging for debugging
    
   for (int i = 0; i < easedX.length; i++) {
        easedX[i] = mappedX[i];
        easedY[i] = mappedY[i];
    }
    
    //   // Create multiple HoneyCombBee objects
    //honeyCombBees = new ArrayList<HoneyCombBee>();
    //for (int i = 0; i < 6; i++) {
    //    float x = random(width);  // Random x position
    //    float y = random(height);  // Random y position
    //    float size = random(0.3, 1.5);  // Random size between 0.5 and 1.5
    //    honeyCombBees.add(new HoneyCombBee(x, y, size));
    //} 
}

void draw() {
    background(150);
    
       // Draw the blurred background image
    image(bgImage, 0, 0);

    // Draw honeycombs with RGB color mode
    colorMode(RGB, 255);
    for (HexagonGrid grid : grids) {
        grid.draw();
    }
    
        // Update and display flowers with new rotations
colorMode(HSB, 255);
for (int i = 0; i < flowers.size(); i++) {
    int flowerId = flowers.get(i).id;
    flowers.get(i).updateAdditionalRotation(mappedAccelX[flowerId], mappedAccelY[flowerId]);  // Update each flower with its corresponding mappedAccelX and mappedAccelY values
    flowers.get(i).update();  // Update flower rotation
    flowers.get(i).display();  // Display flower with updated rotation
}


        // Update and display vehicles
    colorMode(RGB, 255);
    for (Vehicle v : vehicles) {
        v.applyBehaviors(vehicles);
        v.update();
        v.display();
    }
    

   

     //Display accelerometer data
    text("Receiving accelerometer data", 10, height / 2);
    for (int i = 0; i < 3; i++) {
      text("IMU " + i + " - X: " + x[i] + " Y: " + y[i] + " Z: " + z[i], 10, height / 2 + 20 * (i + 1));
    }

    // Easing for the ellipse position
     float easing = 0.09;
    for (int i = 0; i < easedX.length; i++) {
        easedX[i] = lerp(easedX[i], mappedX[i], easing);
        easedY[i] = lerp(easedY[i], mappedY[i], easing);

        if (i == 0) fill(255, 0, 0);
        else if (i == 1) fill(0, 0, 255);
        else if (i == 2) fill(0, 255, 0);
        else fill(100, 100, 100);
        
        ellipse(easedX[i], easedY[i], 30, 30);
    }
    
        // Draw wind lines if acceleration values are high

        if (abs(mappedAccelX[3]) > 1) {
            drawWavyWindLines(mappedAccelX[3]);
        }
    
    //    for (HoneyCombBee bee : honeyCombBees) {
    //    bee.display();
    //}


}

void drawWavyWindLines(float accelValue) {
    stroke(255, 255, 255, 150);  // White lines with some transparency
    strokeWeight(2);
    noFill();
    int numLines = int(map(abs(accelValue), 0.5, 1.5, 10, 50));  // Number of lines increases with acceleration

    for (int i = 0; i < numLines; i++) {
        float startX = random(width);
        float startY = random(height);
        float amplitude = random(10, 30);  // Height of the wave
        float wavelength = random(50, 130);  // Length of the wave
        float endX = startX + wavelength;
        float endY = startY + random(-20, 20);  // Small random offset

        beginShape();
        for (float x = startX; x <= endX; x += 5) {
            // Interpolate Y position between startY and endY
            float t = map(x, startX, endX, 0, 1);
            float y = lerp(startY, endY, t) + amplitude * sin(TWO_PI * (x - startX) / wavelength);
            vertex(x, y);
        }
        endShape();
    }
}
