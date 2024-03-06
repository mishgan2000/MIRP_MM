#include <string.h>
#include <stdio.h>

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
#define EEPROM_ADDRESS 		    0x50 	/* 0xA0 as an 8 bit number. */
#define IIC_MUX_ADDRESS 		0x74
//#define IIC_MUX_ADDRESS 		0x78
#define IIC_EEPROM_CHANNEL		0x08
#define PAGE_SIZE   16
#define EEPROM_TEST_START_ADDRESS   1280//1024

//typedef u8 AddressType;
#define IIC_DEVICE_ID		XPAR_IIC_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_INTC_0_DEVICE_ID
#define INTC_IIC_INTERRUPT_ID	XPAR_INTC_0_IIC_0_VEC_ID

#define TEMP_SENSOR_ADDRESS	0x50 /* The actual address is 0x30 */

/**************************** Type Definitions *******************************/

typedef u16 AddressType;//u8 AddressType;

/************************** Function Prototypes ******************************/

int IicEepromExample();

int EepromWriteData(u16 ByteCount);

int EepromReadData(u8 *BufferPtr, u16 ByteCount);

static int SetupInterruptSystem(XIic *IicInstPtr);

static void SendHandler(XIic *InstancePtr);

static void ReceiveHandler(XIic *InstancePtr);

static void StatusHandler(XIic *InstancePtr, int Event);

//#ifdef IIC_MUX_ENABLE
//static int MuxInit(void);
//#endif
/************************** Variable Definitions *****************************/

XIic IicInstance;	/* The instance of the IIC device. */
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
static canmsg_t	candata;
//int Status = 111;
u8 Index;
int Status;
XIic_Config *ConfigPtr;	/* Pointer to configuration data */
AddressType Address = EEPROM_TEST_START_ADDRESS;



int main()
{

	EepromIicAddr = EEPROM_ADDRESS;

	init_platform();
    to_fpga = (uint32_t *)( XPAR_AXI_PWM_0_BASEADDR);//XPAR_AXI_PWM_0_BASEADDR

    //XGpio_Initialize(&led_gpio, LED_DEV_ID);
    //XGpio_SetDataDirection(&led_gpio, LED_Channel, 0x00);
    //XGpio_DiscreteWrite(&led_gpio, LED_Channel, 0x0);

    //vApplicationSetupTimerInterrupt();
//    my_timer_continuos_start();
    microblaze_enable_interrupts();
    microblaze_enable_exceptions();

    //xTaskCreate( mt_1, ( const char * )"MT_1", 256, NULL, MRTE_TASKS_PRIORITY, NULL );
    //init_mrte_tasks(MRTE_TASKS_PRIORITY);
    // ------------------------------
    ConfigPtr = XIic_LookupConfig(IIC_DEVICE_ID);
       if (ConfigPtr == NULL) {
       	return XST_FAILURE;
       }

       Status = XIic_CfgInitialize(&IicInstance, ConfigPtr, ConfigPtr->BaseAddress);
       	if (Status != XST_SUCCESS) {
       		return XST_FAILURE;
       	}

       	Status = SetupInterruptSystem(&IicInstance);
       	if (Status != XST_SUCCESS) {
       		return XST_FAILURE;
       	}

       	/*
       		 * Set the Handlers for transmit and reception.
       		 */
       		XIic_SetSendHandler(&IicInstance, &IicInstance,	(XIic_Handler) SendHandler);
       		XIic_SetRecvHandler(&IicInstance, &IicInstance, (XIic_Handler) ReceiveHandler);
       		XIic_SetStatusHandler(&IicInstance, &IicInstance, (XIic_StatusHandler) StatusHandler);

       		/*
       			 * Initialize the data to write and the read buffer.
       			 */
       		if (sizeof(Address) == 1) {
       			WriteBuffer[0] = (u8) (EEPROM_TEST_START_ADDRESS);
       			EepromIicAddr |= (EEPROM_TEST_START_ADDRESS >> 8) & 0x7;
       		} else {
       			WriteBuffer[0] = (u8) (EEPROM_TEST_START_ADDRESS >> 8);
       			WriteBuffer[1] = (u8) (EEPROM_TEST_START_ADDRESS);
       			ReadBuffer[Index] = 0;
       		}

       		for (Index = 0; Index < PAGE_SIZE; Index++) {
       			//WriteBuffer[sizeof(Address) + Index] = 0xFF;
       			WriteBuffer[sizeof(Address) + Index] = (Index + 1) & 0xFF;
       			ReadBuffer[Index] = 0;
       		}

       			/*
       			 * Set the Slave address.
       			 */
       		Status = XIic_SetAddress(&IicInstance, XII_ADDR_TO_SEND_TYPE, EepromIicAddr);
       		if (Status != XST_SUCCESS) {
       			return XST_FAILURE;
       		}

       		/*
       			 * Write to the EEPROM.
       			 */
       			//Status = EepromWriteData(sizeof(Address) + PAGE_SIZE);
       		Status = EepromWriteData(18);
       			if (Status != XST_SUCCESS) {
       				return XST_FAILURE;
       			}
         IicEepromExample();
    //delay(100000);
    /*
    Status = IicEepromExample();
    if (Status != 0) {
     	delay(1);
    }
    delay(2);
    */
    // ------------------------------
    xTaskCreate( mt_1, ( const char * )"MT_2", 256, NULL, 1, NULL );
    xTaskCreate( mt_2, ( const char * )"MT_2", 1024, NULL, 1, NULL );
    xTaskCreate( mt_3, ( const char * )"MT_3", 256, NULL, 1, NULL );
    vTaskStartScheduler();



    while(1)    {


    }
    return 0;
}

