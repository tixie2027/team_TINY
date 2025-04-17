void setup() {
  Serial.begin(9600);
  analogReadResolution(12);
  //analogReadAveraging(16);  // Add this line
  delay(1000);
}

void loop() {
  int rawValue = analogRead(16);     // Read raw ADC value (0 - 4095)
  
  // Convert to voltage (3.3V reference)
  float voltage = (rawValue / 4095.0) * 3.3;

  // Print both raw value and voltage
  Serial.print("Raw ADC: ");
  Serial.print(rawValue);
  Serial.print("  |  Voltage: ");
  Serial.print(voltage, 3);           // 3 decimal places (e.g., 1.234 V)
  Serial.println(" V");

  delay(100);  // Sample every 200 ms
}
