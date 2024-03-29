/*
 * can_cmd_defs.h
 *
 *  Created on: 08.09.2017
 *      Author: pavlenko_av
 */

#ifndef CAN_CMD_DEFS_H_
#define CAN_CMD_DEFS_H_

//#include "plt_bpsk_buff_desc.h"
//#include "plt_msmt_proc.h"
#include "io_mrte_config.h"

//-----------------------------------------------------------------------------
//#define MODULE_VER_PO				"MEGA-SPEAR_Dev_1.0_18.05.2020"
#ifndef NDEBUG
#define MODULE_VER_PO				"MEGA-SPEAR_Dev_2.2_29.09.2021"
#else
#define MODULE_VER_PO				"MEGA-SPEAR_Rel_2.2_29.09.2021"
#endif

#define LENGTH_VER_PO			(32)
#define COMMAND_SET_SER_NUM						(0x01)
#define COMMAND_SET_PARAMS						(0x02)
#define COMMAND_GET_PARAMS						(0x03)
#define COMMAND_GET_INFO						(0x04)
#define COMMAND_SET_TIME						(0x05)
#define COMMAND_SET_TIMER						(0x06)

#define COMMAND_WRITE_FILE_DATA					(0x0E)
#define COMMAND_READ_FILE_DATA					(0x0F)
#define COMMAND_READ_ARC_FILE_DATA				(0x46)

#define COMMAND_GET_ARC_ADDR					(0x10)
#define COMMAND_SET_ARC_ADDR					(0x11)

#define COMMAND_COPY_TO_GOLDEN					(0x41)
#define COMMAND_START_STOP_LOGGING				(0x44)
#define COMMAND_CAN_ECHO_TEST					(0x55)

#define COMMAND_SAVE_CANID						(0x5A)
#define COMMAND_FORMAT_FLASH					(0x5B)
#define COMMAND_RESET_WORK_INFO					(0x5C)

#define COMMAND_GET_BASE_TLM					(0x0B)
#define COMMAND_GET_EXT_TLM						(0x17)

#define COMMAND_GET_OSC							(0x20)

#define COMMAND_TIMESTAMP						(0x43)

#define COMMAND_SET_DISTR_SERIES_TIME 			(0x33)
#define COMMAND_SET_MODE_SP						(0x0C)
#define COMMAND_PWR_OFF_ON						(0x50)
#define COMMAND_UP_37V							(0x51)
#define COMMAND_SET_STI							(0x4F)
#define GET_SPEED_SIMPLEX						(0x4E)

//-----------------------------------------------------------------------------
#define Length_HEAD_RX			(2)
#define Length_HEAD_TX			(2 + 4)

#define Length_CRC				(2)

#define Length_ERROR_TX			(8)

