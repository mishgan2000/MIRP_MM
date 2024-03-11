/*
 * dd_mirp.c
 *
 *  Created on: 19.03.2014
 *      Author: kochergin_m
 */
#include "xiic_l.h"
#include "fpga.h"
#include "xparameters.h"
#include "math.h"
#include "mirp.h"
#include "dd_mirp.h"
//#include <sys/timer.h>
#include "stdio.h"

#ifndef MIRP_V2
	#define MIRP_V2
#endif

#define DDS_AD5433						0x0D
#define eeprom_wr_delay					20
#define PI								3.141592954
int msg_incl_id;
struct CalibrCoefsStr CalibrCoefs;

unsigned short Calculate_Angles(void);
//******************************************************************************************************************************
//******************************************************************************************************************************
extern void sleep(unsigned long int c);

// Setting an output frequence DDS
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

//******************************************************************************************************************************
//******************************************************************************************************************************
// Update of control register
void update_control_reg(void)
{
	static unsigned int i=0;
	char stat;

	stat = rd(REG_CONTROL, (unsigned int*)&i);
	i =0;			// ��������
	i |= control_reg.all;
	if(control_reg.bit.strend1 ==1)	// �.�. ������������� �� ������������
	{
		i |= 0x10;
	}else{
		i &= 0xFFEF;
	}
	wr(REG_CONTROL, i);
}

