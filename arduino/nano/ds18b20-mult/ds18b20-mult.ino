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

DeviceAddress Probe01 = { 0x28, 0xFF, 0x5A, 0xB6, 0x82, 0x15, 0x02, 0x7A }; 
DeviceAddress Probe02 = { 0x28, 0xFF, 0x8E, 0xDE, 0x82, 0x15, 0x02, 0xB7 }; 
DeviceAddress Probe03 = { 0x28, 0xFF, 0xC1, 0xF8, 0x82, 0x15, 0x02, 0x48 }; 
DeviceAddress Probe04 = { 0x28, 0xFF, 0x7E, 0x0A, 0x82, 0x15, 0x03, 0x40 }; 
DeviceAddress Probe05 = { 0x28, 0xFF, 0xAF, 0xF3, 0x82, 0x15, 0x02, 0x6F }; 


void setup()   /****** SETUP: RUNS ONCE ******/
{
  // start serial port to show results
  Serial.begin(9600);
  Serial.print("Initializing Temperature Control Library Version ");
  Serial.println(DALLASTEMPLIBVERSION);
  
  // Initialize the Temperature measurement library
  sensors.begin();
  
  // set the resolution to 12 bit (Can be 9 to 12 bits .. lower is faster)
  sensors.setResolution(Probe01, 12);
  sensors.setResolution(Probe02, 12);
  sensors.setResolution(Probe03, 12);
  sensors.setResolution(Probe04, 12);
  sensors.setResolution(Probe05, 12);

}//--(end setup )---

void loop()   /****** LOOP: RUNS CONSTANTLY ******/
{
  delay(1000);
  Serial.println();
  Serial.print("Number of Devices found on bus = ");  
  Serial.println(sensors.getDeviceCount());   
  Serial.print("Getting temperatures... ");  
  Serial.println();   
  
  // Command all devices on bus to read temperature  
  sensors.requestTemperatures();  
  
  Serial.print("Probe 01 temperature is:   ");
  printTemperature(Probe01);
  Serial.println();

  Serial.print("Probe 02 temperature is:   ");
  printTemperature(Probe02);
  Serial.println();
 
  Serial.print("Probe 03 temperature is:   ");
  printTemperature(Probe03);
  Serial.println();
   
  Serial.print("Probe 04 temperature is:   ");
  printTemperature(Probe04);
  Serial.println();
  
  Serial.print("Probe 05 temperature is:   ");
  printTemperature(Probe05);
  Serial.println();
   
  
}//--(end main loop )---

/*-----( Declare User-written Functions )-----*/
void printTemperature(DeviceAddress deviceAddress)
{

float tempC = sensors.getTempC(deviceAddress);

   if (tempC == -127.00) 
   {
   Serial.print("Error getting temperature  ");
   } 
   else
   {
   Serial.print("C: ");
   Serial.print(tempC);
   Serial.print(" F: ");
   Serial.print(DallasTemperature::toFahrenheit(tempC));
   }
}// End printTemperature
//*********( THE END )***********

