#include <string.h>
#include <stdio.h>
#include <stdint.h>

#include "xtmrctr.h"
#include "microblaze_exceptions_g.h"

#include "platform.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xgpio.h"

#include <FreeRTOS.h>
#include "task.h"
#include "timers.h"
#include "queue.h"
#include "semphr.h"
#include "croutine.h"

#include "can_cmd.h"
#include "can_cmd_defs.h"
#include "can_freertos.h"

#include "xiic.h"
#include "xil_exception.h"
#include "xintc.h"

//#include "crc.h"
//#include "FreeRTOS_mb_hooks.h"
void mt_1(void *pvParameters);
void mt_2(void *pvParameters);
void mt_3(void *pvParameters);
void GetInclData(void);
void delay(uint32_t del);
// --------------------------------------------------------------------------

// --- I2C ------------------------------------------------------------------
#define IIC_DEVICE_ID	        XPAR_IIC_0_DEVICE_ID
#define INTC_DEVICE_ID	        XPAR_INTC_0_DEVICE_ID
#define IIC_INTR_ID	            XPAR_INTC_0_IIC_0_VEC_ID
#define INTC			        XIntc
#define INTC_HANDLER	        XIntc_InterruptHandler
//#define EEPROM_ADDRESS 		    0x54 	/* 0xA0 as an 8 bit number. */
//#define EEPROM_ADDRESS 		    0x50 	/* 0xA0 as an 8 bit number. */
//#define IIC_MUX_ADDRESS 		0x74
//#define IIC_EEPROM_CHANNEL		0x08
#define SLAVE_ADDRESS	0x50	/* 0xE0 as an 8 bit number. */
#define SEND_COUNT   	16
#define RECEIVE_COUNT   16
#define PAGE_SIZE       16

#define EEPROM_TEST_START_ADDRESS   1280//1024

//typedef u8 AddressType;
#define IIC_DEVICE_ID		XPAR_IIC_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_INTC_0_DEVICE_ID
#define INTC_IIC_INTERRUPT_ID	XPAR_INTC_0_IIC_0_VEC_ID

#define TEMP_SENSOR_ADDRESS	0x50 /* The actual address is 0x30 */

/**************************** Type Definitions *******************************/

typedef u16 AddressType;//u8 AddressType;

/************************** Function Prototypes ******************************/

//int IicEepromExample();
//int Iic_Init(void);
//int EepromWriteData(u16 ByteCount);
//int EepromReadData(u8 *BufferPtr, u16 ByteCount);
//static int SetupInterruptSystem(XIic *IicInstPtr);
//static void SendHandler(XIic *InstancePtr);
//static void ReceiveHandler(XIic *InstancePtr);
//static void StatusHandler(XIic *InstancePtr, int Event);
int IicRepeatedStartExample();
static int WriteData(u16 ByteCount);
static int ReadData(u8 *BufferPtr, u16 ByteCount);
static int SetupInterruptSystem(XIic *IicInstPtr);
static void SendHandler(XIic *InstancePtr);
static void ReceiveHandler(XIic *InstancePtr);
static void StatusHandler(XIic *InstancePtr, int Event);
void Iic_init(void);
//#ifdef IIC_MUX_ENABLE
//static int MuxInit(void);
//#endif
/************************** Variable Definitions *****************************/

XIic IicInstance;	/* The instance of the IIC device. */
XIntc InterruptController;
INTC Intc; 	/* The instance of the Interrupt Controller Driver */

//u8 WriteBuffer[sizeof(AddressType) + PAGE_SIZE];
u8 WriteBuffer[18];

//u8 ReadBuffer[PAGE_SIZE];	/* Read buffer for reading a page. */
u8 ReadBuffer[16];	/* Read buffer for reading a page. */

volatile u8 TransmitComplete;	/* Flag to check completion of Transmission */
volatile u8 ReceiveComplete;	/* Flag to check completion of Reception */

u8 EepromIicAddr;		/* Variable for storing Eeprom IIC address */

#define ddd *((volatile uint32_t *)(XPAR_AXI_PWM_0_BASEADDR))

uint32_t *to_fpga;

//void print(char *str);

#define LED_DEV_ID      XPAR_GPIO_0_DEVICE_ID   //LED ID
#define LED_Channel   1

