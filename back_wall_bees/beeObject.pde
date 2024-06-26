

class Bee {
    float headX, headY;
    float headWidth; // Make headWidth dynamic
    float wingMovementR = 4;
    float wingMovementL = 4;
    float wingSpeedR = 0.1;
    float wingSpeedL = 0.1;
    float size; // Size of the bee

    // Constructor to set initial position and size
    Bee(float x, float y, float size) {
        headX = x;
        headY = y;
        this.size = size;
        headWidth = 10 * size; // Default head width scaled by size
    }

    void updateDimensions(int canvasWidth, int canvasHeight) {
        // Update head width based on canvas size
        headWidth = (canvasWidth / 15) * size; // Example ratio to make it responsive
        
        // Update position to always be centered
        headX = canvasWidth / 2;
        headY = canvasHeight / 2;
    }

    void display() {
        drawHead(0, 0);
        drawTentacles(0, 0);
        drawBody(0, 0);
        drawWings(0, 0);
    }

    void drawHead(float localX, float localY) {
        strokeWeight(2);
        stroke(0);
        fill(0); // Yellow head
        circle(localX, localY, headWidth);
    }

    void drawTentacles(float localX, float localY) {
        noFill();
        arc(localX + headWidth * 0.75, localY - headWidth / 2, headWidth, headWidth * 0.75, PI, PI + HALF_PI);
        arc(localX - headWidth * 0.75, localY - headWidth / 2, headWidth, headWidth * 0.75, PI + HALF_PI, TWO_PI);
    }

    void drawBody(float localX, float localY) {
        fill(230, 200, 10); // Body color
        ellipse(localX, localY + headWidth * 1.8, headWidth * 1.7, headWidth * 2.7);
        noFill();
        strokeWeight(2);
    }

    void updatePosition(float x, float y) {
        headX = x;
        headY = y;
    }

    void drawWings(float localX, float localY) {
        // Left wing
        pushMatrix();
        translate(localX - headWidth * 0.8, localY + headWidth * 1.1); // Adjusted to move wings slightly down
        
        wingMovementR += wingSpeedR;
        rotate(PI / wingMovementR);
        if (wingMovementR < 3 || wingMovementR > 6) {
            wingSpeedR *= -1;
        }

        fill(0);
        ellipse(0, 0, headWidth * 1.35, headWidth * 2.35);
        popMatrix();

        // Right wing  
        pushMatrix();
        translate(localX + headWidth * 0.8, localY + headWidth * 1.1); // Adjusted to move wings slightly down
        
        wingMovementL += wingSpeedL;
        rotate(-PI / wingMovementL);
        if (wingMovementL < 3 || wingMovementL > 6) {
            wingSpeedL *= -1;
        }

        fill(0);
        ellipse(0, 0, headWidth * 1.35, headWidth * 2.35);
        popMatrix();
    }
}
