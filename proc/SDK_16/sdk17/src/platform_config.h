#ifndef __PLATFORM_CONFIG_H_
#define __PLATFORM_CONFIG_H_

#define STDOUT_IS_16550
#define STDOUT_BASEADDR XPAR_AXI_UART16550_0_BASEADDR
#ifdef __PPC__
#define CACHEABLE_REGION_MASK 0x80000080
#endif

#endif
