class HexagonGrid {
    List<Hexagon> hexs;
    float width;
    float radius;
    float posX, posY;
    ArrayList<HoneyCombBee> restingBees;

    HexagonGrid(float width, float radius, float posX, float posY) {
        this.width = width;
        this.radius = radius;
        this.posX = posX;
        this.posY = posY;
        this.hexs = new ArrayList<Hexagon>();
        this.restingBees = new ArrayList<HoneyCombBee>();
        createGrid();
        addBees();  // Add bees to the grid
    }

    void createGrid() {
        float gap = sqrt(pow(radius, 2) - pow(radius / 2, 2));
        float center = width % 2 == 0 ? width / 2 : (width - 1) / 2;

        for (int row = 0; row < width; row++) {
            int cols = (int) width - (int) (row >= center ? row - center : center - row);
            int offset = (int) (width - cols);

            for (int col = offset; col < offset + cols; col++) {
                float x = col * gap * 2 - offset * gap + posX;
                float y = row * sqrt(pow(radius, 2) - pow(gap, 2)) * 3 + posY;
                hexs.add(new Hexagon(x, y, radius));
            }
        }
    }

    void addBees() {
        int numBees = 3 + int(random(2)); // Add between 3 and 4 bees
        for (int i = 0; i < numBees; i++) {
            // Place bees within the bounds of the grid
            Hexagon targetHex = hexs.get(int(random(hexs.size())));
            float angle = random(TWO_PI); // Random angle within the hexagon
            float distance = random(radius * 0.5); // Random distance within the hexagon
            float offsetX = cos(angle) * distance;
            float offsetY = sin(angle) * distance;
            float size = random(0.7, 1.2);  // Random size between 0.5 and 1.5
            restingBees.add(new HoneyCombBee(targetHex.x + offsetX, targetHex.y + offsetY, size));
        }
    }

    void draw() {
        pushMatrix();
        translate(radius, radius);
        for (Hexagon h : hexs) {
            h.draw();
        }
        popMatrix();

        // Draw resting bees
        for (HoneyCombBee bee : restingBees) {
            bee.display();
        }
    }
}





//class Hexagon {
//  private final float x, y, radius;
//  private final float z;

//  public Hexagon(float x, float y, float radius) {
//    this.x = x;
//    this.y = y;
//    this.radius = radius;
//    this.z = random(-10, 10); // Random z value for slight 3D effect
//  }

//  public void draw() {
//    stroke(255, 150, 0);
//    fill(255, 200, 10, 200);
//    float hexagonAngle = TWO_PI / 6;

//    beginShape();
//    for (float a = PI / 2; a < TWO_PI + PI / 2; a += hexagonAngle) {
//      float sx = x + cos(a) * radius;
//      float sy = y + sin(a) * radius + z; // Adjust y by z to create depth effect
//      vertex(sx, sy);
//    }
//    endShape(CLOSE);
//  }
//}

class Hexagon {
    final float x, y, radius;
    final float z;

    public Hexagon(float x, float y, float radius) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.z = random(-10, 10); // Random z value for slight 3D effect
    }

    public void draw() {
        stroke(255, 150, 0);
        fill(255, 200, 10, 200);
        float hexagonAngle = TWO_PI / 6;

        beginShape();
        for (float a = PI / 2; a < TWO_PI + PI / 2; a += hexagonAngle) {
            float sx = x + cos(a) * radius;
            float sy = y + sin(a) * radius + z; // Adjust y by z to create depth effect
            vertex(sx, sy);
        }
        endShape(CLOSE);
    }
}
