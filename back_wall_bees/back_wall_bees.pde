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



float beeThreshold = 0.1;  // Threshold for bees
float flowerThreshold = 0.2;  // Threshold for flowers



int numFlowers = 75;  // Number of flowers to create

void setup() {
    size(1000, 1000);
    //fullScreen(2);


    bgImage = loadImage("grass.png");

    // Resize the image to fit the screen
    bgImage.resize(width, height);

    // Apply a blur filter
    bgImage.filter(BLUR, 5);

    grids = new ArrayList<HexagonGrid>();
    grids.add(new HexagonGrid(10, 56, 0, 60));
 
for (int i = 0; i < numFlowers; i++) {
    PVector pos = getRandomEdgePosition(random(130, 180)); // Half the maximum width of the flower
    flowers.add(new Flower(pos.x, pos.y, i));
}


    //flowers.add(new Flower(flowerPositions[0].x, flowerPositions[0].y, 0));
    //flowers.add(new Flower(flowerPositions[1].x, flowerPositions[1].y, 1));
    //flowers.add(new Flower(flowerPositions[2].x, flowerPositions[2].y, 2));

    vehicles = new ArrayList<Vehicle>();
    for (int i = 0; i < 100; i++) {
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


    for (int i = 0; i < flowers.size() / 2; i++) {
        Flower flower = flowers.get(i);
        flowers.get(i).drawStem(); 
        flower.update();  // Update flower rotation
        flower.display();  // Display flower with updated rotation
    }
        // Draw honeycombs with RGB color mode
    colorMode(RGB, 255);
    for (HexagonGrid grid : grids) {
        grid.draw();
    }

    for (int i = 0; i < flowers.size() / 2; i++) {
        Flower flower = flowers.get(i);
        //flower.updateAdditionalRotation(mappedAccelX[flower.id]);  // Update each flower with its corresponding mappedAccelX value
        flower.update();  // Update flower rotation
        flower.display();  // Display flower with updated rotation
    }
        // Update and display vehicles
    colorMode(RGB, 255);
    for (Vehicle v : vehicles) {
        v.applyBehaviors(vehicles);
        v.update();
        v.display();
    }
    

   




}

void drawWavyWindLines(float accelValue) {
    stroke(255, 255, 255, 150);  // White lines with some transparency
    strokeWeight(2);
    noFill();
    int numLines = int(map(abs(accelValue), 0.1, 1.0, 10, 50));  // Number of lines increases with acceleration

    for (int i = 0; i < numLines; i++) {
        float startX = random(width);
        float startY = random(height);
        float amplitude = random(10, 30);  // Height of the wave
        float wavelength = random(50, 100);  // Length of the wave
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
PVector getRandomEdgePosition(float offset) {
    float x = 0, y = 0;
    int side = int(random(4));
    switch (side) {
        case 0:  // Top edge
            x = random(offset, width - offset);
            y = offset;
            break;
        case 1:  // Right edge
            x = width - offset;
            y = random(offset, height - offset);
            break;
        case 2:  // Bottom edge
            x = random(offset, width - offset);
            y = height - offset;
            break;
        case 3:  // Left edge
            x = offset;
            y = random(offset, height - offset);
            break;
    }
    return new PVector(x, y);
}


//void drawWindLines(float windThreshold) {
//    for (int i = 0; i < vehicles.size(); i++) {
//        if (abs(mappedAccelX[3]) > windThreshold) {
//            float startX = vehicles.get(i).position.x;
//            float startY = vehicles.get(i).position.y;
//            float endX = startX + mappedAccelX[3] * 100; // Adjust length as needed
//            //float endY = startY;
            
//            stroke(200, 200, 255);
//            strokeWeight(2);
//            noFill();
//            beginShape();
//            float waveHeight = 10;
//            for (float x = startX; x < endX; x += 10) {
//                float y = startY + sin((x - startX) / 10.0) * waveHeight;
//                vertex(x, y);
//            }
//            endShape();
//        }
//    }
//}
