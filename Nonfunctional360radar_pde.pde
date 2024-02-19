import processing.serial.*;

Serial myPort;
String angle = "", distance1 = "";
float pixsDistance1;
int iAngle, iDistance1;
PFont orcFont;
float searchAngle = 0;
color radarLineColor1 = color(30, 250, 60); // Initial color for radar line (sensor 1)

void setup() {
  size(1200, 900);
  smooth();
  myPort = new Serial(this, "COM5", 9600);
  myPort.bufferUntil('.');
  orcFont = createFont("Arial", 30);
}

void draw() {
  // Apply a slight background blur effect
  fill(0, 4);
  rect(0, 0, width, height);

  fill(98, 245, 31);
  textFont(orcFont);
  noStroke();

  float centerX = width / 2;
  float centerY = height / 2;

  fill(98, 245, 31);
  drawRadar(centerX, centerY);

  // Use the modified drawLine and drawObject functions
  drawObject(centerX, centerY);
  drawLine(centerX, centerY);
  
  drawText(centerX, centerY);
  
  // Update the searchAngle to make lines rotate
  searchAngle = (searchAngle + 1) % 360;
}

void drawObject(float x, float y) {
  pushMatrix();
  translate(x, y);
  rotate(radians(searchAngle));
  strokeWeight(12);

  // Use the color defined for sensor 1
  stroke(255, 0, 0);

  pixsDistance1 = iDistance1 * ((height - height * 0.7758) * 0.025);
  if (iDistance1 < 40) {
    // draws the object according to the angle and the distance
    line(0, 0, pixsDistance1, 0);
  }
  popMatrix();
}

void drawLine(float x, float y) {
  pushMatrix();
  translate(x, y);
  rotate(radians(searchAngle));
  strokeWeight(3);
  stroke(30, 250, 60);
  line(0, 0, (height - height * 0.78), 0); // draws the line according to the angle
  popMatrix();
}

void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('.');
  if (data != null) {
    data = data.substring(0, data.length() - 1);
    String[] values = split(data, ',');
    if (values.length == 2) {
      angle = values[0];
      distance1 = values[1];
      iAngle = int(angle);
      iDistance1 = int(distance1);

      // Check if the detected object is at the current angle for sensor 1
      if (iDistance1 < 40) {
        radarLineColor1 = color(255, 10, 10); // Change radar line color to red for sensor 1
      } else {
        radarLineColor1 = color(30, 250, 60); // Reset radar line color to green for sensor 1
      }
    }
  }
}

void drawRadar(float x, float y) {
  pushMatrix();
  translate(x, y);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);

  for (int i = 0; i < 360; i += 30) {
    // Correct the angles to start from the top
    arc(0, 0, 400, 400, radians(i - 90), radians(i + 30 - 90));
  }

  for (int i = 0; i < 360; i += 30) {
    // Correct the angles to start from the top
    line(0, 0, -200 * cos(radians(i - 90)), -200 * sin(radians(i - 90)));
  }

  popMatrix();
}

void drawText(float x, float y) {
  pushMatrix();
  String noObject;

  if (iDistance1 > 40) {
    fill(255);
    noObject = "Out of Range";
  } else {
    fill(98, 245, 31);
    noObject = "In Range";
  }

  noStroke();
  rect(0, height - 30, width, 30);
  fill(98, 245, 31);

  textSize(20);
  text("Object: " + noObject, 10, height - 10);
  text("Angle: " + iAngle + " °", width / 2 - 150, height - 10);
  text("Distance1: " + iDistance1 + " cm", width / 2 + 30, height - 10);

  textSize(10);
  fill(98, 245, 60);

  for (int i = 0; i < 360; i += 30) {
    float xLabel = x + 200 * cos(radians(-i + 90));
    float yLabel = y - 200 * sin(radians(-i + 90));
    translate(xLabel, yLabel);
    rotate(radians(i));
    text(i + "°", 0, 0);
    resetMatrix();
  }

  popMatrix();
}
