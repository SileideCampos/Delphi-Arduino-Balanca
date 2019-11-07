#include <SoftwareSerial.h>
#include "HX711.h"                    

#define DOUT  A0                      // HX711 DATA OUT = pino A0 do Arduino Fio amarelo
#define CLK  A1                       // HX711 SCK IN = pino A1 do Arduino Fio Cinza
int rxpin = 10 , txpin =11;
char c;
float tara = 0 ;
HX711 balanca;   // define instancia balança HX711
SoftwareSerial bt(rxpin, txpin);
float calibration_factor = 24411.16;   
 
void setup(){
  bt.begin(9600);
  Serial.begin(9600);   
  balanca.begin(DOUT, CLK);  
  balanca.set_scale(calibration_factor); 
  balanca.tare();
  tara = (balanca.get_units(),3);
  Serial.println(String(tara));
  c=0;
}
 
void loop(){
  c = bt.read();
  if (c == 112){ //p
    bt.print(balanca.get_units() ,2);
    digitalWrite(13, HIGH);
    delay(1000);
    digitalWrite(13, LOW);
  }

  if (c == 116){ //t
     balanca.tare();
     tara = (balanca.get_units(),3);
  }
}
