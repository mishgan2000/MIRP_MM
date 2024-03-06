/*
 * can_opc.c
 *
 *  Created on: 27.03.2017
 *      Author: pavlenko_av
 */

#include "can_opc.h"
#include "can_opc_defs.h"

//Functions

static void set_can_filter_hw(u32 ch, u32 filter, u32 mask)
{
	AcceptMask0Reg = ch & 0x1F;
	AcceptCode0Reg = filter;
	AcceptMask0Reg = 0x20 | (ch & 0x1F);
	AcceptCode0Reg = mask;
}
static can_ret_type can_assert_reset_mode(void)
{
	//===
	u32 ind=0;
	const u32 err_level = 10000;
	//
	while(((ModeControlReg & RM_RR_Bit ) == ClrByte) && (ind < err_level))
	{
		ModeControlReg = ModeControlReg | RM_RR_Bit ;
		ind++;
	}
	if(ind == err_level)
	{
		return can_err;
	}
	return can_ok;
}
static can_ret_type can_deassert_reset_mode(void)
{
	//===
	u32 ind=0;
	const u32 err_level = 10000;
	//
	do /* wait until RM_RR_Bit is cleared */
		/* break loop after a time out and signal an error */
	{
		ModeControlReg = ClrByte;
		ind++;
	}
	while(((ModeControlReg & RM_RR_Bit ) != ClrByte) && (ind < err_level));
	if(ind == err_level)
	{
		return can_err;
	}
	return can_ok;
}

can_ret_type can_init_hw(void)
{
	u32 ii;
	if(can_assert_reset_mode() == can_err)
	{
		return can_err;
	}
	//===
	ClockDivideReg = CANMode_Bit/* | CBP_Bit*/ | ClkOff_Bit;
	//=reset filters==
	for(ii=0;ii<32;ii++)
	{
		set_can_filter_hw(ii, 0, 0);
	}
	set_can_filter_hw(28, FILTER_ENA_BIT | 0, 0);	//Enable Broadcast request
//	set_can_filter_hw(29, 0, 0x7FF);	//Broadcast request
//	set_can_filter_hw(0, 1, 0);	//
//	set_can_filter_hw(1, 2, 0);	//
//	set_can_filter_hw(2, 3, 0);	//
//	set_can_filter_hw(3, 4, 0);	//
//	AcceptCode0Reg = ClrByte;	/* define acceptance code and mask */
//	AcceptMask0Reg = DontCare; 	/* every identifier is accepted */
//	AcceptCode1Reg = ClrByte;	/* define acceptance code and mask */
//	AcceptMask1Reg = DontCare; 	/* every identifier is accepted */
//	AcceptCode2Reg = ClrByte;	/* define acceptance code and mask */
//	AcceptMask2Reg = DontCare; 	/* every identifier is accepted */
//	AcceptCode3Reg = ClrByte;	/* define acceptance code and mask */
//	AcceptMask3Reg = DontCare; 	/* every identifier is accepted */
	//===
	BusTiming0Reg = SJW_MB_20 | Presc_MB_20;
	BusTiming1Reg = TSEG2_MB_20 | TSEG1_MB_20;
	//===
	OutControlReg = Tx1Float | Tx0PshPull | NormalMode;
	InterruptEnReg |= (TIE_Bit | RIE_Bit | EIE_Bit | DOIE_Bit | BEI_Bit | EPIE_Bit | ALIE_Bit | WUIE_Bit);
	//===
	if(can_deassert_reset_mode() == can_err)
	{
		return can_err;
	}
	return can_ok;
}

can_ret_type can_set_filter(u8 ch, u32 arbcode, u8 frame, u8 mode)
{
	if(can_assert_reset_mode() == can_err)
	{
		return can_err;
	}
	//===
	arbcode |= FILTER_ENA_BIT;
	if(frame)
	{
		arbcode |= FILTER_EXT_CANID;
	}
	if(mode)
	{
		arbcode |= FILTER_RTR;
	}
	set_can_filter_hw(ch, arbcode, 0);
	//===
	if(can_deassert_reset_mode() == can_err)
	{
		return can_err;
	}
	return can_ok;
}

void can_get_msg_hw(canmsg_t * p_can_data)
{
	static u32 can_rd_word;// = RxFrameInfo;
	static u32 can_rd_data;

	can_rd_word = RxFrameInfo;
//	u32 ii;

	p_can_data->format 	= ((can_rd_word & 0x80) == 0x80) ? 1 : 0;
	p_can_data->type 	= ((can_rd_word & 0x40) == 0x40) ? 1 : 0;

	p_can_data->dlc 	= (can_rd_word & 0xF);
	if( (p_can_data->format) & 1 )
	{
		can_rd_data = RxBuffer4;
		p_can_data->arbcode = ((can_rd_word << 13) & (0xFF << 21)) | ((can_rd_word >> 3) & (0xFF << 13)) | ((can_rd_word >> 19) & (0xFF << 5)) | ((can_rd_data >> 3) & 0x1F);
		p_can_data->ch = ((can_rd_data >> 8) & 0xFF);
		p_can_data->data.dU8[0] = ((can_rd_data >> 16) & 0xFF);
		p_can_data->data.dU8[1] = ((can_rd_data >> 24) & 0xFF);
		//
		if(p_can_data->dlc >= 3)
		{
			can_rd_data = RxBuffer8;
			(*((u32*) (&p_can_data->data.dU8[2]))) = can_rd_data;
		}
		//
		if(p_can_data->dlc >= 7)
		{
			can_rd_data = RxBuffer12;
			p_can_data->data.dU8[6] = ((can_rd_data     ) & 0xFF);
			p_can_data->data.dU8[7] = ((can_rd_data >> 8) & 0xFF);
		}
	}
	else
	{
		p_can_data->arbcode = ((can_rd_word >> 5) & 0x7F8) | ((can_rd_word >> 21) & 0x7);// ((RxBuffer1 << 3) & 0x7F8) | ((RxBuffer2 >> 5) & 0x7);
		p_can_data->ch = ((can_rd_word >> 24) & 0xFF);
		if(p_can_data->dlc > 0)
		{
			can_rd_data = RxBuffer4;
			p_can_data->data.dU32[0] = can_rd_data;
		}
		if(p_can_data->dlc > 4)
		{
			can_rd_data = RxBuffer8;
			p_can_data->data.dU32[1] = can_rd_data;
		}
	}
}

