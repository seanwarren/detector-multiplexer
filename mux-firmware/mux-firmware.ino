#include "Debounce.h"

Debounce bouncer;

int state = 0;
int cur_detector = 0;

int line = 0;

const int framePin  = 1;
const int linePin   = 2;
const int muxPin    = 3;
const int buttonPin = 4;

const int segA = 5;
const int segGnd = 12;


const int pattern[5][7] = {{LOW,  LOW,  LOW,  LOW,  LOW,  LOW,  HIGH},
                           {HIGH, LOW,  LOW,  HIGH, HIGH, HIGH, HIGH},
                           {LOW,  LOW,  HIGH, LOW,  LOW,  HIGH, LOW},
                           {LOW,  LOW,  LOW,  LOW,  HIGH, HIGH, LOW},
                           {HIGH, LOW,  LOW,  HIGH, HIGH, LOW,  LOW}};

void writeNumber(int value)
{
  for(int i=0; i<7; i++)
    digitalWrite(segA+i, pattern[value][i]);  
}

void setState()
{
  if (state == 0) 
     digitalWrite(muxPin, LOW);
  else if (state == 1)
     digitalWrite(muxPin, HIGH);    

  if (state == 0)
    SerialUSB.write("Detector 1\n");
  else if (state == 1)
    SerialUSB.write("Detector 2\n");
  else if (state == 2)
    SerialUSB.write("Interleaved\n");
}

void line_clock()
{
  if (state == 2)
  {
    cur_detector = 1-cur_detector;
    digitalWrite(muxPin, cur_detector);  
  }
}

void frame_clock()
{
  cur_detector = 1;
}


void setup() {
  // put your setup code here, to run once:
  SerialUSB.begin(9600);
  
  
  pinMode(segGnd, OUTPUT);
  for(int i=0; i<7; i++)
  {
    pinMode(segA+i, OUTPUT);
    digitalWrite(segA+i, LOW);
  }

  digitalWrite(segGnd, HIGH);

  bouncer.attach(buttonPin);

  attachInterrupt(linePin, line_clock, RISING);
  attachInterrupt(framePin, frame_clock, RISING);
}

void loop() 
{
  if (bouncer.update() && !bouncer.read())
  {
    state = (state + 1) % 3;
    setState();
    writeNumber(state+1);
  }

  if (SerialUSB.available() > 0) 
  {
    // get incoming byte:
    char inByte = SerialUSB.read();

    switch (inByte)
    {
      case '0':
        state = 0;
        setState();
        break;
      case '1':
        state = 1;
        setState();
        break;
      case '2':
        state = 2;
        setState();
        break;
      case 'I':
        SerialUSB.write("Detector Multiplexer v1.2\n");
        setState();
        break;
      case 'S':
        setState();
        break;
    }
  }
  
}
