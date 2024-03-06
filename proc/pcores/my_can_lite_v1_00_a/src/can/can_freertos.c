
//#ifdef CAN_EN
//	state_type		CAN_state		= {0};
//	CAN_ERROR			last_CAN_error;
//	unsigned long	CAN_started	= 0;			// биты соотвествуют индексу CAN-контроллера
//	unsigned long	CAN_tx_enbl	= 0;			// биты соотвествуют индексу CAN-контроллера
//
//	extern u32 CAN_TX_counter;
//	extern u32 CAN_TX_errors;
//
//	#define LAST_CAN_ERROR(err)		(last_CAN_error = (err))
//
//	#define	CAN_ON_OFF_MASK	(1 << 24)
//#else //CAN_EN
//	#define LAST_CAN_ERROR(err)		(err)
//#endif//CAN_EN
//
//#pragma diag_suppress 550
//
///* Declare memory pool for CAN messages, both transmit and receive           */
//CAN_msgpool_declare(CAN_mpool,CAN_CTRL_MAX_NUM*(CAN_No_SendObjects+CAN_No_ReceiveObjects));
//
///* Declare mailbox, for CAN transmit messages                                */
//mbx_arr_declare(MBX_tx_ctrl,CAN_CTRL_MAX_NUM,CAN_No_SendObjects);
//
///* Declare mailbox, for CAN receive messages                                 */
//mbx_arr_declare(MBX_rx_ctrl,CAN_CTRL_MAX_NUM,CAN_No_ReceiveObjects);
//
///* Semaphores used for protecting writing to CAN hardware                    */
//OS_SEM wr_sem[CAN_CTRL_MAX_NUM];
//
//
//
//void CAN_on(void)
//{
//#ifdef CAN_EN
//	//TO DO!!! On Off CAN
//	CAN_state.bits.on_off	= 1;
//#endif //CAN_EN
//}
//
//void CAN_off(void)
//{
//#ifdef CAN_EN
//	//TO DO!!! On Off CAN
//	CAN_state.bits.on_off	= 0;
//#endif //CAN_EN
//}
//
//bool is_CAN_on(void)
//{
//#ifdef CAN_EN
//	if(CAN_state.bits.on_off)
//		return true;
//#endif //CAN_EN
//	return false;
//}
//
//bool is_CAN_started(U32 ctrl)
//{
//#ifdef CAN_EN
//  register U32 ctrl0 = ctrl-1;         /* Controller index 0 .. x-1           */
//	if(CAN_started & (1 << ctrl0) )
//		return true;
//#endif //CAN_EN
//	return false;
//}
//
//void CAN_tx_start(U32 ctrl)
//{
//#ifdef CAN_EN
//  register U32 ctrl0 = ctrl-1;         /* Controller index 0 .. x-1           */
//	CAN_tx_enbl	|= (1 << ctrl0);
//#endif //CAN_EN
//}
//
//void CAN_tx_stop(U32 ctrl)
//{
//#ifdef CAN_EN
//  register U32 ctrl0 = ctrl-1;         /* Controller index 0 .. x-1           */
//	CAN_tx_enbl	&= ~(1 << ctrl0);
//#endif //CAN_EN
//}
//
//
///*----------------------------------------------------------------------------
// *      CAN RTX Generic Driver Functions
// *----------------------------------------------------------------------------
// *  Functions implemented in this module:
// *           CAN_ERROR CAN_mem_init  (void);
// *           CAN_ERROR CAN_setup     (void)
// *           CAN_ERROR CAN_init      (U32 ctrl, U32 baudrate)
// *           CAN_ERROR CAN_start     (U32 ctrl)
// *    static CAN_ERROR CAN_push      (U32 ctrl, CAN_msg *msg, U16 timeout)
// *           CAN_ERROR CAN_send      (U32 ctrl, CAN_msg *msg, U16 timeout)
// *           CAN_ERROR CAN_request   (U32 ctrl, CAN_msg *msg, U16 timeout)
// *           CAN_ERROR CAN_set       (U32 ctrl, CAN_msg *msg, U16 timeout)
// *    static CAN_ERROR CAN_pull      (U32 ctrl, CAN_msg *msg, U16 timeout)
// *           CAN_ERROR CAN_receive   (U32 ctrl, CAN_msg *msg, U16 timeout)
// *           CAN_ERROR CAN_rx_object (U32 ctrl, U32 ch, U32 id, U32 object_para)
// *           CAN_ERROR CAN_tx_object (U32 ctrl, U32 ch,         U32 object_para)
// *---------------------------------------------------------------------------*/
//
//
///*--------------------------- CAN_init --------------------------------------
// *
// *  The first time this function is called initialize the memory pool for
// *  CAN messages and setup CAN controllers hardware
// *
// *  Initialize mailboxes for CAN messages and initialize CAN controller
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              baudrate:   Baudrate
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_init(U32 ctrl, U32 baudrate)
//{
//#ifdef CAN_EN
//  static U8 first_run_flag = 0;
////  CAN_ERROR error_code;
//  U32 ctrl0 = ctrl-1;                 /* Controller index 0 .. x-1           */
//
//  LAST_CAN_ERROR(CAN_UNEXIST_CTRL_ERROR);
//
//  /* Initialize the Semaphore before the first use */
//  os_sem_init(wr_sem[ctrl0], 1);
//
//  /* When function is called for the first time it will initialize and setup
//     all of the resources that are common to CAN functionality               */
//  if(first_run_flag == 0)
//	{
//    first_run_flag = 1;
//    if(_init_box(CAN_mpool, sizeof(CAN_mpool), sizeof(CAN_msg)) == 1)
//      return LAST_CAN_ERROR(CAN_MEM_POOL_INIT_ERROR);
//  }
//
//  os_mbx_init(MBX_tx_ctrl[ctrl0], sizeof(MBX_tx_ctrl[ctrl0]));
//  os_mbx_init(MBX_rx_ctrl[ctrl0], sizeof(MBX_rx_ctrl[ctrl0]));
//
//  LAST_CAN_ERROR(_CAN_hw_setup(ctrl));
//  if(last_CAN_error != CAN_OK)
//    return last_CAN_error;
//
//	{	// Конфигурирование бита включения питания на CAN
//		unsigned long PINSEL2_var = PINSEL2;
//		const unsigned long PINSEL2_clr_bits	= 0x00000020;	// CTRLDBP=01 (enable P2.24)
//		const unsigned long PINSEL2_set_bits	= 0x00000010;
//		if((PINSEL2_var & (PINSEL2_clr_bits|PINSEL2_set_bits)) != PINSEL2_set_bits)
//		{	PINSEL2_var &= ~PINSEL2_clr_bits;
//			PINSEL2_var |= PINSEL2_set_bits;
//			PINSEL2 = PINSEL2_var;
//		}
//	}
//
//	{
//		IO2SET	=  CAN_ON_OFF_MASK;
//		IO2DIR	|= CAN_ON_OFF_MASK;		// P2.24 - output
//		CAN_state.bits.on_off	= 0;
//	}
//
//  LAST_CAN_ERROR(CAN_hw_init(ctrl, baudrate));
//	CAN_tx_enbl			= 0;					// биты соотвествуют индексу CAN-контроллера
//  if(last_CAN_error == CAN_OK)
//		CAN_state.bits.init	= 1;
//	return last_CAN_error;
//#else //CAN_EN
//	return CAN_UNEXIST_CTRL_ERROR;
//#endif //CAN_EN
//}
//
//
///*--------------------------- CAN_start -------------------------------------
// *
// *  Start CAN controller (enable it to participate on CAN network)
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_start(U32 ctrl)
//{
//#ifdef CAN_EN
//  U32 ctrl0 = ctrl-1;                 /* Controller index 0 .. x-1           */
//	if(LAST_CAN_ERROR(CAN_hw_start(ctrl)) == CAN_OK)
//	{
//		CAN_tx_enbl	|= (1 << ctrl0);
//		CAN_started	|= (1 << ctrl0);
//	}
//  return last_CAN_error;
//#else //CAN_EN
//	return CAN_OK;
//#endif//CAN_EN
//}
//
//
///*--------------------------- CAN_push --------------------------------------
// *
// *  Send CAN_msg ifhardware is free for sending, otherwise push message to
// *  message queue to be sent when hardware becomes free
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              msg:        Pointer to CAN message to be sent
// *              timeout:    Timeout value for message sending
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//static CAN_ERROR CAN_push(U32 ctrl, CAN_msg *msg, U16 timeout)
//{
//  CAN_msg *ptrmsg;
//  U32 ctrl0 = ctrl-1;                 /* Controller index 0 .. x-1           */
//
//  if(CAN_hw_tx_empty(ctrl) == CAN_OK)
//	{																		/* Transmit hardware free for send */
//    CAN_hw_wr(ctrl, msg);            /* Send message                        */
//  }
//  else
//	{			                              /* ifhardware for sending is busy     */
//    /* Write the message to send mailbox ifthere is room for it             */
//    ptrmsg = _alloc_box(CAN_mpool);
//    if(ptrmsg != NULL)
//		{
//      *ptrmsg = *msg;
//      /* ifmessage hasn't been sent but timeout expired, deallocate memory  */
//      if(os_mbx_send(MBX_tx_ctrl[ctrl0], ptrmsg, timeout) == OS_R_TMO)
//			{
//        if(_free_box(CAN_mpool, ptrmsg) == 1)
//          return LAST_CAN_ERROR(CAN_DEALLOC_MEM_ERROR);
//
//        return LAST_CAN_ERROR(CAN_TIMEOUT_ERROR);
//      }
//			else
//			{
//        /* Check once again iftransmit hardware is ready for transmission   */
//        if(CAN_hw_tx_empty(ctrl) == CAN_OK)
//				{ /* Transmit hw free for send */
//          if(os_mbx_wait(MBX_tx_ctrl[ctrl0], (void **)&ptrmsg, 0) == OS_R_TMO)
//					{
//            os_sem_send(wr_sem[ctrl0]); /* Return a token back to semaphore  */
//            return LAST_CAN_ERROR(CAN_OK);              /* Message was sent from IRQ already */
//          }
//          if(_free_box (CAN_mpool, ptrmsg) == 1)
//					{
//            os_sem_send(wr_sem[ctrl0]); /* Return a token back to semaphore  */
//            return LAST_CAN_ERROR(CAN_DEALLOC_MEM_ERROR);
//          }
//          CAN_hw_wr(ctrl, msg);      /* Send message                        */
//        }
//      }
//    }
//		else
//      return LAST_CAN_ERROR(CAN_ALLOC_MEM_ERROR);
//  }
//  return LAST_CAN_ERROR(CAN_OK);
//}
//
//
///*--------------------------- CAN_send --------------------------------------
// *
// *  Send DATA FRAME message, see CAN_push function comment
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              msg:        Pointer to CAN message to be sent
// *              timeout:    Timeout value for message sending
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_send(U32 ctrl, CAN_msg *msg, U16 timeout)
//{
//  msg->type = DATA_FRAME;
//
//  return LAST_CAN_ERROR(CAN_push(ctrl, msg, timeout));
//}
//
//
///*--------------------------- CAN_request -----------------------------------
// *
// *  Send REMOTE FRAME message, see CAN_push function comment
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              msg:        Pointer to CAN message to be sent
// *              timeout:    Timeout value for message sending
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_request(U32 ctrl, CAN_msg *msg, U16 timeout)
//{
//  msg->type = REMOTE_FRAME;
//
//  return LAST_CAN_ERROR(CAN_push(ctrl, msg, timeout));
//}
//
//
///*--------------------------- CAN_set ---------------------------------------
// *
// *  Set a message that will automatically be sent as an answer to REMOTE
// *  FRAME message
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              msg:        Pointer to CAN message to be set
// *              timeout:    Timeout value for message to be set
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_set(U32 ctrl, CAN_msg *msg, U16 timeout)
//{
//  S32 i = timeout;
//  CAN_ERROR error_code;
//
//  do
//	{
//    if(CAN_hw_tx_empty(ctrl) == CAN_OK)
//		{  /* Transmit hardware free      */
//      error_code = CAN_hw_set(ctrl, msg);    /* Set message                 */
//      os_sem_send(wr_sem[ctrl-1]);     /* Return a token back to semaphore  */
//      return LAST_CAN_ERROR(error_code);
//    }
//    if(timeout == 0xffff)              /* Indefinite wait                   */
//      i++;
//    i--;
//    os_dly_wait (1);                    /* Wait 1 timer tick                 */
//  }  while (i >= 0);
//
//  return LAST_CAN_ERROR(CAN_TIMEOUT_ERROR);  /* CAN message not set               */
//}
//
//
///*--------------------------- CAN_pull --------------------------------------
// *
// *  Pull first received and unread CAN_msg from receiving message queue
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              msg:        Pointer where CAN message will be read
// *              timeout:    Timeout value for message receiving
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//
//static CAN_ERROR CAN_pull(U32 ctrl, CAN_msg *msg, U16 timeout)
//{
//  CAN_msg *ptrmsg;
//  U32 ctrl0 = ctrl-1;                 /* Controller index 0 .. x-1           */
//
//  /* Wait for received message in mailbox                                    */
//  if(os_mbx_wait(MBX_rx_ctrl[ctrl0], (void **)&ptrmsg, timeout) == OS_R_TMO)
//    return LAST_CAN_ERROR(CAN_TIMEOUT_ERROR);
//
//  /* Copy received message from mailbox to address given in function parameter msg */
//  *msg = *ptrmsg;
//
//  /* Free box where message was kept                                         */
//  if(_free_box(CAN_mpool, ptrmsg) == 1)
//    return LAST_CAN_ERROR(CAN_DEALLOC_MEM_ERROR);
//
//  return LAST_CAN_ERROR(CAN_OK);
//}
//
//
///*--------------------------- CAN_receive -----------------------------------
// *
// *  Read received message, see CAN_pull function comment
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              msg:        Pointer where CAN message will be read
// *              timeout:    Timeout value for message receiving
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_receive(U32 ctrl, CAN_msg *msg, U16 timeout)
//{
//  return LAST_CAN_ERROR(CAN_pull(ctrl, msg, timeout));
//}
//
//
///*--------------------------- CAN_rx_object ---------------------------------
// *
// *  Enable reception of messages on specified controller and channel with
// *  specified identifier
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              ch:         Channel for the message transmission
// *              id:         CAN message identifier
// *              object_para:Object parameters (standard or extended format,
// *                          data or remote frame)
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
//CAN_ERROR CAN_rx_object(U32 ctrl, U32 ch, U32 id, U32 object_para)
//{
//  return LAST_CAN_ERROR(CAN_hw_rx_object(ctrl, ch, id, object_para));
//}
//
//
///*--------------------------- CAN_tx_object ---------------------------------
// *
// *  Enable transmission of messages on specified controller and channel with
// *  specified identifier
// *
// *  Parameter:  ctrl:       Index of the hardware CAN controller (1 .. x)
// *              ch:         Channel for the message transmission
// *              object_para:Object parameters (standard or extended format,
// *                          data or remote frame)
// *
// *  Return:     CAN_ERROR:  Error code
// *---------------------------------------------------------------------------*/
//
////CAN_ERROR CAN_tx_object(U32 ctrl, U32 ch, U32 object_para)
////{
////  return LAST_CAN_ERROR(CAN_hw_tx_object(ctrl, ch, object_para));
////}


