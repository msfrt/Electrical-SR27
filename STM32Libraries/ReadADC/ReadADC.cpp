#include "ReadADC.h"
#include "GpioUtil.h"

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
  gpioInit(chip_select_port_, chip_select_pin_, GPIO_MODE_OUTPUT_PP,)

  // set the chip select pin high
  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);
}

// read the sample value and add it to the appropriate variables
void ADCSensor::sample(int value){

  this->read_value_ = value;

  // if the read value is less than the current minimum, it is the new minimum
  if (value < this->read_min_){this->read_min_ = value;}

  // if the read value is more than the current maximum, it is the new maximum
  if (value> this->read_max_){this->read_max_ = value;}

  // add the read value to the running total for average calculation and increment the read counter
  this->running_read_total_ += value;
  this->running_read_count_++;

  // there is at least one new sample since calculating the actual values, so set the values_updated_ bool to false
  this->values_updated_ = false;
}

// resets the sampling variables
void ADCSensor::reset(){
  this->running_read_total_ = 0;
  this->running_read_count_ = 0;
  this->read_min_ = 4095;
  this->read_max_ = 0;
}

void ADCSensor::calculate(){

  float mV = 0.00; // initialize a temp variable only once to save processing power

  // calculate the average values
  float sensor_read_avg = static_cast<float>(this->running_read_total_) / this->running_read_count_;
  mV = (sensor_read_avg / 4095.0f) * 5000.0f; // read 0 = 0V, 4095 = 5V. 5000mV = 5V.
  this->actual_avg_ = (mV - this->zero_mV_) / this->mV_per_sensor_unit_; // calculates the sensor value

  // set the last calculated mv average to the mv getter variable
  this->read_mvoltage_ = mV;

  // calculate the min values
  mV = (static_cast<float>(this->read_min_) / 4095.0f) * 5000.0f;
  this->actual_min_ = (mV - this->zero_mV_) / this->mV_per_sensor_unit_;

  // calculate the max values
  mV = (static_cast<float>(this->read_max_) / 4095.0f) * 5000.0f;
  this->actual_max_ = (mV - this->zero_mV_) / this->mV_per_sensor_unit_;

  this->reset();
  this->values_updated_ = true;
}

float ADCSensor::avg(){
  if (!values_updated_){ // if the values are not the most current, update them before returning the average!
    this->calculate();
  }
  return this->actual_avg_;
}

float ADCSensor::min(){
  if (!values_updated_){ // if the values are not the most current, update them before returning the average!
    this->calculate();
  }
  return this->actual_min_;
}

float ADCSensor::max(){
  if (!values_updated_){ // if the values are not the most current, update them before returning the average!
    this->calculate();
  }
  return this->actual_max_;
}

void ADCChip::sample(ADCSensor &sensor0){

  // Start the SPI communication
 
  // In order to tell the ADC which input to read you must send it a binary value corresponding to the channel.
  // ADC_channel_number should be a value between 0 and 7 corresponding to the input you want to read. The binary
  // representation of this value must be bit shifted so that it is in the correct position during the SPI communication
  // sequence. The SPI sequence lasts 16 clock cycles so both the sent value and recieved value are 16 bits, one for
  // each clock cycle.
  //
  // Example: The the position of the channelNo must be in the following position
  // "00XXX00000000000", (X represents the position) as defined by the ADC's datasheet. To achieve this, the value
  // input into this function is bit shifted by 11 to the left. The transfer sends this value and returns
  // the value sent back by the ADC.
  //
  // One last thing to note is that the ADC returns the read value in the SECOND transaction. So, if you
  // individually sample every ADC channel, you essentially need two transactions for every read. This is why
  // it's better for you to chain channel readings using a multi-sample function

  // timeout constant
  static constexpr uint32_t kSpiTimeoutMs = 10;

  // send the channel number for the ADC to read
  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;

  // transaction 1: send the channel number
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11); // shift because adc wants data formatted like that
  tx[0] = (uint8_t)(cmd >> 8);     // high byte first (MSB first)
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
  
  // transaction 2: send a dummy word, the reply is the reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(((uint16_t)rx[0] << 8) | rx[1]);

  // end the SPI communication

}

void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1){

  // timeout constant
  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send a dummy word, the reply is sensor1's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
}


void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1, ADCSensor &sensor2){

  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0, reply2 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send sensor2's channel, the reply is sensor1's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor2.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 4: send a dummy word, the reply is sensor2's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply2 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
  sensor2.sample(reply2);
}


void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1, ADCSensor &sensor2, ADCSensor &sensor3){

  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0, reply2 = 0, reply3 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send sensor2's channel, the reply is sensor1's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor2.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 4: send sensor3's channel, the reply is sensor2's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor3.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply2 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 5: send a dummy word, the reply is sensor3's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply3 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
  sensor2.sample(reply2);
  sensor3.sample(reply3);
}


