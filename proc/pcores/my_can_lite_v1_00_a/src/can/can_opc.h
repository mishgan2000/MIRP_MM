/*
 * can_opc.h
 *
 *  Created on: 27.03.2017
 *      Author: pavlenko_av
 */

#ifndef CAN_OPC_H_
#define CAN_OPC_H_

#include "xparameters.h"
#include "xil_types.h"



//==================================================================
//==================	FUNCTION DEFIFNITIONS	====================
//==================================================================

#define CAN_PCKT_MAX_LEN	(8)
#pragma pack(push, 1)
typedef union{
	  u8	dU8[CAN_PCKT_MAX_LEN];
	  u32	dU32[CAN_PCKT_MAX_LEN/sizeof(u32)];
} can_data_t;

typedef struct {
  u32	arbcode;
  can_data_t	data;
  u8	dlc;
  u8  	ch;
  u8  	format;	/* 0 - STANDARD,   1 - EXTENDED IDENTIFIER         */
  u8  	type;	/* 0 - DATA FRAME, 1 - REMOTE FRAME                */
} canmsg_t;
#pragma pack(pop)
typedef enum {
	can_ok = 0,
	can_err = 1
} can_ret_type;

#define check_status_can_bit(status, bit)	((status & bit) == bit)
//#define is_status_can_tx(status)			(check_status_can_bit(status, TI_Bit))
//#define is_status_can_rx(status)			(check_status_can_bit(status, RI_Bit))
//#define is_status_can_beie(status) 			(check_status_can_bit(status, BEIE_Bit))
//#define is_status_can_eie(status) 			(check_status_can_bit(status, EIE_Bit))
//#define is_status_can_doie(status) 			(check_status_can_bit(status, DOIE_Bit))
//#define is_status_can_alie(status) 			(check_status_can_bit(status, ALIE_Bit))
//#define is_status_can_epie(status) 			(check_status_can_bit(status, EPIE_Bit))

u8 get_isr_status(void);
void release_rx_buff(void);

u8 is_status_can_tx(u8 status);
u8 is_status_can_rx(u8 status);
u8 is_status_no_error(u8 status);
u8 is_status_can_beie(u8 status);
u8 is_status_can_eie(u8 status);
u8 is_status_can_doie(u8 status);
u8 is_status_can_alie(u8 status);
u8 is_status_can_epie(u8 status);


can_ret_type can_init_hw(void);
can_ret_type can_set_filter(u8 ch, u32 arbcode, u8 frame, u8 mode);
void can_get_msg_hw(canmsg_t * p_can_data);
can_ret_type  can_put_msg_hw(canmsg_t * can_data);



#endif /* CAN_OPC_H_ */