void mt_1(void *pvParameters){
	static t_mrte_msg_buff * 	p_mrte_buff = NULL;
	static TX_Com_buf_type *	TX_Com_buf_ponter;
	static u8 base_tlm_counter;
	static u8 ext_tlm_counter;
	static u8 osc_tlm_counter;

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
		IicEepromExample();
		/*
		Status = IicEepromExample();
		if(Status != 0) {
		   vTaskDelay(100);
		}
		*/
		vTaskDelay(200);


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
//--============ I2C SECTION ================---------
// ---------------------------------------------------
// ---------------------------------------------------
int IicEepromExample()
{

	//u8 Index;
	//int Status;
	//XIic_Config *ConfigPtr;	/* Pointer to configuration data */
	//AddressType Address = EEPROM_TEST_START_ADDRESS;
	//EepromIicAddr = EEPROM_ADDRESS;
	/*
	 * Initialize the IIC driver so that it is ready to use.
	 */









	/*
	 * Read from the EEPROM.
	 */
	Status = EepromReadData(ReadBuffer, PAGE_SIZE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Verify the data read against the data written.
	 */
	for (Index = 0; Index < PAGE_SIZE; Index++) {
		if (ReadBuffer[Index] != WriteBuffer[Index + sizeof(Address)]) {
			return XST_FAILURE;
		}

		ReadBuffer[Index] = 0;
	}

	return XST_SUCCESS;
}
// ---------------------------------------------------
int EepromWriteData(u16 ByteCount)
{
	int Status;

	/*
	 * Set the defaults.
	 */
	TransmitComplete = 1;
	IicInstance.Stats.TxErrors = 0;

	/*
	 * Start the IIC device.
	 */
	Status = XIic_Start(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Send the Data.
	 */
	Status = XIic_MasterSend(&IicInstance, WriteBuffer, ByteCount);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait till the transmission is completed.
	 */
	while ((TransmitComplete) || (XIic_IsIicBusy(&IicInstance) == TRUE)) {
		/*
		 * This condition is required to be checked in the case where we
		 * are writing two consecutive buffers of data to the EEPROM.
		 * The EEPROM takes about 2 milliseconds time to update the data
		 * internally after a STOP has been sent on the bus.
		 * A NACK will be generated in the case of a second write before
		 * the EEPROM updates the data internally resulting in a
		 * Transmission Error.
		 */
		if (IicInstance.Stats.TxErrors != 0) {


			/*
			 * Enable the IIC device.
			 */
			Status = XIic_Start(&IicInstance);
			if (Status != XST_SUCCESS) {
				return XST_FAILURE;
			}


			if (!XIic_IsIicBusy(&IicInstance)) {
				/*
				 * Send the Data.
				 */
				Status = XIic_MasterSend(&IicInstance,
							 WriteBuffer,
							 ByteCount);
				if (Status == XST_SUCCESS) {
					IicInstance.Stats.TxErrors = 0;
				}
				else {
				}
			}
		}
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
// ---------------------------------------------------
int EepromReadData(u8 *BufferPtr, u16 ByteCount)
{
	int Status;
	AddressType Address = EEPROM_TEST_START_ADDRESS;

	/*
	 * Set the Defaults.
	 */
	ReceiveComplete = 1;

	/*
	 * Position the Pointer in EEPROM.
	 */
	if (sizeof(Address) == 1) {
		WriteBuffer[0] = (u8) (EEPROM_TEST_START_ADDRESS);
	}
	else {
		WriteBuffer[0] = (u8) (EEPROM_TEST_START_ADDRESS >> 8);
		WriteBuffer[1] = (u8) (EEPROM_TEST_START_ADDRESS);
	}

	Status = EepromWriteData(sizeof(Address));
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the IIC device.
	 */
	Status = XIic_Start(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

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
// ---------------------------------------------------
static int SetupInterruptSystem(XIic *IicInstPtr)
{
	int Status;

#ifdef XPAR_INTC_0_DEVICE_ID

	/*
	 * Initialize the interrupt controller driver so that it's ready to use.
	 */
	Status = XIntc_Initialize(&Intc, INTC_DEVICE_ID);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XIntc_Connect(&Intc, IIC_INTR_ID,
				   (XInterruptHandler) XIic_InterruptHandler,
				   IicInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the interrupt controller so interrupts are enabled for all
	 * devices that cause interrupts.
	 */
	Status = XIntc_Start(&Intc, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupts for the IIC device.
	 */
	XIntc_Enable(&Intc, IIC_INTR_ID);

#else

	XScuGic_Config *IntcConfig;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&Intc, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XScuGic_SetPriorityTriggerType(&Intc, IIC_INTR_ID,
					0xA0, 0x3);

	/*
	 * Connect the interrupt handler that will be called when an
	 * interrupt occurs for the device.
	 */
	Status = XScuGic_Connect(&Intc, IIC_INTR_ID,
				 (Xil_InterruptHandler)XIic_InterruptHandler,
				 IicInstPtr);
	if (Status != XST_SUCCESS) {
		return Status;
	}

	/*
	 * Enable the interrupt for the IIC device.
	 */
	XScuGic_Enable(&Intc, IIC_INTR_ID);

#endif

	/*
	 * Initialize the exception table and register the interrupt
	 * controller handler with the exception table
	 */
	Xil_ExceptionInit();

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			 (Xil_ExceptionHandler)INTC_HANDLER, &Intc);

	/* Enable non-critical exceptions */
	Xil_ExceptionEnable();



	return XST_SUCCESS;
}
// ---------------------------------------------------
static void SendHandler(XIic *InstancePtr)
{
	TransmitComplete = 0;
}
// ---------------------------------------------------
static void ReceiveHandler(XIic *InstancePtr)
{
	ReceiveComplete = 0;
}
// ---------------------------------------------------
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
