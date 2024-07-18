// Quadtree related classes
class Point {
    float x, y;
    Vehicle vehicle;

    Point(float x, float y, Vehicle vehicle) {
        this.x = x;
        this.y = y;
        this.vehicle = vehicle;
    }
}

class Rectangle {
    float x, y, w, h;

    Rectangle(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    boolean contains(Point point) {
        return (point.x >= x - w &&
                point.x < x + w &&
                point.y >= y - h &&
                point.y < y + h);
    }

    boolean intersects(Rectangle range) {
        return !(range.x - range.w > x + w ||
                 range.x + range.w < x - w ||
                 range.y - range.h > y + h ||
                 range.y + range.h < y - h);
    }
}

class Quadtree {
    int capacity;
    ArrayList<Point> points;
    Rectangle boundary;
    Quadtree[] divisions;
    boolean divided;

    Quadtree(int capacity, Rectangle boundary) {
        this.capacity = capacity;
        this.points = new ArrayList<Point>();
        this.boundary = boundary;
        this.divisions = new Quadtree[4];
        this.divided = false;
    }

    void subdivide() {
        float x = boundary.x;
        float y = boundary.y;
        float w = boundary.w / 2;
        float h = boundary.h / 2;

        divisions[0] = new Quadtree(capacity, new Rectangle(x + w, y - h, w, h));
        divisions[1] = new Quadtree(capacity, new Rectangle(x - w, y - h, w, h));
        divisions[2] = new Quadtree(capacity, new Rectangle(x - w, y + h, w, h));
        divisions[3] = new Quadtree(capacity, new Rectangle(x + w, y + h, w, h));

        divided = true;
    }

    void insert(Point point) {
        if (!boundary.contains(point)) {
            return;
        }

        if (points.size() < capacity) {
            points.add(point);
        } else {
            if (!divided) {
                subdivide();
            }
            for (Quadtree division : divisions) {
                division.insert(point);
            }
        }
    }

    ArrayList<Point> query(Rectangle range) {
        ArrayList<Point> found = new ArrayList<Point>();
        if (!boundary.intersects(range)) {
            return found;
        } else {
            for (Point point : points) {
                if (range.contains(point)) {
                    found.add(point);
                }
            }
            if (divided) {
                for (Quadtree division : divisions) {
                    found.addAll(division.query(range));
                }
            }
        }
        return found;
    }
}