#define I2C_NUM_INSTANCES	XPAR_XIIC_NUM_INSTANCES		// количество физических интерфейсов i2c

// Priorities at which the tasks are created
#define INIT_TASK_PRIORITY		( tskIDLE_PRIORITY )
#define MRTE_TASKS_PRIORITY 	( tskIDLE_PRIORITY+1 )
#define PT_MSMT_TASK_PRIORITY	( tskIDLE_PRIORITY+1 )
//#define INIT_TASK_PRIORITY	( tskIDLE_PRIORITY )
//#define MIKE_STACK_SIZE     (1024U)
//#define MIKE_STACK_SIZE     (256U)
XGpio    led_gpio; // LED instance
uint8_t flash = 0x00;
uint16_t ax, ay, az, hx, hy, hz, temperature, voltage;
uint32_t adr;
uint32_t temp;
uint8_t i, j = 0;
//static canmsg_t	candata;
int Status = 111;
uint8_t load = 0;

int main()
{
    init_platform();
    to_fpga = (uint32_t *)( XPAR_AXI_PWM_0_BASEADDR);//XPAR_AXI_PWM_0_BASEADDR

    XGpio_Initialize(&led_gpio, LED_DEV_ID);
    XGpio_SetDataDirection(&led_gpio, LED_Channel, 0x00);
    XGpio_DiscreteWrite(&led_gpio, LED_Channel, 0x0);

    //vApplicationSetupTimerInterrupt();
//    my_timer_continuos_start();
    microblaze_enable_interrupts();
    microblaze_enable_exceptions();

    //Status = Iic_Init();

    //xTaskCreate( mt_1, ( const char * )"MT_1", 256, NULL, MRTE_TASKS_PRIORITY, NULL );
    //init_mrte_tasks(MRTE_TASKS_PRIORITY);
    // ------------------------------

    Iic_init();
    // ------------------------------
    xTaskCreate( mt_1, ( const char * )"MT_2", 256, NULL, 1, NULL );
    xTaskCreate( mt_2, ( const char * )"MT_2", 4096, NULL, 1, NULL );
    xTaskCreate( mt_3, ( const char * )"MT_3", 256, NULL, 1, NULL );
    vTaskStartScheduler();

    while(1)    {
    	//IicEepromExample();
    	//    delay(100000);

    }
    return 0;
}

void mt_1(void *pvParameters){
//	static t_mrte_msg_buff * 	p_mrte_buff = NULL;
//	static TX_Com_buf_type *	TX_Com_buf_ponter;
//	static u8 base_tlm_counter;
//	static u8 ext_tlm_counter;
//	static u8 osc_tlm_counter;

	for(;;){
		//vTaskDelay(1);
		flash ^= 0x01;
		//TX_Com_buf_ponter = (TX_Com_buf_type*) &p_mrte_buff->buff->data.dU8[0];
		//p_mrte_buff->len = 7;
		//TX_Com_buf_ponter->CmdCode = COMMAND_GET_BASE_TLM;
		//TX_Com_buf_ponter->CmdMarker = base_tlm_counter++;
		//TX_Com_buf_ponter->Timer = 0x1234;

		//while(request_mrte_send(CAN_SEND_ASYNC, p_mrte_buff) == pdFALSE);
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);
		vTaskDelay(1);
	}
	vTaskDelete(NULL);
}
void mt_2(void *pvParameters){
	int Status;

	for(;;){
		flash ^= 0x02;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);

		/*
		 * Run the EEPROM example.
		 */
		//IicEepromExample();
		Status = IicRepeatedStartExample();
		//if (Status != XST_SUCCESS) {vTaskDelay(1);}
		vTaskDelay(300);


		//vTaskDelay(200);
	}
	vTaskDelete(NULL);
}

