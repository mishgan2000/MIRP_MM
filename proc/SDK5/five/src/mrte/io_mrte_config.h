/*
 * io_mrte_config.h
 *
 *  Created on: 16.03.2018
 *      Author: pavlenko_av
 */

#ifndef IO_MRTE_CONFIG_H_
#define IO_MRTE_CONFIG_H_

#define MAX_LENGTH_PACKAGE_def		(20*1024)//(8*528)//(4224)
#define MSG_MAX_LEN					(MAX_LENGTH_PACKAGE_def+32)
#define TX_MSG_NUM					(5)//(5)

// MEGA-2 implementation

#define RX_INIT_BUF_LEN				(80)
#define RX_CMD_CH_BUF_LEN			(MSG_MAX_LEN)
#define RX_BROADCAST_CH_BUF_LEN		(1024)
#define CHANEL_ANY_FILTER			(20)

#endif /* IO_MRTE_CONFIG_H_ */
