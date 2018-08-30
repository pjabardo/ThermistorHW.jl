// Get 1-wire Library here: http://www.pjrc.com/teensy/td_libs_OneWire.html
#include <OneWire.h>

//Get DallasTemperature Library here:  http://milesburton.com/Main_Page?title=Dallas_Temperature_Control_Library
#include <DallasTemperature.h>

/*-----( Declare Constants and Pin Numbers )-----*/
#define ONE_WIRE_BUS_PIN 2

/*-----( Declare objects )-----*/
// Setup a oneWire instance to communicate with any OneWire devices
OneWire oneWire(ONE_WIRE_BUS_PIN);

// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);

/*-----( Declare Variables )-----*/
// Assign the addresses of your 1-Wire temp sensors.
// See the tutorial on how to obtain these addresses:
// http://www.hacktronics.com/Tutorials/arduino-1-wire-address-finder.html

uint8_t Probe01[] = { 0x28, 0xFF, 0x5A, 0xB6, 0x82, 0x15, 0x02, 0x7A }; 
uint8_t Probe02[] = { 0x28, 0xFF, 0x8E, 0xDE, 0x82, 0x15, 0x02, 0xB7 }; 
uint8_t Probe03[] = { 0x28, 0xFF, 0xC1, 0xF8, 0x82, 0x15, 0x02, 0x48 }; 
uint8_t Probe04[] = { 0x28, 0xFF, 0x7E, 0x0A, 0x82, 0x15, 0x03, 0x40 }; 
//uint8_t Probe05[] = { 0x28, 0xFF, 0xAF, 0xF3, 0x82, 0x15, 0x02, 0x6F }; 


#define NDEVS 4
uint8_t *addrs[NDEVS];


void setup()   /****** SETUP: RUNS ONCE ******/
{
  addrs[0] = Probe01;
  addrs[1] = Probe02;
  addrs[2] = Probe03;
  addrs[3] = Probe04;
  //addrs[4] = Probe05;
  
  // start serial port to show results
  Serial.begin(9600);
  
  // Initialize the Temperature measurement library
  sensors.begin();
  
  // set the resolution to 12 bit (Can be 9 to 12 bits .. lower is faster)
  for (int i = 0; i < NDEVS; ++i){
    sensors.setResolution(addrs[i], 12);
  }

}//--(end setup )---


void loop()   /****** LOOP: RUNS CONSTANTLY ******/
{
  //delay(200);
  
  // Command all devices on bus to read temperature  
  sensors.requestTemperatures();  

  Serial.print("IPTT\t");
  Serial.print(millis());
  for (int i = 0; i < NDEVS; ++i){
    Serial.print("\t");
    Serial.print(sensors.getTempC(addrs[i]));
    
  }
  Serial.println();
  
}//--(end main loop )---