/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

#include "can_freertos.h"
#include "led.h"
#include "timer_1ms.h"

#define CAN_No_SendObjects     80
#define CAN_No_ReceiveObjects  80

#define CAN_TX_NOWAIT		0
#define CANTX_TIMEOUT		100	//ms
#define CANRX_TIMEOUT		100	//ms

SemaphoreHandle_t cantx_mutex = NULL;
SemaphoreHandle_t canrx_mutex = NULL;
xQueueHandle xQueueCanRx;
xQueueHandle xQueueCanTx;

void canISR( void );
//portBASE_TYPE can_send_msg(canmsg_t * p_can_data);

void can_init(void)
{
	portBASE_TYPE 	xCanStatus;
	cantx_mutex = xSemaphoreCreateBinary();
	canrx_mutex = xSemaphoreCreateBinary();
	xSemaphoreGive( cantx_mutex );		// tx mutex should be opened at first time
	xQueueCanRx = xQueueCreate( CAN_No_ReceiveObjects, sizeof( canmsg_t ) );
	xQueueCanTx = xQueueCreate( CAN_No_SendObjects, sizeof( canmsg_t ) );

	if(can_init_hw() == can_ok)
	{
		xCanStatus = xPortInstallInterruptHandler( XPAR_AXI_INTC_0_MY_CAN_LITE_0_CAN_IRQ_INTR, (void *)canISR, NULL );
		if( xCanStatus == pdPASS )
		{
			vPortEnableInterrupt(XPAR_AXI_INTC_0_MY_CAN_LITE_0_CAN_IRQ_INTR);
		}
	}
}

