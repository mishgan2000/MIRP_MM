/*
 * can_opc.c
 *
 *  Created on: 27.03.2017
 *      Author: pavlenko_av
 */

#include "can_opc.h"
#include "can_opc_defs.h"
#include "xil_assert.h"

//Functions

static void can_filter_reg_write_hw(u32 ch, u32 filter, u32 mask)
{
	AcceptMask0Reg = ch & 0x1F;
	AcceptCode0Reg = filter;
	AcceptMask0Reg = 0x20 | (ch & 0x1F);
	AcceptCode0Reg = mask;
}

static void can_filter_reg_read_hw(u32 ch, u32 * pfilter, u32 * pmask)
{
	AcceptMask0Reg = ch & 0x1F;
	*pfilter = AcceptCode0Reg;
	AcceptMask0Reg = 0x20 | (ch & 0x1F);
	*pmask = AcceptCode0Reg;
}

static int can_assert_reset_mode(void)
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
		return -1;
	}
	return 0;
}
static int can_deassert_reset_mode(void)
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
		return -1;
	}
	return 0;
}

//void set_baud_rate_prescalers(u8 presc, u8 tseg1, u8 tseg2, u8 sjw)
void set_baud_rate_prescalers(can_baud_config_type * pbaud)
{
	u8 bus_timing0, bus_timing1;

	Xil_AssertVoid(pbaud->presc < 0x40);
	Xil_AssertVoid(pbaud->tseg1 < 0x10);
	Xil_AssertVoid(pbaud->tseg2 < 0x08);
	Xil_AssertVoid(pbaud->sjw   < 0x04);

	bus_timing0 = (pbaud->presc & (0x3F)) | ( (pbaud->sjw & 0x03)   << 6 );
	bus_timing1 = (pbaud->tseg1 & (0x0F)) | ( (pbaud->tseg2 & 0x07) << 4 );

	BusTiming0Reg = bus_timing0;
	BusTiming1Reg = bus_timing1;
}

int can_reset_if_error(void)
{
	if(can_assert_reset_mode() != 0)
	{
		return -1;
	}
	if(can_deassert_reset_mode() != 0)
	{
		return -1;
	}
	return 0;
}

static u16 is_using_can_rx_irq = 0;

u16 use_can_rx_irq(void)
{
	return is_using_can_rx_irq;
}

int can_init_hw(void)
{
	u32 ii;
	if(can_assert_reset_mode() != 0)
	{
		return -1;
	}
	//===
	ClockDivideReg = CANMode_Bit/* | CBP_Bit*/ | ClkOff_Bit;
	//=reset filters==
	for(ii=0;ii<32;ii++)
	{
		can_filter_reg_write_hw(ii, 0, 0);
	}
	//Enable CAN control Interface
	can_filter_reg_write_hw(28, FILTER_ENA_BIT | 0, 0);
	can_filter_reg_write_hw(29, FILTER_ENA_BIT | 1, 0);
	can_filter_reg_write_hw(30, FILTER_ENA_BIT | 2, 0);
	can_filter_reg_write_hw(31, FILTER_ENA_BIT | 3, 0);
	//===
	set_baud_rate_prescalers(&can_config_data.baud); //(u8 presc, u8 tseg1, u8 tseg2, u8 sjw); // T_baud = T_cpu * (2*(presc+1)) * ( (1+tseg1) + (1+tseg2) + 1)
	//===
	OutControlReg = Tx1Float | Tx0PshPull | NormalMode;
	ii = RxFifoSize;
	if(ii == 4)
	{
		InterruptEnReg = (TIE_Bit | RIE_Bit | EIE_Bit | DOIE_Bit | BEI_Bit | EPIE_Bit | ALIE_Bit | WUIE_Bit);
		is_using_can_rx_irq = 1;
	}
	else
	{
		InterruptEnReg = (TIE_Bit | /*RIE_Bit |*/ EIE_Bit | DOIE_Bit | BEI_Bit | EPIE_Bit | ALIE_Bit | WUIE_Bit);
		is_using_can_rx_irq = 0;
	}
	//===
	if(can_deassert_reset_mode() != 0)
	{
		return -1;
	}
	return 0;
}