//******************************************************************************************************************************
//******************************************************************************************************************************
//-- Starting all measurements
void start_acquisition(void)
{
	unsigned int i=0;
	char stat;

	status_reg.bit.fatal_error = 0;
	stat = rd(REG_STATUS, (unsigned int*)&i);
	control_reg.bit.reset_adcs = 0;
	if ((stat==0)&&(i>3)&&(i<16))
	{
		control_reg.bit.reset_adcs = 1;
		update_control_reg();
		control_reg.bit.reset_adcs = 0;
//		update_control_reg();
		status_reg.bit.fatal_error = 1;
	}

	control_reg.bit.gyro_data = 1;
//	control_reg.bit.incl_ext_data = 1;
	control_reg.bit.start_adc_res = 1;
	control_reg.bit.start_adc_sp = 1;
	update_control_reg();
	control_reg.bit.gyro_data = 0;
//	control_reg.bit.incl_ext_data = 0;
	control_reg.bit.start_adc_res = 0;
	control_reg.bit.start_adc_sp = 0;
}
//******************************************************************************************************************************
//******************************************************************************************************************************
// Polling 3DM-DH3 sensor
void get_incl_data(void)
{
	static int i;
	static float data[15], *ptr;
	//struct msqid_ds stats;
	static unsigned int num_points, azim_shift;

	i=0;
	num_points = 0;
	azim_shift = 0;
	//msgctl(msg_incl_id,IPC_STAT,&stats);
	status_reg.bit.incl_checksum = 0; // �������� ������

	while(i != -1)
	{
		i = msg_incl_read(data,60);
		if (i==60)	// ����� ���������
		{
			ptr = &MirpExtTelem.incl;
			if (num_points==0)
			{
				if(data[1]>350)
				{
					azim_shift = 1;
					data[1] -= 360;
				}
				if(data[1]<10)
				{
					azim_shift = 1;
				}
				for(i=0; i<15;) *ptr++ = data[i++];	//
			}else{
				if((azim_shift==1)&(data[1]>340))data[1] -= 360;
				for(i=0; i<2;) *ptr++ += data[i++];
				*ptr++ = data[2];		// GTF
				*ptr++ = data[3];		// MTF
				for(i=4; i<15;) *ptr++ += data[i++];
			}
			num_points++;

		}
	}
	if (num_points>0)
	{
		ptr = &MirpExtTelem.incl;
		for(i=0; i<2;i++) *ptr++ /= num_points;
		ptr++;
		ptr++;
		for(i=4; i<15;i++) *ptr++ /= num_points;
		if(MirpExtTelem.azimuth<0) MirpExtTelem.azimuth +=360;
		if(MirpExtTelem.azimuth>360) MirpExtTelem.azimuth -=360;

		MirpTelem.incl = MirpExtTelem.incl;
		MirpTelem.azimuth = MirpExtTelem.azimuth;
		MirpTelem.DipAngle = MirpExtTelem.DipAngle;
		MirpTelem.GTF = MirpExtTelem.GTF;
		MirpTelem.GTOT = MirpExtTelem.GTOT;
		MirpTelem.HTOT = MirpExtTelem.HTOT;
		MirpTelem.MTF = MirpExtTelem.MTF;

#ifdef MIRP_V2
		Calculate_Angles();
#endif
	}

}
//******************************************************************************************************************************
//******************************************************************************************************************************
void get_Ext_XLX_data( void )
{
	static unsigned int i, stat;
	static unsigned int temp[2];

	get_ADC_RES_data();
	get_ADC_SP_data();
	get_incl_data();		// ����� 3DM-DH3

	status_reg.bit.gyro_checksum = 0;
	for(i=0; i<10;i++)		// GyroTemp
	{
		wr(REG_GYRO, i*2);
		rd(REG_GYRO, &temp[0]);
		wr(REG_GYRO, i*2+1);
		rd(REG_GYRO, &temp[1]);
		MirpExtTelem.Gyro[i] = (float)( (int)(( (temp[0]&0xFF00)+((temp[0]>>16)&0xFF) )<<16) )/65536*0.03125;
		MirpExtTelem.GyroTemp = ((float)( (temp[1]&0xFF) + ( (temp[0]>>16)&0xFF00 )))*0.125 ;
		stat = 0xFF - (((temp[0]&0xFF) + ((temp[0]>>8)&0xFF) + ((temp[0]>>16)&0xFF) + ((temp[0]>>24)&0xFF) + (temp[1]&0xFF))&0xFF) - ((temp[1]>>8)&0xFF);
		if (stat != 0) status_reg.bit.gyro_checksum = 0;		// !!! For #3 and #4 MIRP-M3. Temporarily  only!
	}
	if((MirpExtTelem.Temperature>125)|(MirpExtTelem.Temperature<0)) status_reg.bit.temperature_bad = 1; else status_reg.bit.temperature_bad = 0;

	MirpExtTelem.STATUS = status_reg.all;
	MirpTelem.STATUS = status_reg.all;

}
//******************************************************************************************************************************
//******************************************************************************************************************************
void get_ADC_RES_data( void )
{
	static int tmp_res[60];
	static int i, j, ave, min, max, val;
	static double sum, amplitude[13];

	val = 0;
	for(j=0;j<12;j++)
	{
		ave=0;
		min=41943;
		max=-41943;
		sum = 0;
		for(i=0; i<60;i++)
		{
			wr(REG_ADC_RES, i+60*j);
			rd(REG_ADC_RES, (unsigned int*)&tmp_res[i]);
			ave += tmp_res[i];
			if (max < tmp_res[i]) max = tmp_res[i];
			if (min > tmp_res[i]) min = tmp_res[i];
		}
		if((max>3145728)|(min<-3145728)) val++;	//����������
		if (j==3)	//���������� DDS
		{
			if(((max<83886)|(min>-83886))&(DDS_param.voltage!=1600))//5mV
			{
				DDS_param.up_current++;
				DDS_param.down_current = 0;
				if (DDS_param.up_current>=4)
				{
					DDS_param.voltage *=2;
					DDS_param.update_DDS = 1;
					DDS_param.up_current = 0;
				}
			}else{
				DDS_param.up_current = 0;
			}
			if(((max>838861)|(min<-838861))&(DDS_param.voltage!=200))//50mV
			{
				DDS_param.down_current ++;
				if (DDS_param.down_current>=4)
				{
					DDS_param.voltage /=2;
					DDS_param.update_DDS = 1;
					DDS_param.down_current = 0;
				}
			}else{
				DDS_param.down_current = 0;
			}
		}
		ave /=60;
		for(i=0; i<60;i++)
		{
			tmp_res[i] -= ave;
			sum += (((double)tmp_res[i])*((double)tmp_res[i]));
		}
		sum /=60;
		amplitude[j] = sqrt(sum);
	}
	if(val>0) status_reg.bit.res_data_val = 1; else status_reg.bit.res_data_val = 0;
	amplitude[12] = 0;
	for(i=0; i<60;i++)
	{
		wr(REG_ADC_RES, i+60*12);
		rd(REG_ADC_RES, (unsigned int*)&tmp_res[i]);
		amplitude[12] += tmp_res[i];
	}
	amplitude[12] = (-1)*amplitude[12]*5000/(8388608*60);		//REF

//	rd(REG_ADC_GAIN_RES, &PGA_RES.all);
	PGA_RES.all = 0;
	// Voltage A0-A1
	MirpExtTelem.Ua01 = (float)(amplitude[0]+amplitude[1]+amplitude[2]+amplitude[3])*5000*1.4142/4/(8388608*(1<<PGA_RES.bit.ch0))/GAIN_Ua0_a1;	// PGA

	// Voltage U0-U1
	MirpExtTelem.Um01 = (float)(amplitude[4]+amplitude[5]+amplitude[6]+amplitude[7])*5000*1.4142/4/(8388608*(1<<PGA_RES.bit.ch1))/GAIN_Um0_m1;	// PGA

	// resistivetor current
	MirpExtTelem.Ires = (float)(amplitude[8]+amplitude[9]+amplitude[10]+amplitude[11])*5000*1.4142/4/(8388608*(1<<PGA_RES.bit.ch3))/GAIN_IRES;	// PGA

	MirpExtTelem.Rm = (MirpExtTelem.Um01/(MirpExtTelem.Ires+0.0001))*GAIN_GKZ;	// Drilling mud resistance
	MirpTelem.Rm = MirpExtTelem.Rm;	// Drilling mud resistance

}
//******************************************************************************************************************************
//******************************************************************************************************************************
void get_ADC_SP_data( void )
{
	static int tmp_sp[100];
	static int i, j, min, max, k=0;
	static double sum;
	static float noise[10], Usp[10];

//	rd(REG_ADC_GAIN_SP, &PGA_SP.all);
//OLD BOARD: SP_OK(0),   SP_FISH(1), SP_RSP(2), SP_CHAS(3), RSP_OK(4), RSP_FISH(5), RSP_CHAS(6), FISH_OK(7), SPARC_SP_OK(8)
//NEW BOARD: FISH_SP(0), FISH_OK(1), OK_SP(2),  RSP_SP(3), SP_CHAS(3), RSP_OK(4), RSP_FISH(5), RSP_CHAS(6), FISH_OK(7), SPARC_SP_OK(8)
	status_reg.bit.sp_data_val = 0;
	PGA_SP.all = 0;
	for(j=0;j<4;j++)
	{
//		MirpExtTelem.Usp[j+4] = 0;	// �������� RSP_OK, RSP_FISH, RSP_CHAS (4,5,6)
		Usp[j+4] = 0;
		// SP_OK, SP_FISH, SP_RSP, SP_CHAS
		min=0;
		max=0;
		sum = 0;
		for(i=0; i<100;i++)
		{
			wr(REG_ADC_SP, i+100*j);
			rd(REG_ADC_SP, (unsigned int*)&tmp_sp[i]);
			sum += (double)tmp_sp[i];
			if (max < tmp_sp[i]) max = tmp_sp[i];
			if (min > tmp_sp[i]) min = tmp_sp[i];
		}
		if((max>1747626)|(min<-1747626)) status_reg.bit.sp_data_val = 1;	//2500mv/2 /GAIN_SP
//		if((max>3145728)|(min<-3145728)) status_reg.bit.sp_data_val = 1;	//2250mv*1,2
// OLD BOARD		MirpExtTelem.Usp[j] = (-1)*(float)(sum)*5000/(8388608*(1<<PGA_SP.bit.ch0))*GAIN_SP/100;	// PGA
		Usp[j] = (float)(sum)*5000/(8388608*(1<<PGA_SP.bit.ch0))*GAIN_SP/100;	// PGA
	}
//	MirpExtTelem.Usp[4] = MirpExtTelem.Usp[0] - MirpExtTelem.Usp[2];	//RSP_OK
//	MirpExtTelem.Usp[5] = MirpExtTelem.Usp[1] - MirpExtTelem.Usp[2];	//RSP_FISH
//	MirpExtTelem.Usp[6] = MirpExtTelem.Usp[3] - MirpExtTelem.Usp[2];	//RSP_CHAS
	MirpExtTelem.Usp[0] = Usp[2];//SP_OK
	MirpExtTelem.Usp[1] = Usp[0];//SP_FISH
	MirpExtTelem.Usp[2] = Usp[3];//SP_RSP
	MirpExtTelem.Usp[3] = Usp[3];//SP_CHAS
	MirpExtTelem.Usp[4] = Usp[2]-Usp[3];//RSP_OK
	MirpExtTelem.Usp[5] = Usp[0]-Usp[3];//RSP_FISH
	MirpExtTelem.Usp[6] = Usp[0]-Usp[3];//RSP_CHAS
	if(k >= 10) k=0;
//OLD BOARD	noise[k++] = MirpExtTelem.Usp[1]-MirpExtTelem.Usp[0];	// FISH_OK
	noise[k++] = Usp[1];	// FISH_OK
	MirpExtTelem.Usp[7] = 0;
	for(i=0; i<9;i++) MirpExtTelem.Usp[7] += noise[i];
	MirpExtTelem.Usp[7] /=10;
	MirpExtTelem.Usp[8] = MirpExtTelem.Usp[0]+MirpExtTelem.Usp[7];
	MirpTelem.Usp = MirpExtTelem.Usp[1];
	MirpTelem.Udsp = MirpExtTelem.Usp[2];

}
//******************************************************************************************************************************
//******************************************************************************************************************************
void write_incl_calibr_mem(unsigned char *buf, unsigned char addr, unsigned char length)
{
#ifndef MIRP_V2
	static unsigned int i;
	static union UNION_WORD	union_word;

	for(i=addr; i<addr+length; i++)
	{
		union_word.ub[3] = buf[i-addr];		// byte 3
		union_word.ub[2] = (unsigned char)(i&0xFF); // byte 4
		union_word.ub[1] = (unsigned char)((i>>8)&0xFF); // byte 5
		union_word.ub[0] = 0; // byte 6

		wr(REG_DATA_WR_INCL, (unsigned int)union_word.ul);
		control_reg.bit.incl_wr_data = 1;
		update_control_reg();
		control_reg.bit.incl_wr_data = 0;
		sleep(100);
	}
#endif
#ifdef MIRP_V2
	static unsigned char ee_buf[3];
		// write copy of calib byte to eeprom
		ee_buf[0] = (unsigned char)(((EE_CALIB_OFFSET + (unsigned int)addr)>>8)&0xFF);
		ee_buf[1] = (unsigned char)(EE_CALIB_OFFSET + (unsigned int)addr);
		ee_buf[2] = buf[0];
		XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&ee_buf[0], 3, XIIC_STOP);
		sleep(20);
	if (addr == 95){
		read_eeprom_calibr_mem();
	}
