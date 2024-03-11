
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
extern void sleep(unsigned long int c);
//******************************************************************************************************************************
// Setting output frequence DDS
void set_DDS_param(unsigned int freq, unsigned int OutVolt)
{
	static int rc;
	static unsigned char tmp[2];
	unsigned int freq_code;

// set freq
	freq_code = (unsigned int)(((((float)freq) * (1<<27))/7680000)*4);
	tmp[0] = 0x84;	// address of freq register
	tmp[1] = (unsigned char)(freq_code&0xFF);// 0x22;//0xE1;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x83; // address of freq register
	tmp[1] = (unsigned char)((freq_code>>8)&0xFF);//0x22;//0x7A;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x82; // address of freq register
	tmp[1] = (unsigned char)((freq_code>>16)&0xFF);//0x02;//0x00;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);
// end set freq

// Others configuration registers
	tmp[0] = 0x85;
	tmp[1] = 0x00;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x86;
	tmp[1] = 0x00;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x87;
	tmp[1] = 0x01;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x88;
	tmp[1] = 0x01;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x89;
	tmp[1] = 0xFF;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x80;
	tmp[1] = 0xB0;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);

	tmp[0] = 0x81;
	tmp[1] = 0x08;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);
// Others configuration registers

//reset DDS
	tmp[0] = 0x81;
	tmp[1] = 0x18;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);
//release from reset DDS
	tmp[0] = 0x81;
	tmp[1] = 0x08;
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);
//init with start freq. 0x12 - 200mV,0x14,0x16 0x10 - 2000mV
	tmp[0] = 0x80;
	switch(OutVolt)
	{
		case 200:
			tmp[1] = 0x12;
			break;
		case 400:
			tmp[1] = 0x14;
			break;
		case 800:
			tmp[1] = 0x16;
			break;
		case 1600:
			tmp[1] = 0x10;
			break;
		default:
			tmp[1] = 0x12;	//200mV
			break;
	}
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, DDS_AD5433, (u8*)&tmp[0], 2, XIIC_STOP);
}

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
/////////////////////////////////////////////////////////////////////////////////////
/////																			/////
/////																			/////
/////									TOR 									/////
/////																			/////
/////																			/////
/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------
// Aplication time
//---------------------------------------------------------------------------
void TOR(void)
{
  static unsigned short x=0;
  static int rc;
  static unsigned short addr;
  static unsigned char i=0, buf[6];

	sleep(eeprom_wr_delay);
	info.WTime[0] +=60;
	if (x==0)
	{
		x=1;
		addr = TOR_SECTOR1;
	}else{
		x=0;
		addr = TOR_SECTOR2;
	}
	buf[0] = (unsigned char)(addr>>8);
	buf[1] = (unsigned char)addr;
	buf[2] = (unsigned char)(info.WTime[0]);
	buf[3] = (unsigned char)(info.WTime[0]>>8);
	buf[4] = (unsigned char)(info.WTime[0]>>16);
	buf[5] = (unsigned char)(info.WTime[0]>>24);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&buf[0], 6, XIIC_STOP);

	if (MirpTelem.Temperature<0){
		info.WTime[1] +=60;
		i=1;
	}
	if ((MirpTelem.Temperature>=0)&&(MirpTelem.Temperature<35)){
		info.WTime[2] +=60;
		i=2;
	}
	if ((MirpTelem.Temperature>=35)&&(MirpTelem.Temperature<90)){
		info.WTime[3] +=60;
		i=3;
	}
	if ((MirpTelem.Temperature>=90)&&(MirpTelem.Temperature<120)){
		info.WTime[4] +=60;
		i=4;
	}
	if (MirpTelem.Temperature>=120){
		info.WTime[5] +=60;
		i=5;
	}
	addr+=i*4;
	sleep(eeprom_wr_delay);
	buf[0] = (unsigned char)(addr>>8);
	buf[1] = addr;
	buf[2] = (unsigned char)(info.WTime[i]);
	buf[3] = (unsigned char)(info.WTime[i]>>8);
	buf[4] = (unsigned char)(info.WTime[i]>>16);
	buf[5] = (unsigned char)(info.WTime[i]>>24);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&buf[0], 6, XIIC_STOP);
}
//==================================================================================






