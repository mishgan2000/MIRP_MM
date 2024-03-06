/*
 * can_cmd.c
 *
 *  Created on: 03.04.2017
 *      Author: pavlenko_av
 */

#include "can_cmd.h"
#include "can_cmd_defs.h"
#include "io-mrte.h"


extern u16	device_type;
extern u16 	serial_num;


//something goes wrong...
static void	Prepare_Buf_ERROR (RX_Com_buf_type* RX_Com_buf_ponter, TX_Com_buf_type * TX_Com_buf_ponter, u8 ERROR)
{
	TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
	TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode | 0x80;
//	TX_Com_buf_ponter->TimeMarker 		= MSGetTime();
	TX_Com_buf_ponter->COMMAND.ERROR	= ERROR;
}

void cmd_decoder( t_mega2_rxdatablock *pmega )
{
	int request_length, answer_length = 0;
	static t_mrte_msg_buff	* p_mrte_buff = NULL;

	int ii=0;

	TX_Com_buf_type*	TX_Com_buf_ponter;
	RX_Com_buf_type*	RX_Com_buf_ponter;

	p_mrte_buff = alloc_mrte_send_buff(portMAX_DELAY);

	configASSERT(p_mrte_buff != NULL);

	RX_Com_buf_ponter = (RX_Com_buf_type*) &pmega->data[0];
	TX_Com_buf_ponter = (TX_Com_buf_type*) &p_mrte_buff->buff->data.dU8[0];

	request_length = pmega->curr_ind;
	switch(pmega->data[1])
	{
	case COMMAND_PROPERTY_GET_DEVICE_TYPE:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_GET_DEVICE_TYPE)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			//			static u16 cnt_tmp = 0;
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_GET_DEVICE_TYPE;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_DEVICE_TYPE_buf.device_type = device_type;
		}
		break;
	}
	case COMMAND_PROPERTY_GET_SERIAL_NUMBER:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_GET_SERIAL_NUMBER)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			//			static u16 cnt_tmp = 0;
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_GET_SERIAL_NUMBER;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_SERIAL_NUMBER_buf.serial_number = serial_num;
		}
		break;
	}
	case COMMAND_PROPERTY_GET_SOFTWARE_VERSION:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_GET_SOFTWARE_VERSION)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			//			static u16 cnt_tmp = 0;
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_GET_SOFTWARE_VERSION;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf.main_version = 1;	// TODO
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf.sub_version = 2;	// TODO
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_SOFTWARE_VERSION_buf.build_number = 3;	// TODO
		}
		break;
	}
	case COMMAND_SET_START_REG:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_SET_START_REG)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, Length_ERROR_TX);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			// TODO	start registration
			answer_length = SIZE_ANSWER_COMMAND_SET_START_REG;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	}
	case COMMAND_SET_PARAM:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_SET_PARAM)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			// TODO set parameter
			answer_length = SIZE_ANSWER_COMMAND_SET_PARAM;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	}
	case COMMAND_SET_SOURCE:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_SET_SOURCE)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			//Check parameter bands
			if( (RX_Com_buf_ponter->COMMAND.COMMAND_SET_SOURCE_RD_buf.max_voltage < PLT_MIN_VOLTAGE) ||
				(RX_Com_buf_ponter->COMMAND.COMMAND_SET_SOURCE_RD_buf.max_voltage > PLT_MAX_VOLTAGE) ||
				(RX_Com_buf_ponter->COMMAND.COMMAND_SET_SOURCE_RD_buf.max_current > PLT_MAX_CURRENT) ||
				(RX_Com_buf_ponter->COMMAND.COMMAND_SET_SOURCE_RD_buf.set_current > PLT_MAX_CURRENT)
				)
			{
				Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAM_OUT_OF_RANGE);
				answer_length 	=	Length_ERROR_TX;
				break;
			}
			if(RX_Com_buf_ponter->COMMAND.COMMAND_SET_SOURCE_RD_buf.max_current < RX_Com_buf_ponter->COMMAND.COMMAND_SET_SOURCE_RD_buf.set_current)
			{
				Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_CONFLICT);
				answer_length 	=	Length_ERROR_TX;
				break;
			}
			// TODO set source
			answer_length = SIZE_ANSWER_COMMAND_SET_SOURCE;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	}
	case COMMAND_GET_SOURCE:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_GET_SOURCE)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			// TODO measure parameters if necessary
			answer_length = SIZE_ANSWER_COMMAND_GET_SOURCE;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
