/****************************************************************************************
 *											*
 *	MRTE-C for Microblaze								*
 *											*
 *	Yurik V. Nikiforoff								*
 *	NOKB GP, Nsk									*
 *	yurik@megasignal.com								*
 *											*
 *	jun 2008									*
 *
 *  eddited to be used with FreeRTOS by											*
 *	Anton V. Pavlenko										*
 *	NOKB GP, Nsk									*
 *	pavlenko_av@megasignal.com								*
 *	may 2017										*
 ****************************************************************************************/

//#include "setup.h"
#include "io-mrte.h"

//#include "LPC22XX/RTX_CAN.h"
#include "lib_crc_ccitt.h"
//#include "ikn_a2_cmd.h"
//#include "type.h"
#include "can_freertos.h"

#include "can_cmd.h"
#include "queue.h"

#include "can_archiver.h"

// Возвращает true, если reset, иначе false
// После вызова не передавать пакет в функцию mrte_push
portBASE_TYPE is_mrte_reset(int);
// Возвращает true, если start, иначе false
// После вызова не передавать пакет в функцию mrte_push
portBASE_TYPE is_mrte_start(int);
// Возвращает true, если stop, иначе false
// После вызова не передавать пакет в функцию mrte_push
portBASE_TYPE is_mrte_stop(int);

int mrte_push(const canmsg_t * candata);

static portBASE_TYPE send_init_request(void);
//static void assign_canid(void);
//void assign_canid(void);
//int get_channel_by_canid(unsigned short);
//void get_canid(short*);
//void set_canid(short*);
//int is_mrte_busy(void);
//portBASE_TYPE mrte_check(int);

#ifdef MEGA2_EN

#define CHANNEL_LIMIT				(5)
									// 0 - канал инициализации;
									// 1 - канал команд;
									// 2 - канал синхронного ответа на команду;
									// 3 - канал ассинхронного ответа;
									// 4 - широковещательный

#define START_STOP_CHANNEL			(0)
#define INIT_CHANNEL				(0)
#define CMD_CHANNEL					(1)
#define CMD_ANSWER_CHANNEL			(2)
#define ASYNC_CHANNEL				(3)
#define BROADCAST_CHANNEL			(4)

#define CAN_PROTO_RST				(0x0000)
#define CAN_PROTO_INIT_REQUEST		(0x0200)

#define CAN_PROTO_HEAD				(0x00FF)
#define CAN_PROTO_BODY				(0x00FE)
#define CAN_PROTO_TAIL				(0x00FD)
#define CAN_PROTO_HEADTAIL			(0x00FC)

#define CAN_PROTO_RUN				(0x00FB)

#define CAN_CMD_START				(2)
#define CAN_CMD_STOP				(1)

#define MAXCANDATALENGTH			(8)

#define INIT_SIZE					(24)
#define RX_SIZE						(1024)
#define RX4_SIZE					(64)


#define HAVE_DATA					(0)


#define HEAD						(1)
#define BODY						(2)
#define TAIL						(3)
#define HEADTAIL					(4)



xQueueHandle		xMrteSendQueue = NULL;

// MEGA-2 implementation

#define RX_INIT_BUF_LEN			(80)
#define RX_CMD_CH_BUF_LEN		(1024)
#define RX_BROADCAST_CH_BUF_LEN	(64)

static t_mega2_channel _global_mega_impl[CHANNEL_LIMIT];//						MRTE_SECTION;
static u8 _rx_channel_init[RX_INIT_BUF_LEN];
static u8 _rx_channel_cmd[RX_CMD_CH_BUF_LEN];
static u8 _rx_channel_broadcast[RX_BROADCAST_CH_BUF_LEN];
// static buffers for receiver

const u16	device_type = 0x800C;
const u16 	serial_num 	= 0x10;
unsigned int		software_version;

static u16 _global_devnum;//														MRTE_SECTION;
static u16 _global_devtype;

u32 MRTE_send_counter;
u32 MRTE_send_errors;

xQueueHandle		xMrteSendFreeQueue = NULL;

t_mrte_dt_buff	mrte_send_buff[TX_MSG_NUM];
t_mrte_msg_buff	mrte_send_desc[TX_MSG_NUM];

#endif //MEGA2_EN

