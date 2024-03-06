/*
 * my_xil_timer.h
 *
 *  Created on: 07.03.2018
 *      Author: pavlenko_av
 */

#ifndef MY_XIL_TIMER_H_
#define MY_XIL_TIMER_H_

#include "xil_types.h"
#include "xil_io.h"

/************************** Constant Definitions *****************************/

/**
 * Defines the number of timer counters within a single hardware device. This
 * number is not currently parameterized in the hardware but may be in the
 * future.
 */
#define XTC_DEVICE_TIMER_COUNT		2

/* Each timer counter consumes 16 bytes of address space */

#define XTC_TIMER_COUNTER_OFFSET	16

/** @name Register Offset Definitions
 * Register offsets within a timer counter, there are multiple
 * timer counters within a single device
 * @{
 */

#define XTC_TCSR_OFFSET		0	/**< Control/Status register */
#define XTC_TLR_OFFSET		4	/**< Load register */
#define XTC_TCR_OFFSET		8	/**< Timer counter register */

/* @} */

/** @name Control Status Register Bit Definitions
 * Control Status Register bit masks
 * Used to configure the timer counter device.
 * @{
 */

#define XTC_CSR_CASC_MASK		0x00000800 /**< Cascade Mode */
#define XTC_CSR_ENABLE_ALL_MASK		0x00000400 /**< Enables all timer
							counters */
#define XTC_CSR_ENABLE_PWM_MASK		0x00000200 /**< Enables the Pulse Width
							Modulation */
#define XTC_CSR_INT_OCCURED_MASK	0x00000100 /**< If bit is set, an
							interrupt has occured.
							If set and '1' is
							written to this bit
							position, bit is
							cleared. */
#define XTC_CSR_ENABLE_TMR_MASK		0x00000080 /**< Enables only the
							specific timer */
#define XTC_CSR_ENABLE_INT_MASK		0x00000040 /**< Enables the interrupt
							output. */
#define XTC_CSR_LOAD_MASK		0x00000020 /**< Loads the timer using
							the load value provided
							earlier in the Load
							Register,
							XTC_TLR_OFFSET. */
#define XTC_CSR_AUTO_RELOAD_MASK	0x00000010 /**< In compare mode,
							configures
							the timer counter to
							reload  from the
							Load Register. The
							default  mode
							causes the timer counter
							to hold when the compare
							value is hit. In capture
							mode, configures  the
							timer counter to not
							hold the previous
							capture value if a new
							event occurs. The
							default mode cause the
							timer counter to hold
							the capture value until
							recognized. */
#define XTC_CSR_EXT_CAPTURE_MASK	0x00000008 /**< Enables the
							external input
							to the timer counter. */
#define XTC_CSR_EXT_GENERATE_MASK	0x00000004 /**< Enables the
							external generate output
							for the timer. */
#define XTC_CSR_DOWN_COUNT_MASK		0x00000002 /**< Configures the timer
							counter to count down
							from start value, the
							default is to count
							up.*/
#define XTC_CSR_CAPTURE_MODE_MASK	0x00000001 /**< Enables the timer to
							capture the timer
							counter value when the
							external capture line is
							asserted. The default
							mode is compare mode.*/
/* @} */

/************************** Constant Definitions *****************************/

/**
 * @name Configuration options
 * These options are used in XTmrCtr_SetOptions() and XTmrCtr_GetOptions()
 * @{
 */
/**
 * Used to configure the timer counter device.
 * <pre>
 * XTC_CASCADE_MODE_OPTION	Enables the Cascade Mode only valid for TCSRO.
 * XTC_ENABLE_ALL_OPTION	Enables all timer counters at once.
 * XTC_DOWN_COUNT_OPTION	Configures the timer counter to count down from
 *				start value, the default is to count up.
 * XTC_CAPTURE_MODE_OPTION	Configures the timer to capture the timer
 *				counter value when the external capture line is
 *				asserted. The default mode is compare mode.
 * XTC_INT_MODE_OPTION		Enables the timer counter interrupt output.
 * XTC_AUTO_RELOAD_OPTION	In compare mode, configures the timer counter to
 *				reload from the compare value. The default mode
 *				causes the timer counter to hold when the
 *				compare value is hit.
 *				In capture mode, configures the timer counter to
 *				not hold the previous capture value if a new
 *				event occurs. The default mode cause the timer
 *				counter to hold the capture value until
 *				recognized.
 * XTC_EXT_COMPARE_OPTION	Enables the external compare output signal.
 * </pre>
 */
#define XTC_CASCADE_MODE_OPTION		0x00000080UL
#define XTC_ENABLE_ALL_OPTION		0x00000040UL
#define XTC_DOWN_COUNT_OPTION		0x00000020UL
#define XTC_CAPTURE_MODE_OPTION		0x00000010UL
#define XTC_INT_MODE_OPTION			0x00000008UL
#define XTC_AUTO_RELOAD_OPTION		0x00000004UL
#define XTC_EXT_COMPARE_OPTION		0x00000002UL

extern u8 XTmrCtr_Offsets[];// = { 0, XTC_TIMER_COUNTER_OFFSET };

#define XTmrCtr_ReadReg(BaseAddress, TmrCtrNumber, RegOffset)	\
	Xil_In32((BaseAddress) + XTmrCtr_Offsets[(TmrCtrNumber)] + \
			(RegOffset))