//			TX_Com_buf_ponter->COMMAND.COMMAND_GET_SOURCE_buf.time = MSGetTime();
			TX_Com_buf_ponter->COMMAND.COMMAND_GET_SOURCE_buf = source_temp_buff;

		}
		break;
	}
	/*
	case COMMAND_SET_CHANNEL:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_SET_CHANNEL)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			//Check parameter bands
			if(RX_Com_buf_ponter->COMMAND.COMMAND_SET_CHANNEL_RD_buf.channel >= PLT_CHANNEL_NUMBER)
			{
				Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAM_OUT_OF_RANGE);
				answer_length 	=	Length_ERROR_TX;
				break;
			}
			plt_tlm_set_channel(RX_Com_buf_ponter->COMMAND.COMMAND_SET_CHANNEL_RD_buf.channel);
			answer_length = SIZE_ANSWER_COMMAND_SET_CHANNEL;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	}
	case COMMAND_PROPERTY_GET_TIME:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_GET_TIME)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_GET_TIME;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_TIME_buf.time = MSGetTime();
		}
		break;
	}
	case COMMAND_PROPERTY_SET_TIME:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_SET_TIME)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			MSSetTime( RX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_SET_TIME_RD_buf.time );
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_SET_TIME;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	}
	case COMMAND_PROPERTY_GET_OSC:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_GET_OSC)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_GET_OSC;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
			plt_cmd_get_osc(TX_Com_buf_ponter);
		}
		break;
	}
	case COMMAND_PROPERTY_SET_ASYNC:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_SET_ASYNC)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			if(cmd_set_async(RX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_SET_ASYNC_RD_buf.async_cmd, RX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_SET_ASYNC_RD_buf.param, RX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_SET_ASYNC_RD_buf.period) == pdFALSE)
			{
				Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_CONFLICT);
				answer_length 	=	Length_ERROR_TX;
				break;
			}
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_SET_ASYNC;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	} */
	case COMMAND_GET_DATA:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_GET_DATA)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{

			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
//			TX_Com_buf_ponter->COMMAND.COMMAND_GET_DATA_buf.time = MSGetTime();
//			for(ii=0;ii<PLT_CHANNEL_NUMBER;ii++)
//			{
//				TX_Com_buf_ponter->COMMAND.COMMAND_GET_DATA_buf.chan[ii].data = 100+ii;				//TODO fill with TLM data
//				TX_Com_buf_ponter->COMMAND.COMMAND_GET_DATA_buf.chan[ii].number = (ii+12) & 0x000F; //TODO fill with TLM ch number
//			}
			answer_length = plt_cmd_get_data(TX_Com_buf_ponter);
			configASSERT((answer_length + 2) <= pmega->len);
		}
		break;
	}
	case COMMAND_PROPERTY_SET_OSC_SOURCE:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_SET_OSC_SOURCE)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			// TODO RX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_SET_OSC_SOURCE_RD_buf.osc_source
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_SET_OSC_SOURCE;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		}
		break;
	}
	case COMMAND_PROPERTY_GET_OSC_SOURCE:
	{
		if(request_length != SIZE_RECEIVE_COMMAND_PROPERTY_GET_OSC_SOURCE)
		{
			Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_PARAMS_SIZE);
			answer_length 	=	Length_ERROR_TX;
		}
		else
		{
			// TODO set parameter
			answer_length = SIZE_ANSWER_COMMAND_PROPERTY_GET_OSC_SOURCE;
			configASSERT((answer_length + 2) <= pmega->len);
			TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
			TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
			TX_Com_buf_ponter->COMMAND.COMMAND_PROPERTY_GET_OSC_SOURCE_buf.osc_source = 0; //TODO osc source
		}
		break;
	}
	case COMMAND_TEST_CAN_TRANSFER:
	{
		answer_length = request_length;
		if(answer_length > 8)
		{
			answer_length -= 2;
		}
		configASSERT((answer_length + 2) <= pmega->len);
		TX_Com_buf_ponter->CmdMarker 		= RX_Com_buf_ponter->CmdMarker;
		TX_Com_buf_ponter->CmdCode 			= RX_Com_buf_ponter->CmdCode;
		for(ii=2; ii<answer_length;ii++)
		{
			p_mrte_buff->buff->data.dU8[ii] = pmega->data[ii];
		}
		break;

	}
	default:
	{
		Prepare_Buf_ERROR(RX_Com_buf_ponter, TX_Com_buf_ponter, ERROR_UNKNOWN_COMMAND);
		answer_length 	=	Length_ERROR_TX;
		break;
	}
	}
	p_mrte_buff->len = answer_length;
	while(request_mrte_send(CAN_SEND_SYNC, p_mrte_buff) == pdFALSE);
}