//============================= Declare Internal Functions ============================================
portBASE_TYPE 	mrte_transmit(portTickType timeout);
void 			assign_canid( t_mega2_rxdatablock *pbuff );
void 			can_rx_mrte_task(void *pvParameters);
void 			can_tx_mrte_task(void *pvParameters);
//portBASE_TYPE 	init_mrte_buffers(void);
//t_mrte_msg_buff * alloc_mrte_send_buff(portTickType timeout);
//portBASE_TYPE 	free_mrte_send_buff(t_mrte_msg_buff *pbuf);
//portBASE_TYPE 	request_mrte_send(t_mrte_msg_buff * pbuf);
//*************************** MEGA-2 protocol implementation *******************************************

portBASE_TYPE 	init_mrte_buffers(void)
{
	int ii=0;

	xMrteSendFreeQueue = xQueueCreate( TX_MSG_NUM, sizeof( t_mrte_msg_buff * ) );

	for(ii=0; ii<TX_MSG_NUM; ii++)
	{
		t_mrte_msg_buff * pbuff;
		mrte_send_desc[ii].buff = &(mrte_send_buff[ii]);
		pbuff = &mrte_send_desc[ii];
		configASSERT(xQueueSendToBack(xMrteSendFreeQueue, &pbuff, MRTE_SEND_BLOCK_TIME));
	}
	return pdTRUE;

}

//============== MRTE send buffer allocation =================================================
t_mrte_msg_buff * alloc_mrte_send_buff(portTickType timeout)
{
	t_mrte_msg_buff * pbuf;
	if(xQueueReceive( xMrteSendFreeQueue, &pbuf, timeout ) != pdTRUE)
	{
		pbuf = NULL;
	}
	else
	{
		pbuf->curr_ind = 0;
	}
	return pbuf;
}

portBASE_TYPE 	free_mrte_send_buff(t_mrte_msg_buff * pbuf)
{
	return xQueueSendToBack(xMrteSendFreeQueue, &pbuf, MRTE_SEND_BLOCK_TIME);
}

portBASE_TYPE 	request_mrte_send(u8 sync, t_mrte_msg_buff * pbuf)
{
	ts_mrte_send_queue	mrte_cmd;
	mrte_cmd.cmd = mrte_send_data;
	if(sync)
	{
		pbuf->chan_num = CMD_ANSWER_CHANNEL;
	}
	else
	{
		pbuf->chan_num = ASYNC_CHANNEL;
	}
	mrte_cmd.pbuf = pbuf;
	return xQueueSendToBack(xMrteSendQueue, &mrte_cmd, MRTE_SEND_BLOCK_TIME);
}

//***======================================================================================

void mrte_init()
{
#ifdef MEGA2_EN
	int i;
	t_mega2_channel *pmega;
	static u8		first_run_flag = 0;

	// init pmega-2
	pmega = _global_mega_impl;
	_global_devtype = device_type ;	// should be taken from EEPROM, see main module
	_global_devnum = serial_num;		// from EEPROM

	if(first_run_flag == 0)
	{
		first_run_flag = 1;
		xMrteSendQueue = xQueueCreate( TX_MSG_NUM, sizeof( ts_mrte_send_queue ) );
		for (i=0; i<CHANNEL_LIMIT; i++)
		{
			pmega->head = 0;
			pmega->body = 0;
			pmega->tail = 0;
			pmega->headtail = 0;
			pmega->ready = 0;
			pmega->rxdata.chan_num = i;
			pmega->rxdata.curr_ind = 0;
			pmega->rxdata.data = NULL;
			pmega->rxdata.len = 0;
			pmega->p_txdata = NULL;
			pmega->xMega2ChanMutex = NULL;
			pmega->xMega2ChanMutex = xSemaphoreCreateMutex();
			configASSERT(pmega->xMega2ChanMutex != NULL);
			pmega++;
		}
		init_mrte_buffers();
	}

	pmega = _global_mega_impl;
	// zero channel - for initialize
	pmega->head = CAN_PROTO_HEAD;
	can_set_filter(0, CAN_PROTO_HEAD, 0, 0);
	pmega->body = CAN_PROTO_BODY;
	can_set_filter(1, CAN_PROTO_BODY, 0, 0);
	pmega->tail = CAN_PROTO_TAIL;
	can_set_filter(2, CAN_PROTO_TAIL, 0, 0);
	pmega->headtail = CAN_PROTO_HEADTAIL;
	can_set_filter(3, CAN_PROTO_HEADTAIL, 0, 0);
	pmega->rxdata.curr_ind = 0;
	pmega->rxdata.data = _rx_channel_init;
	pmega->rxdata.len = RX_INIT_BUF_LEN;
	pmega->ready = 1;								// this channel always ready

//	pmega->rx_limit = INIT_SIZE;
//	pmega->rx_datablock = init_buf;	// short buffer for initialize datablock

	pmega++;													// channel 1 - for receive
	pmega->rxdata.data = _rx_channel_cmd;
	pmega->rxdata.curr_ind = 0;
	pmega->rxdata.len = RX_CMD_CH_BUF_LEN;
////	pmega->rx_limit = sizeof( rcv_buf );
////	pmega->rx_datablock = rcv_buf;		// buffer for data
//
	pmega++;													// channel 2 - for receive
	pmega++;													// channel 3 - for receive
	pmega++;													// channel 4 - for receive
	pmega->rxdata.data = _rx_channel_broadcast;
	pmega->rxdata.curr_ind = 0;
	pmega->rxdata.len = RX_BROADCAST_CH_BUF_LEN;

	//	//	pmega->rx_limit = RX_SIZE;
//	pmega->rx_limit = sizeof( rcv4_buf );
//	pmega->rx_datablock = rcv4_buf;	// buffer for data

#endif //MEGA2_EN
}


