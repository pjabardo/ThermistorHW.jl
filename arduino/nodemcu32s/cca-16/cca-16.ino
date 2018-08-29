/*
  ESP 32 Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
  The ESP32 has an internal blue LED at D2 (GPIO 02)
*/

const int NSAMPLES = 1154;

//const int AICHANS[] = {35, 34, 39, 36, 26, 25, 33, 32, 13, 12, 14, 27, 15, 2, 0, 4};
//const int NCHANS = 16;

const int AICHANS[] = {35, 34, 39, 36, 26, 25, 33, 32, 13, 12, 14, 27, 15,  4};
const int NCHANS = 14;


int aivals[NCHANS];


void readchans(const int chans[], int nchans, int aival[], int nsamples){

  for (int k = 0; k < nchans; ++k){
    aival[k] = 0;
  }

  for (int i = 0; i < nsamples; ++i){
    for (int k = 0; k < nchans; ++k){
      aival[k] += analogRead(chans[k]);  
    }
  }

  for (int k = 0; k < nchans; ++k){
    aival[k] /= nsamples;
  }
  
}

void setup() 
{
  //for (int i = 0; i < NCHANS; ++i){
    //pinMode(AICHANS[i], INPUT);
     
  //}
  Serial.begin(9600);
  
  
}


void loop() 
{
  int t1 = millis();
  //readchans(AICHANS, NCHANS, aivals, NSAMPLES);
  
  //Serial.printf("IPT\t%d", t1);
  //for (int k = 0; k < NCHANS; ++k){
  //  Serial.printf("\t%d", aivals[k]);
  //}

  //Serial.printf("\n");
  

  
}