//------------------------------------------------------
// COMMAND_SET_SER_NUM
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16	serial_number;
} SET_SER_NUM_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_SET_SER_NUM	 			(sizeof(SET_SER_NUM_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_SER_NUM					(sizeof(SET_SER_NUM_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_PARAMS
//------------------------------------------------------

//*******************************************************
// DEVICE DEFAULTS
//*******************************************************
#define PLT_MIN_VOLTAGE (0.0f)
#define PLT_MAX_VOLTAGE	(89.0f)
#define PLT_DEFAULT_VOLTAGE	(60.0f)

#define PLT_MAX_CURRENT	(400.0f)
#define PLT_DEFAULT_CURRENT	(120.0f)

#pragma pack(push, 1)
typedef struct
{
	float	volt_limit;
	float	curr_value;
	u16		channel;
} SET_PARAMS_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_SET_PARAMS	 			(sizeof(SET_PARAMS_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_PARAMS				(sizeof(SET_PARAMS_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_GET_PARAMS
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	float	temp;
	float	volt_limit;
	float	curr_value;
	float	volt_measd;
	float	curr_measd;
	u16		channel;
} GET_PARAMS_TX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_GET_PARAMS 			(Length_HEAD_RX)
#define SIZE_ANSWER_COM_GET_PARAMS				(sizeof(GET_PARAMS_TX_type) + Length_HEAD_TX)

//------------------------------------------------------
// ���������  ������ ���. "GET_INFO" (4-� ���.)
//------------------------------------------------------

//-----------------------------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16 					ModuleType;
	u16						TimerTick;
	u32						TimeUTC;
	u16						ModuleSN;
	u8						VER_PO[LENGTH_VER_PO];
	u16						COUNTER_INCLUSION;
	u32             		Time_Worked;
	u32						Alarm_Time;//Reserve_1; //Alarm_Time;
	u32						Time_STOP_Of_Work;//Reserve_2; //Time_STOP_Of_Work;
	u16						COM_Measure_AS_CmdPeriod;
	u16						COM_Tesh_Measure_AS_CmdPeriod;
	u16 					MAX_Length_Package; 	//Reserve_3; //MAX_Length_Package;
	u16 					Length_File_LOG; 	//Reserve_4; //Length_File_LOG;
	u16 					Length_File_CAL; 	//Reserve_5; //Length_File_CAL;
	u32 				    Length_File_ARC[2];	//	u64						Reserve_6;
	u32 					Length_Block_ARC; //Reserve_7; //Length_Block_ARC;
	u32 					Count_Block_ARC; //Reserve_8; //Count_Block_ARC;
	u32 					Count_Bad_Block_ARC;//Reserve_9; //Count_Bad_Block_ARC;
	u32						Status;
} COM_RD_GET_INFO_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_RD_GET_INFO	 			(Length_HEAD_RX)
#define SIZE_ANSWER_COM_RD_GET_INFO					(sizeof(COM_RD_GET_INFO_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_TIME
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32		utc_time;
} SET_TIME_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_SET_TIME 				(sizeof(SET_TIME_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_TIME				(sizeof(SET_TIME_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_TIMESTAMP
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32		utc_time;
	u16 	time_ms;
} COMMAND_TIMESTAMP_RX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_TIMESTAMP 				(sizeof(COMMAND_TIMESTAMP_RX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_TIMESTAMP				(0)

//------------------------------------------------------
// COMMAND_SET_TIMER
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32		start_time;
	u32		stop_time;
	u16		base_tlm_rate;
	u16		ext_tlm_rate;
} SET_TIMER_RTX_type;
#pragma pack(pop)

#define BASE_TLM_MIN_RATE	(23)
#define EXT_TLM_MIN_RATE	(100)
#define EXT_TLM_MAX_RATE	(10000)

#define SIZE_RECEIVE_COM_SET_TIMER 				(sizeof(SET_TIMER_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_TIMER				(sizeof(SET_TIMER_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// ���������  ������ ���. "WRITE_FILE_DATA" ������ � ���� ������ ������ ������ (14-� ���.)
//------------------------------------------------------

typedef enum
{
		FILE_LOG_com 	= 0,
		FILE_CAL_com 	= 1,
		FILE_ARC_com 	= 2,

		FILE_ERR_com 	= 4,
		FILE_PROG_com 	= 5
} COMMAND_FILE_type;

#pragma pack(push, 1)
typedef struct	// ��������� ���.
{
	u16						FILE_SEL; 						// ����: 0 - LOG, 1 - CAL
	u32						START_ADDRES[2]; 				// ��������� �����
	u32						STOP_ADDRES[2];					// �������� ����� +1
	u8						DATA[MAX_LENGTH_PACKAGE_def];	// ������ ������
} COM_WR_FILE_DATA_buf_r_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct	// ��������� ������
{
	u16						FILE_SEL; 						// ����: 0 - LOG, 1 - CAL
	u32						START_ADDRES[2]; 				// ��������� �����
	u32						STOP_ADDRES[2];					// �������� ����� +1
} COM_WR_FILE_DATA_buf_t_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_WR_FILE_DATA  			(sizeof(COM_WR_FILE_DATA_buf_r_type) + Length_HEAD_RX) //+ Length_CRC �����, �� �������� ����� � �����
#define SIZE_ANSWER_COM_WR_FILE_DATA 			(sizeof(COM_WR_FILE_DATA_buf_t_type) + Length_HEAD_TX)

//------------------------------------------------------
// ���������  ������ ���. "READ_FILE_DATA" ������ � ���� ������ ������ ������ (15-� ���.)
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct	// ��������� ���.
{
	u16						FILE_SEL; 						// ����: 0 - LOG, 1 - CAL
	u32						START_ADDRES[2]; 				// ��������� �����
	u32						STOP_ADDRES[2];					// �������� ����� +1
} COM_RD_FILE_DATA_buf_r_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct	// ��������� ������
{
	u32						CUR_ADDRES[2];					// �������� ����� +1
	u8						DATA[MAX_LENGTH_PACKAGE_def];	// ������ ������
} COM_RD_FILE_DATA_buf_t_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_RD_FILE_DATA  		(sizeof(COM_RD_FILE_DATA_buf_r_type) + Length_HEAD_RX ) //+ Length_CRC �����, �� �������� ����� � �����
#define SIZE_ANSWER_COM_RD_FILE_DATA 		(sizeof(COM_RD_FILE_DATA_buf_t_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_ARC_ADDR / COMMAND_GET_ARC_ADDR
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32		arc_addr[2];
} GET_SET_ARC_ADDR_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_GET_ARC_ADDR			(Length_HEAD_RX)
#define SIZE_RECEIVE_SET_ARC_ADDR 			(sizeof(GET_SET_ARC_ADDR_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_GET_SET_ARC_ADDR		(sizeof(GET_SET_ARC_ADDR_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_COPY_TO_GOLDEN
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct{
	u32 sequrity_key;
} COMMAND_COPY_TO_GOLDEN_buf_type;
#pragma pack(pop)

//#define COPY_TO_GOLDEN_MAGIC_KEY						(0x80230041)
#define COPY_TO_GOLDEN_MAGIC_KEY						(0x80300041)

#define SIZE_RECEIVE_COMMAND_COPY_TO_GOLDEN	 	(Length_HEAD_RX + sizeof(COMMAND_COPY_TO_GOLDEN_buf_type))
#define SIZE_ANSWER_COMMAND_COPY_TO_GOLDEN		(Length_HEAD_TX + sizeof(COMMAND_COPY_TO_GOLDEN_buf_type))


//------------------------------------------------------
//#define COMMAND_START_STOP_LOGGING					(0x44)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct{
	u8 cmd;
} COMMAND_START_STOP_LOGGING_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_START_STOP_LOGGING	 	(Length_HEAD_RX + sizeof(COMMAND_START_STOP_LOGGING_buf_type))
#define SIZE_ANSWER_COMMAND_START_STOP_LOGGING		(Length_HEAD_TX + sizeof(COMMAND_START_STOP_LOGGING_buf_type))


//------------------------------------------------------
//#define COMMAND_TEST_CAN_TRANSFER						(0x55)
//------------------------------------------------------


//------------------------------------------------------
// COMMAND_SAVE_CAN_ID
//------------------------------------------------------
//#pragma pack(push, 1)
//typedef struct
//{
//	u16		head;
//	u16		body;
//	u16		tail;
//	u16		head_tail;
//} can_id_type;
//
//typedef struct{
//	can_id_type	can_id[4];
//} COMMAND_SAVE_CAN_ID_TX_type;
//#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_SAVE_CAN_ID	(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_SAVE_CAN_ID		(Length_HEAD_TX + 4*4*sizeof(u16)/*sizeof(COMMAND_SAVE_CAN_ID_TX_type)*/)

//------------------------------------------------------
// COMMAND_FORMAT_FLASH
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct{
	u32 sequrity_key;
} COMMAND_FORMAT_FLASH_RX_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct{
	//u16 flash_status; //Shishkin
	u32 bad_block_num;//Shishkin view in GET_INFO u32
} COMMAND_FORMAT_FLASH_TX_type;
#pragma pack(pop)

#define FORMAT_FLASH_MAGIC_KEY						(0x8023005B)

#define SIZE_RECEIVE_COMMAND_COMMAND_FORMAT_FLASH	(Length_HEAD_RX + sizeof(COMMAND_FORMAT_FLASH_RX_type))
#define SIZE_ANSWER_COMMAND_COMMAND_FORMAT_FLASH	(Length_HEAD_TX + sizeof(COMMAND_FORMAT_FLASH_TX_type))

//------------------------------------------------------
// COMMAND_CLEAR_WORK_INFO
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct{
	u32 sequrity_key;
} COMMAND_CLEAR_WORK_INFO_RTX_type;
#pragma pack(pop)

#define CLEAR_WORK_INFO_MAGIC_KEY						(0x8023005C)

#define SIZE_RECEIVE_COMMAND_CLEAR_WORK_INFO	(Length_HEAD_RX + sizeof(COMMAND_CLEAR_WORK_INFO_RTX_type))
#define SIZE_ANSWER_COMMAND_CLEAR_WORK_INFO		(Length_HEAD_TX + sizeof(COMMAND_CLEAR_WORK_INFO_RTX_type))

//------------------------------------------------------
// COMMAND_GET_BASE_TLM
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u16 		TLM_PERIOD;
	u16			PeriodZond;
	u8			Len;
	u8			Adr;
	u8			Com;
	u8			Data[13];
} GET_BASE_TLM_RX_type;
#pragma pack(pop)


//------------------------------------------------------
// COMMAND_GET_EXT_TLM
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u16 		TLM_PERIOD;
} GET_EXT_TLM_RX_type;
#pragma pack(pop)

/*
#pragma pack(push, 1)
typedef struct
{
	u16 		ModuleType;
	u16			TimerTick;
	u32			TimeUTC;
	u32			PltBaseStatus;
	u16			PltChanValid;
	u16			channel[PLT_CHANNELS_COUNT];
} GET_BASE_TLM_TX_type;
#pragma pack(pop)
*/

#pragma pack(push, 1)
typedef struct
{
	u16 		ModuleType;
	u16			TimerTick;
	u32			TimeUTC;
	u8			DATA[256];
} GET_BASE_TLM_TX_type;
#pragma pack(pop)





u32 PrepareBaseTlm(GET_BASE_TLM_TX_type* pbuff);
u32 PrepareBaseTlmSimplex(GET_BASE_TLM_TX_type* pbuff);
u32 PrepareBaseDataEmpty(GET_BASE_TLM_TX_type* pbuff);

#define SIZE_RECEIVE_GET_BASE_TLM				(Length_HEAD_RX)
//#ifndef NDEBUG
//#define SIZE_ANSWER_GET_BASE_TLM_HEAD			(MAX_LENGTH_PACKAGE_def + Length_HEAD_TX)
//#else
#define SIZE_ANSWER_GET_BASE_TLM_HEAD			(sizeof(GET_BASE_TLM_TX_type) + Length_HEAD_TX)
//#endif //NDEBUG

//TODO!!! Rise compilation error if ( SIZE_ANSWER_GET_BASE_TLM > MAX_LENGTH_PACKAGE_def )

//------------------------------------------------------
// COMMAND_GET_EXT_TLM
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16 				ModuleType;
	u16					TimerTick;
	u32					TimeUTC;
	u32             	pwr;
	u32					status;
	u16					ErrorCounter;
	u16					reserve;
	float				volt_measd;
	float				curr_measd;
} GET_EXT_TLM_TX_type;
#pragma pack(pop)

/*
typedef struct
{
	u16 				ModuleType;
	u16					TimerTick;
	u32					TimeUTC;
	plt_pwr_params_type	pwr;
	u32				status;
	u32				reserve;
	float				volt_measd;
	float				curr_measd;
} GET_EXT_TLM_TX_type;
#pragma pack(pop)*/

u32 PrepareExtTlm(GET_EXT_TLM_TX_type* pbuff);

#define SIZE_RECEIVE_GET_EXT_TLM			(Length_HEAD_RX)
#define SIZE_ANSWER_GET_EXT_TLM				(sizeof(GET_EXT_TLM_TX_type) + Length_HEAD_TX)


//------------------------------------------------------
// COMMAND_SET_DISTR_SERIES_TIME
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u16 		TimeShift;
} SET_DISTR_SERIES_TIME_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_SET_DISTR_SERIES_TIME	 			(sizeof(SET_DISTR_SERIES_TIME_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_DISTR_SERIES_TIME				(sizeof(SET_DISTR_SERIES_TIME_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_MODE_SP
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u8 		mode_sp;
} SET_MODE_SP_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_SET_MODE_SP	 			(sizeof(SET_MODE_SP_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_MODE_SP					(sizeof(SET_MODE_SP_RTX_type) + Length_HEAD_TX)
//------------------------------------------------------
// COMMAND_PWR_OFF_ON
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u8 		pwr;
} PWR_OFF_ON_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_PWR_OFF_ON	 			(sizeof(PWR_OFF_ON_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_PWR_OFF_ON				(sizeof(PWR_OFF_ON_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_UP_37V
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u8 		state;
} UP_37V_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_UP_37V	 			(sizeof(UP_37V_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_UP_37V				(sizeof(UP_37V_RTX_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_STI
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u8 		STI;
} SET_STI_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_SET_STI 			(sizeof(SET_STI_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COM_SET_STI				(sizeof(SET_STI_RTX_type) + Length_HEAD_TX)


//------------------------------------------------------
// GET_SPEED_SIMPLEX
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u16 		rx;
	u16 		tx;
} GET_SPEED_RTX_type;
#pragma pack(pop)

#define SIZE_RECEIVE_GET_SPEED_SIMPLEX 			(Length_HEAD_RX)
#define SIZE_ANSWER_GET_SPEED_SIMPLEX			(sizeof(GET_SPEED_RTX_type) + Length_HEAD_TX)
//------------------------------------------------------

//------------------------------------------------------
// COMMAND_GET_OSC
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16		OscPeriod;
	u8		Channel;
} GET_OSC_RTX_type;

typedef struct
{
	u16 osc[1024];
} OSC_PCKT_TX_type;
#pragma pack(pop)

u32 PrepareOscPkt(OSC_PCKT_TX_type* pbuff);
int SetupOscPeriod(u16 period, u8 chan);
u16 GetActualOscPeriod(void);
u8  GetActualOscCh(void);

#define SIZE_RECEIVE_GET_OSC			(sizeof(GET_OSC_RTX_type) + Length_HEAD_RX)
#define SIZE_ANSWER_GET_OSC				(sizeof(GET_OSC_RTX_type) + Length_HEAD_TX)
#define SIZE_OF_OSC_PACKET				(sizeof(OSC_PCKT_TX_type) + Length_HEAD_TX)


//------------------------------------------------------
// ���������  ������ ���. "READ_ARC_FILE_DATA" ������ � ���� ������ ������ ������ (70-� ���.)
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct	// ��������� ���.
{
	u32						NUM_BEGIN_PAGE; 				// ����� ��������� ��������
	u32						NUM_END_PAGE;					// ����� �������� ��������
} COM_RD_ARC_FILE_DATA_buf_r_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct	// ��������� ������
{
	u32						NUM_PAGE;						// ����� �������� ��������
	u32						STATUS_PAGE;					// ������ ������ ��������
	u8						DATA[2040];	// ������ ��������
} COM_RD_ARC_FILE_DATA_buf_t_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COM_RD_ARC_FILE_DATA  		(sizeof(COM_RD_ARC_FILE_DATA_buf_r_type) + Length_HEAD_RX ) //+ Length_CRC �����, �� �������� ����� � �����
#define SIZE_ANSWER_COM_RD_ARC_FILE_DATA 		(sizeof(COM_RD_ARC_FILE_DATA_buf_t_type) + Length_HEAD_TX)

//------------------------------------------------------
// ����� ���������  ������ ���.
//------------------------------------------------------
#pragma pack(push, 1)
typedef union
{
	SET_SER_NUM_RTX_type							SET_SER_NUM_buf;
	SET_PARAMS_RTX_type								SET_PARAMS_buf;
	SET_TIME_RTX_type								SET_TIME_buf;
	SET_TIMER_RTX_type								SET_TIMER_buf;
	COM_RD_FILE_DATA_buf_r_type						COM_RD_FILE_DATA_buf;
	COM_WR_FILE_DATA_buf_r_type						COM_WR_FILE_DATA_buf;
	GET_SET_ARC_ADDR_RTX_type						SET_ARC_ADDR_buf;
	COMMAND_COPY_TO_GOLDEN_buf_type					COPY_TO_GOLDEN_buf;
	COMMAND_FORMAT_FLASH_RX_type					FORMAT_FLASH_MAGIC_word;
	COMMAND_CLEAR_WORK_INFO_RTX_type				CLEAR_WORK_INFO_MAGIC_word;
	GET_OSC_RTX_type								GET_OSC_buf;
	COMMAND_START_STOP_LOGGING_buf_type				START_STOP_LOGGING;
	COMMAND_TIMESTAMP_RX_type						TIMESTAMP;
	COM_RD_ARC_FILE_DATA_buf_r_type					COM_RD_ARC_FILE_DATA_buf;
	GET_BASE_TLM_RX_type							BASE_TLM_buf;
	GET_EXT_TLM_RX_type								EXT_TLM_buf;
	SET_DISTR_SERIES_TIME_RTX_type					SET_DISTR_SERIES_TIME;
	SET_MODE_SP_RTX_type							SET_MODE_SP;
	PWR_OFF_ON_RTX_type								PWR_OFF_ON;
	UP_37V_RTX_type									UP_37V;
	SET_STI_RTX_type								SET_STI;
} IKN_A2_COMMAND_rx_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef union
{
	SET_SER_NUM_RTX_type							SET_SER_NUM_buf;
	SET_PARAMS_RTX_type								SET_PARAMS_buf;
	GET_PARAMS_TX_type								GET_PARAMS_buf;
	COM_RD_GET_INFO_buf_type						COMMAND_GET_INFO_buf;
	SET_TIME_RTX_type								SET_TIME_buf;
	SET_TIMER_RTX_type								SET_TIMER_buf;
	GET_SET_ARC_ADDR_RTX_type						GET_ARC_ADDR_buf;
	COM_RD_FILE_DATA_buf_t_type						COM_RD_FILE_DATA_buf;
	COM_WR_FILE_DATA_buf_t_type						COM_WR_FILE_DATA_buf;
	COMMAND_COPY_TO_GOLDEN_buf_type					COPY_TO_GOLDEN_buf;
//	COMMAND_SAVE_CAN_ID_TX_type						SAVED_CAN_ID_buf;
	COMMAND_FORMAT_FLASH_TX_type					FORMAT_FLASH_TX_buf;
	COMMAND_CLEAR_WORK_INFO_RTX_type				CLEAR_WORK_INFO_MAGIC_word;
	GET_BASE_TLM_TX_type							BASE_TLM_buf;
	GET_EXT_TLM_TX_type								EXT_TLM_buf;
	GET_OSC_RTX_type								GET_OSC_buf;
	OSC_PCKT_TX_type								OSC_PCKT_buf;
	COMMAND_START_STOP_LOGGING_buf_type				START_STOP_LOGGING;
	COM_RD_ARC_FILE_DATA_buf_t_type					COM_RD_ARC_FILE_DATA_buf;
	SET_DISTR_SERIES_TIME_RTX_type					SET_DISTR_SERIES_TIME;
	SET_MODE_SP_RTX_type							SET_MODE_SP;
	PWR_OFF_ON_RTX_type								PWR_OFF_ON;
	UP_37V_RTX_type									UP_37V;
	SET_STI_RTX_type								SET_STI;
	GET_SPEED_RTX_type								GET_SPEED;
	u16												ERROR;
} IKN_A2_COMMAND_tx_type;
#pragma pack(pop)

//*******************************************************
#pragma pack(push, 1)
typedef struct
{
	u8 								CmdMarker; 	//������
	u8 								CmdCode;   	// ��� �������
	IKN_A2_COMMAND_rx_type			COMMAND;
	u16								CRC_val;
} RX_Com_buf_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
	u8 								CmdMarker; 	//������
	u8 								CmdCode;   	// ��� �������
	u32								Timer;
	IKN_A2_COMMAND_tx_type			COMMAND;
	u16								CRC_val;
} TX_Com_buf_type;
#pragma pack(pop)

//TODO!!! Rise compilation error if ( sizeof(RX_Com_buf_type) > MSG_MAX_LEN )
//TODO!!! Rise compilation error if ( sizeof(TX_Com_buf_type) > MSG_MAX_LEN )


//*******************************************************
// ERROR CODES
//*******************************************************

//#define ERROR_UNKNOWN_COMMAND		(0x01)
//#define ERROR_PARAMS_SIZE			(0x02)
//#define ERROR_PARAM_OUT_OF_RANGE	(0x03)
//#define ERROR_PARAMS_CONFLICT		(0x04)
//#define ERROR_HARDWARE				(0x05)
//#define ERROR_UNEXPECTED			(0x06)

//#define SIZE_ANSWER_ERROR 			(0x08)

//#define ERROR_QUEUE_IS_EMPTY		(0x10)
//
//#define ANSWER_SIZE					(sizeof(TX_Com_buf_type)+4)

//*******************************************************
//*******************************************************
//*******************************************************

#endif /* CAN_CMD_DEFS_H_ */
