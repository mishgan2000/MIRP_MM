
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <crc.h>

void CalcCRC16(uint8_t c){
	uint16_t a = 0;
	uint8_t	b = 0;

	b = (crc ^ c) & 0xFF;
	a = crc16tab[b];
	//crc = ((uint16_t)((crc >> 8) ^ crc16tab[ (crc ^ c) & 0xFF ]));
	crc = ((uint16_t)((crc >> 8) ^ a));

}

uint8_t CalcCRC(uint32_t *bbb){
   uint8_t r[20], k, l = 0, crc_h, crc_l;
   uint32_t t;

   for(k = 0; k < 5; k++){
	  t = *bbb;
	  l = (4 * k);
      r[l + 0] = (t >> 24) & 0xff;
      r[l + 1] = (t >> 16) & 0xff;
      r[l + 2] = (t >> 8) & 0xff;
      r[l + 3] = t & 0xff;
      bbb++;
   }

   crc_h = r[18];
   crc_l = r[19];
   crc = 0;
   for(k = 0; k < 16; k++){
	   CalcCRC16(r[k]);
   }


   if((((crc >> 8) & 0xFF) == crc_h)&&((crc & 0xFF) == crc_l))
      return 0;
   else
   	  return 1;;
}


