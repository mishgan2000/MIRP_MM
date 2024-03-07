
#include "can_freertos.h"
#include "can_config.h"
//#include "led.h"


//#define CAN_No_SendObjects     80
//#define CAN_No_ReceiveObjects  100
//
//#define CAN_TX_NOWAIT		0
//#define CANTX_TIMEOUT		2	//ms
//#define CANRX_TIMEOUT		100	//ms

SemaphoreHandle_t cantx_mutex = NULL;
xQueueHandle xQueueCanRx;
xQueueHandle xQueueCanTx;

void canISR( void );

void can_init(void)
{
	portBASE_TYPE 	xCanStatus;
	cantx_mutex = xSemaphoreCreateBinary();
	xSemaphoreGive( cantx_mutex );		// tx mutex should be opened at first time
	xQueueCanRx = xQueueCreate( can_config_data.CAN_No_ReceiveObjects, sizeof( canmsg_t ) );
	xQueueCanTx = xQueueCreate( can_config_data.CAN_No_SendObjects, sizeof( canmsg_t ) );

	if(can_init_hw() == 0)
	{
		xCanStatus = xPortInstallInterruptHandler( XPAR_AXI_INTC_0_MY_CAN_LITE_0_CAN_IRQ_INTR, (void *)canISR, NULL );
		//xCanStatus = xPortInstallInterruptHandler( XPAR_MICROBLAZE_0_INTC_MY_CAN_LITE_0_CAN_IRQ_INTR, (void *)canISR, NULL );
		if( xCanStatus == pdPASS )
		{
			vPortEnableInterrupt(XPAR_AXI_INTC_0_MY_CAN_LITE_0_CAN_IRQ_INTR);
			//vPortEnableInterrupt(XPAR_MICROBLAZE_0_INTC_MY_CAN_LITE_0_CAN_IRQ_INTR);
		}
	}
}

int can_set_filter(u8 ch, u32 arbcode, u8 frame, u8 mode)
{
	int ret = 0;
//	if( xSemaphoreTake( cantx_mutex, 1000 ) == pdTRUE )
	{
		if(can_set_filter_hw(ch, arbcode, frame, mode) != 0)
		{
			ret = 1;
		}
//		xSemaphoreGive( cantx_mutex );
	}
//	else
//	{
//		ret = 2;
//	}
	return ret;
}
int can_set_any_filter(u8 ch)
{
	int ret = 0;
//	if( xSemaphoreTake( cantx_mutex, 1000 ) == pdTRUE )
	{
		if(can_filter_enable_all_hw(ch) != 0)
		{
			ret = 1;
		}
//		xSemaphoreGive( cantx_mutex );
	}
//	else
//	{
//		ret = 2;
//	}
	return ret;
}


static portBASE_TYPE on_can_send_message_hook_def(const canmsg_t * p_can_data)
{
	return pdTRUE;
}

static on_can_send_message_hook_ptr on_can_send_message_hook = on_can_send_message_hook_def;


void set_on_can_send_message_hook(on_can_send_message_hook_ptr hook)
{
	if(hook != NULL)
		on_can_send_message_hook = hook;
	else
		on_can_send_message_hook = on_can_send_message_hook_def;
}

unsigned int can_send_queue_free_bytes(void)
{
	return uxQueueSpacesAvailable( xQueueCanTx ) * sizeof(can_data_t);
}

portBASE_TYPE can_send_msg(canmsg_t * p_can_data, const TickType_t t_wait)
{
	portBASE_TYPE ret = pdTRUE;
//
	taskENTER_CRITICAL();
//	if(uxQueueSpacesAvailable(xQueueCanTx) > 0)
	{
		if(xQueueSendToBack(xQueueCanTx, p_can_data, t_wait/*can_config_data.CANTX_TIMEOUT*/ /*CAN_TX_NOWAIT*/ ) != pdTRUE)
		{
			ret = pdFALSE;
		}
	}
//	else
//	{
//		ret = pdFALSE;
//	}
	if( xSemaphoreTake( cantx_mutex, 0 ) == pdTRUE )
	{
		canmsg_t can_message;
		if(xQueueReceive(xQueueCanTx, &can_message, 0) == pdTRUE)
		{//Always know here that there are at least one message in queue
			can_put_msg_hw(&can_message);
		}
		else
		{
//			xSemaphoreGive(cantx_mutex);
//			ret = pdFALSE;
		}
	}

//	func();
//	on_can_send_message_hook(p_can_data);

	taskEXIT_CRITICAL();
	return ret;
}

portBASE_TYPE can_queu_recieved_msg(canmsg_t * p_can_data, u32 timeout)
{
	portBASE_TYPE	ret = pdFALSE;
	if( xQueueSend( xQueueCanRx, p_can_data, ( portTickType ) timeout ) == pdTRUE)
	{
		ret = pdTRUE;
	}
	return ret;
}

