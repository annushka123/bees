class Flower {
    float x, y;  // Position of the flower
    float originalX, originalY;  
    color baseColor;  // RGB color
    color[] petalColors;
    int petalCount;
    float len;
    float wid;
    int rowCount;
    float rotate;  // Current rotation angle
    float baseRotationSpeed;  // Base speed of rotation
    float additionalRotationSpeedX;
    float additionalRotationSpeedY;// Additional speed of rotation influenced by acceleration
    float accumulatedRotationSpeedX;
    float accumulatedRotationSpeedY;// Accumulated rotation speed
    int id;
    float sideToSideSpeed;  // Speed for side-to-side movement
    float sideToSideOffset;  // Offset for side-to-side movement
    float sideToSideAmplitudeX; 
    float sideToSideAmplitudeY; 
    float directionX;
    float directionY; 
    
    Flower(float x, float y, int id) {
        this.x = x;
        this.y = y;
        this.originalX = x;
        this.originalY = y;
        this.id = id;
        baseColor = color(random(130, 255), random(130, 250), random(130, 250)); // Random RGB color
        petalCount = int(random(2, 8)) * 4;
        len = random(110, 160);
        wid = random(0.3, 0.7);
        rowCount = int(random(5, 12));
        rotate = random(0, TWO_PI);
        baseRotationSpeed = 0.01;  // Initialize base rotation speed
        additionalRotationSpeedX = 0; 
        additionalRotationSpeedY = 0;// Initialize additional rotation speed to 0
        accumulatedRotationSpeedX = 0;
        accumulatedRotationSpeedY = 0;// Initialize accumulated rotation speed to 0
        sideToSideSpeed = random(0.0005, 0.0002);  // Further reduced speed for side-to-side movement
        sideToSideOffset = random(TWO_PI);  // Random initial offset for side-to-side movement
        sideToSideAmplitudeX = 10;
        sideToSideAmplitudeY = 10;
        directionX = random(-0.8, 0.8);  // Random initial direction for movement
        directionY = random(-0.8, 0.8);
        petalColors = new color[rowCount];
        for (int r = 0; r < rowCount; r++) {
            float hue = hue(baseColor) + random(-10, 10); // Small random hue variation
            float saturation = saturation(baseColor) + random(-10, 10); // Small random saturation variation
            float brightness = brightness(baseColor) + random(-10, 10); // Small random brightness variation
            petalColors[r] = color(hue, saturation, brightness);  // Use HSB for color variation
        }
    }
    
        void drawStem() {
        stroke(44, 149, 44); // Green color
        strokeWeight(6); // Thick stem
        line(originalX, originalY, x + sin(sideToSideOffset) * sideToSideAmplitudeX, y + sin(sideToSideOffset) * sideToSideAmplitudeY);
    }

    void display() {
        stroke(0);
        strokeWeight(1);
        float deltaA = (2 * PI) / petalCount;
        float petalLen = len;
        pushMatrix();
        translate(x + sin(sideToSideOffset) * sideToSideAmplitudeX, y + sin(sideToSideOffset) * sideToSideAmplitudeY);  // Reduced side-to-side movement amplitude
        rotate(rotate);
        for (int r = 0; r < rowCount; r++) {
            fill(petalColors[r]);
            pushMatrix();
            for (float angle = 0; angle < 2 * PI; angle += deltaA) {
                rotate(deltaA);
                pushMatrix();
                rotate(random(-0.055, 0.005));  // Further reduced random rotation for each petal
                ellipse(petalLen * 0.75, 0, petalLen, petalLen * wid);
                popMatrix();
            }
            popMatrix();
            petalLen *= (1 - 3.0 / rowCount);
        }
        popMatrix();
    }

    void update() {
        // Apply easing to accumulated rotation speed
        float easing = 0.001;
        accumulatedRotationSpeedX = lerp(accumulatedRotationSpeedX, additionalRotationSpeedX, easing);
        accumulatedRotationSpeedY = lerp(accumulatedRotationSpeedY, additionalRotationSpeedY, easing);

        // Update rotation angle
        rotate += baseRotationSpeed + accumulatedRotationSpeedX+accumulatedRotationSpeedY;
        
        // Update side-to-side movement
        sideToSideOffset += sideToSideSpeed * 0.001;
        
        // Define the boundary range around the original position
    float boundaryRange = 150;  // Adjust this value as needed
    
    // Update x position with direction and boundary constraints
    x += directionX * sideToSideAmplitudeX * 0.05;  // Move in the specified direction (X-axis)
    y += directionY * sideToSideAmplitudeY * 0.05;  // Move in the specified direction (Y-axis)
    
    // Constrain x within the boundary range around originalX
    if (x < originalX - boundaryRange || x > originalX + boundaryRange) {
        directionX *= -1;  // Reverse direction if hitting the boundary
        x = constrain(x, originalX - boundaryRange, originalX + boundaryRange);  // Constrain x within the boundary range
    }
    
    // Constrain y within the boundary range around originalY
    if (y < originalY - boundaryRange || y > originalY + boundaryRange) {
        directionY *= -1;  // Reverse direction if hitting the boundary
        y = constrain(y, originalY - boundaryRange, originalY + boundaryRange);  // Constrain y within the boundary range
    }
    }
    
        void updateAdditionalRotation(float newAdditionalRotationSpeedX, float newAdditionalRotationSpeedY) {
        // Cap the additional rotation speed to prevent it from being too high
        float maxAdditionalSpeed = 0.001;
        additionalRotationSpeedX = constrain(newAdditionalRotationSpeedX, -maxAdditionalSpeed, maxAdditionalSpeed);
        additionalRotationSpeedY = constrain(newAdditionalRotationSpeedY, -maxAdditionalSpeed, maxAdditionalSpeed);
        float targetAmplitudeX = map(abs(newAdditionalRotationSpeedX), 0, 3, 10, 40);
        float targetAmplitudeY = map(abs(newAdditionalRotationSpeedY), 0, 3, 10, 40);
        float easing = 0.05; // Easing factor, adjust as needed
        sideToSideAmplitudeX += (targetAmplitudeX - sideToSideAmplitudeX) * easing;
        sideToSideAmplitudeY += (targetAmplitudeY - sideToSideAmplitudeY) * easing;

      
    }

    void updateRotationWithThreshold(float newAdditionalRotationSpeedX, float newAdditionalRotationSpeedY, float threshold) {
        // Only apply additional rotation if it exceeds the threshold
        if (abs(newAdditionalRotationSpeedX) > threshold) {
            updateAdditionalRotation(newAdditionalRotationSpeedX, additionalRotationSpeedY);
        } else {
            additionalRotationSpeedX = 0; // Reset additional rotation speed if below threshold (X-axis)
            sideToSideAmplitudeX = 30;  // Reset side-to-side amplitude (X-axis)
        }
        
        if (abs(newAdditionalRotationSpeedY) > threshold) {
            updateAdditionalRotation(additionalRotationSpeedX, newAdditionalRotationSpeedY);
        } else {
            additionalRotationSpeedY = 0; // Reset additional rotation speed if below threshold (Y-axis)
            sideToSideAmplitudeY = 30;  // Reset side-to-side amplitude (Y-axis)
        }
    }
    
        PVector getPosition() {
        return new PVector(x + sin(sideToSideOffset) * sideToSideAmplitudeX, y + sin(sideToSideOffset) * sideToSideAmplitudeY);
    }
}
