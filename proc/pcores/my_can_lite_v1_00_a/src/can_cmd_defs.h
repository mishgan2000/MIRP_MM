/*
 * can_cmd_defs.h
 *
 *  Created on: 08.09.2017
 *      Author: pavlenko_av
 */

#ifndef CAN_CMD_DEFS_H_
#define CAN_CMD_DEFS_H_

#include "plt_bpsk.h"

//*******************************************************
// DEVICE DEFAULTS
//*******************************************************
#define PLT_MIN_VOLTAGE (27)
#define PLT_MAX_VOLTAGE	(89)
#define PLT_MAX_CURRENT	(400)

//-----------------------------------------------------------------------------
//#define MODULE_VER_PO				"\IKN_A2_DD1_ARM_0.35_09_04_13$\00"
//#define LENGTH_VER_PO				32
//#define COMMAND_GET_INFO								0x04
#define COMMAND_PROPERTY_GET_DEVICE_TYPE		(0x31)
#define COMMAND_PROPERTY_GET_SERIAL_NUMBER		(0x30)
#define COMMAND_PROPERTY_GET_SOFTWARE_VERSION	(0x2A)

#define COMMAND_SET_START_REG					(0x00)
#define COMMAND_SET_PARAM						(0x02)
#define COMMAND_SET_SOURCE						(0x03)
#define COMMAND_GET_SOURCE						(0x04)
#define COMMAND_SET_CHANNEL						(0x05)

#define COMMAND_PROPERTY_GET_TIME				(0x22)
#define COMMAND_PROPERTY_SET_TIME				(0x14)

#define COMMAND_PROPERTY_SET_OSC_SOURCE			(0x15)
#define COMMAND_PROPERTY_GET_OSC_SOURCE			(0x16)
#define COMMAND_PROPERTY_GET_OSC				(0x20)

#define COMMAND_PROPERTY_SET_ASYNC				(0x34)

#define COMMAND_GET_DATA						(0x01)

#define COMMAND_TEST_CAN_TRANSFER				(0x55)


//-----------------------------------------------------------------------------
#define Length_HEAD_RX			2
#define Length_HEAD_TX			2

#define Length_CRC				2

#define Length_ERROR_TX			4
//------------------------------------------------------
// структура  данных ком. "GET_INFO" (4-я ком.)
//------------------------------------------------------

//-----------------------------------------------------------------------------
//// структура времени наработки
//typedef struct
//{
//	u32  	Time_Worked_General;
//	u32  	Time_Worked_Less_0;
//	u32  	Time_Worked_Between_0_35;
//	u32  	Time_Worked_Between_35_90;
//	u32  	Time_Worked_Between_90_120;
//	u32  	Time_Worked_Bigger_120;
//}  Time_Worked_type;
//
//#pragma pack(push, 1)
//
//typedef struct
//{
//	u16 					ModuleType;
//	u16						TimerTick;
//	u32						TIME_UTC;
//	u16						ModuleSN;
//	u8						VER_PO[LENGTH_VER_PO];
//	u16						COUNTER_INCLUSION;
//	Time_Worked_type		Time_Worked;
//	u32						Alarm_Time;
//	u32						Time_STOP_Of_Work;
//	u16						COM_Measure_AS_CmdPeriod;
//	u16						COM_Tesh_Measure_AS_CmdPeriod;
//	u16 					MAX_Length_Package;
//	u16 					Length_File_LOG;
//	u16 					Length_File_CAL;
//	u32 					Length_File_ARC[2];
//	u32 					Length_Block_ARC;
//	u32 					Count_Block_ARC;
//	u32 					Count_Bad_Block_ARC;
//	u32 					Length_File_PSM;
//	u32						Time_Instalation1_UTC;
//	u32						Time_Instalation2_UTC;
//	u16						RG_STATUS;
//} COM_RD_GET_INFO_buf_type;
//#pragma pack(pop)

