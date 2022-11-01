#include <esp_now.h>
#include <WiFi.h>

typedef struct struct_message {
  int id;
}struct_message;

struct_message myData;

void OnDataRecv(const uint8_t * mac_addr, const uint8_t *incomingData, int len) {
  int senderID = ((struct_message *) incomingData)->id;
  // memcpy(&myData, incomingData, sizeof(myData));
  Serial.printf("%c%d",127,senderID);//("Trig from ID %u\n", senderID);
  }
 
void setup() {
  Serial.begin(115200);

  WiFi.mode(WIFI_STA);
  //Serial.println(WiFi.macAddress());
  
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    
    return;
  }
  
  esp_now_register_recv_cb(OnDataRecv);
}
 
void loop() { 
}
