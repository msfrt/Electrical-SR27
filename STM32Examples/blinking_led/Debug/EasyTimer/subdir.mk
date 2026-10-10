################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
/Users/bharatelav/Documents/Formula/Software/Electrical-SR27/STM32Libraries/EasyTimer/EasyTimer.cpp 

OBJS += \
./EasyTimer/EasyTimer.o 

CPP_DEPS += \
./EasyTimer/EasyTimer.d 


# Each subdirectory must supply rules for building sources it contributes
EasyTimer/EasyTimer.o: /Users/bharatelav/Documents/Formula/Software/Electrical-SR27/STM32Libraries/EasyTimer/EasyTimer.cpp EasyTimer/subdir.mk
	arm-none-eabi-g++ "$<" -mcpu=cortex-m33 -std=gnu++14 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32H503xx -c -I/Users/bharatelav/Documents/Formula/Software/Electrical-SR27/STM32Libraries/EasyTimer -I../Core/Inc -I../Drivers/STM32H5xx_HAL_Driver/Inc -I../Drivers/STM32H5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32H5xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-use-cxa-atexit -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-EasyTimer

clean-EasyTimer:
	-$(RM) ./EasyTimer/EasyTimer.cyclo ./EasyTimer/EasyTimer.d ./EasyTimer/EasyTimer.o ./EasyTimer/EasyTimer.su

.PHONY: clean-EasyTimer

