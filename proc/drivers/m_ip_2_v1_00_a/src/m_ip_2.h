/*****************************************************************************
* Filename:          C:\Work\XILINX\Projects\New_25\proc/drivers/m_ip_2_v1_00_a/src/m_ip_2.h
* Version:           1.00.a
* Description:       m_ip_2 Driver Header File
* Date:              Thu Jan 25 15:00:41 2024 (by Create and Import Peripheral Wizard)
*****************************************************************************/

#ifndef M_IP_2_H
#define M_IP_2_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/


/**
 * User Logic Slave Space Offsets
 * -- SLV_REG0 : user logic slave module register 0
 * -- SLV_REG1 : user logic slave module register 1
 */
#define M_IP_2_USER_SLV_SPACE_OFFSET (0x00000000)
#define M_IP_2_SLV_REG0_OFFSET (M_IP_2_USER_SLV_SPACE_OFFSET + 0x00000000)
#define M_IP_2_SLV_REG1_OFFSET (M_IP_2_USER_SLV_SPACE_OFFSET + 0x00000004)

/**************************** Type Definitions *****************************/


/***************** Macros (Inline Functions) Definitions *******************/

/**
 *
 * Write a value to a M_IP_2 register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the M_IP_2 device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void M_IP_2_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define M_IP_2_mWriteReg(BaseAddress, RegOffset, Data) \
 	Xil_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a M_IP_2 register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the M_IP_2 device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	Xuint32 M_IP_2_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define M_IP_2_mReadReg(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (RegOffset))


/**
 *
 * Write/Read 32 bit value to/from M_IP_2 user logic slave registers.
 *
 * @param   BaseAddress is the base address of the M_IP_2 device.
 * @param   RegOffset is the offset from the slave register to write to or read from.
 * @param   Value is the data written to the register.
 *
 * @return  Data is the data from the user logic slave register.
 *
 * @note
 * C-style signature:
 * 	void M_IP_2_mWriteSlaveRegn(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Value)
 * 	Xuint32 M_IP_2_mReadSlaveRegn(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define M_IP_2_mWriteSlaveReg0(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (M_IP_2_SLV_REG0_OFFSET) + (RegOffset), (Xuint32)(Value))
#define M_IP_2_mWriteSlaveReg1(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (M_IP_2_SLV_REG1_OFFSET) + (RegOffset), (Xuint32)(Value))

#define M_IP_2_mReadSlaveReg0(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (M_IP_2_SLV_REG0_OFFSET) + (RegOffset))
#define M_IP_2_mReadSlaveReg1(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (M_IP_2_SLV_REG1_OFFSET) + (RegOffset))

/************************** Function Prototypes ****************************/


/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the M_IP_2 instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus M_IP_2_SelfTest(void * baseaddr_p);
/**
*  Defines the number of registers available for read and write*/
#define TEST_AXI_LITE_USER_NUM_REG 2


#endif /** M_IP_2_H */
