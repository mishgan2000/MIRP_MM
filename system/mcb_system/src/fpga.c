#include "fpga.h"
#include "fsl.h"

//********************************************************************************************************
#define	REGADR						0
#define	REGDAT						1

#define wr_a(adr)					nputfsl(adr, REGADR)
#define wr_d(dat)					nputfsl(dat, REGDAT)
#define rd_a(adr) 					ngetfsl(adr, REGADR)
#define rd_d(dat) 					ngetfsl(dat, REGDAT)

//********************************************************************************************************
void wr(unsigned int adr, unsigned int dat)
{
DIS_INTS;
	wr_a(adr);
	NOP;
	wr_d(dat);
ENA_INTS;
}

static unsigned char invalid, error;
char rd(unsigned int adr, unsigned int *dat)
{
DIS_INTS;
	invalid = 1;
	error = 0;
	wr_a(adr);
	NOP; NOP;
	while(invalid)
	{
		rd_d(*dat);
		fsl_isinvalid(invalid);
		if (invalid)
			error++;
		if (error > RD_ERROR_LIMIT)
		{
ENA_INTS;
			return error;
		}

	}
ENA_INTS;
	return RD_OK;
}

/*
unsigned int rd(unsigned int adr)
{
DIS_INTS;
	static unsigned int dat_buf;
	wr_a(adr);
	rd_d(dat_buf);
ENA_INTS;
	return dat_buf;
}

void rd(unsigned int adr, unsigned int *dat)
{
DIS_INTS;
	wr_a(adr);
	rd_d(*dat);
ENA_INTS;
}
*/

//********************************************************************************************************
static unsigned int local_addr;

void save_adr()
{
	rd_a(local_addr);
}

void load_adr()
{
	wr_a(local_addr);
}
