/****************************************************************************************
*											*
*	MRTE-C for Microblaze								*
*											*
*	Yurik V. Nikiforoff								*
*	NOKB GP, Nsk									*
*	yurik@megasignal.com								*
*											*
*	jun 2008									*
*											*
*											*
****************************************************************************************/
#ifndef _MRTE_C3
#define _MRTE_C3

#include <FreeRTOS.h>
#include "xil_types.h"
#include "task.h"
#include "semphr.h"

#define MEGA2_EN

// Error Codes
#define CMD_OK						(0)
#define ERROR_UNKNOWN_COMMAND		(1)
#define ERROR_PARAMS_SIZE			(2)
#define ERROR_PARAM_OUT_OF_RANGE	(3)
#define ERROR_PARAMS_CONFLICT		(4)
#define ERROR_HARDWARE				(5)
#define ERROR_UNEXPECTED			(6)
#define ERROR_QUEUE_IS_EMPTY		(0x10)
// by Yurik Nikiforoff:
#define ERROR_SET_ASYNC				(0x11)
// by Vadim Shishkin
#define ERROR_QUEUE_IS_OVERFULL		(0x12)
#define ERROR_VERIFY_SPI_FLASH		(0x13)


#define MSG_MAX_LEN					(2112)
#define TX_MSG_NUM					(2)
#define MSG_BOX_BLOCK_TIME			(100)

//#pragma pack(push, 1)
typedef struct
{
	union{
		u8 	dU8[MSG_MAX_LEN];
		u32	du32[MSG_MAX_LEN/sizeof(u32)];
	} data;
} t_mrte_dt_buff;

typedef struct
{
	u32 chan_num;
	u32 len;
	u32 curr_ind;
	t_mrte_dt_buff * buff;
} t_mrte_msg_buff;


#pragma pack(push, 1)

typedef struct
{
	u32 chan_num;
	u32 len;
	u32 curr_ind;
	u8 * data;
} t_mega2_rxdatablock;

typedef struct
{
	// CAN ids
	u16 head;
	u16 body;
	u16 tail;
	u16 headtail;
	// Channel ready flag
	u32 ready;
	//	unsigned short tx_crc;
	// Receiver state
	//t_mrte_msg_buff *rx_datablock;
	t_mega2_rxdatablock	rxdata;
	t_mrte_msg_buff	 	* p_txdata;
	SemaphoreHandle_t 	xMega2ChanMutex;
}  t_mega2_channel;

#pragma pack(pop)

//

#define MRTE_SEND_BLOCK_TIME (100)

//messsages to
//extern xQueueHandle		xMrteSendQueue;

typedef enum{
	mrte_send_data = 0,
	mrte_send_init = 1
} tu_mrte_semd_cmd;

typedef struct{
	tu_mrte_semd_cmd	cmd;
	t_mrte_msg_buff	*	pbuf;
} ts_mrte_send_queue;

//

void mrte_init(void);

#define CAN_SEND_ASYNC	(0)
#define CAN_SEND_SYNC	(1)

t_mrte_msg_buff * alloc_mrte_send_buff(portTickType timeout);
portBASE_TYPE 	request_mrte_send(u8 sync, t_mrte_msg_buff * pbuf);
// mega-2 protocol support

//void can_rx_mrte_task(void *pvParameters);
//void can_tx_mrte_task(void *pvParameters);

void init_mrte_tasks(UBaseType_t task_priority);

#endif // _MRTE_C3