// Возвращает true, если reset, иначе false
// После вызова не передавать пакет в функцию mrte_push
portBASE_TYPE is_mrte_reset(int arbcode)
{
#ifdef MEGA2_EN
	if(arbcode == CAN_PROTO_RST)	// reset cmd found
	{
		mrte_init();
		send_init_request();
		return pdTRUE;
	}
#endif //MEGA2_EN
	return pdFALSE;
}


// Возвращает true, если start, иначе false
// После вызова не передавать пакет в функцию mrte_push
portBASE_TYPE is_mrte_start(int arbcode)
{
#ifdef MEGA2_EN
	if(arbcode == CAN_CMD_START)	// enable MRTE exchange
		return pdTRUE;
#endif //MEGA2_EN
	return pdFALSE;
}


// Возвращает true, если stop, иначе false
// После вызова не передавать пакет в функцию mrte_push
portBASE_TYPE is_mrte_stop(int arbcode)
{
#ifdef MEGA2_EN
	if(arbcode == CAN_CMD_STOP)		// disable MRTE exchange
		return pdTRUE;
#endif //MEGA2_EN
	return pdFALSE;
}

static portBASE_TYPE send_recieved_mrte_command(t_mega2_rxdatablock * pbuf)
{
#ifdef MEGA2_EN
	if( pbuf->chan_num == INIT_CHANNEL )
	{		// initialize block found
		assign_canid(pbuf);
	}
	else
	{		// regular datablock
		cmd_decoder(pbuf);
	}
#endif //MEGA2_EN
	return pdTRUE;
}

