/************************************************************************

	LED support for Microblaze
	Pavel Sukharev, Yurik V. Nikiforoff
	NOKB GP, jul 2008

************************************************************************/

#include "leds.h"
#include "fpga.h"
#include "xgpio.h"
#include "xparameters.h"

extern XGpio  led_gpio; // LED instance

#define LED_Channel   1

char _global_led_state=0;

void led( int bit )
{
	_global_led_state = bit;
	//wr(REG_LED, _global_led_state);
}

void set_led( int bit )
{
	_global_led_state = _global_led_state | (1 << bit);
	XGpio_DiscreteWrite(&led_gpio, LED_Channel, _global_led_state);
}

void reset_led( int bit )
{
	_global_led_state = _global_led_state & ~(1 << bit);
	XGpio_DiscreteWrite(&led_gpio, LED_Channel, _global_led_state);
}

void toggle_led( int bit )
{
	_global_led_state = _global_led_state ^ (1 << bit);
	XGpio_DiscreteWrite(&led_gpio, LED_Channel, _global_led_state);
}
