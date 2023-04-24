

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xparameters.h"
#include "xil_types.h"

XGpio input;

void driverInit() {
	int status;
	status = XGpio_Initialize(&input, XPAR_AXI_GPIO_0_DEVICE_ID);
}

void configGpio(){
	XGpio_SetDataDirection(&input, 1, 1);
}

int main()
{
    init_platform();
    driverInit();
    configGpio();

    int8_t a; 

    while(1)
    {
    	a = XGpio_DiscreteRead(&input, 1);
    	xil_printf("\n\r %d", a);
    }

    cleanup_platform();
    return 0;
}