int mrte_push(const canmsg_t * candata)
{

#ifdef MEGA2_EN
	t_mega2_channel *pmega;						// local ptr
	int chan;
	int limit, i;
	unsigned char byte;
	unsigned short rx_crc;

	chan = (candata->ch >> 2);
//	configASSERT((chan < CHANNEL_LIMIT));
	if(chan < CHANNEL_LIMIT)
	{
		pmega = &_global_mega_impl[chan];
		if( (pmega->ready == 0) )
			return -1;
		if( candata->arbcode == pmega->head )
		{
//			configASSERT(pmega->rxdata.data != NULL);
			if(pmega->rxdata.data == NULL)
				return -1;
			pmega->rxdata.curr_ind = 0;
			limit = candata->dlc;
//			configASSERT((limit > 0) && (limit <= CAN_PCKT_MAX_LEN));
			if( (limit <= 0) || (limit > CAN_PCKT_MAX_LEN) )
				return -1;
			for( i=0; i<limit; i++ )
				pmega->rxdata.data[i] = candata->data.dU8[i];
			pmega->rxdata.curr_ind += limit;
			return 0;
		}
		if( candata->arbcode == pmega->body )
		{
//			configASSERT(pmega->rxdata.data != NULL);
			if(pmega->rxdata.data == NULL)
				return 0;
			limit = candata->dlc;
//			configASSERT((limit > 0) && (limit <= CAN_PCKT_MAX_LEN) && ((pmega->rxdata.curr_ind+limit) <= pmega->rxdata.len));
			if( (limit == 0) || (limit > CAN_PCKT_MAX_LEN) || ((pmega->rxdata.curr_ind+limit) > pmega->rxdata.len) )
				return 0;
			for( i=0; i<limit; i++ )
				pmega->rxdata.data[pmega->rxdata.curr_ind+i] = candata->data.dU8[i];
			pmega->rxdata.curr_ind += limit;		// increment datablock
			return 0;
		}
		if( candata->arbcode == pmega->tail )
		{
//			configASSERT(pmega->rxdata.data != NULL);
			if(pmega->rxdata.data == NULL)
				return 0;
			limit = candata->dlc;
//			configASSERT((limit > 0) && (limit <= CAN_PCKT_MAX_LEN) && ((pmega->rxdata.curr_ind+limit) <= pmega->rxdata.len));
			if( (limit == 0) || (limit > CAN_PCKT_MAX_LEN) || ((pmega->rxdata.curr_ind+limit) > pmega->rxdata.len) )
				return 0;
			for( i=0; i<limit; i++ )
				pmega->rxdata.data[pmega->rxdata.curr_ind+i] = candata->data.dU8[i];
			pmega->rxdata.curr_ind += limit;		// increment datablock
			// swap CRC bytes
			byte = pmega->rxdata.data[pmega->rxdata.curr_ind-2];
			pmega->rxdata.data[pmega->rxdata.curr_ind-2] = pmega->rxdata.data[pmega->rxdata.curr_ind-1];
			pmega->rxdata.data[pmega->rxdata.curr_ind-1] = byte;
			// CRC check
			rx_crc = 0xFFFF;
			for( i=0; i<pmega->rxdata.curr_ind; i++ )
				rx_crc = update_crc_ccitt( rx_crc, pmega->rxdata.data[i] );
			if( rx_crc )
			{
				return 0;													// wrong crc, drop it
			}
			else
			{	// Call userspace here if you want - datablock ready
				send_recieved_mrte_command(&(pmega->rxdata));
				return 1;
			}
		}
		if( candata->arbcode == pmega->headtail )
		{
//			configASSERT(pmega->rxdata.data != NULL);
			if(pmega->rxdata.data == NULL)
				return -1;
			pmega->rxdata.curr_ind = 0;
			limit = candata->dlc;
//			configASSERT((limit > 0) && (limit <= CAN_PCKT_MAX_LEN));
			if( (limit <= 0) || (limit > CAN_PCKT_MAX_LEN) )
				return -1;
			for( i=0; i<limit; i++ )
				pmega->rxdata.data[i] = candata->data.dU8[i];
			pmega->rxdata.curr_ind += limit;
			// Call userspace here - datablock ready
			send_recieved_mrte_command(&(pmega->rxdata));
			return 1;
		}
	}

#endif //MEGA2_EN
	return 0;
}


