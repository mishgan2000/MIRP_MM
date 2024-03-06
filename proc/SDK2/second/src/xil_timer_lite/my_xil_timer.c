/*
 * my_xil_timer.c
 *
 *  Created on: 07.03.2018
 *      Author: pavlenko_av
 */


#include "my_xil_timer.h"
#include "xil_assert.h"



u8 XTmrCtr_Offsets[] = { 0, XTC_TIMER_COUNTER_OFFSET };

int my_timer_init(u32 base, u16 tmr_num)
{
	int TmrCtrNumber;
	int TmrCtrLowIndex = 0;
	int TmrCtrHighIndex = XTC_DEVICE_TIMER_COUNT;

	for (TmrCtrNumber = TmrCtrLowIndex; TmrCtrNumber < TmrCtrHighIndex;
			TmrCtrNumber++) {

		/*
		 * Set the Compare register to 0
		 */
		XTmrCtr_WriteReg(base, TmrCtrNumber, XTC_TLR_OFFSET, 0);
		/*
		 * Reset the timer and the interrupt, the reset bit will need to
		 * be cleared after this
		 */
		XTmrCtr_WriteReg(base, TmrCtrNumber, XTC_TCSR_OFFSET, XTC_CSR_INT_OCCURED_MASK | XTC_CSR_LOAD_MASK);
		/*
		 * Set the control/status register to complete initialization by
		 * clearing the reset bit which was just set
		 */
		XTmrCtr_WriteReg(base, TmrCtrNumber, XTC_TCSR_OFFSET, 0);
	}

	return 0;
}

void my_timer_SetResetValue(u32 base, u16 tmr_num, u32 ResetValue)
{

	Xil_AssertVoid(base != NULL);
	Xil_AssertVoid(tmr_num < XTC_DEVICE_TIMER_COUNT);

	XTmrCtr_WriteReg(base, tmr_num,  XTC_TLR_OFFSET, ResetValue);
}


/************************** Variable Definitions *****************************/

/*
 * The following data type maps an option to a register mask such that getting
 * and setting the options may be table driven.
 */
typedef struct {
	u32 Option;
	u32 Mask;
} Mapping;

/*
 * Create the table which contains options which are to be processed to get/set
 * the options. These options are table driven to allow easy maintenance and
 * expansion of the options.
 */
//static Mapping OptionsTable[] = {
//	{XTC_CASCADE_MODE_OPTION, XTC_CSR_CASC_MASK},
//	{XTC_ENABLE_ALL_OPTION, XTC_CSR_ENABLE_ALL_MASK},
//	{XTC_DOWN_COUNT_OPTION, XTC_CSR_DOWN_COUNT_MASK},
//	{XTC_CAPTURE_MODE_OPTION, XTC_CSR_CAPTURE_MODE_MASK | XTC_CSR_EXT_CAPTURE_MASK},
//	{XTC_INT_MODE_OPTION, XTC_CSR_ENABLE_INT_MASK},
//	{XTC_AUTO_RELOAD_OPTION, XTC_CSR_AUTO_RELOAD_MASK},
//	{XTC_EXT_COMPARE_OPTION, XTC_CSR_EXT_GENERATE_MASK}
//};

/* Create a constant for the number of entries in the table */

#define XTC_NUM_OPTIONS   (sizeof(OptionsTable) / sizeof(Mapping))

/*****************************************************************************/
/**
*
* Enables the specified options for the specified timer counter. This function
* sets the options without regard to the current options of the driver. To
* prevent a loss of the current options, the user should call
* XTmrCtr_GetOptions() prior to this function and modify the retrieved options
* to pass into this function to prevent loss of the current options.
*
* @param	InstancePtr is a pointer to the XTmrCtr instance.
* @param	TmrCtrNumber is the timer counter of the device to operate on.
*		Each device may contain multiple timer counters. The timer
*		number is a zero based number with a range of
*		0 - (XTC_DEVICE_TIMER_COUNT - 1).
* @param	Options contains the desired options to be set or cleared.
*		Setting the option to '1' enables the option, clearing the to
*		'0' disables the option. The options are bit masks such that
*		multiple options may be set or cleared. The options are
*		described in xtmrctr.h.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
//void my_XTmrCtr_SetOptions(u32 base, u16 tmr_num, u32 Options)
//{
//	u32 CounterControlReg = 0;
//	u32 Index;
//
//	Xil_AssertVoid(base != NULL);
//	Xil_AssertVoid(tmr_num < XTC_DEVICE_TIMER_COUNT);
//
//	/*
//	 * Loop through the Options table, turning the enable on or off
//	 * depending on whether the bit is set in the incoming Options flag.
//	 */
//
//	for (Index = 0; Index < XTC_NUM_OPTIONS; Index++) {
//		if (Options & OptionsTable[Index].Option) {
//
//			/*
//			 * Turn the option on
//			 */
//			CounterControlReg |= OptionsTable[Index].Mask;
//		}
//		else {
//			/*
//			 * Turn the option off
//			 */
//			CounterControlReg &= ~OptionsTable[Index].Mask;
//		}
//	}
//
//	/*
//	 * Write out the updated value to the actual register
//	 */
//	XTmrCtr_WriteReg(base, tmr_num, XTC_TCSR_OFFSET, CounterControlReg);
//}

void my_timer_continuos_start(u32 base, u16 tmr_num, u32 ResetValue)
{
	u32 ControlStatusReg = XTC_CSR_ENABLE_INT_MASK | XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_DOWN_COUNT_MASK | XTC_CSR_ENABLE_TMR_MASK;

	Xil_AssertVoid(base != NULL);
	Xil_AssertVoid(tmr_num < XTC_DEVICE_TIMER_COUNT);

	XTmrCtr_WriteReg(base, tmr_num, XTC_TLR_OFFSET, ResetValue);

//	my_XTmrCtr_SetOptions(base, tmr_num, ( XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION ));

//	ControlStatusReg = XTmrCtr_ReadReg(base, tmr_num, XTC_TCSR_OFFSET);

	XTmrCtr_WriteReg(base, tmr_num, XTC_TCSR_OFFSET, XTC_CSR_LOAD_MASK);

	XTmrCtr_WriteReg(base, tmr_num, XTC_TCSR_OFFSET, ControlStatusReg );
}
