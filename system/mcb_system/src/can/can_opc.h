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
#include "can_config.h"


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
	u8	dlc;
	u8  ch;
	u8  format;	/* 0 - STANDARD,   1 - EXTENDED IDENTIFIER         */
	u8  type;	/* 0 - DATA FRAME, 1 - REMOTE FRAME                */
	u32	arbcode;
	can_data_t	data;
} canmsg_t;
#pragma pack(pop)


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

u8 is_status_error(u8 status);
u8 is_status_warning(u8 status);

u8 is_status_can_beie(u8 status);
u8 is_status_can_eie(u8 status);
u8 is_status_can_doie(u8 status);
u8 is_status_can_alie(u8 status);
u8 is_status_can_epie(u8 status);

void set_baud_rate_prescalers(can_baud_config_type * pbaud); // T_baud = T_cpu * (2*(presc+1)) * ( (1+tseg1) + (1+tseg2) )
int can_init_hw(void);
int can_reset_if_error(void);
int can_set_filter_hw(u8 ch, u32 arbcode, u8 frame, u8 mode);
void can_get_msg_hw(canmsg_t * p_can_data);
int can_put_msg_hw(canmsg_t * can_data);
u32 can_get_rx_msg_num(void);

u16 use_can_rx_irq(void);

//Debug FILTER logic
void can_filter_read_back(void);
int can_filter_enable_all_hw(u8 ch);

#endif /* CAN_OPC_H_ */