#endif

}
//******************************************************************************************************************************
//******************************************************************************************************************************
void read_incl_calibr_mem(unsigned char *buf, unsigned char addr, unsigned char length)
{
	static unsigned int i, data[6];

#ifdef MIRP_V2
	if (addr == 0){
		read_eeprom_calibr_mem();
	}
	read_ee_buf(EE_CALIB_OFFSET+addr, length, buf);
#endif
#ifndef MIRP_V2
	for(i=addr; i<addr+length; i++)
	{
		wr(REG_DATA_WR_INCL, i);
		control_reg.bit.incl_rd_data = 1;
		update_control_reg();
		control_reg.bit.incl_rd_data = 0;

		sleep(10);
		wr(REG_INCL, 1);
		rd(REG_INCL, &data[0]);
		wr(REG_INCL, 2);
		rd(REG_INCL, &data[1]);
		wr(REG_INCL, 3);
		rd(REG_INCL, &data[2]);
		wr(REG_INCL, 4);
		rd(REG_INCL, &data[3]);
		wr(REG_INCL, 5);
		rd(REG_INCL, &data[4]);
		*buf++ = (unsigned char)(data[2]&0xFF);
	}
#endif
}

//==================================================================================

//-------- Reading calibration bytes from EEPROM -----------------
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