void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1, ADCSensor &sensor2, ADCSensor &sensor3, ADCSensor &sensor4){

  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0, reply2 = 0, reply3 = 0, reply4 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send sensor2's channel, the reply is sensor1's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor2.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 4: send sensor3's channel, the reply is sensor2's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor3.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply2 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 5: send sensor4's channel, the reply is sensor3's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor4.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply3 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 6: send a dummy word, the reply is sensor4's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply4 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
  sensor2.sample(reply2);
  sensor3.sample(reply3);
  sensor4.sample(reply4);
}


void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1, ADCSensor &sensor2, ADCSensor &sensor3, ADCSensor &sensor4, ADCSensor &sensor5){

  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0, reply2 = 0, reply3 = 0, reply4 = 0, reply5 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send sensor2's channel, the reply is sensor1's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor2.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 4: send sensor3's channel, the reply is sensor2's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor3.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply2 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 5: send sensor4's channel, the reply is sensor3's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor4.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply3 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 6: send sensor5's channel, the reply is sensor4's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor5.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply4 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 7: send a dummy word, the reply is sensor5's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply5 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
  sensor2.sample(reply2);
  sensor3.sample(reply3);
  sensor4.sample(reply4);
  sensor5.sample(reply5);
}


void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1, ADCSensor &sensor2, ADCSensor &sensor3, ADCSensor &sensor4, ADCSensor &sensor5, ADCSensor &sensor6){

  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0, reply2 = 0, reply3 = 0, reply4 = 0, reply5 = 0, reply6 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send sensor2's channel, the reply is sensor1's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor2.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 4: send sensor3's channel, the reply is sensor2's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor3.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply2 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 5: send sensor4's channel, the reply is sensor3's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor4.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply3 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 6: send sensor5's channel, the reply is sensor4's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor5.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply4 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 7: send sensor6's channel, the reply is sensor5's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor6.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply5 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 8: send a dummy word, the reply is sensor6's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply6 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
  sensor2.sample(reply2);
  sensor3.sample(reply3);
  sensor4.sample(reply4);
  sensor5.sample(reply5);
  sensor6.sample(reply6);
}


void ADCChip::sample(ADCSensor &sensor0, ADCSensor &sensor1, ADCSensor &sensor2, ADCSensor &sensor3, ADCSensor &sensor4, ADCSensor &sensor5, ADCSensor &sensor6, ADCSensor &sensor7){

  static constexpr uint32_t kSpiTimeoutMs = 10;

  uint8_t tx[2];
  uint8_t rx[2];
  HAL_StatusTypeDef st;
  uint16_t reply0 = 0, reply1 = 0, reply2 = 0, reply3 = 0, reply4 = 0, reply5 = 0, reply6 = 0, reply7 = 0;

  // transaction 1: send sensor0's channel (the reply is junk)
  uint16_t cmd = (uint16_t)(sensor0.get_channel() << 11);
  tx[0] = (uint8_t)(cmd >> 8);
  tx[1] = (uint8_t)(cmd & 0xFF);

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_RESET);  // CS low
  st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);

  // transaction 2: send sensor1's channel, the reply is sensor0's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor1.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply0 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 3: send sensor2's channel, the reply is sensor1's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor2.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply1 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 4: send sensor3's channel, the reply is sensor2's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor3.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply2 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 5: send sensor4's channel, the reply is sensor3's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor4.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply3 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 6: send sensor5's channel, the reply is sensor4's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor5.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply4 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 7: send sensor6's channel, the reply is sensor5's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor6.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply5 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 8: send sensor7's channel, the reply is sensor6's reading
  if (st == HAL_OK) {
    cmd = (uint16_t)(sensor7.get_channel() << 11);
    tx[0] = (uint8_t)(cmd >> 8);
    tx[1] = (uint8_t)(cmd & 0xFF);
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply6 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  // transaction 9: send a dummy word, the reply is sensor7's reading
  if (st == HAL_OK) {
    tx[0] = 0;
    tx[1] = 0;
    st = HAL_SPI_TransmitReceive(spi_, tx, rx, 2, kSpiTimeoutMs);
    reply7 = ((uint16_t)rx[0] << 8) | rx[1];
  }

  HAL_GPIO_WritePin(chip_select_port_, chip_select_pin_, GPIO_PIN_SET);    // CS high

  if (st != HAL_OK) return;

  sensor0.sample(reply0);
  sensor1.sample(reply1);
  sensor2.sample(reply2);
  sensor3.sample(reply3);
  sensor4.sample(reply4);
  sensor5.sample(reply5);
  sensor6.sample(reply6);
  sensor7.sample(reply7);
}