// transmit datablock if exist
// main transmitter method
// return -3 if mpool is empty
// return -2 if mbx is full
// return -1 if failure
// return 0 if current datablock not transmitted
// return 1 if datablock transmitted
portBASE_TYPE mrte_transmit(portTickType timeout)
{
#ifdef MEGA2_EN
	t_mega2_channel *pmega;					// local ptr
	u32 i, limit, mode;//, rc
	u16 tx_crc;
	static canmsg_t	candata;
	u32 chan_num;
	ts_mrte_send_queue	mrte_cmd;
	t_mrte_msg_buff * p_mrte_buff;

	if( xQueueReceive( xMrteSendQueue, &mrte_cmd, timeout ) == pdTRUE)
	{
		if(mrte_cmd.cmd == mrte_send_data)
		{
			p_mrte_buff = mrte_cmd.pbuf;

			configASSERT(p_mrte_buff != NULL);

			chan_num = p_mrte_buff->chan_num;
			pmega = &_global_mega_impl[chan_num];
			while( (p_mrte_buff->curr_ind < p_mrte_buff->len) && (pmega->ready))
			{
				limit = p_mrte_buff->len - p_mrte_buff->curr_ind;		// rest of datablock in bytes
				// channel has initialized, ptr ok, datablock has not transmitted
				// let's select mode of transmitter
				// what a kind of canid we should use?
				// may be, head?
				if( p_mrte_buff->curr_ind )			// not zero if we has transmit some data in this datablock
				{
					if( limit > MAXCANDATALENGTH )
						mode = BODY;									// transmit body
					else
						mode = TAIL; 									// body
				}
				else
				{	// this datablock is first in sequence
					// but may be, it's to short for head-body-tail?
					if( limit <= MAXCANDATALENGTH )
						mode = HEADTAIL;							// headtail
					else
					{
						mode = HEAD;									// select head
						// CRC staff
						tx_crc = 0xFFFF;
						for( i=0; i<p_mrte_buff->len; i++ )
							tx_crc = update_crc_ccitt( tx_crc, p_mrte_buff->buff->data.dU8[i] );
						// store CRC
						p_mrte_buff->len += 2;
						configASSERT(p_mrte_buff->len <= MSG_MAX_LEN);
						p_mrte_buff->buff->data.dU8[p_mrte_buff->len-2] = tx_crc;
						p_mrte_buff->buff->data.dU8[p_mrte_buff->len-1] = tx_crc>>8;
					}
				}

				{
					// mode selected, let's proceed
					switch( mode )
					{
					case HEAD:
					{// proceed head
						if( limit > MAXCANDATALENGTH )
							limit = MAXCANDATALENGTH;
						for( i=0; i<limit; i++ )
							candata.data.dU8[i] = p_mrte_buff->buff->data.dU8[i];
						candata.arbcode = pmega->head;
						candata.dlc = limit;
						p_mrte_buff->curr_ind += limit;
						break;
					}
					case BODY:
					{				// proceed body
						if( limit > MAXCANDATALENGTH )
							limit = MAXCANDATALENGTH;
						for( i=0; i<limit; i++ )
							candata.data.dU8[i] = p_mrte_buff->buff->data.dU8[p_mrte_buff->curr_ind+i];
						candata.arbcode = pmega->body;
						candata.dlc = limit;
						p_mrte_buff->curr_ind += limit;
						break;
					}
					case TAIL:
					{				// proceed tail
						configASSERT(limit <= MAXCANDATALENGTH);	// sanity;

						for( i=0; i<limit; i++ )
							candata.data.dU8[i] = p_mrte_buff->buff->data.dU8[p_mrte_buff->curr_ind+i];
						p_mrte_buff->curr_ind += limit;
						candata.arbcode = pmega->tail;
						candata.dlc = limit;

						break;
					}
					case HEADTAIL:
					{	// proceed headtail
						configASSERT(limit <= MAXCANDATALENGTH);	// sanity;
						for( i=0; i<limit; i++ )
							candata.data.dU8[i] = p_mrte_buff->buff->data.dU8[i];
						candata.arbcode = pmega->headtail;
						candata.dlc = limit;
						p_mrte_buff->curr_ind += limit;
						//					find_ch = true;
						break;
					}
					}

					if(chan_num == ASYNC_CHANNEL)
					{
						CAN_MONITOR_typ		can_arch_data;
						can_arch_data.CAN_ID.canid = candata.arbcode & 0x3FF;
						can_arch_data.CAN_ID.len = candata.dlc;
						can_arch_data.DATA_CAN = candata.data;
//						can_arch_data.TIME_UTC = //TODO
//						can_arch_data.TIME_MS = //TODO
						//Put to FLASH queue
						if(can_send_msg(&candata) == pdTRUE)
						{
							//data are sended to CAN TX QUEUE
							can_arch_data.CAN_ID.tx_ok = 0;
						}
						else
						{
							can_arch_data.CAN_ID.tx_ok = 1;
						}
						put_can_pckt_to_arch(&can_arch_data);
					}
					else
					{
						//Do not save this traffic
						if(can_send_msg(&candata) != pdTRUE)
						{
							//TODO
						}
					}

				}
			}
			//mssage sended, release the buffer
			configASSERT(free_mrte_send_buff(p_mrte_buff) == pdTRUE);
		}
		else if(mrte_cmd.cmd == mrte_send_init)
		{
			candata.data.dU8[0] = _global_devtype;
			candata.data.dU8[1] = _global_devtype >> 8;
			candata.data.dU8[2] = _global_devnum;
			candata.data.dU8[3] = _global_devnum >> 8;

			candata.data.dU8[4] = 0;
			candata.data.dU8[5] = 0;
			candata.data.dU8[6] = 0;
			candata.data.dU8[7] = 0;
			// get random num for arb code
			tx_crc = 0xFFFF;
			for( i=0; i<4; i++ )
				tx_crc = update_crc_16( tx_crc, candata.data.dU8[i] );

			tx_crc &= 0x01FF;
			tx_crc |= 0x0200;
			// check reserved canids
			if( (tx_crc == CAN_PROTO_RST) ||
				(tx_crc == CAN_PROTO_HEAD) ||
				(tx_crc == CAN_PROTO_BODY) ||
				(tx_crc == CAN_PROTO_TAIL) ||
				(tx_crc == CAN_PROTO_HEADTAIL) ||
				(tx_crc == CAN_PROTO_RUN)
			)
				tx_crc = 0x123;	// change random to fixed value
			candata.arbcode = tx_crc;
			candata.dlc = 8;

			can_send_msg(&candata);
		}
		else
		{
			return pdFALSE;
		}

		return pdTRUE;
	}
	return pdFALSE;
	//	return rc;
#else //MEGA2_EN
	return pdFALSE;
#endif //MEGA2_EN
}


