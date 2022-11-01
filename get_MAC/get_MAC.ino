//to get MAC Address

#ifdef ESP32
#include <WiFi.h>
#else
#include <ESP8266WiFi.h>
#endif


void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.print("ESP Board MAC Address:  ");
  Serial.println(WiFi.macAddress());
  
  String macAdd =  {WiFi.macAddress()};
  Serial.println(macAdd + " yes!");
}

void loop() {
}
