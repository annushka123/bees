class HoneyCombBee extends Bee {
    // Constructor to set initial position and size
    HoneyCombBee(float x, float y, float size) {
        super(x, y, size);
    }

    @Override
    void display() {
        pushMatrix();
        translate(headX, headY); // Translate to bee's position
        scale(size); // Scale the bee according to its size
        super.display();
        popMatrix();
    }
}
