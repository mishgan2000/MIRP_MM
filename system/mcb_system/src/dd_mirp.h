/*
 * dd_mirp.h
 *
 *  Created on: 19.03.2014
 *      Author: kochergin_m
 */

#ifndef DD_MIRP_H_
#define DD_MIRP_H_

void set_DDS_param(unsigned int freq, unsigned int OutVolt);
void update_control_reg(void); 	// Обновление регистра контроля
void start_acquisition(void);	// Запуск всех измерений
void get_incl_data(void);		// Опрос 3DM-DH3
void get_XLX_data( void );
void get_Ext_XLX_data( void );
void get_ADC_RES_data( void );
void get_ADC_SP_data( void );
void write_incl_calibr_mem(unsigned char *buf, unsigned char addr, unsigned char length);
void read_incl_calibr_mem(unsigned char *buf, unsigned char addr, unsigned char length);
void read_eeprom_calibr_mem(void);
void msg_incl_send(void *buf, int size);
int msg_incl_ini(void);
int msg_incl_read(void *buf, int size);

void TOR(void);
void ClrWorkTime(void);
void InitCoefs(void);
int read_ee_buf(unsigned short reg_addr, unsigned short num_bytes, unsigned char *buf);
void write_SN(unsigned short SN);
unsigned short read_SN(void);

extern int msg_incl_id;
extern char MIRP_Version[32];

#define EEPROM_ADR					0x50
#define TOR_SECTOR1					0x40		// first tor bin
#define TOR_SECTOR1_START_CNT		0x58		// first tor bin from start cnt и далее SN и ToolType
#define TOR_SECTOR2					0x80		// second tor bin
#define TOR_SECTOR2_START_CNT		0x98		// second tor bin from start cnt
#define TOR_SECTOR_LENGTH			28			// 24 байта время наработки + StartCnt + ToolSN
#define EE_CALIB_OFFSET				0x200		// Начало калибровочного файла
#endif /* DD_MIRP_H_ */