#define XTmrCtr_WriteReg(BaseAddress, TmrCtrNumber, RegOffset, ValueToWrite)\
	Xil_Out32(((BaseAddress) + XTmrCtr_Offsets[(TmrCtrNumber)] +	\
			   (RegOffset)), (ValueToWrite))

/****************************************************************************/
/**
*
* Set the Control Status Register of a timer counter to the specified value.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
* @param	RegisterValue is the 32 bit value to be written to the register.
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_SetControlStatusReg(u32 BaseAddress,
*					u8 TmrCtrNumber,u32 RegisterValue);
*****************************************************************************/
#define XTmrCtr_SetControlStatusReg(BaseAddress, TmrCtrNumber, RegisterValue)\
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET,     \
					   (RegisterValue))

/****************************************************************************/
/**
*
* Get the Control Status Register of a timer counter.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device,
*		a zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	The value read from the register, a 32 bit value.
*
* @note		C-Style signature:
* 		u32 XTmrCtr_GetControlStatusReg(u32 BaseAddress,
*						u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_GetControlStatusReg(BaseAddress, TmrCtrNumber)		\
	XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET)

/****************************************************************************/
/**
*
* Get the Timer Counter Register of a timer counter.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device,
*		a zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	The value read from the register, a 32 bit value.
*
* @note		C-Style signature:
* 		u32 XTmrCtr_GetTimerCounterReg(u32 BaseAddress,
*						u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_GetTimerCounterReg(BaseAddress, TmrCtrNumber)		  \
	XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber), XTC_TCR_OFFSET) \

/****************************************************************************/
/**
*
* Set the Load Register of a timer counter to the specified value.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
* @param	RegisterValue is the 32 bit value to be written to the register.
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_SetLoadReg(u32 BaseAddress, u8 TmrCtrNumber,
*						  u32 RegisterValue);
*****************************************************************************/
#define XTmrCtr_SetLoadReg(BaseAddress, TmrCtrNumber, RegisterValue)	 \
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TLR_OFFSET, \
					   (RegisterValue))

/****************************************************************************/
/**
*
* Get the Load Register of a timer counter.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	The value read from the register, a 32 bit value.
*
* @note		C-Style signature:
* 		u32 XTmrCtr_GetLoadReg(u32 BaseAddress, u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_GetLoadReg(BaseAddress, TmrCtrNumber)	\
XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber), XTC_TLR_OFFSET)

/****************************************************************************/
/**
*
* Enable a timer counter such that it starts running.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_Enable(u32 BaseAddress, u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_Enable(BaseAddress, TmrCtrNumber)			    \
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET,   \
			(XTmrCtr_ReadReg((BaseAddress), ( TmrCtrNumber), \
			XTC_TCSR_OFFSET) | XTC_CSR_ENABLE_TMR_MASK))

/****************************************************************************/
/**
*
* Disable a timer counter such that it stops running.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device,
*		a zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_Disable(u32 BaseAddress, u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_Disable(BaseAddress, TmrCtrNumber)			  \
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET, \
			(XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber),\
			XTC_TCSR_OFFSET) & ~ XTC_CSR_ENABLE_TMR_MASK))

/****************************************************************************/
/**
*
* Enable the interrupt for a timer counter.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_EnableIntr(u32 BaseAddress, u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_EnableIntr(BaseAddress, TmrCtrNumber)			    \
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET,   \
			(XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber),  \
			XTC_TCSR_OFFSET) | XTC_CSR_ENABLE_INT_MASK))

/****************************************************************************/
/**
*
* Disable the interrupt for a timer counter.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_DisableIntr(u32 BaseAddress, u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_DisableIntr(BaseAddress, TmrCtrNumber)			   \
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET,  \
	(XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber),		   \
		XTC_TCSR_OFFSET) & ~ XTC_CSR_ENABLE_INT_MASK))

/****************************************************************************/
/**
*
* Cause the timer counter to load it's Timer Counter Register with the value
* in the Load Register.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		   zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return	None.
*
* @note		C-Style signature:
* 		void XTmrCtr_LoadTimerCounterReg(u32 BaseAddress,
					u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_LoadTimerCounterReg(BaseAddress, TmrCtrNumber)		  \
	XTmrCtr_WriteReg((BaseAddress), (TmrCtrNumber), XTC_TCSR_OFFSET, \
			(XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber),\
			XTC_TCSR_OFFSET) | XTC_CSR_LOAD_MASK))

/****************************************************************************/
/**
*
* Determine if a timer counter event has occurred.  Events are defined to be
* when a capture has occurred or the counter has roller over.
*
* @param	BaseAddress is the base address of the device.
* @param	TmrCtrNumber is the specific timer counter within the device, a
*		zero based number, 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @note		C-Style signature:
* 		int XTmrCtr_HasEventOccurred(u32 BaseAddress, u8 TmrCtrNumber);
*****************************************************************************/
#define XTmrCtr_HasEventOccurred(BaseAddress, TmrCtrNumber)		\
		((XTmrCtr_ReadReg((BaseAddress), (TmrCtrNumber),	\
		XTC_TCSR_OFFSET) & XTC_CSR_INT_OCCURED_MASK) ==		\
		XTC_CSR_INT_OCCURED_MASK)

/************************** Function Prototypes ******************************/
/************************** Variable Definitions *****************************/

int my_timer_init(u32 base, u16 tmr_num);
void my_timer_SetResetValue(u32 base, u16 tmr_num, u32 ResetValue);
void my_timer_continuos_start(u32 base, u16 tmr_num, u32 ResetValue);

#endif /* MY_XIL_TIMER_H_ */
