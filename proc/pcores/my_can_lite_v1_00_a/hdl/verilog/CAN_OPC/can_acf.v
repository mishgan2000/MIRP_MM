//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_acf.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the CAN Protocol Controller            ////
////  http://www.opencores.org/projects/can/                      ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002, 2003, 2004 Authors                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//// The CAN protocol is developed by Robert Bosch GmbH and       ////
//// protected by patents. Anybody who wants to implement this    ////
//// CAN IP core on silicon has to obtain a CAN protocol license  ////
//// from Bosch.                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.9  2004/05/31 14:46:11  igorm
// Bit acceptance_filter_mode was inverted.
//
// Revision 1.8  2004/02/08 14:16:44  mohor
// Header changed.
//
// Revision 1.7  2003/07/16 13:41:34  mohor
// Fixed according to the linter.
//
// Revision 1.6  2003/02/10 16:02:11  mohor
// CAN is working according to the specification. WB interface and more
// registers (status, IRQ, ...) needs to be added.
//
// Revision 1.5  2003/02/09 18:40:29  mohor
// Overload fixed. Hard synchronization also enabled at the last bit of
// interframe.
//
// Revision 1.4  2003/02/09 02:24:33  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.3  2003/01/31 01:13:37  mohor
// backup.
//
// Revision 1.2  2003/01/14 12:19:35  mohor
// rx_fifo is now working.
//
// Revision 1.1  2003/01/08 02:13:15  mohor
// Acceptance filter added.
//
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "can_defines.v"

module can_acf
( 
  clk,
  rst,

  id,
  
  /* Mode register */
  reset_mode,
  acceptance_filter_mode,

  extended_mode,
  
  acceptance_code_0,
  acceptance_code_1,
  acceptance_code_2,
  acceptance_code_3,
  acceptance_mask_0,
  acceptance_mask_1,
  acceptance_mask_2,
  acceptance_mask_3,
  
  go_rx_crc_lim,
  go_rx_inter,
  go_error_frame,
  
  data0,
  data1,
  rtr1,
  rtr2,
  ide,
  no_byte0,
  no_byte1,
  
  id_ok,
  
  can_acf_dbg,
  
  /* Configure Acceptance Filters */
  wr_acceptance_reg,
  wr_acceptance_code,
  rd_acceptance_code,
  wr_acceptance_addr,
  filtering_in_progress,
  make_filtering,
  filter_number  
);

