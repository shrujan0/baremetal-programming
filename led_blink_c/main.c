#include "stm32f401_gpio.h"

#define GPIOCEN (1U << 2) //3rd bit to enable GPIO
#define LED_PIN (1U << 13)

void led_init(void) {
    //
    RCC->AHB1ENR |= GPIOCEN;

    //Set led pin as output
    GPIOC->MODER |= (1U << 26);
    GPIOC->MODER &= ~(1U << 27);
}

void led_on(void) {
    //set led pin HIGH (PC13)
    GPIOC->ODR |= LED_PIN;
}

void led_off(void) {
    //set led pin low (PC13)
    GPIOC->ODR &= ~LED_PIN;
}

int main(void) {
    led_init();

    while(1) {
        led_on();
        for (int i = 0; i < 1000000; i++) {}
        led_off();
        for (int i = 0; i < 1000000; i++) {}
    }
}