const int sensorPin = 17; // pin 17
int sensorState = 0;

void setup() {
  pinMode(sensorPin, INPUT);
  Serial.begin(9600); // Start serial communication
}

void loop() {
  sensorState = digitalRead(sensorPin); // Read sensor state (0 or 1)

  // Print the sensor state to the Serial Monitor
  Serial.print("Sensor Output: ");
  Serial.println(sensorState);

  delay(100); // Delay to prevent flooding the serial output
}
