#include <HCSR04.h>
#include <esp_now.h>
#include <WiFi.h>

#define TRIG_PIN 0
#define ECHO_PIN 2
#define SENDER_ID 4 //change it before uploading

float distance = 0;
float smoothing = 0.5;
bool isTrig = false;
float lastMsgTime = 0;
float minMsgDelta = 500;
float changedThresh = 10;

UltraSonicDistanceSensor distanceSensor(TRIG_PIN, ECHO_PIN);

uint8_t broadcastAddress[] = {0x10, 0x52, 0x1c, 0x68, 0x72, 0x30};

typedef struct struct_message {
  int id; // must be unique for each sender board
} struct_message;

struct_message myData;

// callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  Serial.print("\r\nLast Packet Send Status:\t");
  Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Delivery Success" : "Delivery Fail");
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);

  myData.id = SENDER_ID;

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  esp_now_register_send_cb(OnDataSent);

  // Register peer
  esp_now_peer_info_t peerInfo;
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;
  peerInfo.encrypt = false;

  if (esp_now_add_peer(&peerInfo) != ESP_OK) {
    Serial.println("Failed to add peer");
    return;
  }
}

void loop() {

  float newDistance = distanceSensor.measureDistanceCm();
  distance = (smoothing * distance) + (1 - smoothing) * newDistance;

  Serial.println(distance);
  float nowTime = millis();
  bool changedEnough = abs(newDistance-distance)>changedThresh;

  if (changedEnough && distance > 0 && distance < 400) {
    //isTrig = true;
    if (nowTime - lastMsgTime > minMsgDelta) {
      esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
      lastMsgTime = nowTime;
    }
  }

  delay(100);
}
