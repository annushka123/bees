class HoneyCombBee extends Bee {
    PVector targetPosition;
    PVector originalPosition;
    float wanderTheta;

    // Constructor to set initial position and size
    HoneyCombBee(float x, float y, float size) {
        super(x, y, size);
        this.originalPosition = new PVector(x, y);
        this.targetPosition = originalPosition.copy();
        this.wanderTheta = random(TWO_PI); // Initial wander angle
    }

    @Override
    void display() {
        updatePosition();
        pushMatrix();
        translate(headX, headY); // Translate to bee's position
        scale(size); // Scale the bee according to its size
        super.display();
        popMatrix();
    }

    void updatePosition() {
        // Update the wander angle randomly
        wanderTheta += random(-0.05, 0.05);

        // Calculate the new target position for hovering
        float wanderRadius = 20;
        targetPosition.x = originalPosition.x + wanderRadius * cos(wanderTheta);
        targetPosition.y = originalPosition.y + wanderRadius * sin(wanderTheta);

        // Seek the new target position
        PVector desired = PVector.sub(targetPosition, new PVector(headX, headY));
        float distance = desired.mag();
        float speed = distance < 100 ? map(distance, 0, 100, 0, 2) : 2;
        desired.setMag(speed);
        PVector steer = PVector.sub(desired, new PVector(0, 0));
        steer.limit(0.1); // Limit the steering force
        headX += steer.x;
        headY += steer.y;
    }
}
