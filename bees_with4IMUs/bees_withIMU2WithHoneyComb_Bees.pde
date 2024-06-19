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
int[] state = new int[4];  // Initialize the state variable for each swarm
int[] accelX = new int[4]; // Initialize the acceleration arrays
int[] accelY = new int[4];
int[] accelZ = new int[4];
float[] mappedAccelX = new float[4];
float[] mappedAccelY = new float[4];
float[] mappedAccelZ = new float[4];
int imuId;

float easedX;
float easedY;
float easedX2;
float easedY2;
float easedX3;
float easedY3;

PImage bgImage;
PVector[] flowerPositions;

void setup() {
    size(1920, 1080);
    
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

    flowers.add(new Flower(flowerPositions[0].x, flowerPositions[0].y));
    flowers.add(new Flower(flowerPositions[1].x, flowerPositions[1].y));
    flowers.add(new Flower(flowerPositions[2].x, flowerPositions[2].y));

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
    
    easedX = mappedX[1];
    easedY = mappedY[1];
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
        flowers.get(i).update();  // Update flower rotation
        flowers.get(i).display();  // Display flower with updated rotation
    }

        // Update and display vehicles
            colorMode(RGB, 255);
    for (Vehicle v : vehicles) {
        v.applyBehaviors(vehicles, imuId);
        v.update();
        v.display();
    }
    

   

    // Display accelerometer data
    //text("Receiving accelerometer data", 10, height / 2);
    //for (int i = 0; i < 3; i++) {
    //  text("IMU " + i + " - X: " + x[i] + " Y: " + y[i] + " Z: " + z[i], 10, height / 2 + 20 * (i + 1));
    //}

    // Easing for the ellipse position
    float easing = 0.03;
    easedX = lerp(easedX, mappedX[0], easing);
    easedY = lerp(easedY, mappedY[0], easing);

    // Debugging for mapped values
    fill(255, 0, 0);
    ellipse(easedX, easedY, 20, 20);  // Visualize the target point for Swarm 1
        // Easing for the ellipse position
   
    easedX2 = lerp(easedX2, mappedX[2], easing);
    easedY2 = lerp(easedY2, mappedY[2], easing);

    // Debugging for mapped values
    fill(0, 0, 255);
    ellipse(easedX2, easedY2, 20, 20);  // Visualize the target point for Swarm 1
        // Easing for the ellipse position
    
    //easedX3 = lerp(easedX3, mappedX[3], easing);
    //easedY3 = lerp(easedY3, mappedY[3], easing);

    //// Debugging for mapped values
    //fill(0, 255, 0);
    //ellipse(easedX3, easedY3, 20, 20);  // Visualize the target point for Swarm 1
    
}
