/*
 * can_opc_defs.h
 *
 *  Created on: 19.09.2017
 *      Author: pavlenko_av
 */

#ifndef CAN_OPC_DEFS_H_
#define CAN_OPC_DEFS_H_

/* definition for direct access to 8051 memory areas */
//(*(volatile u32 *)(Addr))

#define PeliCANMode

//==================================================================
//==================	TIME SEGS DEFINITIONS	====================
//==================================================================

#define ClrByte			0x00
#define DontCare 		0xFF
//////====20MHz=and=250kBaud==============
//#define Presc_MB_20 	0x04 /* baud rate prescaler : 1 */
//#define SJW_MB_20 		0x00 /* SJW : 1 */
//#define TSEG1_MB_20		0x05 /* TSEG1 : 9 */
//#define TSEG2_MB_20 	(0x02 << 4) /* TSEG2 : 2 */
//
////====20MHz=and=1MBaud================
//#define Presc_MB_20 	0x00 /* baud rate prescaler : 1 */
//#define SJW_MB_20 		0x00 /* SJW : 1 */
//#define TSEG1_MB_20		0x05 /* TSEG1 : 9 */
//#define TSEG2_MB_20 	(0x02 << 4) /* TSEG2 : 2 */

////====50MHz=and=250kBaud=============
//#define Presc_MB_20 	0x09 /* baud rate prescaler : 1 */
//#define SJW_MB_20 		0x00 /* SJW : 1 */
//#define TSEG1_MB_20		0x05 /* TSEG1 : 9 */
//#define TSEG2_MB_20 	(0x02 << 4) /* TSEG2 : 2 */

////====50MHz=and=1MBaud===============
//#define Presc_MB_20 	0x00 /* baud rate prescaler : 1 */
//#define SJW_MB_20 		0x00 /* SJW : 1 */
//#define TSEG1_MB_20		0x0F /* TSEG1 : 9 */
//#define TSEG2_MB_20 	(0x07 << 4) /* TSEG2 : 2 */

////====100MHz=and=1MBaud===============
//
//#define SJW_MB_20 		(0x02 << 6) /* SJW : 3 */
//
//#define Presc_MB_20 	0x04 /* baud rate prescaler : 5 */
//#define TSEG1_MB_20		0x04 /* TSEG1 : 5 */
//#define TSEG2_MB_20 	(0x03 << 4) /* TSEG2 : 4 */

//====80MHz=and=1MBaud===============

#define SJW_MB_20 		(0x02 << 6) /* SJW : 1 */
//#define Presc_MB_20 	0x00 /* baud rate prescaler : 1 */
//#define TSEG1_MB_20		0x0A /* TSEG1 : 11 */
//#define TSEG2_MB_20 	(0x07 << 4) /* TSEG2 : 8 */

#define Presc_MB_20 	0x03 /* baud rate prescaler :  */
#define TSEG1_MB_20		0x04 /* TSEG1 : 11 */
#define TSEG2_MB_20 	(0x03 << 4) /* TSEG2 : 8 */



//==================================================================
//=========	REG DEFINITIONS FROM SJA1000 DATASHEET	================
//=============	8051 REGISTERS ACCESS STYLE	========================
//==================================================================

