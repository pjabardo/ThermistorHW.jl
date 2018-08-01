/*
  ESP 32 Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
  The ESP32 has an internal blue LED at D2 (GPIO 02)
*/

const int FREQ = 2000; // Frequencia do PWM
const int PWM_CHAN = 0;
const int GPIO_PWM = 22;
const int PWM_RESOLUTION = 12;
const int AICHAN = 4;
const int NSAMPLES = 1125;

// Constantes de operação do anemômetro
const float Tw = 75.0;
const float Ta = 20.0;
const float R0 = 5e3;
const float Tref = 20.0;
const float B = 3e3;

const float Ei = 24.0;
const float Ri = 100.0;
const float XMIN = 0.1;
const float XMAX = 0.9;
const float DXMAX = 0.1;

// Constantes do controlador de temperatura
const float alpha1 = 0.012;
const float alpha2 = 0.008;

const float dt = 0.1;
float Rw;
float Ra;
float xval; 
float Temp;
float Tm1;
float Rlast;

int LED_BUILTIN = 2;

// Calcula a a resistência de um termistor a partir da temperatura
float therm_resist(float temp, float R0=5e3, float B=3e3, float Tref=20.0){
  return R0 * exp(B * (1.0/(temp + 273.15) - 1.0 / (Tref + 273.15)));
}

// Calcula a temperatura de um termistor a partir da resistência
float therm_temp(float R, float R0=5e3, float B=3e3, float Tref=20.0){
  float term = 1.0/(Tref + 273.15) + 1.0/B * log(R/R0);
  return 1.0/term - 273.15;
}

// Ler nsamples de um canal analógico
float airead(int chan, int nsamples=5000){
  int ival = 0;
  for (int i = 0; i < nsamples; ++i){
    ival += analogRead(chan);
  }
  return (ival/nsamples) * (3.28/4095);
}

// Calcula a resistência do sensor/termistor a partir da tensão medida em Ri
float cta_resist(float Eo, float x, float Ei=24.0, float Ri=100.0){
  return Ri*(x * Ei/Eo - 1.0);
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
float xcontrol(float x, float Tw, float T, float Tm1, float dt, float a1, float a2){

  float dT = (T - Tm1) ;

  float dx = - a1*dT - a2 * dt * (T - Tw);
  int s = sgn(dx);
  if (abs(dx) > DXMAX){
    dx = DXMAX * s;
  }

  return clamp(x + dx, 0.1, 0.9);
    
}

int x2pwm(float x, int imax=4095){
  return (int) (x * imax);
}
void setup() 
{
  Rw = therm_resist(Tw, R0, B, Tref);
  Ra = therm_resist(Ta, R0, B, Tref) * 0.95;
  
  ledcSetup(PWM_CHAN, FREQ, PWM_RESOLUTION);
  ledcAttachPin(GPIO_PWM, PWM_CHAN);
  pinMode(AICHAN, INPUT);
  Serial.begin(115200);
  
  Temp = Ta + 1.0;
  Tm1 = Temp;
  ledcWrite(PWM_CHAN, x2pwm(0.2));
  delay(200);
  xval = 0.2;
  Rlast = Ra;
  ledcWrite(PWM_CHAN, x2pwm(xval));
  delay(dt);
  
  
}

void loop() 
{

  
  int t1 = micros();

  Tm1 = Temp;
  
  float Eo = airead(AICHAN, NSAMPLES)+0.15;
  float Rt;
  
  if (Eo < 0.1){
    Rt = Rlast;
  }else{
    Rt = cta_resist(Eo, xval, Ei, Ri);
    Rlast = Rt;
  }

  Temp = therm_temp(Rt, R0, B, Tref);


  //float xcontrol(float x, float Tw, float T, float Tm1, float dt, float a1, float a2){

  float xval2;
  xval = xcontrol(xval, Tw, Temp, Tm1, dt, alpha1, alpha2);
  
  int ix = x2pwm(xval);

  ledcWrite(PWM_CHAN, ix);


  Serial.print(Eo);
  Serial.print("\t");
  Serial.print(xval);
  Serial.print("\t");
  Serial.print(Rt);
  Serial.print("\t");
  Serial.print(Temp);
  Serial.print("\t");
  int t2 = micros();
  delay(88);
  Serial.println((t2-t1)/1000);
  
  //delay(500);
}

