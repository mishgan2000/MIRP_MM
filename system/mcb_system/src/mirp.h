/*
 * mirp.h
 *
 *  Created on: 27.12.2013
 *      Author: kochergin_m
 */

#ifndef MIRP_H_
#define MIRP_H_

#define DEVICE_TYPE					0x8018
#define SERIAL_NUM					0x0001
#define SOFTWARE_VERSION			0x000001

#define ANSWER_SIZE					70

#define WAIT_TIME					2 //ms
#define WAIT_TIME_LIMIT				(100*WAIT_TIME) //ms
#define WATCHDOG_TIME				100	// ms

#define GAIN_IRES					101	// коэф усиления аналогового тракта измерителя тока запитки
#define GAIN_Ua0_a1					11	// коэф усиления аналогового тракта измерителя Ua0-a1
#define GAIN_Um0_m1					11	// коэф усиления аналогового тракта измерителя Um0-m1
#define GAIN_SP						1.043	// коэф усиления аналогового тракта ПС
#define GAIN_GKZ					0.27// ГКЗ


void telem_st();

#define TO_UNION_UB(dat)		\
union_word.ub[3] = *dat++;		\
union_word.ub[2] = *dat++;		\
union_word.ub[1] = *dat++;		\
union_word.ub[0] = *dat++

#define TO_PTR_UNION_UB(dat)	\
*dat++ = union_word.ub[3];		\
*dat++ = union_word.ub[2];		\
*dat++ = union_word.ub[1];		\
*dat++ = union_word.ub[0]

#define TO_PTR_UNION_UB_INV(dat)	\
*dat++ = union_word.ub[0];		\
*dat++ = union_word.ub[1];		\
*dat++ = union_word.ub[2];		\
*dat++ = union_word.ub[3]

union UNION_WORD
{
	float			f;
	signed long		sl;
	unsigned long	ul;
	signed short	ss[2];
	unsigned short	us[2];
	signed char		sb[4];
	unsigned char	ub[4];
};

#define HEAD_SIZE			8
#define CH_BODY_SIZE		1024
#define CH_NUM				8

#define MEGA2_PLUS			0x80

typedef struct {
	unsigned char status;
	unsigned char sync;
	unsigned char async;
} SendSetup;

struct MirpExtendedTelem{
	unsigned char index;
	unsigned char cmd;
	unsigned short time_mark;
	unsigned short time_mark2;
	unsigned short regim;
	float incl;
	float azimuth;
	float GTF;
	float MTF;
	float DipAngle;
	float AccelTemp;
	float MagTemp;
	float GTOT;
	float HTOT;
	float Ax;
	float Ay;
	float Az;
	float Mx;
	float My;
	float Mz;
	float Gyro[10];
	float GyroTemp;
	float Rm;
	float Ires;
	float Um01;
	float Ua01;
	float Usp[9];
   	float Temperature;
	unsigned int STATUS;
	unsigned int crc;
	unsigned int irq_tik;
} ;

struct MirpBaseTelem{
	unsigned char index;
	unsigned char cmd;
	unsigned short time_mark;
	unsigned short time_mark2;
	unsigned short regim;
	float incl;
	float azimuth;
	float GTF;
	float MTF;
	float DipAngle;
	float GTOT;
	float HTOT;
	float Rm;
	float Usp;
	float Udsp;
   	float Temperature;
	unsigned int STATUS;
	unsigned int crc;
	unsigned int irq_tik;
} ;
struct MirpControlParam{
	unsigned char index;
	unsigned char cmd;
	unsigned short time_mark;
	unsigned short time_mark2;
	unsigned short mod_type;
	float U9V;
	float U5V;
	float U3_3V;
	float U2_5V;
	float U1_8V;
	float U1_2V;
	float I5V;
   	float Temperature;
	unsigned int crc;
	unsigned int irq_tik;
} ;
typedef struct {
	unsigned short device_type;
	unsigned short serial_num;
	char MIRP_Version[32];
	unsigned int	WTime[6];	// время наработки: [0] - общее, [1..5] - по температурам,24б
	unsigned short StartCnt;	// счетчик включений
} DevInfo;

