#include <Arduino.h>

class Debounce
{
public:
  void attach(int buttonPin_)
  {
    buttonPin = buttonPin_;
    pinMode(buttonPin, INPUT);
    digitalWrite(buttonPin, HIGH); 
  }

  bool update()
  {
    bool updated = false;
    // read the state of the switch into a local variable:
    int reading = digitalRead(buttonPin);
    
    // check to see if you just pressed the button
    // (i.e. the input went from LOW to HIGH),  and you've waited
    // long enough since the last press to ignore any noise:
    
    // If the switch changed, due to noise or pressing:
    if (reading != lastButtonState) 
      lastDebounceTime = millis();
    
    if ((millis() - lastDebounceTime) > debounceDelay) 
    {
    // whatever the reading is at, it's been there for longer
    // than the debounce delay, so take it as the actual current state:
    
      // if the button state has changed:
      if (reading != buttonState) 
      {
        buttonState = reading;
        updated = true;
      }
    }

    // save the reading.  Next time through the loop,
    // it'll be the lastButtonState:
    lastButtonState = reading;  

    return updated;
  }

  int read()
  {
    return buttonState;
  }
  
private:  
  // Variables will change:
  int buttonPin;
  int buttonState;             // the current reading from the input pin
  int lastButtonState = LOW;   // the previous reading from the input pin

  // the following variables are long's because the time, measured in miliseconds,
  // will quickly become a bigger number than can be stored in an int.
  long lastDebounceTime = 0;  // the last time the output pin was toggled
  long debounceDelay = 50;    // the debounce time; increase if the output flickers
};