//******************************************************************************************************************************
int msg_incl_ini()
{
	//key_t msgkey_incl = 0x1;
	//return msgget(msgkey_incl, IPC_CREAT);
	return 1;
}

//******************************************************************************************************************************
#include "errno.h"

//******************************************************************************************************************************
void msg_incl_send(void *buf, int size)
{
	//int ret = msgsnd(msg_incl_id, buf, size, 0);
	//if (ret == -1) xil_printf("msgsnd ret: %d; errno: %d\n\r", ret, errno);
}

//******************************************************************************************************************************
int msg_incl_read(void *buf, int size)
{
	//int ret = msgrcv(msg_incl_id, buf, size, 0, IPC_NOWAIT);
//	if (ret == -1)
//		xil_printf("msgrcv ret: %d; errno: %d\n\r", ret, errno);
	//return ret;
	return 1;
}
/////////////////////////////////////////////////////////////////////////////////////
/////																			/////
/////																			/////
/////									TOR 									/////
/////																			/////
/////																			/////
/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------
// ------  Operating time
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

//-------- Reset operating time
void ClrWorkTime(void)
{
  static unsigned char buf[29];
  static int rc, i;

	sleep(10);
	for(i=0;i<TOR_SECTOR_LENGTH;i++) buf[i]=0x0;
	// erase Coef.WTime + Startcnt
	buf[0] = (unsigned char)((TOR_SECTOR1)>>8);
	buf[1] = (unsigned char)((TOR_SECTOR1)&0xFF);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&buf[0], TOR_SECTOR_LENGTH, XIIC_STOP);
	sleep(10);
	buf[0] = (unsigned char)((TOR_SECTOR2)>>8);
	buf[1] = (unsigned char)((TOR_SECTOR2)&0xFF);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&buf[0], TOR_SECTOR_LENGTH, XIIC_STOP);
	sleep(10);
}
//==================================================================================

