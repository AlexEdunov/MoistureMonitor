#include <ArduinoBLE.h>

BLEService moistureService("098D");
BLEUnsignedCharCharacteristic moistureLevelCharacteristic("098E", BLERead | BLENotify);

long previousMillis = 0;

void setup() {
  Serial.begin(9600);
  // while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT);

  if (!BLE.begin()) {
    Serial.println("Starting BLE failed");

    while (1);
  }

  BLE.setLocalName("Moisture Monitor");

  BLE.setAdvertisedService(moistureService);
  moistureService.addCharacteristic(moistureLevelCharacteristic);
  BLE.addService(moistureService);

  BLE.advertise();
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    digitalWrite(LED_BUILTIN, HIGH);

    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      long currentMillis = millis();
      if (currentMillis - previousMillis >= 1000) {
        previousMillis = currentMillis;

        int moisture = analogRead(A0);
        int moistureLevel = map(moisture, 0, 1023, 0, 100);

        Serial.print("Moisture Level % is now: ");
        Serial.println(moistureLevel);

        moistureLevelCharacteristic.writeValue(moistureLevel);
      }
    }

    digitalWrite(LED_BUILTIN, LOW);

    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}