portBASE_TYPE can_recieve_msg(canmsg_t * p_can_data, u32 timeout)
{
	portBASE_TYPE	ret = pdFALSE;
	if( xQueueReceive( xQueueCanRx, p_can_data, ( portTickType ) timeout ) == pdTRUE)
	{
		ret = pdTRUE;
	}
	return ret;
}
//================================================
void CAN_tx_start(u32 ctrl)
{
	//TODO
}
//================================================
void CAN_tx_stop(u32 ctrl)
{
	//TODO
}
//================================================
//extern portBASE_TYPE mrte_tx_datablock_abort_isr(void);

void CAN_reset(void)
{
//	BaseType_t ret;
//	ret = mrte_tx_datablock_abort_isr();
	xQueueReset(xQueueCanTx);
	xQueueReset(xQueueCanRx);
	can_init_hw();//can_reset_if_error();
	xSemaphoreTake(cantx_mutex, 0);
	xSemaphoreGive(cantx_mutex);
}

static canmsg_t isr_can_message;
static int rx_cnt=0;
static int rx_can_err_cnt=0;
#pragma pack(push, 1)
typedef struct{
	u16 dummy;
	u32 utc;
	u16 time_ms;
} timestamp_type;
#pragma pack(pop)

//static timestamp_type* ptm = (timestamp_type*)&(isr_can_message.data.dU8[0]);

void inc_can_err_counter(void)
{
	++rx_can_err_cnt;
}

u32 can_get_err_counter(void)
{
	u32 tmp = rx_can_err_cnt;
	rx_can_err_cnt = 0;
	return tmp;
}

extern void utcClockSetDeltaTime(u32 time_mark_sec, u16 time_mark_ms);

void canISR( void )
{
	portBASE_TYPE xTaskWokenByPost = pdFALSE;
	u8 canIrqStatus = get_isr_status();//reading acknowledges an irq

//	fast_led(1);
//	*(u32 *)(LED_REG) |= LED_0;

	if( is_status_can_tx(canIrqStatus) )
	{
		if(xQueueIsQueueEmptyFromISR(xQueueCanTx) == pdFALSE)
		{
			if(xQueueReceiveFromISR(xQueueCanTx, &isr_can_message, &xTaskWokenByPost) == pdTRUE)
			{
				if(can_put_msg_hw(&isr_can_message) != 0)
				{
					xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );//TODO Can`t do anything in case of can_err ?
				}
			}
		}
		else
		{
			xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		}

	}
	if( is_status_can_rx(canIrqStatus) )
	{
		can_get_msg_hw(&isr_can_message);
		//Release buffer
		release_rx_buff();//CommandReg = RRB_Bit;
		if(is_status_no_error(canIrqStatus))
		{
			//Timestamp handling
			if(((isr_can_message.ch >> 2) == 4) && (isr_can_message.dlc == 8) && (isr_can_message.data.dU8[1] == 0x43)) //TODO: Fix hardcoded constants
			{
				//utcClockSetDeltaTime(ptm->utc, ptm->time_ms);
			}
			else
			{
				if(xQueueSendFromISR( xQueueCanRx, &isr_can_message, &xTaskWokenByPost ) == pdTRUE)
				{
					rx_cnt++;
				}
				else
				{
					rx_can_err_cnt++;
				}
			}
		}
//		else
//		{
//			rx_can_err_cnt++;
//		}
	}
	//
	if( is_status_error(canIrqStatus) )
	{
		can_reset_if_error();
		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		rx_can_err_cnt++;
	}
	else if( is_status_warning(canIrqStatus) )
	{
		rx_can_err_cnt++;
	}

//	if( is_status_can_beie(canIrqStatus) )
//	{
//		if(can_reset_if_error() == 0)
//		{
//			xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
//		}
//		rx_can_err_cnt++;
//	}
//	if( is_status_can_eie(canIrqStatus) )
//	{
//		if(can_reset_if_error() == 0)
//		{
//			xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
//		}
////		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
//		rx_can_err_cnt++;
//	}
//	if( is_status_can_doie(canIrqStatus) )
//	{
//		//Rx Fifo Overrun Occures
//		//TODO!!! CAN controller should be reseted
////		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
//		rx_can_err_cnt++;
//	}
//	if( is_status_can_alie(canIrqStatus) )
//	{
////		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
//		rx_can_err_cnt++;
//	}
//	if( is_status_can_epie(canIrqStatus) )
//	{
////		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
//		rx_can_err_cnt++;
//	}

//	fast_led(0);
//	*(u32 *)(LED_REG) &= ~LED_0;

	portYIELD_FROM_ISR( xTaskWokenByPost );

}