void mt_3(void *pvParameters){
	//volatile unsigned long ul;
	for(;;){
		//vTaskDelay(1);
		flash ^= 0x04;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);

		GetInclData();

		vTaskDelay(400);

	}
	vTaskDelete(NULL);
}
//--------------------------------------------
void GetInclData(void){
	uint8_t i, j = 0;
	uint32_t dataByte[5];
	adr = (1 << 31) + 1;
	for(i = 0; i < 5; i++){
	   temp = 0;
	   *(to_fpga) = adr;
	   *(to_fpga) = adr;
	   temp = ddd;
	   dataByte[j++] = temp;// & 0xFF;
	   adr++;
	}
	adr = 0;
	*(to_fpga) = adr;
	*(to_fpga) = adr;

	if(!CalcCRC(dataByte)){
	   hx = (dataByte[0] >> 16) & 0xFFFF;
	   ax =  dataByte[0] & 0xFFFF;
	   hy = (dataByte[1] >> 16) & 0xFFFF;
	   ay =  dataByte[1] & 0xFFFF;
	   hz = (dataByte[2] >> 16) & 0xFFFF;
	   az =  dataByte[2] & 0xFFFF;
	   temperature = (dataByte[3] >> 16) & 0xFFFF;
	   voltage = dataByte[3] & 0xFFFF;
	}

	//extern CalcCRC(dataByte);

	for(i = 0; i < 17; i++){
	  //q += dataByte[i];
	}
	//if(q) delay(1);

}
void Iic_init(void){
	u8 Index;
		int Status;
		XIic_Config *ConfigPtr;	/* Pointer to configuration data */

		/*
		 * Initialize the data to write and the read buffer.
		 */
		for (Index = 0; Index < SEND_COUNT; Index++) {
			WriteBuffer[Index] = Index;
			ReadBuffer[Index] = 0;
		}
		//WriteBuffer[0] =

		/*
		 * Initialize the IIC driver so that it is ready to use.
		 */
		ConfigPtr = XIic_LookupConfig(XPAR_IIC_0_DEVICE_ID);
		if (ConfigPtr == NULL) {
			return XST_FAILURE;
		}

		Status = XIic_CfgInitialize(&IicInstance, ConfigPtr,
						ConfigPtr->BaseAddress);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

		/*
		 * Setup the Interrupt System.
		 */
		Status = SetupInterruptSystem(&IicInstance);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

		/*
		 * Set the Transmit, Receive and Status handlers.
		 */
		XIic_SetSendHandler(&IicInstance, &IicInstance,
					(XIic_Handler) SendHandler);
		XIic_SetRecvHandler(&IicInstance, &IicInstance,
					(XIic_Handler) ReceiveHandler);
		XIic_SetStatusHandler(&IicInstance, &IicInstance,
					  (XIic_StatusHandler) StatusHandler);
}
//--============ I2C SECTION ================---------
int IicRepeatedStartExample(void)
{
	u8 Index;
			int Status;
			XIic_Config *ConfigPtr;	/* Pointer to configuration data */

	/*
	 * Set the Address of the Slave.
	 */
	Status = XIic_SetAddress(&IicInstance, XII_ADDR_TO_SEND_TYPE,
				 SLAVE_ADDRESS);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Write to the IIC Slave.
	 */
	Status = WriteData(SEND_COUNT);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Read from the IIC Slave.
	 */
	/*
	Status = ReadData(ReadBuffer, RECEIVE_COUNT);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
    */
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This function writes a buffer of data to IIC Slave.
*
* @param	ByteCount contains the number of bytes in the buffer to be
*		written.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
static int WriteData(u16 ByteCount)
{
	int Status;
	int BusBusy;

	/*
	 * Set the defaults.
	 */
	TransmitComplete = 1;

	/*
	 * Start the IIC device.
	 */
	Status = XIic_Start(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the Repeated Start option.
	 */
	IicInstance.Options = XII_REPEATED_START_OPTION;

	/*
	 * Send the data.
	 */
	Status = XIic_MasterSend(&IicInstance, WriteBuffer, ByteCount);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till data is transmitted.
	 */
	delay(100);//while (TransmitComplete) {}

	/*
	 * This is for verification that Bus is not released and still Busy.
	 */
	//BusBusy = XIic_IsIicBusy(&IicInstance);

	//TransmitComplete = 1;
	//IicInstance.Options = 0x0;

	/*
	 * Send the Data.
	 */
	//Status = XIic_MasterSend(&IicInstance, WriteBuffer, ByteCount);
	//if (Status != XST_SUCCESS) {
	//	return XST_FAILURE;
	//}

	/*
	 * Wait till data is transmitted.
	 */
	//while ((TransmitComplete) || (XIic_IsIicBusy(&IicInstance) == TRUE)) {
//
	//}

	/*
	 * Stop the IIC device.
	 */
	Status = XIic_Stop(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This function reads a data from the IIC Slave into a specified buffer.
*
* @param	BufferPtr contains the address of the data buffer to be filled.
* @param	ByteCount contains the number of bytes to be read.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
static int ReadData(u8 *BufferPtr, u16 ByteCount)
{
	int Status;
	int BusBusy;

	/*
	 * Set the defaults.
	 */
	ReceiveComplete = 1;

	/*
	 * Start the IIC device.
	 */
	Status = XIic_Start(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the Repeated Start option.
	 */
	IicInstance.Options = XII_REPEATED_START_OPTION;

	/*
	 * Receive the data.
	 */
	Status = XIic_MasterRecv(&IicInstance, BufferPtr, ByteCount);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till all the data is received.
	 */
	while (ReceiveComplete) {

	}

	/*
	 * This is for verification that Bus is not released and still Busy.
	 */
	BusBusy = XIic_IsIicBusy(&IicInstance);

	ReceiveComplete = 1;
	IicInstance.Options = 0x0;

	/*
	 * Receive the Data.
	 */
	Status = XIic_MasterRecv(&IicInstance, BufferPtr, ByteCount);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till all the data is received.
	 */
	while ((ReceiveComplete) || (XIic_IsIicBusy(&IicInstance) == TRUE)) {

	}

	/*
	 * Stop the IIC device.
	 */
	Status = XIic_Stop(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This function setups the interrupt system so interrupts can occur for the
* IIC. The function is application-specific since the actual system may or
* may not have an interrupt controller. The IIC device could be directly
* connected to a processor without an interrupt controller. The user should
* modify this function to fit the application.
*
* @param	IicInstPtr contains a pointer to the instance of the IIC  which
*		is going to be connected to the interrupt controller.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
static int SetupInterruptSystem(XIic *IicInstPtr)
{
	int Status;

	if (InterruptController.IsStarted == XIL_COMPONENT_IS_STARTED) {
		return XST_SUCCESS;
	}

	/*
	 * Initialize the interrupt controller driver so that it's ready to use.
	 */
	Status = XIntc_Initialize(&InterruptController, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 *  the specific interrupt processing for the device.
	 */
	Status = XIntc_Connect(&InterruptController, IIC_INTR_ID,
				   (XInterruptHandler) XIic_InterruptHandler,
				   IicInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the interrupt controller so interrupts are enabled for all
	 * devices that cause interrupts.
	 */
	Status = XIntc_Start(&InterruptController, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupts for the IIC device.
	 */
	XIntc_Enable(&InterruptController, IIC_INTR_ID);

	/*
	 * Initialize the exception table.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				 (Xil_ExceptionHandler) XIntc_InterruptHandler,
				 &InterruptController);

	/*
	 * Enable non-critical exceptions.
	 */
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This Send handler is called asynchronously from an interrupt context and
* indicates that data in the specified buffer has been sent.
*
* @param	InstancePtr is a pointer to the IIC driver instance for which
* 		the handler is being called for.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static void SendHandler(XIic *InstancePtr)
{
	TransmitComplete = 0;
}

/*****************************************************************************/
/**
* This Receive handler is called asynchronously from an interrupt context and
* indicates that data in the specified buffer has been Received.
*
* @param	InstancePtr is a pointer to the IIC driver instance for which
* 		the handler is being called for.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static void ReceiveHandler(XIic *InstancePtr)
{
	ReceiveComplete = 0;
}

/*****************************************************************************/
/**
* This Status handler is called asynchronously from an interrupt
* context and indicates the events that have occurred.
*
* @param	InstancePtr is a pointer to the IIC driver instance for which
*		the handler is being called for.
* @param	Event indicates the condition that has occurred.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static void StatusHandler(XIic *InstancePtr, int Event)
{

}
//--=========================================---------
//--------------------------------------------
void delay(uint32_t del){
   uint32_t a;
   for(a = 0; a < del; a++){

   }

}