static portBASE_TYPE send_init_request(void)
{
#ifdef MEGA2_EN
	ts_mrte_send_queue	mrte_cmd;
	mrte_cmd.cmd = mrte_send_init;
	return xQueueSendToBack(xMrteSendQueue, &mrte_cmd, MRTE_SEND_BLOCK_TIME);

#endif //MEGA2_EN
	return pdTRUE;
}

//static void assign_canid(void)
void assign_canid( t_mega2_rxdatablock *pbuff )
{
#ifdef MEGA2_EN
	t_mega2_channel *pmega;
	u16 canid, devtype, devnum, channel, type;
	//	short i;

	devtype = ((pbuff->data[1] << 8) & 0xFF00) + ((pbuff->data[0]) & 0xFF);
	devnum =  ((pbuff->data[3] << 8) & 0xFF00) + ((pbuff->data[2]) & 0xFF);

	// is this datablock for me?
	if( (devtype == _global_devtype) &&
		(devnum == _global_devnum)
	)
	{
		// extract datablock
		canid 	= ((pbuff->data[11] << 8) & 0xFF00) + ((pbuff->data[10]) & 0x00FF);
		channel = ((pbuff->data[8]) & 0x00FF);
		type 	= ((pbuff->data[9]) & 0x00FF);
		// sanity check
		if( (channel == INIT_CHANNEL) || (channel >= CHANNEL_LIMIT) )
			return;
		// go to assigned channel
		pmega = _global_mega_impl;
		pmega += channel;
		// drop ready flag - channel initialize now
		if(xSemaphoreTake(pmega->xMega2ChanMutex, portMAX_DELAY ) == pdTRUE)
		{
			pmega->ready = 0;
			// let's assign CAN id
			switch( type )
			{
			case CAN_PROTO_HEAD:
				pmega->head = canid;
				break;
			case CAN_PROTO_BODY:
				pmega->body = canid;
				break;
			case CAN_PROTO_TAIL:
				pmega->tail = canid;
				break;
			case CAN_PROTO_HEADTAIL:
				pmega->headtail = canid;
				break;
			case CAN_PROTO_RUN:
				pmega->ready = 1;
				if(channel == 1)
				{
					for(; channel < CHANNEL_LIMIT; channel++)
					{
						can_set_filter((channel << 2) + 0, _global_mega_impl[channel].head, 0, 0);
						can_set_filter((channel << 2) + 1, _global_mega_impl[channel].body, 0, 0);
						can_set_filter((channel << 2) + 2, _global_mega_impl[channel].tail, 0, 0);
						can_set_filter((channel << 2) + 3, _global_mega_impl[channel].headtail, 0, 0);
					}
				}
			}// switch (type)
			xSemaphoreGive(pmega->xMega2ChanMutex);
		}
	}
#endif //MEGA2_EN
}


