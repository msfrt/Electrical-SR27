#include "ReadADC.h"

// constructor
// param channel - The channel of the ADC that this sensor is on
// param zero_mV - the millivolt where the sensor is equal to zero
// param mV_per_sensor_unit - the millivolts per units measured (ex. mV per degree C)
ADCSensor::ADCSensor(unsigned int channel, int zero_mV, int mV_per_sensor_unit){

  this->channel_ = channel;
  this->zero_mV_ = zero_mV;
  this->mV_per_sensor_unit_ = mV_per_sensor_unit;

  this->read_value_ = 0;
  this->read_mvoltage_ = 0;
  this->running_read_total_ = 0; // used to store values for an average calculation
  this->running_read_count_ = 0;
  this->read_min_ = 4095; // max value of a read
  this->read_max_ = 0;

  this->actual_avg_ = 0;
  this->actual_min_ = 0;
  this->actual_max_ = 0;
  this->values_updated_ = false;
}

void ADCChip::begin(){
  // set the chip select pin as an output:
  GPIO_InitTypeDef GPIO_InitStruct = [0]; // zero-initialize all fields first
  GPIO_InitStruct.Pin = this->chip_select_pin_;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;

  HAL_GPIO_Init(chip_select_port_, &GPIO_InitStruct);

  // set the chip select pin high
  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);
}