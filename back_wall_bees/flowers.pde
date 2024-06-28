class Flower {
    float x, y;  // Position of the flower
    color baseColor;  // RGB color
    color[] petalColors;
    int petalCount;
    float len;
    float wid;
    int rowCount;
    float rotate;  // Current rotation angle
    float baseRotationSpeed;  // Base speed of rotation
    float additionalRotationSpeed;  // Additional speed of rotation influenced by acceleration
    float accumulatedRotationSpeed;  // Accumulated rotation speed
    int id;
    float sideToSideSpeed;  // Speed for side-to-side movement
    float sideToSideOffset;  // Offset for side-to-side movement

    Flower(float x, float y, int id) {
        this.x = x;
        this.y = y;
        this.id = id;
        baseColor = color(random(100, 255), random(100, 250), random(100, 250)); // Random RGB color
        petalCount = int(random(2, 8)) * 4;
        len = random(30, 120);
        wid = random(0.3, 0.7);
        rowCount = int(random(5, 12));
        rotate = random(0, TWO_PI);
        baseRotationSpeed = random(0.0005, 0.002);  // Further reduced base rotation speed range
        additionalRotationSpeed = 0;  // Initialize additional rotation speed to 0
        accumulatedRotationSpeed = 0;  // Initialize accumulated rotation speed to 0
        sideToSideSpeed = random(0.0005, 0.002);  // Further reduced speed for side-to-side movement
        sideToSideOffset = random(TWO_PI);  // Random initial offset for side-to-side movement
        petalColors = new color[rowCount];
        for (int r = 0; r < rowCount; r++) {
            float hue = hue(baseColor) + random(-10, 10); // Small random hue variation
            float saturation = saturation(baseColor) + random(-10, 10); // Small random saturation variation
            float brightness = brightness(baseColor) + random(-10, 10); // Small random brightness variation
            petalColors[r] = color(hue, saturation, brightness);  // Use HSB for color variation
        }
    }

    void display() {
        stroke(0);
        strokeWeight(1);
        float deltaA = (2 * PI) / petalCount;
        float petalLen = len;
        pushMatrix();
        translate(x + sin(sideToSideOffset) * 20, y);  // Reduced side-to-side movement amplitude
        rotate(rotate);
        for (int r = 0; r < rowCount; r++) {
            fill(petalColors[r]);
            pushMatrix();
            for (float angle = 0; angle < 2 * PI; angle += deltaA) {
                rotate(deltaA);
                pushMatrix();
                rotate(random(-0.05, 0.05));  // Further reduced random rotation for each petal
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
        accumulatedRotationSpeed = lerp(accumulatedRotationSpeed, additionalRotationSpeed, easing);

        // Update rotation angle
        rotate += baseRotationSpeed + accumulatedRotationSpeed;

        // Update side-to-side movement
        sideToSideOffset += sideToSideSpeed * 0.001;
    }
    
    void updateAdditionalRotation(float newAdditionalRotationSpeed) {
        // Cap the additional rotation speed to prevent it from being too high
        float maxAdditionalSpeed = 0.01;  // Further reduced additional rotation speed
        additionalRotationSpeed = constrain(newAdditionalRotationSpeed, -maxAdditionalSpeed, maxAdditionalSpeed);
    }

    void updateRotationWithThreshold(float newAdditionalRotationSpeed, float threshold) {
        // Only apply additional rotation if it exceeds the threshold
        if (abs(newAdditionalRotationSpeed) > threshold) {
            updateAdditionalRotation(newAdditionalRotationSpeed);
        } else {
            additionalRotationSpeed = 0; // Reset additional rotation speed if below threshold
        }
    }
}
