#pragma once
#include "stm32g4xx_hal.h"

inline void gpioClockEnable(GPIO_TypeDef* port) {
  if      (port == GPIOA) __HAL_RCC_GPIOA_CLK_ENABLE();
  else if (port == GPIOB) __HAL_RCC_GPIOB_CLK_ENABLE();
  else if (port == GPIOC) __HAL_RCC_GPIOC_CLK_ENABLE();
  else if (port == GPIOD) __HAL_RCC_GPIOD_CLK_ENABLE();
  else if (port == GPIOE) __HAL_RCC_GPIOE_CLK_ENABLE();
  else if (port == GPIOF) __HAL_RCC_GPIOF_CLK_ENABLE();
  else if (port == GPIOG) __HAL_RCC_GPIOG_CLK_ENABLE();
}

inline void gpioInit(GPIO_TypeDef* port, uint16_t pin, uint32_t mode,
                     uint32_t pull = GPIO_NOPULL,
                     uint32_t speed = GPIO_SPEED_FREQ_LOW) {
  gpioClockEnable(port);
  GPIO_InitTypeDef init = {0};
  init.Pin = pin;
  init.Mode = mode;
  init.Pull = pull;
  init.Speed = speed;
  HAL_GPIO_Init(port, &init);
}