struct CalibrCoefsStr {
	float			accelMt[12];	// коэф акселерометров,48б + offset
	float			magMt[12];	// коэф магнитометров,48б, hard iron + offset
	float			magMs[9];	// коэф магнитометров,48б, soft iron
};


struct PGA_setting_bits{
	unsigned int rsrvd:20;  // резерв
	unsigned int ch3:3;		// канал 3
	unsigned int ch2:3;		// канал 2
	unsigned int ch1:3;		// канал 1
	unsigned int ch0:3;		// канал 0
} ;

union PGA_setting {
	unsigned int		     all;
	struct PGA_setting_bits  bit;
};
// регистр управления
struct control_BITs {					//
	unsigned int 	  rsrvd:18;  		// резерв
	unsigned int      ena_acquisition:1;     	// разрешение работы цикла измерения
	unsigned int      incl_wr_data:1;     			// запись данных (eeprom и пр) инклинометра
	unsigned int      incl_rd_data:1;     			// чтение данных (eeprom и пр) инклинометра
	unsigned int      incl_check:1;     		// поверка инклинометра
	unsigned int      incl_stat:1;     			// статус инклинометра (смещение на сенсоры)
	unsigned int      gyro_stat:1;     			// статус гироскопа
	unsigned int      gyro_data:1;     			// данные гироскопа
	unsigned int      incl_ext_data:1;     		// все данные
	unsigned int      incl_base_data:1;     	// только углы
	unsigned int      strend1:1;       			// Жила 1
	unsigned int      reset_incl:1;       	// сброс инклинометра
	unsigned int      reset_adcs:1;			// сброс ADS1256
	unsigned int      start_adc_sp:1;	// запуск ацп пс
	unsigned int      start_adc_res:1;	// запуск ацп резистивиметра
};
union control_reg_union {
	unsigned int              all;
   struct control_BITs  bit;
};

// регистр статуса
struct status_BITs {					//
	unsigned int 	  rsrvd:19;  				// резерв
	unsigned int      gyro_checksum:1;     		// Гироскоп ОК
	unsigned int      G1_error:1;     			// Жила1 не в транзите
	unsigned int      fatal_error:1;     		// ERROR
	unsigned int      sp_data_val:1;     		// данные ПС ОК
	unsigned int      res_data_val:1;     		// данные резистивиметра ОК
	unsigned int      incl_checksum:1;     		// инклинометр ОК
	unsigned int      temperature_bad:1;     	// вне диапазона 0-125С
	unsigned int      U1_2V_stat:1;     		// напряжение не в допуске
	unsigned int      U1_8V_stat:1;     		// напряжение не в допуске
	unsigned int      U2_5V_stat:1;     		// напряжение не в допуске
	unsigned int      U3_3V_stat:1;     		// напряжение не в допуске
	unsigned int      U5V_stat:1;     			// напряжение не в допуске
	unsigned int      U9V_stat:1;     			// напряжение не в допуске
};
union status_reg_union {
	unsigned int       all;
   struct status_BITs  bit;
};

// параметры DDS
typedef struct{					//
   unsigned int      freq;		// частота DDS
   unsigned int      voltage;	// выходное напряжение DDS
   unsigned int      update_DDS;// при >5 обновление DDS
   unsigned int      up_current;// при >5 обновление DDS
   unsigned int      down_current;// при 5 обновление DDS
}DDS_param_type;

extern DevInfo info;
extern SendSetup send;
extern DDS_param_type DDS_param;
extern struct MirpBaseTelem MirpTelem;
extern struct MirpExtendedTelem MirpExtTelem;
extern struct MirpControlParam MirpContPar;
extern union PGA_setting PGA_SP;
extern union PGA_setting PGA_RES;

#define CONVERT_TO_TIME(dat)				(((dat / 10) << 4) + (dat % 10))
#define CONVERT_FROM_TIME(dat, mask)		((dat & (mask & 0xF0)) >> 4) * 10 + (dat & (mask & 0x0F))

extern union control_reg_union control_reg;
extern union status_reg_union status_reg;
#endif /* MIRP_H_ */
