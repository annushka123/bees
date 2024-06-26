class Vehicle {
    PVector position;
    PVector velocity;
    PVector acceleration;
    float r;
    float maxforce;    // Maximum steering force
    float maxspeed;    // Maximum speed
    int swarm;

    Bee myBee;

    Vehicle(float x, float y, int swarm) {
        position = new PVector(x, y);
        acceleration = new PVector(0, 0);
        velocity = new PVector(0, 0);
        maxspeed = 5 + random(2);  // Increase base speed
        maxforce = 0.4 + random(0.1);  // Increase maximum steering force
        float size = random(0.7, .9);  
        myBee = new Bee(x, y, size);
        this.swarm = swarm;
    }

    void applyForce(PVector force) {
        acceleration.add(force);
    }

    void applyBehaviors(ArrayList<Vehicle> vehicles) {
        // Apply wandering behavior
        PVector wanderForce = wander();
        applyForce(wanderForce);

        // Apply separation force to avoid clustering
        PVector separateForce = separate(vehicles);
        separateForce.mult(1.5);  // Adjust separation weight as needed
        applyForce(separateForce);
        
        // Apply random steering force occasionally to introduce unpredictability
        if (random(1) < 0.05) {
            PVector randomSteer = PVector.random2D();
            randomSteer.mult(random(0.5));
            applyForce(randomSteer);
        }

        myBee.updatePosition(position.x, position.y);
    }

    PVector wander() {
        float wanderR = 25; // Radius for our "wander circle"
        float wanderD = 80; // Distance for our "wander circle"
        float change = 0.3f;
        float wanderTheta = random(TWO_PI); // Random angle

        PVector circlepos = velocity.copy();
        circlepos.normalize();
        circlepos.mult(wanderD);
        circlepos.add(position);

        float h = velocity.heading();

        PVector circleOffset = new PVector(wanderR * cos(wanderTheta + h), wanderR * sin(wanderTheta + h));
        PVector target = PVector.add(circlepos, circleOffset);

        return seek(target);
    }

    PVector seek(PVector target) {
        PVector desired = PVector.sub(target, position);
        desired.normalize();
        desired.mult(maxspeed);
        PVector steer = PVector.sub(desired, velocity);
        steer.limit(maxforce);
        return steer;
    }

    PVector separate(ArrayList<Vehicle> vehicles) {
        float desiredSeparation = myBee.headWidth * 5;  // Separation distance relative to head width
        PVector steer = new PVector();
        int count = 0;
        for (Vehicle other : vehicles) {
            float d = PVector.dist(position, other.position);
            if ((d > 0) && (d < desiredSeparation)) {
                PVector diff = PVector.sub(position, other.position);
                diff.normalize();
                diff.div(d);  // Weight by distance
                steer.add(diff);
                count++;
            }
        }
        if (count > 0) {
            steer.div(count);
            steer.normalize();
            steer.mult(maxspeed);
            steer.sub(velocity);
            steer.limit(maxforce);
        }
        return steer;
    }

    void update() {
        velocity.add(acceleration);
        velocity.limit(maxspeed);
        position.add(velocity);
        acceleration.mult(0);
        constrainPosition();
        myBee.updatePosition(position.x, position.y);
    }

    void display() {
        float theta = velocity.heading() + PI / 2;
        pushMatrix();
        translate(position.x, position.y);
        rotate(theta);
        myBee.display();
        popMatrix();
    }

    void constrainPosition() {
        position.x = constrain(position.x, 0, width);
        position.y = constrain(position.y, 0, height);
    }
}