//#define SIZE_RECEIVE_COM_RD_GET_INFO	 			(Length_HEAD_RX)
//#define SIZE_ANSWER_COM_RD_GET_INFO					(sizeof(COM_RD_GET_INFO_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_PROPERTY_GET_DEVICE_TYPE
//------------------------------------------------------
#pragma pack(push, 1)
typedef struct
{
	u16	device_type;
} COMMAND_PROPERTY_GET_DEVICE_TYPE_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_GET_DEVICE_TYPE	 			(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_GET_DEVICE_TYPE				(sizeof(COMMAND_PROPERTY_GET_DEVICE_TYPE_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_PROPERTY_GET_SERIAL_NUMBER
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16	serial_number;
} COMMAND_PROPERTY_GET_SERIAL_NUMBER_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_GET_SERIAL_NUMBER	 			(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_GET_SERIAL_NUMBER				(sizeof(COMMAND_PROPERTY_GET_SERIAL_NUMBER_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
//	COMMAND_PROPERTY_GET_SOFTWARE_VERSION
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u8	main_version;
	u8 	sub_version;
	u8 	build_number;
} COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_GET_SOFTWARE_VERSION	 			(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_GET_SOFTWARE_VERSION				(sizeof(COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_START_REG
//------------------------------------------------------

#define SIZE_RECEIVE_COMMAND_SET_START_REG	 		(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_SET_START_REG			(Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_PARAM
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16	gain;
} COMMAND_SET_PARAM_RD_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_SET_PARAM	 			(sizeof(COMMAND_SET_PARAM_RD_buf_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_SET_PARAM				(Length_HEAD_TX)

//------------------------------------------------------
// COMMAND_SET_SOURCE
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16	max_voltage;
	u16 max_current;
	u16 set_current;
} COMMAND_SET_SOURCE_RD_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_SET_SOURCE	 			(sizeof(COMMAND_SET_SOURCE_RD_buf_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_SET_SOURCE				(Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_GET_SOURCE						(0x04)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32	time;
	u16	voltage;
	u16 current;
	u16 reserve;
} COMMAND_GET_SOURCE_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_GET_SOURCE	 			(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_GET_SOURCE				(sizeof(COMMAND_GET_SOURCE_buf_type) + Length_HEAD_TX)


//------------------------------------------------------
//#define COMMAND_SET_CHANNEL						(0x05)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u8	channel;
} COMMAND_SET_CHANNEL_RD_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_SET_CHANNEL	 		(sizeof(COMMAND_SET_CHANNEL_RD_buf_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_SET_CHANNEL				(Length_HEAD_TX)


//------------------------------------------------------
//#define COMMAND_PROPERTY_GET_TIME				(0x22)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32 time;
} COMMAND_PROPERTY_GET_TIME_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_GET_TIME	 	(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_GET_TIME		(sizeof(COMMAND_PROPERTY_GET_TIME_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_PROPERTY_SET_TIME				(0x14)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32	time;
} COMMAND_PROPERTY_SET_TIME_RD_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_SET_TIME	 	(sizeof(COMMAND_PROPERTY_SET_TIME_RD_buf_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_SET_TIME		(Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_PROPERTY_SET_OSC_SOURCE		(0x15)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16	osc_source;
} COMMAND_PROPERTY_SET_OSC_SOURCE_RD_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_SET_OSC_SOURCE	(sizeof(COMMAND_PROPERTY_SET_OSC_SOURCE_RD_buf_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_SET_OSC_SOURCE		(Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_PROPERTY_GET_OSC_SOURCE		(0x16)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u16	osc_source;
} COMMAND_PROPERTY_GET_OSC_SOURCE_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_GET_OSC_SOURCE	(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_GET_OSC_SOURCE		(sizeof(COMMAND_PROPERTY_GET_OSC_SOURCE_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_PROPERTY_GET_OSC				(0x20)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u32 time;
	u16 osc[PLT_OSC_SIZE];
} COMMAND_PROPERTY_GET_OSC_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_GET_OSC	 	(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_GET_OSC		(sizeof(COMMAND_PROPERTY_GET_OSC_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_PROPERTY_SET_ASYNC			(0x34)
//------------------------------------------------------

#pragma pack(push, 1)
typedef struct
{
	u8	async_cmd;
	u8	param;
	u16 period;
} COMMAND_PROPERTY_SET_ASYNC_RD_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_PROPERTY_SET_ASYNC	 	(sizeof(COMMAND_PROPERTY_SET_ASYNC_RD_buf_type) + Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_PROPERTY_SET_ASYNC		(Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_GET_DATA						(0x01)
//------------------------------------------------------

#pragma pack(push, 1)

//typedef struct
//{
//	u16	number;
//	u16 data;
//} PLT_PCKT_buf_type;

typedef struct
{
	u32 time;
	PLT_PCKT_buf_type chan[PLT_CHANNEL_NUMBER];
} COMMAND_GET_DATA_buf_type;
#pragma pack(pop)

#define SIZE_RECEIVE_COMMAND_GET_DATA	 	(Length_HEAD_RX)
#define SIZE_ANSWER_COMMAND_GET_DATA		(sizeof(COMMAND_GET_DATA_buf_type) + Length_HEAD_TX)

//------------------------------------------------------
//#define COMMAND_TEST_CAN_TRANSFER						(0x55)
//------------------------------------------------------


//------------------------------------------------------
// общая структура  данных ком.
//------------------------------------------------------
#pragma pack(push, 1)
typedef union
{
	COMMAND_SET_PARAM_RD_buf_type					COMMAND_SET_PARAM_RD_buf;
	COMMAND_PROPERTY_SET_TIME_RD_buf_type			COMMAND_PROPERTY_SET_TIME_RD_buf;
	COMMAND_PROPERTY_SET_ASYNC_RD_buf_type			COMMAND_PROPERTY_SET_ASYNC_RD_buf;
	COMMAND_SET_CHANNEL_RD_buf_type					COMMAND_SET_CHANNEL_RD_buf;
	COMMAND_SET_SOURCE_RD_buf_type					COMMAND_SET_SOURCE_RD_buf;
	COMMAND_PROPERTY_SET_OSC_SOURCE_RD_buf_type 	COMMAND_PROPERTY_SET_OSC_SOURCE_RD_buf;
} IKN_A2_COMMAND_rx_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef union
{
	COMMAND_PROPERTY_GET_DEVICE_TYPE_buf_type		COMMAND_PROPERTY_GET_DEVICE_TYPE_buf;
	COMMAND_PROPERTY_GET_SERIAL_NUMBER_buf_type		COMMAND_PROPERTY_GET_SERIAL_NUMBER_buf;
	COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf_type	COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf;
	COMMAND_GET_SOURCE_buf_type						COMMAND_GET_SOURCE_buf;
	COMMAND_PROPERTY_GET_TIME_buf_type				COMMAND_PROPERTY_GET_TIME_buf;
	COMMAND_PROPERTY_GET_OSC_SOURCE_buf_type		COMMAND_PROPERTY_GET_OSC_SOURCE_buf;
	COMMAND_PROPERTY_GET_OSC_buf_type				COMMAND_PROPERTY_GET_OSC_buf;
	COMMAND_GET_DATA_buf_type						COMMAND_GET_DATA_buf;
	u16												ERROR;
} IKN_A2_COMMAND_tx_type;
#pragma pack(pop)

//*******************************************************
#pragma pack(push, 1)
typedef struct
{
	u8 								CmdMarker; 	//маркер
	u8 								CmdCode;   	// код команды
	IKN_A2_COMMAND_rx_type			COMMAND;
	u16								CRC_val;
} RX_Com_buf_type;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
	u8 								CmdMarker; 	//маркер
	u8 								CmdCode;   	// код команды
	IKN_A2_COMMAND_tx_type			COMMAND;
	u16								CRC_val;
} TX_Com_buf_type;
#pragma pack(pop)



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
#define ANSWER_SIZE					(sizeof(TX_Com_buf_type)+4)

//*******************************************************
//*******************************************************
//*******************************************************

#endif /* CAN_CMD_DEFS_H_ */