int can_set_filter_hw(u8 ch, u32 arbcode, u8 frame, u8 mode)
{
//	u32 mask_tmp;
//	if(can_assert_reset_mode() != 0)
//	{
//		return -1;
//	}
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
	can_filter_reg_write_hw(ch, arbcode, 0);
	//===
//	if(can_deassert_reset_mode() != 0)
//	{
//		return -1;
//	}
	return 0;
}

int can_filter_enable_all_hw(u8 ch)
{
	can_filter_reg_write_hw(ch, FILTER_ENA_BIT, 0xFFFFFFFF);
	return 0;
}

static u32 arbcodes[5*4];
static u32 masks[5*4];
void can_filter_read_back(void)
{
//	if(can_assert_reset_mode() != 0)
//	{
////		return -1;
//	}

	int ii;
	for(ii=0; ii<(5*4); ii++)
	{
		can_filter_reg_read_hw(ii, &arbcodes[ii], &masks[ii]);
	}

//	if(can_deassert_reset_mode() != 0)
//	{
////		return -1;
//	}

}

u32 can_get_rx_msg_num(void)
{
	if(is_using_can_rx_irq == 1)
		return 0;
	return RxMsgCountReg;
}

void can_get_msg_hw(canmsg_t * p_can_data)
{
//	static u32 can_rd_word;// = RxFrameInfo;
//	static u32 can_rd_data;

//	can_rd_data = RxFrameInfo;

	(*(u32 *)(&(p_can_data->dlc))) = RxFrameInfo;
	p_can_data->arbcode = RxBuffer4;
	p_can_data->data.dU32[0] = RxBuffer8;
	if(p_can_data->dlc > 4) p_can_data->data.dU32[1] = RxBuffer12;


//	can_rd_word = RxFrameInfo;
////	u32 ii;
//
//	p_can_data->format 	= ((can_rd_word & 0x80) == 0x80) ? 1 : 0;
//	p_can_data->type 	= ((can_rd_word & 0x40) == 0x40) ? 1 : 0;
//
//	p_can_data->dlc 	= (can_rd_word & 0xF);
//	if( (p_can_data->format) & 1 )
//	{
//		can_rd_data = RxBuffer4;
//		p_can_data->arbcode = ((can_rd_word << 13) & (0xFF << 21)) | ((can_rd_word >> 3) & (0xFF << 13)) | ((can_rd_word >> 19) & (0xFF << 5)) | ((can_rd_data >> 3) & 0x1F);
//		p_can_data->ch = ((can_rd_data >> 8) & 0xFF);
//		p_can_data->data.dU8[0] = ((can_rd_data >> 16) & 0xFF);
//		p_can_data->data.dU8[1] = ((can_rd_data >> 24) & 0xFF);
//		//
//		if(p_can_data->dlc >= 3)
//		{
//			can_rd_data = RxBuffer8;
//			(*((u32*) (&p_can_data->data.dU8[2]))) = can_rd_data;
//		}
//		//
//		if(p_can_data->dlc >= 7)
//		{
//			can_rd_data = RxBuffer12;
//			p_can_data->data.dU8[6] = ((can_rd_data     ) & 0xFF);
//			p_can_data->data.dU8[7] = ((can_rd_data >> 8) & 0xFF);
//		}
//	}
//	else
//	{
//		p_can_data->arbcode = ((can_rd_word >> 5) & 0x7F8) | ((can_rd_word >> 21) & 0x7);// ((RxBuffer1 << 3) & 0x7F8) | ((RxBuffer2 >> 5) & 0x7);
//		p_can_data->ch = ((can_rd_word >> 24) & 0xFF);
//		if(p_can_data->dlc > 0)
//		{
//			can_rd_data = RxBuffer4;
//			p_can_data->data.dU32[0] = can_rd_data;
//		}
//		if(p_can_data->dlc > 4)
//		{
//			can_rd_data = RxBuffer8;
//			p_can_data->data.dU32[1] = can_rd_data;
//		}
//	}
}

int can_put_msg_hw(canmsg_t * p_can_data)
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

		return 0;
	}
	return -1;
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

u8 is_status_error(u8 status)
{
	return 1 ? ( (status & (BEIE_Bit | EIE_Bit)) != 0) : 0;
}

u8 is_status_warning(u8 status)
{
	return 1 ? ( (status & (DOIE_Bit | ALIE_Bit | EPIE_Bit)) != 0) : 0;
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
