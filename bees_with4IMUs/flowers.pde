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

    Flower(float x, float y) {
        this.x = x;
        this.y = y;
        baseColor = color(random(100, 255), random(100, 250), random(100, 550)); // Random RGB color
        petalCount = int(random(2, 8)) * 4;
        len = random(180, 130);
        wid = random(0.3, 0.7);
        rowCount = int(random(5, 12));
        rotate = random(0, TWO_PI);
        baseRotationSpeed = 0.01;  // Initialize base rotation speed
        additionalRotationSpeed = 0;  // Initialize additional rotation speed to 0
        accumulatedRotationSpeed = 0;  // Initialize accumulated rotation speed to 0
        petalColors = new color[rowCount];
        for (int r = 0; r < rowCount; r++) {
            float hue = hue(baseColor) + random(-20, 20); // Small random hue variation
            float saturation = saturation(baseColor) + random(-30, 30); // Small random saturation variation
            float brightness = brightness(baseColor) + random(-20, 20); // Small random brightness variation
            petalColors[r] = color(hue, saturation, brightness);  // Use HSB for color variation
        }
    }

    void display() {
        stroke(0);
        strokeWeight(1);
        float deltaA = (2 * PI) / petalCount;
        float petalLen = len;
        pushMatrix();
        translate(x, y);
        rotate(rotate);
        for (int r = 0; r < rowCount; r++) {
            fill(petalColors[r]);
            pushMatrix();
            for (float angle = 0; angle < 2 * PI; angle += deltaA) {
                rotate(deltaA);
                ellipse(petalLen * 0.75, 0, petalLen, petalLen * wid);
            }
            popMatrix();
            petalLen *= (1 - 3.0 / rowCount);
        }
        popMatrix();
    }

    void update() {
        // Apply easing to accumulated rotation speed
        float easing = 0.02;
        accumulatedRotationSpeed = lerp(accumulatedRotationSpeed, additionalRotationSpeed, easing);

        // Update rotation angle
        rotate += baseRotationSpeed + accumulatedRotationSpeed;
    }

    void updateAdditionalRotation(float newAdditionalRotationSpeed) {
        // Cap the additional rotation speed to prevent it from being too high
        float maxAdditionalSpeed = 0.05;
        additionalRotationSpeed = constrain(newAdditionalRotationSpeed, -maxAdditionalSpeed, maxAdditionalSpeed);
    }
}
