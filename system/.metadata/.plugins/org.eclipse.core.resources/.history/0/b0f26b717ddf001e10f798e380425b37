
#include "xiic_l.h"
//#include "fpga.h"
#include "xparameters.h"
#include "math.h"
#include "mirp.h"
#include "dd_mirp.h"
//#include <sys/timer.h>
#include "stdio.h"

#define DDS_AD5433						0x0D
#define eeprom_wr_delay					20
#define PI								3.141592653
int msg_incl_id;

struct CalibrCoefsStr CalibrCoefs;

//-------- Reading Calibr from EEPROM -----------------
void read_eeprom_calibr_mem(void)
{
	static unsigned char EE_work_buf[4];
	static union UNION_WORD	union_word;
	static int i;
	static float *ptr;

	ptr = &CalibrCoefs.accelMt[0];
	for(i=0; i<33; i++)
	{
		read_ee_buf(EE_CALIB_OFFSET+i*4, 4,&EE_work_buf[0]);
		union_word.ub[3] = EE_work_buf[0];
		union_word.ub[2] = EE_work_buf[1];
		union_word.ub[1] = EE_work_buf[2];
		union_word.ub[0] = EE_work_buf[3];
		*ptr++ = union_word.f;
	}
}

void InitCoefs(void){
static unsigned short addr;
static unsigned int rc, i, tor1, tor2;
static unsigned char EE_work_buf[6];
for(i=0;i<6;i++)
	{

		addr =TOR_SECTOR1+i*4;
		read_ee_buf(addr, 4, &EE_work_buf[0]);
		tor1 =  (((unsigned char)EE_work_buf[0])&0xFF)+((((unsigned int)EE_work_buf[1])<<8)&0xFF00);
		tor1 += (((unsigned char)EE_work_buf[2])&0xFF)+((((unsigned int)EE_work_buf[3])<<8)&0xFF00);

		addr =TOR_SECTOR2+i*4;
		read_ee_buf(addr, 4,&EE_work_buf[0]);
		tor2 =  (((unsigned char)EE_work_buf[0])&0xFF)+((((unsigned int)EE_work_buf[1])<<8)&0xFF00);
		tor2 += (((unsigned char)EE_work_buf[2])&0xFF)+((((unsigned int)EE_work_buf[3])<<8)&0xFF00);
		if((tor1 >= tor2)&&(tor1 != 0xFFFFFFFF))
		{
			addr = TOR_SECTOR1;
		}else{
			addr = TOR_SECTOR2;
		}
		addr += i * 4;
		read_ee_buf(addr, 4,&EE_work_buf[0]);
		info.WTime[i] = ((unsigned int)EE_work_buf[0])&0xFF;
		info.WTime[i] +=(((unsigned int)EE_work_buf[1]<<8))&0xFF00;
		info.WTime[i] +=(((unsigned int)EE_work_buf[2]<<16))&0xFF0000;
		info.WTime[i] +=(((unsigned int)EE_work_buf[3]<<24))&0xFF000000;
	}
	read_ee_buf(TOR_SECTOR1_START_CNT, 4,&EE_work_buf[0]);
	info.StartCnt = (EE_work_buf[0]&0xFF) + ((EE_work_buf[1]<<8)&0xFF00);
	info.StartCnt++;
	info.serial_num = (EE_work_buf[2]&0xFF) + ((EE_work_buf[3]<<8)&0xFF00);
	sleep(eeprom_wr_delay);
	EE_work_buf[0] = (unsigned char)((TOR_SECTOR1_START_CNT)>>8);
	EE_work_buf[1] = (unsigned char)((TOR_SECTOR1_START_CNT)&0xFF);
	EE_work_buf[2] = (unsigned char)(info.StartCnt&0xFF);
	EE_work_buf[3] = (unsigned char)((info.StartCnt>>8)&0xFF);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&EE_work_buf[0], 4, XIIC_STOP);
	sleep(10);
}
//-------- Reading serial number -----------------
unsigned short read_SN(void)
{
	static unsigned char EE_work_buf[2];
	static unsigned short sn;

	read_ee_buf(TOR_SECTOR1_START_CNT+2,2, &EE_work_buf[0]);
	sn = EE_work_buf[0]&0xFF;
	sn += ( ((unsigned short)EE_work_buf[1]) <<8)&0xFF00;
	return sn;
}

//-------- Read data from EEPROM -----------------
int read_ee_buf(unsigned short reg_addr, unsigned short num_bytes, unsigned char *buf)
{
	static unsigned char EE_work_buf[2];
	static unsigned int rc;

	sleep(eeprom_wr_delay);
	EE_work_buf[0] = (unsigned char)(reg_addr>>8);
	EE_work_buf[1] = (unsigned char)(reg_addr&0xFF);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&EE_work_buf[0], 2, XIIC_STOP);
	sleep(2);
	rc = XIic_Recv(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)buf, num_bytes, XIIC_STOP);
	return rc;
}