//-------- Initialization of calibration coefficients -----------------
void InitCoefs(void)
{
static unsigned short addr;
static unsigned int rc, i, tor1, tor2;
static unsigned char EE_work_buf[6];


	for(i=0;i<6;i++)
	{

		addr =TOR_SECTOR1+i*4;
		read_ee_buf(addr, 4,&EE_work_buf[0]);
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
		addr +=i*4;
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
//==================================================================================

//-------- Reading data from EEPROM -----------------
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
//==================================================================================

//-------- Saving serial number -----------------
void write_SN(unsigned short SN)
{
	static unsigned char EE_work_buf[4];
	static unsigned int rc;

	EE_work_buf[0] = (unsigned char)((TOR_SECTOR1_START_CNT+2)>>8);
	EE_work_buf[1] = (unsigned char)((TOR_SECTOR1_START_CNT+2)&0xFF);
	EE_work_buf[2] = (unsigned char)(SN&0xFF);
	EE_work_buf[3] = (unsigned char)(SN>>8);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&EE_work_buf[0], 4, XIIC_STOP);
	EE_work_buf[0] = (unsigned char)((TOR_SECTOR2_START_CNT+2)>>8);
	EE_work_buf[1] = (unsigned char)((TOR_SECTOR2_START_CNT+2)&0xFF);
	EE_work_buf[2] = (unsigned char)(SN&0xFF);
	EE_work_buf[3] = (unsigned char)(SN>>8);
	rc = XIic_Send(XPAR_IIC_0_BASEADDR, EEPROM_ADR, (u8*)&EE_work_buf[0], 4, XIIC_STOP);
}
//==================================================================================

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
//==================================================================================

//=============   Calculating angles ==============================
#ifdef MIRP_V2
unsigned short Calculate_Angles(void)
{

	double _ax, _ay, _az, _tx, _ty, _tz;
	float Ax, Ay, Az, Mx, My, Mz, *temp;
	double Gtot, Htot, GH, aval, Dip;
	double b1, b2, b3;
	double U1, U2;
	double vizir=0., azim=0., zen=0.;

	temp = &CalibrCoefs.accelMt[0];
// coordinate system transformation  _Ai=SKAij*Aj+SKA0i _Ti=SKTij*Tj+SKT0i
	MirpExtTelem.Ax -= temp[0];
	MirpExtTelem.Ay -= temp[1];
	MirpExtTelem.Az -= temp[2];
	Ax = MirpExtTelem.Ax;
	Ay = MirpExtTelem.Ay;
	Az = MirpExtTelem.Az;
	_ax = temp[3]*Ax + temp[4]*Ay + temp[5]*Az;
	_ay = temp[6]*Ax + temp[7]*Ay + temp[8]*Az;
	_az = temp[9]*Ax + temp[10]*Ay + temp[11]*Az;

	// applying magMt
	temp = &CalibrCoefs.magMt[0];
	MirpExtTelem.Mx -= temp[0];
	MirpExtTelem.My -= temp[1];
	MirpExtTelem.Mz -= temp[2];
	Mx = MirpExtTelem.Mx;
	My = MirpExtTelem.My;
	Mz = MirpExtTelem.Mz;
	_tx = temp[3]*Mx + temp[4]*My + temp[5]*Mz;
	_ty = temp[6]*Mx + temp[7]*My + temp[8]*Mz;
	_tz = temp[9]*Mx + temp[10]*My + temp[11]*Mz;
	Mx = _tx;
	My = _ty;
	Mz = _tz;

	temp = &CalibrCoefs.magMs[0];
	_tx = temp[0]*Mx + temp[1]*My + temp[2]*Mz;
	_ty = temp[3]*Mx + temp[4]*My + temp[5]*Mz;
	_tz = temp[6]*Mx + temp[7]*My + temp[8]*Mz;

	aval = _ax*_ax + _ay*_ay + _az*_az;
	Gtot = sqrt(aval);
	aval = _tx*_tx + _ty*_ty + _tz*_tz;
	Htot = sqrt(aval);

	GH = Gtot*Htot;
	if (GH == 0.)  GH = 1.;
	if (Gtot == 0.)  Gtot = 1.;
	if (Htot ==0.)   Htot = 1.;
//	if (_az == 0.) _az = 1.;

	aval = _ax*_tx/GH + _ay*_ty/GH + _az*_tz/GH;
	if (aval > 1. || aval < -1.) return 1;
	Dip = acos(aval) * 180. / PI - 90.;
	if (Dip>180.) Dip=Dip-180;
	if (Dip<0.) Dip=Dip+180;

	// ****************************************   ZENIT
	b3 = _az/Gtot;
	b2 = _ay/Gtot;
	b1 = _ax/Gtot;


    if (b3 > 1. || b3 < -1.) return 1;
    zen=acos(b3);
    zen = 180. - zen * 180. / PI;

 // ***************   VIZIR
	vizir = atan2(b1,b2);
	vizir = vizir * 180./PI;
	if (vizir > 360.) vizir=vizir-360.;
	if (vizir < 0.) vizir=vizir+360.;


////////////////////////// AZIMUT
	U1 =(_ty*_ax - _tx*_ay)*Gtot;
	U2 =_tz*(_ax*_ax + _ay*_ay) - _az*(_ax*_tx + _ay*_ty);

	azim = atan2(U1,-U2);
	azim=azim*180./PI - 180.;
	if (azim>360.) azim=azim-360;
	if (azim<0.) azim=azim+360;

	MirpExtTelem.incl = zen;
	MirpExtTelem.azimuth = azim;
	MirpExtTelem.GTF = vizir;
	MirpExtTelem.DipAngle = Dip;
	MirpExtTelem.HTOT = Htot;
	MirpExtTelem.GTOT = Gtot;

	return 0;

}
#endif
