// Written by Bharatraj Elavarasan, 2026 (Original Written by Dave Yonkers,
// 2020)
#include "EasyTimer.h"

// creates a timer with the desired frequency.
EasyTimer::EasyTimer(int freq) {
  freq_ = freq;
  // us_ = 1000000 / freq; // microseconds delay
  ms_ = 1000 / freq;  // milliseconds delay

  last_time_ = HAL_GetTick();
}

// this function returns true if it is time, false if time has not been reached
// yet
bool EasyTimer::check() {
  if (enabled_ && (HAL_GetTick() - last_time_ >= ms_)) {
    last_time_ = HAL_GetTick();  // reset the timer
    return true;
  } else {
    return false;
  }
}

// this function returns true if it is time, false if time has not been reached
// yet - same as check()
bool EasyTimer::isup() { return this->check(); }

// this function returns true if it is time, false if time has not been reached
// yet - same as check()
bool EasyTimer::is_up() { return this->check(); }

void EasyTimer::set_frequency(int freq) {
  freq_ = freq;
  // us_ = 1000000 / freq; // microseconds delay
  ms_ = 1000 / freq;  // milliseconds delay
}

void EasyTimer::set_delay_millis(int ms) {
  freq_ = 1000 / ms;
  ms_ = ms;
}

void EasyTimer::reset() {
  last_time_ = HAL_GetTick();  // sets the last time to the current time
}

// creates a LED Blink with the desired frequency.
LEDBlink::LEDBlink(GPIO_TypeDef* port, uint16_t pin, int freq) {
  led_port_ = port;
  led_pin_ = pin;
  freq_ = freq;
  ms_ = 1000 / freq;  // millseconds delay
  last_time_ = HAL_GetTick();
  led_on_ = false;

  GPIO_InitTypeDef GPIO_InitStruct = {0};  // zero-initialize all fields first
  GPIO_InitStruct.Pin = led_pin_;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;

  HAL_GPIO_Init(led_port_, &GPIO_InitStruct);  // initialize the pin
}

// update the frequency of LED blinking
void LEDBlink::set_frequency(int freq) {
  freq_ = freq;
  ms_ = 1000 / freq;  // microseconds delay
}

// check to see what state the LED is on and if we should update it
void LEDBlink::run() {
  if (HAL_GetTick() - last_time_ >= ms_) {
    last_time_ = HAL_GetTick();  // reset the timer

    // do the LED stuffs
    if (led_on_) {
      led_on_ = false;
      HAL_GPIO_WritePin(led_port_, led_pin_, GPIO_PIN_RESET);
    } else {
      led_on_ = true;
      HAL_GPIO_WritePin(led_port_, led_pin_, GPIO_PIN_SET);
    }
  }
}