#define XBYTE(addr)		(*(volatile u32 *)(XPAR_MY_CAN_LITE_0_BASEADDR + (addr << 2)))
/* address and bit definitions for the Mode & Control Register */
#define ModeControlReg XBYTE(0)
#define RM_RR_Bit 0x01 /* reset mode (request) bit */
#if defined (PeliCANMode)
#define LOM_Bit 0x02 /* listen only mode bit */
#define STM_Bit 0x04 /* self test mode bit */
#define AFM_Bit 0x08 /* acceptance filter mode bit */
#define SM_Bit 0x10 /* enter sleep mode bit */
#endif
/* address and bit definitions for the
Interrupt Enable & Control Register */
#if defined (PeliCANMode)
#define InterruptEnReg XBYTE(4) /* PeliCAN mode */
#define RIE_Bit 0x01 /* receive interrupt enable bit */
#define TIE_Bit 0x02 /* transmit interrupt enable bit */
#define EIE_Bit 0x04 /* error warning interrupt enable bit */
#define DOIE_Bit 0x08 /* data overrun interrupt enable bit */
#define WUIE_Bit 0x10 /* wake-up interrupt enable bit */
#define EPIE_Bit 0x20 /* error passive interrupt enable bit */
#define ALIE_Bit 0x40 /* arbitration lost interr. enable bit*/
#define BEIE_Bit 0x80 /* bus error interrupt enable bit */
#else /* BasicCAN mode */
#define InterruptEnReg XBYTE(0) /* Control Register */
#define RIE_Bit 0x02 /* Receive Interrupt enable bit */
#define TIE_Bit 0x04 /* Transmit Interrupt enable bit */
#define EIE_Bit 0x08 /* Error Interrupt enable bit */
#define DOIE_Bit 0x10 /* Overrun Interrupt enable bit */
#endif
/* address and bit definitions for the Command Register */
#define CommandReg XBYTE(1)
#define TR_Bit 0x01 /* transmission request bit */
#define AT_Bit 0x02 /* abort transmission bit */
#define RRB_Bit 0x04 /* release receive buffer bit */
#define CDO_Bit 0x08 /* clear data overrun bit */
#if defined (PeliCANMode)
#define SRR_Bit 0x10 /* self reception request bit */
#else /* BasicCAN mode */
#define GTS_Bit 0x10 /* goto sleep bit (BasicCAN mode) */
#endif
/* address and bit definitions for the Status Register */
#define StatusReg XBYTE(2)
#define RBS_Bit 0x01 /* receive buffer status bit */
#define DOS_Bit 0x02 /* data overrun status bit */
#define TBS_Bit 0x04 /* transmit buffer status bit */
#define TCS_Bit 0x08 /* transmission complete status bit */
#define RS_Bit 0x10 /* receive status bit */
#define TS_Bit 0x20 /* transmit status bit */
#define ES_Bit 0x40 /* error status bit */
#define BS_Bit 0x80 /* bus status bit */
/* address and bit definitions for the Interrupt Register */
#define InterruptReg XBYTE(3)
#define RI_Bit 0x01 /* receive interrupt bit */
#define TI_Bit 0x02 /* transmit interrupt bit */
#define EI_Bit 0x04 /* error warning interrupt bit */
#define DOI_Bit 0x08 /* data overrun interrupt bit */
#define WUI_Bit 0x10 /* wake-up interrupt bit */
#if defined (PeliCANMode)
#define EPI_Bit 0x20 /* error passive interrupt bit */
#define ALI_Bit 0x40 /* arbitration lost interrupt bit */
#define BEI_Bit 0x80 /* bus error interrupt bit */
#endif
/* address and bit definitions for the Bus Timing Registers */
#define BusTiming0Reg XBYTE(6)
#define BusTiming1Reg XBYTE(7)
#define SAM_Bit 0x80 /* sample mode bit
1 == the bus is sampled 3 times
0 == the bus is sampled once */
/* address and bit definitions for the Output Control Register */
#define OutControlReg XBYTE(8)
/* OCMODE1, OCMODE0 */
#define BiPhaseMode 0x00 /* bi-phase output mode */
#define NormalMode 0x02 /* normal output mode */
#define ClkOutMode 0x03 /* clock output mode */
/* output pin configuration for TX1 */
#define OCPOL1_Bit 0x20 /* output polarity control bit */
#define Tx1Float 0x00 /* configured as float */
#define Tx1PullDn 0x40 /* configured as pull-down */
#define Tx1PullUp 0x80 /* configured as pull-up */
#define Tx1PshPull 0xC0 /* configured as push/pull */
/* output pin configuration for TX0 */
#define OCPOL0_Bit 0x04 /* output polarity control bit */
#define Tx0Float 0x00 /* configured as float */
#define Tx0PullDn 0x08 /* configured as pull-down */
#define Tx0PullUp 0x10 /* configured as pull-up */
#define Tx0PshPull 0x18 /* configured as push/pull */
/* address definitions of Acceptance Code & Mask Registers */
#if defined (PeliCANMode)
#define AcceptCode0Reg XBYTE(46)
#define AcceptCode1Reg XBYTE(17)
#define AcceptCode2Reg XBYTE(18)
#define AcceptCode3Reg XBYTE(19)
#define AcceptMask0Reg XBYTE(40)
#define AcceptMask1Reg XBYTE(21)
#define AcceptMask2Reg XBYTE(22)
#define AcceptMask3Reg XBYTE(23)
#else /* BasicCAN mode */
#define AcceptCodeReg XBYTE(4)
#define AcceptMaskReg XBYTE(5)
#endif
/* address definitions of the Rx-Buffer */
#if defined (PeliCANMode)
#define RxFrameInfo XBYTE(16)
#define RxBuffer1 XBYTE(17)
#define RxBuffer2 XBYTE(18)
#define RxBuffer3 XBYTE(19)
#define RxBuffer4 XBYTE(20)
#define RxBuffer5 XBYTE(21)
#define RxBuffer6 XBYTE(22)
#define RxBuffer7 XBYTE(23)
#define RxBuffer8 XBYTE(24)
#define RxBuffer9 XBYTE(25)
#define RxBuffer10 XBYTE(26)
#define RxBuffer11 XBYTE(27)
#define RxBuffer12 XBYTE(28)
#else /* BasicCAN mode */
#define RxBuffer1 XBYTE(20)
#define RxBuffer2 XBYTE(21)
#define RxBuffer3 XBYTE(22)
#define RxBuffer4 XBYTE(23)
#define RxBuffer5 XBYTE(24)
#define RxBuffer6 XBYTE(25)
#define RxBuffer7 XBYTE(26)
#define RxBuffer8 XBYTE(27)
#define RxBuffer9 XBYTE(28)
#define RxBuffer10 XBYTE(29)
#endif
/* address definitions of the Tx-Buffer */
#if defined (PeliCANMode)
/* write only addresses */
#define TxFrameInfo XBYTE(16)
#define TxBuffer1 XBYTE(17)
#define TxBuffer2 XBYTE(18)
#define TxBuffer3 XBYTE(19)
#define TxBuffer4 XBYTE(20)
#define TxBuffer5 XBYTE(21)
#define TxBuffer6 XBYTE(22)
#define TxBuffer7 XBYTE(23)
#define TxBuffer8 XBYTE(24)
#define TxBuffer9 XBYTE(25)
#define TxBuffer10 XBYTE(26)
#define TxBuffer11 XBYTE(27)
#define TxBuffer12 XBYTE(28)
/* read only addresses */
#define TxFrameInfoRd XBYTE(96)
#define TxBufferRd1 XBYTE(97)
#define TxBufferRd2 XBYTE(98)
#define TxBufferRd3 XBYTE(99)
#define TxBufferRd4 XBYTE(100)
#define TxBufferRd5 XBYTE(101)
#define TxBufferRd6 XBYTE(102)
#define TxBufferRd7 XBYTE(103)
#define TxBufferRd8 XBYTE(104)
#define TxBufferRd9 XBYTE(105)
#define TxBufferRd10 XBYTE(106)
#define TxBufferRd11 XBYTE(107)
#define TxBufferRd12 XBYTE(108)
#else /* BasicCAN mode */
#define TxBuffer1 XBYTE(10)
#define TxBuffer2 XBYTE(11)
#define TxBuffer3 XBYTE(12)
#define TxBuffer4 XBYTE(13)
#define TxBuffer5 XBYTE(14)
#define TxBuffer6 XBYTE(15)
#define TxBuffer7 XBYTE(16)
#define TxBuffer8 XBYTE(17)
#define TxBuffer9 XBYTE(18)
#define TxBuffer10 XBYTE(19)
#endif
/* address definitions of Other Registers */
#if defined (PeliCANMode)
#define ArbLostCapReg XBYTE(11)
#define ErrCodeCapReg XBYTE(12)
#define ErrWarnLimitReg XBYTE(13)
#define RxErrCountReg XBYTE(14)
#define TxErrCountReg XBYTE(15)
#define RxMsgCountReg XBYTE(29)
#define RxBufStartAdr XBYTE(30)
#define RxFifoSize	  XBYTE(49)
#endif
/* address and bit definitions for the Clock Divider Register */
#define ClockDivideReg XBYTE(31)
#define DivBy1 0x07 /* CLKOUT = oscillator frequency */
#define DivBy2 0x00 /* CLKOUT = 1/2 oscillator frequency */
#define ClkOff_Bit 0x08 /* clock off bit,
control of the CLK OUT pin */
#define RXINTEN_Bit 0x20 /* pin TX1 used for receive interrupt */
#define CBP_Bit 0x40 /* CAN comparator bypass control bit */
#define CANMode_Bit 0x80 /* CAN mode definition bit */

#define FILTER_ENA_BIT		(0x80000000)
#define FILTER_EXT_CANID	(0x40000000)
#define	FILTER_RTR			(0x20000000)

#pragma pack(push, 1)
typedef union {
	u8  tx_data[16];
	u32 tx_data_u32[4];
} can_tx_fifo_type;
#pragma pack(pop)

#endif /* CAN_OPC_DEFS_H_ */
