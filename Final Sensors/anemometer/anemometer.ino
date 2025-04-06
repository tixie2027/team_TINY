#include <Arduino.h>
#include <Wire.h>
//The following file defines Interrupt Service Routine (ISR)-- what happens when interrupt is triggered
//and provide list of possible interrupt routines.
#include <avr/interrupt.h>

int hallSensor = 17; //connect hall effect sensor output to pin 17 or pin corresponding to A3
int revolution = 0; //initialize revolution count

double endTime = 0; //time of last rotation
double currentTime = 0; //time of most recent (current) rotation
double timeDifference;
double sampleTime = 1000; //how long to count number of rotations for one sample 

constexpr int N = 5; //number of samples to average across
double sampleSet[N];

double RPS; //number of rotations per second
int index = 0;

const double anemometerConst = 0.1; // TO-DO: Go into wind tunnel to obtain anemometer constant to convert RPS to m/s
double windSpeed;

// TO-DO: Add sampling rate (Hz)


void setup() {
  Serial.begin(9600);
  pinMode(hallSensor, INPUT_PULLUP);
  //when hallSensor pin goes from HIGH to LOW (falls), call the ISR function
  attachInterrupt(digitalPinToInterrupt(hallSensor), ISR, FALLING);
}

void loop() {
  //Program that runs continuously as long as arduino is working

  // Calculate running average
  double avgRPS = calculateAverage(sampleSet, N);
  windSpeed = avgRPS * anemometerConst;

  // Print the current wind speed to the serial monitor
  Serial.print("Wind Speed (m/s): ");
  Serial.println(windSpeed);

  // Wait for 1 second before printing again
  delay(1000);
}

//ISR function: increments revolution count and prints to serial monitor
void ISR(){ 
  currentTime = millis();

  revolution += 1;
  Serial.print("Revolution count: ");
  Serial.println(revolution);
  float timeDifference = currentTime - endTime;

  if (timeDifference > sampleTime) {
    // Convert time difference to RPS (Revolutions per second)
    RPS = (revolution / sampleTime) * 1000;

    // Store the RPS value in the history array (for running average)
    RPSHistory[index] = RPS;
    index = (index + 1) % N; // Loop back to the start when the array is full

    endTime = currentTime;
    revolution = 0; // Reset revolution count for next sample set
  }
}

/*
 * Calculates a running average of a sample set
 *
 * @param sampleSet The sample set
 * @param N The number of samples
 * @return The running average
 */
 double runningAverage(double sampleSet, int N) {
    double sum = 0.0;

    for (int i = 0; i < N; i++) {
        sum += sampleSet[i];
    }

    return sum / N;
}

// double runningAverage(double average, double newSample) {
//     average -= average / N;
//     average += newSample / N;

//     return average;
// }