parameter Tp = 1;
`define 		FILTER_ENA_BIT	31
`define 		EXT_CANID_BIT	30
`define		RTR_BIT				29
`define		STD_CANID_MASK		10:0
`define		EXT_CANID_MASK		28:0

input         clk;
input         rst;
input  [28:0] id;
input         reset_mode;
input         acceptance_filter_mode;
input         extended_mode;

input   [7:0] acceptance_code_0;
input   [7:0] acceptance_code_1;
input   [7:0] acceptance_code_2;
input   [7:0] acceptance_code_3;
input   [7:0] acceptance_mask_0;
input   [7:0] acceptance_mask_1;
input   [7:0] acceptance_mask_2;
input   [7:0] acceptance_mask_3;
input         go_rx_crc_lim;
input         go_rx_inter;
input         go_error_frame;
input   [7:0] data0;
input   [7:0] data1;
input         rtr1;
input         rtr2;
input         ide;
input         no_byte0;
input         no_byte1;

input		wr_acceptance_reg;
input	[31:0]  wr_acceptance_code;
input	[ 5:0]  	wr_acceptance_addr;//64 words => 32 mask and 32 filters for 32 message channels
output	filtering_in_progress;
output	[ 4:0]	filter_number;//the number of accepted message channel
output	[31:0]	rd_acceptance_code;

input	make_filtering;

output        id_ok;

output [7:0] can_acf_dbg;

reg           id_ok;
reg				id_ok_tmp;

wire          match;
wire          match_sf_std;
wire          match_sf_ext;
wire          match_df_std;
wire          match_df_ext;

wire [31:0] rd_filter_code;
wire [31:0] rd_mask_code;

wire [31:0] acceptance_filter_code;
wire [31:0] acceptance_mask_code;

reg [4:0] AcceptanceCodeAddr;
reg [4:0] AcceptanceCodeAddrDff;

reg Dff_make_filtering;
reg [7:0] FilteringStepCnt;
wire makeFilteringStr;
reg FilteringFrame;
reg [4:0] MatchedChannel;

wire filter_matched;
wire match_std;
wire match_ext;

//Fill acceptance filter memory
buff32w32bDualPort FilterMem (
  .a(wr_acceptance_addr[4:0]), // input [4 : 0] a
  .d(wr_acceptance_code), // input [31 : 0] d
  .dpra(AcceptanceCodeAddr), // input [4 : 0] dpra
  .clk(clk), // input clk
  .we(wr_acceptance_reg & (~wr_acceptance_addr[5])), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(rd_filter_code), // output [31 : 0] qspo
  .qdpo(acceptance_filter_code) // output [31 : 0] qdpo
);

buff32w32bDualPort MaskMem (
  .a(wr_acceptance_addr[4:0]), // input [4 : 0] a
  .d(wr_acceptance_code), // input [31 : 0] d
  .dpra(AcceptanceCodeAddr), // input [4 : 0] dpra
  .clk(clk), // input clk
  .we(wr_acceptance_reg & (wr_acceptance_addr[5])), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(rd_mask_code), // output [31 : 0] qspo
  .qdpo(acceptance_mask_code) // output [31 : 0] qdpo
);

//Make filtering by iterating through masks and filters

assign makeFilteringStr = (~Dff_make_filtering) & make_filtering;

//filtering state machine
always @ (posedge clk or posedge rst) 
begin
	if (rst)
	begin
		id_ok_tmp <= 1'b0;
		Dff_make_filtering <= 1'b0;
		FilteringStepCnt <= 8'b0;
		FilteringFrame <= 1'b0;
		AcceptanceCodeAddr <= 5'h00;
		AcceptanceCodeAddrDff <= 5'h00;
		MatchedChannel <= 5'h00;
	end
	else
    begin
		AcceptanceCodeAddrDff <=#Tp  AcceptanceCodeAddr;
		Dff_make_filtering <=#Tp  make_filtering;
		case(FilteringStepCnt)
		8'h00:
		begin
			if(makeFilteringStr)
			begin
				FilteringStepCnt <=#Tp  FilteringStepCnt + 1;
				id_ok_tmp <=#Tp  1'b0;
				MatchedChannel <=#Tp  5'h00;
				FilteringFrame <=#Tp  1'b1;
				AcceptanceCodeAddr <=#Tp  AcceptanceCodeAddr + 1;
			end
			else
			begin
				FilteringStepCnt <=#Tp  FilteringStepCnt;
				MatchedChannel <=#Tp  MatchedChannel;
				id_ok_tmp <=#Tp  id_ok_tmp;
				FilteringFrame <=#Tp  1'b0;
				AcceptanceCodeAddr <=#Tp  AcceptanceCodeAddr;
			end
		end
		8'h01:	//count AcceptanceCodeAddr until filter match or end of memory
		begin
			if(filter_matched)
			begin //filter match occures
				id_ok_tmp <=#Tp  1'b1;
				AcceptanceCodeAddr <=#Tp  0;
				FilteringFrame <=#Tp  FilteringFrame;
				FilteringStepCnt <=#Tp  8'h00;
				MatchedChannel <=#Tp  AcceptanceCodeAddrDff;
			end
			else if(AcceptanceCodeAddr == 8'h1F)
			begin //memory is ended, let us check the last memory cell
				id_ok_tmp <=#Tp  id_ok;
				AcceptanceCodeAddr <=#Tp  8'h00;
				FilteringFrame <=#Tp  FilteringFrame;
				FilteringStepCnt <=#Tp  FilteringStepCnt + 1;
				MatchedChannel <=#Tp  MatchedChannel;
			end
			else
			begin
				id_ok_tmp <=#Tp  id_ok_tmp;
				AcceptanceCodeAddr <=#Tp  AcceptanceCodeAddr + 1;
				FilteringFrame <=#Tp  FilteringFrame;
				FilteringStepCnt <=#Tp  FilteringStepCnt;
				MatchedChannel <=#Tp  MatchedChannel;
			end
		end
		8'h02:	//check the last memory cell
		begin
			if(filter_matched)
			begin //filter match occures
				id_ok_tmp <=#Tp  1'b1;
				AcceptanceCodeAddr <=#Tp  0;
				FilteringFrame <=#Tp  FilteringFrame;
				FilteringStepCnt <=#Tp  8'h00;
				MatchedChannel <=#Tp  AcceptanceCodeAddrDff;
			end
			else 
			begin
				id_ok_tmp <=#Tp  1'b0;
				AcceptanceCodeAddr <=#Tp  0;
				FilteringFrame <=#Tp  1'b0;
				FilteringStepCnt <=#Tp  8'h00;
				MatchedChannel <=#Tp  5'h00;
			end
		end
		default:
		begin
			id_ok_tmp <=#Tp  1'b0;
			AcceptanceCodeAddr <=#Tp  0;
			FilteringFrame <=#Tp  1'b0;
			FilteringStepCnt <=#Tp  8'h00;
			MatchedChannel <=#Tp  5'h00;
		end
		endcase
	end
end

assign filter_matched = acceptance_filter_code[`FILTER_ENA_BIT] ? ( acceptance_filter_code[`EXT_CANID_BIT] ? match_ext : match_std ) : 1'b0;
//
assign match_ext = (& (~(id[`EXT_CANID_MASK] ^ acceptance_filter_code[`EXT_CANID_MASK]) | acceptance_mask_code[`EXT_CANID_MASK])) & ((rtr2 == acceptance_filter_code[`RTR_BIT]) | acceptance_mask_code[`RTR_BIT]);
assign match_std = (& (~(id[`STD_CANID_MASK] ^ acceptance_filter_code[`STD_CANID_MASK]) | acceptance_mask_code[`STD_CANID_MASK])) & ((rtr1 == acceptance_filter_code[`RTR_BIT]) | acceptance_mask_code[`RTR_BIT]);

//OUTPUT SECTION
assign filter_number = MatchedChannel;
assign filtering_in_progress = FilteringFrame;
assign rd_acceptance_code = wr_acceptance_addr[5] ? rd_mask_code : rd_filter_code;
/*
// Working in basic mode. ID match for standard format (11-bit ID).
assign match =        ( (id[3]  == acceptance_code_0[0] | acceptance_mask_0[0] ) &
                        (id[4]  == acceptance_code_0[1] | acceptance_mask_0[1] ) &
                        (id[5]  == acceptance_code_0[2] | acceptance_mask_0[2] ) &
                        (id[6]  == acceptance_code_0[3] | acceptance_mask_0[3] ) &
                        (id[7]  == acceptance_code_0[4] | acceptance_mask_0[4] ) &
                        (id[8]  == acceptance_code_0[5] | acceptance_mask_0[5] ) &
                        (id[9]  == acceptance_code_0[6] | acceptance_mask_0[6] ) &
                        (id[10] == acceptance_code_0[7] | acceptance_mask_0[7] )
                      );


// Working in extended mode. ID match for standard format (11-bit ID). Using single filter.
assign match_sf_std = ( (id[3]  == acceptance_code_0[0] | acceptance_mask_0[0] ) &
                        (id[4]  == acceptance_code_0[1] | acceptance_mask_0[1] ) &
                        (id[5]  == acceptance_code_0[2] | acceptance_mask_0[2] ) &
                        (id[6]  == acceptance_code_0[3] | acceptance_mask_0[3] ) &
                        (id[7]  == acceptance_code_0[4] | acceptance_mask_0[4] ) &
                        (id[8]  == acceptance_code_0[5] | acceptance_mask_0[5] ) &
                        (id[9]  == acceptance_code_0[6] | acceptance_mask_0[6] ) &
                        (id[10] == acceptance_code_0[7] | acceptance_mask_0[7] ) &

                        (rtr1   == acceptance_code_1[4] | acceptance_mask_1[4] ) &
                        (id[0]  == acceptance_code_1[5] | acceptance_mask_1[5] ) &
                        (id[1]  == acceptance_code_1[6] | acceptance_mask_1[6] ) &
                        (id[2]  == acceptance_code_1[7] | acceptance_mask_1[7] ) &

                        (data0[0]  == acceptance_code_2[0] | acceptance_mask_2[0] | no_byte0) &
                        (data0[1]  == acceptance_code_2[1] | acceptance_mask_2[1] | no_byte0) &
                        (data0[2]  == acceptance_code_2[2] | acceptance_mask_2[2] | no_byte0) &
                        (data0[3]  == acceptance_code_2[3] | acceptance_mask_2[3] | no_byte0) &
                        (data0[4]  == acceptance_code_2[4] | acceptance_mask_2[4] | no_byte0) &
                        (data0[5]  == acceptance_code_2[5] | acceptance_mask_2[5] | no_byte0) &
                        (data0[6]  == acceptance_code_2[6] | acceptance_mask_2[6] | no_byte0) &
                        (data0[7]  == acceptance_code_2[7] | acceptance_mask_2[7] | no_byte0) &

                        (data1[0]  == acceptance_code_3[0] | acceptance_mask_3[0] | no_byte1) &
                        (data1[1]  == acceptance_code_3[1] | acceptance_mask_3[1] | no_byte1) &
                        (data1[2]  == acceptance_code_3[2] | acceptance_mask_3[2] | no_byte1) &
                        (data1[3]  == acceptance_code_3[3] | acceptance_mask_3[3] | no_byte1) &
                        (data1[4]  == acceptance_code_3[4] | acceptance_mask_3[4] | no_byte1) &
                        (data1[5]  == acceptance_code_3[5] | acceptance_mask_3[5] | no_byte1) &
                        (data1[6]  == acceptance_code_3[6] | acceptance_mask_3[6] | no_byte1) &
                        (data1[7]  == acceptance_code_3[7] | acceptance_mask_3[7] | no_byte1)
                      );



// Working in extended mode. ID match for extended format (29-bit ID). Using single filter.
assign match_sf_ext = ( (id[21]  == acceptance_code_0[0] | acceptance_mask_0[0] ) &
                        (id[22]  == acceptance_code_0[1] | acceptance_mask_0[1] ) &
                        (id[23]  == acceptance_code_0[2] | acceptance_mask_0[2] ) &
                        (id[24]  == acceptance_code_0[3] | acceptance_mask_0[3] ) &
                        (id[25]  == acceptance_code_0[4] | acceptance_mask_0[4] ) &
                        (id[26]  == acceptance_code_0[5] | acceptance_mask_0[5] ) &
                        (id[27]  == acceptance_code_0[6] | acceptance_mask_0[6] ) &
                        (id[28]  == acceptance_code_0[7] | acceptance_mask_0[7] ) &

                        (id[13]  == acceptance_code_1[0] | acceptance_mask_1[0] ) &
                        (id[14]  == acceptance_code_1[1] | acceptance_mask_1[1] ) &
                        (id[15]  == acceptance_code_1[2] | acceptance_mask_1[2] ) &
                        (id[16]  == acceptance_code_1[3] | acceptance_mask_1[3] ) &
                        (id[17]  == acceptance_code_1[4] | acceptance_mask_1[4] ) &
                        (id[18]  == acceptance_code_1[5] | acceptance_mask_1[5] ) &
                        (id[19]  == acceptance_code_1[6] | acceptance_mask_1[6] ) &
                        (id[20]  == acceptance_code_1[7] | acceptance_mask_1[7] ) &

                        (id[5]  == acceptance_code_2[0] | acceptance_mask_2[0] ) &
                        (id[6]  == acceptance_code_2[1] | acceptance_mask_2[1] ) &
                        (id[7]  == acceptance_code_2[2] | acceptance_mask_2[2] ) &
                        (id[8]  == acceptance_code_2[3] | acceptance_mask_2[3] ) &
                        (id[9]  == acceptance_code_2[4] | acceptance_mask_2[4] ) &
                        (id[10] == acceptance_code_2[5] | acceptance_mask_2[5] ) &
                        (id[11] == acceptance_code_2[6] | acceptance_mask_2[6] ) &
                        (id[12] == acceptance_code_2[7] | acceptance_mask_2[7] ) &

                        (rtr2   == acceptance_code_3[2] | acceptance_mask_3[2] ) &
                        (id[0]  == acceptance_code_3[3] | acceptance_mask_3[3] ) &
                        (id[1]  == acceptance_code_3[4] | acceptance_mask_3[4] ) &
                        (id[2]  == acceptance_code_3[5] | acceptance_mask_3[5] ) &
                        (id[3]  == acceptance_code_3[6] | acceptance_mask_3[6] ) &
                        (id[4]  == acceptance_code_3[7] | acceptance_mask_3[7] )

                      );


// Working in extended mode. ID match for standard format (11-bit ID). Using double filter.
assign match_df_std = (((id[3]  == acceptance_code_0[0] | acceptance_mask_0[0] ) &
                        (id[4]  == acceptance_code_0[1] | acceptance_mask_0[1] ) &
                        (id[5]  == acceptance_code_0[2] | acceptance_mask_0[2] ) &
                        (id[6]  == acceptance_code_0[3] | acceptance_mask_0[3] ) &
                        (id[7]  == acceptance_code_0[4] | acceptance_mask_0[4] ) &
                        (id[8]  == acceptance_code_0[5] | acceptance_mask_0[5] ) &
                        (id[9]  == acceptance_code_0[6] | acceptance_mask_0[6] ) &
                        (id[10] == acceptance_code_0[7] | acceptance_mask_0[7] ) &

                        (rtr1   == acceptance_code_1[4] | acceptance_mask_1[4] ) &
                        (id[0]  == acceptance_code_1[5] | acceptance_mask_1[5] ) &
                        (id[1]  == acceptance_code_1[6] | acceptance_mask_1[6] ) &
                        (id[2]  == acceptance_code_1[7] | acceptance_mask_1[7] ) &

                        (data0[0] == acceptance_code_3[0] | acceptance_mask_3[0] | no_byte0) &
                        (data0[1] == acceptance_code_3[1] | acceptance_mask_3[1] | no_byte0) &
                        (data0[2] == acceptance_code_3[2] | acceptance_mask_3[2] | no_byte0) &
                        (data0[3] == acceptance_code_3[3] | acceptance_mask_3[3] | no_byte0) &
                        (data0[4] == acceptance_code_1[0] | acceptance_mask_1[0] | no_byte0) &
                        (data0[5] == acceptance_code_1[1] | acceptance_mask_1[1] | no_byte0) &
                        (data0[6] == acceptance_code_1[2] | acceptance_mask_1[2] | no_byte0) &
                        (data0[7] == acceptance_code_1[3] | acceptance_mask_1[3] | no_byte0) )
                        
                       |

                       ((id[3]  == acceptance_code_2[0] | acceptance_mask_2[0] ) &
                        (id[4]  == acceptance_code_2[1] | acceptance_mask_2[1] ) &
                        (id[5]  == acceptance_code_2[2] | acceptance_mask_2[2] ) &
                        (id[6]  == acceptance_code_2[3] | acceptance_mask_2[3] ) &
                        (id[7]  == acceptance_code_2[4] | acceptance_mask_2[4] ) &
                        (id[8]  == acceptance_code_2[5] | acceptance_mask_2[5] ) &
                        (id[9]  == acceptance_code_2[6] | acceptance_mask_2[6] ) &
                        (id[10] == acceptance_code_2[7] | acceptance_mask_2[7] ) &

                        (rtr1   == acceptance_code_3[4] | acceptance_mask_3[4] ) &
                        (id[0]  == acceptance_code_3[5] | acceptance_mask_3[5] ) &
                        (id[1]  == acceptance_code_3[6] | acceptance_mask_3[6] ) &
                        (id[2]  == acceptance_code_3[7] | acceptance_mask_3[7] ) )

                      );


// Working in extended mode. ID match for extended format (29-bit ID). Using double filter.
assign match_df_ext = (((id[21]  == acceptance_code_0[0] | acceptance_mask_0[0] ) &
                        (id[22]  == acceptance_code_0[1] | acceptance_mask_0[1] ) &
                        (id[23]  == acceptance_code_0[2] | acceptance_mask_0[2] ) &
                        (id[24]  == acceptance_code_0[3] | acceptance_mask_0[3] ) &
                        (id[25]  == acceptance_code_0[4] | acceptance_mask_0[4] ) &
                        (id[26]  == acceptance_code_0[5] | acceptance_mask_0[5] ) &
                        (id[27]  == acceptance_code_0[6] | acceptance_mask_0[6] ) &
                        (id[28]  == acceptance_code_0[7] | acceptance_mask_0[7] ) &

                        (id[13]  == acceptance_code_1[0] | acceptance_mask_1[0] ) &
                        (id[14]  == acceptance_code_1[1] | acceptance_mask_1[1] ) &
                        (id[15]  == acceptance_code_1[2] | acceptance_mask_1[2] ) &
                        (id[16]  == acceptance_code_1[3] | acceptance_mask_1[3] ) &
                        (id[17]  == acceptance_code_1[4] | acceptance_mask_1[4] ) &
                        (id[18]  == acceptance_code_1[5] | acceptance_mask_1[5] ) &
                        (id[19]  == acceptance_code_1[6] | acceptance_mask_1[6] ) &
                        (id[20]  == acceptance_code_1[7] | acceptance_mask_1[7] ) )
                        
                       |
                        
                       ((id[21]  == acceptance_code_2[0] | acceptance_mask_2[0] ) &
                        (id[22]  == acceptance_code_2[1] | acceptance_mask_2[1] ) &
                        (id[23]  == acceptance_code_2[2] | acceptance_mask_2[2] ) &
                        (id[24]  == acceptance_code_2[3] | acceptance_mask_2[3] ) &
                        (id[25]  == acceptance_code_2[4] | acceptance_mask_2[4] ) &
                        (id[26]  == acceptance_code_2[5] | acceptance_mask_2[5] ) &
                        (id[27]  == acceptance_code_2[6] | acceptance_mask_2[6] ) &
                        (id[28]  == acceptance_code_2[7] | acceptance_mask_2[7] ) &

                        (id[13]  == acceptance_code_3[0] | acceptance_mask_3[0] ) &
                        (id[14]  == acceptance_code_3[1] | acceptance_mask_3[1] ) &
                        (id[15]  == acceptance_code_3[2] | acceptance_mask_3[2] ) &
                        (id[16]  == acceptance_code_3[3] | acceptance_mask_3[3] ) &
                        (id[17]  == acceptance_code_3[4] | acceptance_mask_3[4] ) &
                        (id[18]  == acceptance_code_3[5] | acceptance_mask_3[5] ) &
                        (id[19]  == acceptance_code_3[6] | acceptance_mask_3[6] ) &
                        (id[20]  == acceptance_code_3[7] | acceptance_mask_3[7] ) )
                      );


*/
// ID ok signal generation
always @ (posedge clk or posedge rst)
begin
  if (rst)
    id_ok <= 1'b0;
  else if (go_rx_crc_lim)                   // sample_point is already included in go_rx_crc_lim
    begin
      id_ok <=#Tp id_ok_tmp;
    end
  else if (reset_mode | go_rx_inter | go_error_frame)        // sample_point is already included in go_rx_inter
    id_ok <=#Tp 1'b0;
end

assign can_acf_dbg = {make_filtering, id_ok, id_ok_tmp, reset_mode, go_rx_inter, go_error_frame, filter_matched, FilteringFrame};

endmodule
