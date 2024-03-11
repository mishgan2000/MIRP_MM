#ifndef FPGA_H_
#define FPGA_H_

//********************************************************************************************************
#define RD_OK			0
#define RD_ERROR		!RD_OK

#define RD_ERROR_LIMIT	8

void wr(unsigned int adr, unsigned int dat);
char rd(unsigned int adr, unsigned int *dat);
void save_adr();
void load_adr();

//********************************************************************************************************
#define	ENA_INTS					asm volatile ("msrset r0, 2")
#define	DIS_INTS					asm volatile ("msrclr r0, 2")
#define	ENA_INTS_M					microblaze_enable_interrupts()
#define	DIS_INTS_M					microblaze_disable_interrupts()
#define NOP							asm volatile ("nop")

//********************************************************************************************************
#define REG_LED						0x0000
#define REG_INFO					0x0001
#define REG_ADC_MAX1227				0x0002
#define REG_TIME					0x0003
#define REG_TIME_IRQ				0x0004
#define REG_IRQ						0x0005
#define REG_NPI						0x0006
#define REG_STATUS					0x0007
#define REG_ADC_RES					0x000A
#define REG_ADC_SP					0x000B
#define REG_ADC_GAIN_RES			0x000C
#define REG_ADC_GAIN_SP				0x000D
#define REG_CONTROL					0x000E
#define REG_ADC_DATA_ALL			0x000F
#define REG_INCL					0x0010
#define REG_GYRO					0x0011
#define REG_DATA_WR_INCL			0x0012
//	WR
	#define MEGA2_INI						0x01 << 0
	#define ADC_TEST						0x01 << 1
	#define ADC_OFFSET						0x01 << 2
	#define TR_DAMPER						0x01 << 3
// RD
	#define ADC_ENA							0x01 << 0
	#define NPI_WR_FULL						0x01 << 1
	#define NPI_WR_EMPTY					0x01 << 2
	#define NPI_RD_EMPTY					0x01 << 3
	#define NPI_INIT						0x01 << 4
#define REG_VALID					0x0008
#define REG_PGA						0x0009
#define REG_TRATSMIT				0x000A

//********************************************************************************************************
#define COEFT_TEMP						0.0625

#define COEFT_MV						2500 / 4096 / 1000

#define COEFT_EXT						COEFT_MV * (5.100 + 1.000) / 1.000
#define COEFT_I5						COEFT_MV * (1.000 + 1.000) * 1000.0 / 11.0
#define COEFT_5							COEFT_MV * (2.000 + 1.000) / 1.000
#define COEFT_1_2						COEFT_MV * (1.000 + 1.000) / 1.000
#define COEFT_1_8						COEFT_MV * (1.000 + 1.000) / 1.000
#define COEFT_2_5						COEFT_MV * (1.000 + 1.000) / 1.000
#define COEFT_3_3						COEFT_MV * (1.000 + 1.000) / 1.000
#define COEFT_T							0.125

#endif /* FPGA_H_ */