can_ret_type can_put_msg_hw(canmsg_t * p_can_data)
{
	if((StatusReg & TBS_Bit) == TBS_Bit)
	{
		can_tx_fifo_type can_tx_fifo;
		u32 ii;
		can_tx_fifo.tx_data[0] = ((p_can_data->format & 1) << 7) | ((p_can_data->type & 1) << 6) | (p_can_data->dlc &0xF);//TxFrameInfo = ((p_can_data->format & 1) << 7) | ((p_can_data->type & 1) << 6) | (p_can_data->dlc &0xF);	//Standard CANID | Not Retransmission | MSG_LEN
		if(p_can_data->format & 1)
		{
			//Extended frame
			/*TxBuffer1*/can_tx_fifo.tx_data[1] = ((p_can_data->arbcode >> 21) & 0xFF);
			/*TxBuffer2*/can_tx_fifo.tx_data[2] = ((p_can_data->arbcode >> 13) & 0xFF);
			/*TxBuffer3*/can_tx_fifo.tx_data[3] = ((p_can_data->arbcode >> 5) & 0xFF);
			/*TxBuffer4*/can_tx_fifo.tx_data[4] = ((p_can_data->arbcode & 0x1F) << 3);
			for(ii=0; ii<p_can_data->dlc; ii++)
			{
				/*XBYTE((21 + ii))*/can_tx_fifo.tx_data[5+ii] = p_can_data->data.dU8[ii];
			}
			//
			TxFrameInfo = can_tx_fifo.tx_data_u32[0];
			TxBuffer4	= can_tx_fifo.tx_data_u32[1];
			if(p_can_data->dlc > 3)
			{
				TxBuffer6 = can_tx_fifo.tx_data_u32[2];
			}
			if(p_can_data->dlc > 7)
			{
				TxBuffer12 = can_tx_fifo.tx_data_u32[2];
			}
		}
		else
		{
			//Standard frame
			/*TxBuffer1*/can_tx_fifo.tx_data[1] = ((p_can_data->arbcode >> 3) & 0xFF);
			/*TxBuffer2*/can_tx_fifo.tx_data[2] = ((p_can_data->arbcode & 0x07) << 5); //ID[2:0] << 5 | (RTR << 4) | DLC[3:0]

			for(ii=0; ii<p_can_data->dlc; ii++)
			{
				/*XBYTE((19 + ii))*/can_tx_fifo.tx_data[3+ii] = p_can_data->data.dU8[ii];
			}
			//
			TxFrameInfo = can_tx_fifo.tx_data_u32[0];
			if(p_can_data->dlc > 1)
			{
				TxBuffer4 = can_tx_fifo.tx_data_u32[1];
			}
			if(p_can_data->dlc > 5)
			{
				TxBuffer8 = can_tx_fifo.tx_data_u32[2];
			}
			//
		}

		CommandReg = TR_Bit;

		return can_ok;
	}
	return can_err;
}

//ISR function
u8 is_status_can_tx(u8 status)
{
	return 1 ? check_status_can_bit(status, TI_Bit) : 0;
}

u8 is_status_can_rx(u8 status)
{
	return 1 ? check_status_can_bit(status, RI_Bit) : 0;
}

u8 is_status_no_error(u8 status)
{
	return 1 ? ( (status & (BEIE_Bit | EIE_Bit | DOIE_Bit | ALIE_Bit | EPIE_Bit)) == 0) : 0;
}

u8 is_status_can_beie(u8 status)
{
	return 1 ? check_status_can_bit(status, BEIE_Bit) : 0;
}

u8 is_status_can_eie(u8 status)
{
	return 1 ? check_status_can_bit(status, EIE_Bit) : 0;
}

u8 is_status_can_doie(u8 status)
{
	return 1 ? check_status_can_bit(status, DOIE_Bit) : 0;
}

u8 is_status_can_alie(u8 status)
{
	return 1 ? check_status_can_bit(status, ALIE_Bit) : 0;
}

u8 is_status_can_epie(u8 status)
{
	return 1 ? check_status_can_bit(status, EPIE_Bit) : 0;
}

u8 get_isr_status(void)
{
	return InterruptReg;
}

void release_rx_buff(void)
{
	CommandReg = RRB_Bit;
	return;
}