portBASE_TYPE can_send_msg(canmsg_t * p_can_data)
{
	portBASE_TYPE ret = pdTRUE;
//
	taskENTER_CRITICAL();
//	if(uxQueueSpacesAvailable(xQueueCanTx) > 0)
	{
		if(xQueueSendToBack(xQueueCanTx, p_can_data, CANTX_TIMEOUT /* CAN_TX_NOWAIT*/ ) != pdTRUE)
		{
			ret = pdFALSE;
		}
	}
//	else
//	{
//		ret = pdFALSE;
//	}
	if( xSemaphoreTake( cantx_mutex, CAN_TX_NOWAIT ) == pdTRUE )
	{
		canmsg_t can_message;
		if(xQueueReceive(xQueueCanTx, &can_message, /*CANTX_TIMEOUT*/ CAN_TX_NOWAIT) == pdTRUE)
		{//Always know here that there are at least one message in queue
			can_put_msg_hw(&can_message);
		}
		else
		{
//			xSemaphoreGive(cantx_mutex);
//			ret = pdFALSE;
		}
	}
	taskEXIT_CRITICAL();
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

#pragma pack(push, 1)
typedef struct
{
	u8 cmdMark;
	u8 cmdCode;
	u32 timeUTC;
	u16 time1ms;
} utc_time_mark_t;
#pragma pack(pop)

static canmsg_t isr_can_message;
static int rx_cnt=0;
static int rx_can_err_cnt=0;

utc_time_mark_t * p_time_mark = (utc_time_mark_t *)(&isr_can_message.data);

void canISR( void )
{
	portBASE_TYPE xTaskWokenByPost = pdFALSE;
	u8 canIrqStatus = get_isr_status();//reading acknowledges an irq

	set_led(LED_0);

	if( is_status_can_tx(canIrqStatus) )
	{
		if(xQueueIsQueueEmptyFromISR(xQueueCanTx) == pdFALSE)
		{
			if(xQueueReceiveFromISR(xQueueCanTx, &isr_can_message, &xTaskWokenByPost) == pdTRUE)
			{
				can_put_msg_hw(&isr_can_message); //TODO Can`t do anything in case of can_err ?
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
			if((isr_can_message.ch == (4*4+3)) && (isr_can_message.data.dU8[1] == 0x43))
			{
				utcClockSetDeltaTime( p_time_mark->timeUTC, p_time_mark->time1ms );
				rx_cnt++;
			}
			else
			{
				if(xQueueIsQueueFullFromISR(xQueueCanRx) == pdFALSE)
				{
					xQueueSendFromISR( xQueueCanRx, &isr_can_message, &xTaskWokenByPost );
					rx_cnt++;
				}
				else
				{
					//			toggle_led(LED_0);
					//TODO!! Inc err counter?
					rx_can_err_cnt++;
				}
			}
		}
		else
		{
			rx_can_err_cnt++;
		}
	}
	if( is_status_can_beie(canIrqStatus) )
	{
		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		rx_can_err_cnt++;
	}
	if( is_status_can_eie(canIrqStatus) )
	{
		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		rx_can_err_cnt++;
	}
	if( is_status_can_doie(canIrqStatus) )
	{
		//Rx Fifo Overrun Occures
		//TODO!!! CAN controller should be reseted
		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		rx_can_err_cnt++;
	}
	if( is_status_can_alie(canIrqStatus) )
	{
		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		rx_can_err_cnt++;
	}
	if( is_status_can_epie(canIrqStatus) )
	{
		xSemaphoreGiveFromISR( cantx_mutex, &xTaskWokenByPost );
		rx_can_err_cnt++;
	}

	clr_led(LED_0);

	portYIELD_FROM_ISR( xTaskWokenByPost );

}
