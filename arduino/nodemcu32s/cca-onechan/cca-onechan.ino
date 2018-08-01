/*
  ESP 32 Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
  The ESP32 has an internal blue LED at D2 (GPIO 02)
*/

const int NSAMPLES = 1125;
const float VMAX = 3.3;
const int AICHAN = 36;


// Ler nsamples de um canal analógico
float airead(int chan, int nsamples=5000){
  int ival = 0;
  for (int i = 0; i < nsamples; ++i){
    ival += analogRead(chan);
  }
  return (ival/nsamples) * (VMAX/4095);
}

    
float clamp(float x, float xmin, float xmax){
  if (x < xmin){
    return xmin;
  }else if (x > xmax){
    return xmax;
  }else{
    return x;
  }
}

int sgn(float x){
  if (x < 0) {
    return -1;
  }else{
    return 1;
  }
  
}

void setup() 
{
  
  pinMode(AICHAN, INPUT);
  Serial.begin(115200);
  
  
}

void simpledaq(int chan, int nsamples, int iout[]){

  for (int i = 0; i < nsamples; ++i){
    iout[i] = analogRead(chan);
  }
  
}
void loop() 
{

  
  float V = airead(AICHAN, 5000) + 0.15;
  
  Serial.printf("%2.3f\n", V);
  
  /*
  int nsp = 10000;
  int ns = 100;
  float volt[ns];
  for (int i = 0; i < ns; ++i){
    volt[i] = airead(AICHAN, nsp);
  }
  
  for (int i = 0; i < ns; ++i){
    Serial.printf("%f\n", volt[i]);
  }
*/
  //delay(2000);
  
/*
  int t1;
  int t2;
  int t3;
  int ns = 100;
  int ns2 = 100;
  
  float volt[ns];

  t1 = micros();
  for (i in 0; i < ns; ++i){
    volt[i] = airead(AICHAN, ns2);
  }
  simpledaq(AICHAN, ns, volt);
  t2 = micros();
  float freq = ns * 1e6/(t2 - t1);
  //Serial.println("======");
  //Serial.println(freq);
  for (int i = 0; i < ns; ++i){
    Serial.println(volt[i]);
  }
  delay(2000);
  */
  /*

  
  float V;
  float Vn;
  
  for (x = 0.1; x < 1.01; x+=0.1){
    Vn = x * VMAX;
    ledcWrite(PWM_CHAN, x2pwm(x)); 
    delay(1000);
    V = 0.0;
    for (int i = 0; i < 50; ++i){
      V += airead(AICHAN, 5000); 
      
      //Serial.printf("%f\t%f\t%f\n", x, Vn, V);
      }
      Serial.printf("%f\n", V/50.0);
  }
  
  */
}

