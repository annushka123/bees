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
        maxforce = 0.3 + random(0.1);  // Increase maximum steering force
        myBee = new Bee(x, y);
        this.swarm = swarm;
    }

    void applyForce(PVector force) {
        acceleration.add(force);
    }

    void applyBehaviors(ArrayList<Vehicle> vehicles, int imuId) {
        PVector target = flowerPositions[swarm].copy();  // Default target to the flower position for this swarm

        // Check the state and apply behaviors accordingly
        if (swarm == 0 && imuId == 0) {
            if (state[0] == 2) {
                target = new PVector(easedX, easedY);  // Use the eased position of the ellipse
            }
        } else if (swarm == 1 && imuId == 2) {
            if (state[2] == 2) {
                target = new PVector(mappedX[2], mappedY[2]);
                target = new PVector(easedX2, easedY2);  // Use the eased position of the ellipse
            }
        } else if (swarm == 2 && imuId == 4) {
            if (state[4] == 2) {
                target = new PVector(mappedX[3], mappedY[3]);
                //target = new PVector(easedX3, easedY3);  // Use the eased position of the ellipse
            }
        }

        // Apply seeking force towards the target
        PVector seekForce = seek(target);
        seekForce.mult(1.5);  // Increase seek force multiplier
        applyForce(seekForce);

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

        // Apply acceleration based on mappedAccelX and mappedAccelY
        PVector accelForce = new PVector(mappedAccelX[swarm], mappedAccelY[swarm]);
        applyForce(accelForce);
        
            // Apply wind force based on accelX[3]
            //fix this
        PVector windForce = new PVector(mappedAccelX[3], random(-1,1));  // Wind force in the horizontal direction
        //println
        applyForce(windForce);
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