//int get_channel_by_canid(unsigned short canid)
//{
//#ifdef MEGA2_EN
//	int i;
//	for( i=0; i < CHANNEL_LIMIT; i++ )
//	{
//		if(		(_global_mega_impl[i].head == canid) ||
//				(_global_mega_impl[i].body == canid) ||
//				(_global_mega_impl[i].tail == canid) ||
//				(_global_mega_impl[i].headtail == canid)
//		)
//			return i;
//	}
//#endif //MEGA2_EN
//	return -1;
//}
//
//
//void get_canid(short* pcanid)
//{
//	unsigned short ind;
//
//	for(ind = 1; ind < CHANNEL_LIMIT; ind++)
//	{
//		*(pcanid++)		= _global_mega_impl[ind].head;
//		*(pcanid++)		= _global_mega_impl[ind].body;
//		*(pcanid++)		= _global_mega_impl[ind].tail;
//		*(pcanid++)		= _global_mega_impl[ind].headtail;
//	}
//}
//
//void set_canid(short* pcanid)
//{
//	unsigned short ind;
//
//	for(ind = 1; ind < CHANNEL_LIMIT; ind++)
//	{
//		if(xSemaphoreTake(_global_mega_impl[ind].xMega2ChanMutex, portMAX_DELAY ) == pdTRUE)
//		{
//			_global_mega_impl[ind].head			= *(pcanid++);
//			//		CAN_rx_object(CAN_CTRL_NUM, 0, _global_mega_impl[ind].head, DATA_TYPE | STANDARD_TYPE);			// Enable reception
//			_global_mega_impl[ind].body			= *(pcanid++);
//			//		CAN_rx_object(CAN_CTRL_NUM, 0, _global_mega_impl[ind].body, DATA_TYPE | STANDARD_TYPE);			// Enable reception
//			_global_mega_impl[ind].tail			= *(pcanid++);
//			//		CAN_rx_object(CAN_CTRL_NUM, 0, _global_mega_impl[ind].tail, DATA_TYPE | STANDARD_TYPE);			// Enable reception
//			_global_mega_impl[ind].headtail		= *(pcanid++);
//			//		CAN_rx_object(CAN_CTRL_NUM, 0, _global_mega_impl[ind].headtail, DATA_TYPE | STANDARD_TYPE);	// Enable reception
//			_global_mega_impl[ind].ready		= 1;
//			xSemaphoreGive(_global_mega_impl[ind].xMega2ChanMutex);
//		}
//	}
//}


//int is_mrte_busy()
//{
//#ifdef MEGA2_EN
//	int i;
//	for( i=0; i < CHANNEL_LIMIT; i++ )
//		if( _global_mega_impl[i].ready &&
//				_global_mega_impl[i].tx_datablock != NULL &&
//				_global_mega_impl[i].tx_current_offset < _global_mega_impl[i].tx_length )
//			return 1;
//#endif //MEGA2_EN
//	return 0;
//}


//portBASE_TYPE mrte_check(int channel)
//{
//#ifdef MEGA2_EN
//	if(!_global_mega_impl[channel].ready |		// channel not initialized
//			(_global_mega_impl[channel].tx_current_offset < _global_mega_impl[channel].tx_length)) // channel busy
//		return pdFALSE;
//#endif //MEGA2_EN
//	return pdTRUE;
//}

//================================================================================
// ==========					MRTE VIA FREERTOS 					=============
//================================================================================

#define MRTE_RX_TASK_STACK	(512U)
#define MRTE_TX_TASK_STACK	(256U)

void init_mrte_tasks(UBaseType_t task_priority)
{
	configASSERT(xTaskCreate( can_rx_mrte_task, 	"MrteRx", 	MRTE_RX_TASK_STACK, NULL, ( task_priority ), NULL ));
	configASSERT(xTaskCreate( can_tx_mrte_task, 	"MrteTx", 	MRTE_TX_TASK_STACK, NULL, ( task_priority ), NULL ));
}

void can_rx_mrte_task(void *pvParameters)
{
	canmsg_t can_message;
	can_init();
	mrte_init();

	while(1)
	{
		if(can_recieve_msg(&( can_message ), ( portTickType ) 1) == pdTRUE)
		{
			if(is_mrte_reset(can_message.arbcode))		// CAN_ID == 0
			{

			}
			else if(is_mrte_stop(can_message.arbcode))
				CAN_tx_stop(1);
			else if(is_mrte_start(can_message.arbcode))
				CAN_tx_start(1);
			else
			{
				mrte_push(&can_message);
			}

		}
		else
		{
			// DIGITAL_IO_ToggleOutput(&LED);
		}
		// Transmit
//		mrte_transmit(( TickType_t ) 1);
	}
}

//==========================
void can_tx_mrte_task(void *pvParameters)
{
	if(xMrteSendQueue == NULL)
	{
		vTaskDelay(10);	//TODO	DLY_WAIT_TASK
	}
	while(1)
	{
		mrte_transmit(( TickType_t ) portMAX_DELAY);
	}
}
