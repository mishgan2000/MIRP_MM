//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_fifo.v                                                  ////
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
// Revision 1.27  2004/11/18 12:39:34  igorm
// Fixes for compatibility after the SW reset.
//
// Revision 1.26  2004/02/08 14:30:57  mohor
// Header changed.
//
// Revision 1.25  2003/10/23 16:52:17  mohor
// Active high/low problem when Altera devices are used. Bug fixed by
// Rojhalat Ibrahim.
//
// Revision 1.24  2003/10/17 05:55:20  markom
// mbist signals updated according to newest convention
//
// Revision 1.23  2003/09/05 12:46:41  mohor
// ALTERA_RAM supported.
//
// Revision 1.22  2003/08/20 09:59:16  mohor
// Artisan RAM fixed (when not using BIST).
//
// Revision 1.21  2003/08/14 16:04:52  simons
// Artisan ram instances added.
//
// Revision 1.20  2003/07/16 14:00:45  mohor
// Fixed according to the linter.
//
// Revision 1.19  2003/07/03 09:30:44  mohor
// PCI_BIST replaced with CAN_BIST.
//
// Revision 1.18  2003/06/27 22:14:23  simons
// Overrun fifo implemented with FFs, because it is not possible to create such a memory.
//
// Revision 1.17  2003/06/27 20:56:15  simons
// Virtual silicon ram instances added.
//
// Revision 1.16  2003/06/18 23:03:44  mohor
// Typo fixed.
//
// Revision 1.15  2003/06/11 09:37:05  mohor
// overrun and length_info fifos are initialized at the end of reset.
//
// Revision 1.14  2003/03/05 15:02:30  mohor
// Xilinx RAM added.
//
// Revision 1.13  2003/03/01 22:53:33  mohor
// Actel APA ram supported.
//
// Revision 1.12  2003/02/19 14:44:03  mohor
// CAN core finished. Host interface added. Registers finished.
// Synchronization to the wishbone finished.
//
// Revision 1.11  2003/02/14 20:17:01  mohor
// Several registers added. Not finished, yet.
//
// Revision 1.10  2003/02/11 00:56:06  mohor
// Wishbone interface added.
//
// Revision 1.9  2003/02/09 02:24:33  mohor
// Bosch license warning added. Error counters finished. Overload frames
// still need to be fixed.
//
// Revision 1.8  2003/01/31 01:13:38  mohor
// backup.
//
// Revision 1.7  2003/01/17 17:44:31  mohor
// Fifo corrected to be synthesizable.
//
// Revision 1.6  2003/01/15 13:16:47  mohor
// When a frame with "remote request" is received, no data is stored
// to fifo, just the frame information (identifier, ...). Data length
// that is stored is the received data length and not the actual data
// length that is stored to fifo.
//
// Revision 1.5  2003/01/14 17:25:09  mohor
// Addresses corrected to decimal values (previously hex).
//
// Revision 1.4  2003/01/14 12:19:35  mohor
// rx_fifo is now working.
//
// Revision 1.3  2003/01/09 21:54:45  mohor
// rx fifo added. Not 100 % verified, yet.
//
// Revision 1.2  2003/01/09 14:46:58  mohor
// Temporary files (backup).
//
// Revision 1.1  2003/01/08 02:10:55  mohor
// Acceptance filter added.
//
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "can_defines.v"

module can_fifo
( 
  clk,
  rst,

  wr,
  data_in,
  
  addr,
  data_out,
  fifo_selected,
  reading_data,

  reset_mode,
  release_buffer,
  extended_mode,
  overrun,
  info_empty,
  info_cnt,
  fifo_info_size

`ifdef CAN_BIST
  ,
  mbist_si_i,
  mbist_so_o,
  mbist_ctrl_i
`endif
);

parameter 	Tp = 1;
parameter 	RX_FIFO_BRAM_NUM 	= 1;

localparam	RX_FIFO_SIZE_BASE		= (RX_FIFO_BRAM_NUM == 0) ? (6) : (1 * 11);//(RX_FIFO_BRAM_NUM * 11);
localparam	RX_FIFO_SIZE_IN_BYTES 	= (RX_FIFO_BRAM_NUM == 0) ? (64) : (1 * 2048);//(RX_FIFO_BRAM_NUM * 2048);

localparam INFO_CNT_WDTH 		= (RX_FIFO_SIZE_BASE - 3);
localparam INFO_FULL_LEVEL 		= (RX_FIFO_SIZE_IN_BYTES/16);
localparam FIFO_RW_ADDR_WDTH	= (RX_FIFO_SIZE_BASE);


input         clk;
input         rst;
input         wr;
input   [7:0] data_in;
input   [5:0] addr;
input         reset_mode;
input         release_buffer;
input         extended_mode;
input         fifo_selected;

//output  [7:0] data_out;
output  [31:0] data_out;//Modified 2017-04-18
output        overrun;
output        info_empty;
output  [31:0] info_cnt;
output 	[31:0] fifo_info_size;

output		reading_data;

`ifdef CAN_BIST
input         mbist_si_i;
output        mbist_so_o;
input [`CAN_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;       // bist chain shift control
wire          mbist_s_0;
`endif

//`ifdef ALTERA_RAM
//`else
//`ifdef ACTEL_APA_RAM
//`else
//`ifdef XILINX_RAM
//`else
//`ifdef ARTISAN_RAM
//  reg           overrun_info[0:63];
//`else
//`ifdef VIRTUALSILICON_RAM
//  reg           overrun_info[0:63];
//`else
//  reg     [7:0] fifo [0:63];
//  reg     [3:0] length_fifo[0:63];
//  reg           overrun_info[0:63];
//`endif
//`endif
//`endif
//`endif
//`endif

reg     [FIFO_RW_ADDR_WDTH-1:0] rd_pointer;
reg     [FIFO_RW_ADDR_WDTH-1:0] wr_pointer;
reg     [FIFO_RW_ADDR_WDTH-1:0] read_address;
//reg     [5:0] wr_info_pointer;
//reg     [5:0] rd_info_pointer;
reg           wr_q;
//reg     [4:0] len_cnt;
reg     [FIFO_RW_ADDR_WDTH:0] fifo_cnt;
reg     [INFO_CNT_WDTH-1:0] info_cnt_reg;
reg           latch_overrun;
//reg           initialize_memories;

wire    [4:0] length_info;
wire          write_length_info;
wire          fifo_empty;
wire          fifo_full;
wire          info_full;

assign write_length_info = (~wr) & wr_q;

// Delayed write signal
always @ (posedge clk or posedge rst)
begin
  if (rst)
    wr_q <=#Tp 1'b0;
  else if (reset_mode)
    wr_q <=#Tp 1'b0;
  else
    wr_q <=#Tp wr;
end


//// length counter
//always @ (posedge clk or posedge rst)
//begin
//  if (rst)
//    len_cnt <= 5'h0;
//  else if (reset_mode | write_length_info)
//    len_cnt <=#Tp 5'h0;
//  else if (wr & (~fifo_full))
//    len_cnt <=#Tp len_cnt + 1'b1;
//end


//// wr_info_pointer
//always @ (posedge clk or posedge rst)
//begin
//  if (rst)
//    wr_info_pointer <= 6'h0;
//  else if (write_length_info & (~info_full) | initialize_memories)
//    wr_info_pointer <=#Tp wr_info_pointer + 1'b1;
//  else if (reset_mode)
//    wr_info_pointer <=#Tp rd_info_pointer;
//end



//// rd_info_pointer
//always @ (posedge clk or posedge rst)
//begin
//  if (rst)
//    rd_info_pointer <= 6'h0;
//  else if (release_buffer & (~info_full))
//    rd_info_pointer <=#Tp rd_info_pointer + 1'b1;
//end


// rd_pointer
always @ (posedge clk or posedge rst)
begin
  if (rst)
    rd_pointer <= {(FIFO_RW_ADDR_WDTH){1'b0}};
  else if (release_buffer & (~fifo_empty))
    rd_pointer <=#Tp rd_pointer + {{(FIFO_RW_ADDR_WDTH-5){1'b0}}, length_info};
end


// wr_pointer
always @ (posedge clk or posedge rst)
begin
  if (rst)
    wr_pointer <= {(FIFO_RW_ADDR_WDTH){1'b0}};
  else if (reset_mode)
    wr_pointer <=#Tp rd_pointer;
  else if (wr & (~fifo_full))
    wr_pointer <=#Tp wr_pointer + 1'b1;
end


// latch_overrun
always @ (posedge clk or posedge rst)
begin
  if (rst)
    latch_overrun <= 1'b0;
  else if (reset_mode | write_length_info)
    latch_overrun <=#Tp 1'b0;
  else if (wr & fifo_full)
    latch_overrun <=#Tp 1'b1;
end


// Counting data in fifo
always @ (posedge clk or posedge rst)
begin
  if (rst)
    fifo_cnt <= {(FIFO_RW_ADDR_WDTH+1){1'b0}};
  else if (reset_mode)
    fifo_cnt <=#Tp {(FIFO_RW_ADDR_WDTH+1){1'b0}};
  else if (wr & (~release_buffer) & (~fifo_full))
    fifo_cnt <=#Tp fifo_cnt + 1'b1;
  else if ((~wr) & release_buffer & (~fifo_empty))
    fifo_cnt <=#Tp fifo_cnt - {{(FIFO_RW_ADDR_WDTH-4){1'b0}}, length_info};
  else if (wr & release_buffer & (~fifo_full) & (~fifo_empty))
    fifo_cnt <=#Tp fifo_cnt - {{(FIFO_RW_ADDR_WDTH-4){1'b0}}, length_info} + 1'b1;
end

assign fifo_full = 	(fifo_cnt == RX_FIFO_SIZE_IN_BYTES);
assign fifo_empty = (fifo_cnt == {(FIFO_RW_ADDR_WDTH+1){1'b0}});


// Counting data in length_fifo and overrun_info fifo
always @ (posedge clk or posedge rst)
begin
  if (rst)
    info_cnt_reg <=#Tp {(INFO_CNT_WDTH){1'b0}};
  else if (reset_mode)
    info_cnt_reg <=#Tp {(INFO_CNT_WDTH){1'b0}};
  else if (write_length_info ^ release_buffer)
    begin
      if (release_buffer & (~info_empty))
        info_cnt_reg <=#Tp info_cnt_reg - 1'b1;
      else if (write_length_info & (~info_full))
        info_cnt_reg <=#Tp info_cnt_reg + 1'b1;
    end
end
        
assign info_full = (info_cnt_reg == INFO_FULL_LEVEL);
assign info_empty = (info_cnt_reg == {(INFO_CNT_WDTH){1'b0}});
assign info_cnt = {{(32-INFO_CNT_WDTH){1'b0}}, info_cnt_reg};
assign fifo_info_size = {{(32-INFO_CNT_WDTH){1'b0}}, INFO_FULL_LEVEL};
// Added 2017-04-18
// Selecting which address will be used for reading data from rx fifo
//make 4 readings
wire 	[7:0] 	data_d8_out;
wire 	[31:0]	data_d32_tmp_out;
reg		[5:0]	data_rd_counter;
//
reg		[31:0]	data_d32_out;
reg		fifo_reading_frame;
reg		fifo_selected_dff;
wire	fifo_selected_str;

assign fifo_selected_str = (~fifo_selected_dff) & ( fifo_selected);


generate
    if(RX_FIFO_BRAM_NUM == 0)
	begin
	
		reg		[5:0]	addr_tmp;
		
		assign data_d8_out = data_d32_tmp_out[7:0];
	
		always @ (posedge clk or posedge rst)
		begin
			if (rst)
			begin
				fifo_selected_dff <= 0;
				data_rd_counter <= 6'b0;
				fifo_reading_frame <= 0;
				data_d32_out <= 0;
			end
			else 
			begin
				fifo_selected_dff <=#Tp  fifo_selected;
				case(data_rd_counter)
				6'h00:
				begin
					if(fifo_selected_str)
					begin
						addr_tmp <=#Tp  6'b0;
						data_rd_counter <=#Tp  data_rd_counter + 1;
						fifo_reading_frame <=#Tp  1;
						data_d32_out <=#Tp  data_d32_out;
					end
					else
					begin
						addr_tmp <=#Tp 6'b0;
						data_rd_counter <=#Tp 6'h00;
						fifo_reading_frame <=#Tp 0;
						data_d32_out <=#Tp data_d32_out;
					end
				end
				6'h01:
				begin
					addr_tmp <=#Tp addr_tmp + 1;
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
				end
				6'h02:
				begin
					data_d32_out[ 7: 0] <=#Tp data_d8_out;
					data_d32_out[31: 8] <=#Tp data_d32_out[31: 8];
					addr_tmp <=#Tp addr_tmp + 1;
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
				end
				6'h03:
				begin
					data_d32_out[ 7: 0] <=#Tp data_d32_out[ 7: 0];
					data_d32_out[15: 8] <=#Tp data_d8_out;
					data_d32_out[31:16] <=#Tp data_d32_out[31:16];
					addr_tmp <=#Tp addr_tmp + 1;
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
				end
				6'h04:
				begin
					data_d32_out[15: 0] <=#Tp data_d32_out[15: 0];
					data_d32_out[23:16] <=#Tp data_d8_out;
					data_d32_out[31:24] <=#Tp data_d32_out[31:24];
					addr_tmp <=#Tp 0;
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;	
				end
				6'h05:
				begin
					data_d32_out[23: 0] <=#Tp data_d32_out[23: 0];
					data_d32_out[31:24] <=#Tp data_d8_out;
					addr_tmp <=#Tp 0;
					data_rd_counter <=#Tp 0;
					fifo_reading_frame <=#Tp 0;
				end
				default:
				begin
					addr_tmp <=#Tp 6'b0;
					data_rd_counter <=#Tp 6'h00;
					fifo_reading_frame <=#Tp 0;
					data_d32_out <=#Tp data_d32_out;
				end
				endcase
			end
		end
		
		always @ (extended_mode or rd_pointer or addr or addr_tmp)
		begin
		if (extended_mode)      // extended mode
			read_address = rd_pointer + (addr - 12'd16) + addr_tmp;
		else                    // normal mode
			read_address = rd_pointer + (addr - 12'd20) + addr_tmp;
		end
	
	end
	else
	begin
	
		always @ (posedge clk or posedge rst)
		begin
			if (rst)
			begin
				fifo_selected_dff <= 0;
				data_rd_counter <= 6'b0;
				fifo_reading_frame <= 0;
				data_d32_out <= 0;
			end
			else 
			begin
				fifo_selected_dff <=#Tp  fifo_selected;
				case(data_rd_counter)
				6'h00:
				begin
					if(fifo_selected_str)
					begin
						data_rd_counter <=#Tp  data_rd_counter + 1;
						fifo_reading_frame <=#Tp  1;
						data_d32_out <=#Tp  data_d32_out;
					end
					else
					begin
						data_rd_counter <=#Tp 6'h00;
						fifo_reading_frame <=#Tp 0;
						data_d32_out <=#Tp data_d32_out;
					end
				end
				6'h01:
				begin
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
					data_d32_out <=#Tp data_d32_out;
				end
				6'h02:
				begin
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
					data_d32_out <=#Tp data_d32_out;
				end
				6'h03:
				begin
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
					data_d32_out <=#Tp data_d32_out;
				end
				6'h04:
				begin
					data_rd_counter <=#Tp data_rd_counter + 1;
					fifo_reading_frame <=#Tp fifo_reading_frame;
					data_d32_out <=#Tp data_d32_out;
				end
				6'h05:
				begin
					data_rd_counter <=#Tp 6'h00;
					fifo_reading_frame <=#Tp 0;
					data_d32_out <=#Tp data_d32_tmp_out;
				end
				default:
				begin
					data_rd_counter <=#Tp 6'h00;
					fifo_reading_frame <=#Tp 0;
					data_d32_out <=#Tp data_d32_out;
				end
				endcase
			end
		end
		
		always @ (extended_mode or rd_pointer or addr)
		begin
		if (extended_mode)      // extended mode
			read_address = rd_pointer + ({{(FIFO_RW_ADDR_WDTH-6){1'b0}}, addr} - 'd16);
		else                    // normal mode
			read_address = rd_pointer + ({{(FIFO_RW_ADDR_WDTH-6){1'b0}}, addr} - 'd20);
		end
	
	end
endgenerate



assign data_out = data_d32_out;
assign reading_data = ~fifo_reading_frame;

// always @ (extended_mode or rd_pointer or addr)
// begin
  // if (extended_mode)      // extended mode
    // read_address = rd_pointer + (addr - 6'd16);
  // else                    // normal mode
    // read_address = rd_pointer + (addr - 6'd20);
// end


//always @ (posedge clk or posedge rst)
//begin
//  if (rst)
//    initialize_memories <= 1'b1;
//  else if (&wr_info_pointer)
//    initialize_memories <=#Tp 1'b0;
//end


//`ifdef ALTERA_RAM
////  altera_ram_64x8_sync fifo
//  lpm_ram_dp fifo
//  (
//    .q         (data_out),
//    .rdclock   (clk),
//    .wrclock   (clk),
//    .data      (data_in),
//    .wren      (wr & (~fifo_full)),
//    .rden      (fifo_selected),
//    .wraddress (wr_pointer),
//    .rdaddress (read_address[10:2])
//  );
//  defparam fifo.lpm_width = 8;
//  defparam fifo.lpm_widthad = 6;
//  defparam fifo.lpm_numwords = 64;
//
//
////  altera_ram_64x4_sync info_fifo
//  lpm_ram_dp info_fifo
//  (
//    .q         (length_info),
//    .rdclock   (clk),
//    .wrclock   (clk),
//    .data      (len_cnt & {5{~initialize_memories}}),
//    .wren      (write_length_info & (~info_full) | initialize_memories),
//    .wraddress (wr_info_pointer),
//    .rdaddress (rd_info_pointer)
//  );
//  defparam info_fifo.lpm_width = 5;
//  defparam info_fifo.lpm_widthad = 6;
//  defparam info_fifo.lpm_numwords = 64;
//
//
////  altera_ram_64x1_sync overrun_fifo
//  lpm_ram_dp overrun_fifo
//  (
//    .q         (overrun),
//    .rdclock   (clk),
//    .wrclock   (clk),
//    .data      ((latch_overrun | (wr & fifo_full)) & (~initialize_memories)),
//    .wren      (write_length_info & (~info_full) | initialize_memories),
//    .wraddress (wr_info_pointer),
//    .rdaddress (rd_info_pointer)
//  );
//  defparam overrun_fifo.lpm_width = 1;
//  defparam overrun_fifo.lpm_widthad = 6;
//  defparam overrun_fifo.lpm_numwords = 64;
//
//`else
//`ifdef ACTEL_APA_RAM
//  actel_ram_64x8_sync fifo
//  (
//    .DO      (data_out),
//    .RCLOCK  (clk),
//    .WCLOCK  (clk),
//    .DI      (data_in),
//    .PO      (),                       // parity not used
//    .WRB     (~(wr & (~fifo_full))),
//    .RDB     (~fifo_selected),
//    .WADDR   (wr_pointer),
//    .RADDR   (read_address)
//  );
//
//
//  actel_ram_64x4_sync info_fifo
//  (
//    .DO      (length_info),
//    .RCLOCK  (clk),
//    .WCLOCK  (clk),
//    .DI      (len_cnt & {5{~initialize_memories}}),
//    .PO      (),                       // parity not used
//    .WRB     (~(write_length_info & (~info_full) | initialize_memories)),
//    .RDB     (1'b0),                   // always enabled
//    .WADDR   (wr_info_pointer),
//    .RADDR   (rd_info_pointer)
//  );
//
//
//  actel_ram_64x1_sync overrun_fifo
//  (
//    .DO      (overrun),
//    .RCLOCK  (clk),
//    .WCLOCK  (clk),
//    .DI      ((latch_overrun | (wr & fifo_full)) & (~initialize_memories)),
//    .PO      (),                       // parity not used
//    .WRB     (~(write_length_info & (~info_full) | initialize_memories)),
//    .RDB     (1'b0),                   // always enabled
//    .WADDR   (wr_info_pointer),
//    .RADDR   (rd_info_pointer)
//  );
//`else
`ifdef XILINX_RAM

//spartan6_ramb4_s8_s8
//#(
//	.wdth(8)
//)
//fifo
//(
//	.doa(),
//	.dob(data_d8_out),//.dob(data_out),
//	//
//	.addra({3'h0, wr_pointer}),
//	.addrb({3'h0, read_address}),
//	.clka(clk),
//	.clkb(clk),
//	.dia(data_in),
//	.dib(8'h0),
//	.ena(1'b1),
//	.enb(1'b1),
//	.rsta(1'b0),
//	.rstb(1'b0),
//	.wea(wr & (~fifo_full)),
//	.web(1'b0)	
//);

//generate
//    if(RX_FIFO_SIZE_BASE == 0)
        // instantiate a CLA multiplier
//    else
        
//endgenerate

spartan6_ramb4_s8_s8
#(
	.size_base(RX_FIFO_SIZE_BASE)
)
fifo_rx_inst
(
	.dob(data_d32_tmp_out),
	.addra(wr_pointer),
	.addrb(read_address),
	.clk(clk),
	.dia(data_in),
	.wea(wr & (~fifo_full))
);

//generate
//    if(RX_FIFO_SIZE_BASE == 0)
//	begin
//        		
//		slicebuf8b512wDualPort
//		BRAM_BUFF(
//			.a(wr_pointer),
//			.d(data_in),
//			.dpra(addrb),
//			.clk(clk),
//			.we(wr & (~fifo_full)),
//			.qdpo_clk(clk),
//			//.qspo(doa),
//			.qdpo(data_d8_out)
//		);
//		
//	end
//    else
//	begin
//	
////	BLK_MEM_GEN_V7_3 #(
////		.C_ADDRA_WIDTH(RX_FIFO_SIZE_BASE),
////		.C_ADDRB_WIDTH(RX_FIFO_SIZE_BASE-2),
////		.C_ALGORITHM(1),
////		.C_AXI_ID_WIDTH(4),
////		.C_AXI_SLAVE_TYPE(0),
////		.C_AXI_TYPE(1),
////		.C_BYTE_SIZE(9),
////		.C_COMMON_CLK(1),
////		.C_DEFAULT_DATA("0"),
////		.C_DISABLE_WARN_BHV_COLL(0),
////		.C_DISABLE_WARN_BHV_RANGE(0),
////		.C_ENABLE_32BIT_ADDRESS(0),
////		.C_FAMILY("spartan6"),
////		.C_HAS_AXI_ID(0),
////		.C_HAS_ENA(0),
////		.C_HAS_ENB(0),
////		.C_HAS_INJECTERR(0),
////		.C_HAS_MEM_OUTPUT_REGS_A(0),
////		.C_HAS_MEM_OUTPUT_REGS_B(0),
////		.C_HAS_MUX_OUTPUT_REGS_A(0),
////		.C_HAS_MUX_OUTPUT_REGS_B(0),
////		.C_HAS_REGCEA(0),
////		.C_HAS_REGCEB(0),
////		.C_HAS_RSTA(0),
////		.C_HAS_RSTB(0),
////		.C_HAS_SOFTECC_INPUT_REGS_A(0),
////		.C_HAS_SOFTECC_OUTPUT_REGS_B(0),
////		.C_INIT_FILE("BlankString"),
////		.C_INIT_FILE_NAME("no_coe_file_loaded"),
////		.C_INITA_VAL("0"),
////		.C_INITB_VAL("0"),
////		.C_INTERFACE_TYPE(0),
////		.C_LOAD_INIT_FILE(0),
////		.C_MEM_TYPE(1),
////		.C_MUX_PIPELINE_STAGES(0),
////		.C_PRIM_TYPE(1),
////		.C_READ_DEPTH_A(RX_FIFO_SIZE_IN_BYTES),
////		.C_READ_DEPTH_B(RX_FIFO_SIZE_IN_BYTES/4),
////		.C_READ_WIDTH_A(8),
////		.C_READ_WIDTH_B(32),
////		.C_RST_PRIORITY_A("CE"),
////		.C_RST_PRIORITY_B("CE"),
////		.C_RST_TYPE("SYNC"),
////		.C_RSTRAM_A(0),
////		.C_RSTRAM_B(0),
////		.C_SIM_COLLISION_CHECK("ALL"),
////		.C_USE_BRAM_BLOCK(0),
////		.C_USE_BYTE_WEA(0),
////		.C_USE_BYTE_WEB(0),
////		.C_USE_DEFAULT_DATA(0),
////		.C_USE_ECC(0),
////		.C_USE_SOFTECC(0),
////		.C_WEA_WIDTH(1),
////		.C_WEB_WIDTH(1),
////		.C_WRITE_DEPTH_A(RX_FIFO_SIZE_IN_BYTES),
////		.C_WRITE_DEPTH_B(RX_FIFO_SIZE_IN_BYTES/4),
////		.C_WRITE_MODE_A("READ_FIRST"),
////		.C_WRITE_MODE_B("READ_FIRST"),
////		.C_WRITE_WIDTH_A(8),
////		.C_WRITE_WIDTH_B(32),
////		.C_XDEVICEFAMILY("spartan6")
////	)
////	inst_fifo_rx (
////		.CLKA(clk),
////		.WEA(wr & (~fifo_full)),
////		.ADDRA(wr_pointer),
////		.DINA(data_in),
////		.CLKB(clk),
////		.ADDRB(read_address[FIFO_RW_ADDR_WDTH-1:2]),
////		.DOUTB(data_d32_tmp_out),
////		.RSTA(),
////		.ENA(),
////		.REGCEA(),
////		.DOUTA(),
////		.RSTB(),
////		.ENB(),
////		.REGCEB(),
////		.WEB(),
////		.DINB(),
////		.INJECTSBITERR(),
////		.INJECTDBITERR(),
////		.SBITERR(),
////		.DBITERR(),
////		.RDADDRECC(),
////		.S_ACLK(),
////		.S_ARESETN(),
////		.S_AXI_AWID(),
////		.S_AXI_AWADDR(),
////		.S_AXI_AWLEN(),
////		.S_AXI_AWSIZE(),
////		.S_AXI_AWBURST(),
////		.S_AXI_AWVALID(),
////		.S_AXI_AWREADY(),
////		.S_AXI_WDATA(),
////		.S_AXI_WSTRB(),
////		.S_AXI_WLAST(),
////		.S_AXI_WVALID(),
////		.S_AXI_WREADY(),
////		.S_AXI_BID(),
////		.S_AXI_BRESP(),
////		.S_AXI_BVALID(),
////		.S_AXI_BREADY(),
////		.S_AXI_ARID(),
////		.S_AXI_ARADDR(),
////		.S_AXI_ARLEN(),
////		.S_AXI_ARSIZE(),
////		.S_AXI_ARBURST(),
////		.S_AXI_ARVALID(),
////		.S_AXI_ARREADY(),
////		.S_AXI_RID(),
////		.S_AXI_RDATA(),
////		.S_AXI_RRESP(),
////		.S_AXI_RLAST(),
////		.S_AXI_RVALID(),
////		.S_AXI_RREADY(),
////		.S_AXI_INJECTSBITERR(),
////		.S_AXI_INJECTDBITERR(),
////		.S_AXI_SBITERR(),
////		.S_AXI_DBITERR(),
////		.S_AXI_RDADDRECC()
////	);
//		// BRAM MEM
//		bram_buff_8bin_32bout_2kB
//		BRAM_BUFF(
//			.clka(clk),
//			.wea(wr & (~fifo_full)),
//			.addra(wr_pointer),//TODO
//			.dina(data_in),//8bits
//			.clkb(clk),
//			.addrb(read_address[FIFO_RW_ADDR_WDTH-1:2]),//TODO
//			.doutb(data_d32_tmp_out) //32 bits
//		);
//	end
//	
//endgenerate


//  RAMB4_S8_S8 fifo
//  (
//    .DOA(),
//    .DOB(data_out),
//    .ADDRA({3'h0, wr_pointer}),
//    .CLKA(clk),
//    .DIA(data_in),
//    .ENA(1'b1),
//    .RSTA(1'b0),
//    .WEA(wr & (~fifo_full)),
//    .ADDRB({3'h0, read_address}),
//    .CLKB(clk),
//    .DIB(8'h0),
//    .ENB(1'b1),
//    .RSTB(1'b0),
//    .WEB(1'b0)
//  );

/* spartan6_ramb4_s8_s8
#(
	.wdth(5)
)
info_fifo
(
	.doa(),
	.dob(length_info),
	//
	.addra({4'h0, wr_info_pointer}),
	.addrb({4'h0, rd_info_pointer}),
	.clka(clk),
	.clkb(clk),
	.dia(len_cnt & {5{~initialize_memories}}),
	.dib(8'h0),
	.ena(1'b1),
	.enb(1'b1),
	.rsta(1'b0),
	.rstb(1'b0),
	.wea(write_length_info & (~info_full) | initialize_memories),
	.web(1'b0)	
); */

assign length_info = 5'd16;

//
//  RAMB4_S4_S4 info_fifo
//  (
//    .DOA(),
//    .DOB(length_info),
//    .ADDRA({4'h0, wr_info_pointer}),
//    .CLKA(clk),
//    .DIA(len_cnt & {4{~initialize_memories}}),
//    .ENA(1'b1),
//    .RSTA(1'b0),
//    .WEA(write_length_info & (~info_full) | initialize_memories),
//    .ADDRB({4'h0, rd_info_pointer}),
//    .CLKB(clk),
//    .DIB(4'h0),
//    .ENB(1'b1),
//    .RSTB(1'b0),
//    .WEB(1'b0)
//  );


//spartan6_ramb4_s8_s8
//#(
//	.wdth(1)
//)
//overrun_fifo
//(
//	.doa(),
//	.dob(overrun),
//	//
//	.addra({6'h0, wr_info_pointer}),
//	.addrb({6'h0, rd_info_pointer}),
//	.clka(clk),
//	.clkb(clk),
//	.dia((latch_overrun | (wr & fifo_full)) & (~initialize_memories)),
//	.dib(8'h0),
//	.ena(1'b1),
//	.enb(1'b1),
//	.rsta(1'b0),
//	.rstb(1'b0),
//	.wea(write_length_info & (~info_full) | initialize_memories),
//	.web(1'b0)	
//);

assign overrun = latch_overrun | (wr & fifo_full);

//  RAMB4_S1_S1 overrun_fifo
//  (
//    .DOA(),
//    .DOB(overrun),
//    .ADDRA({6'h0, wr_info_pointer}),
//    .CLKA(clk),
//    .DIA((latch_overrun | (wr & fifo_full)) & (~initialize_memories)),
//    .ENA(1'b1),
//    .RSTA(1'b0),
//    .WEA(write_length_info & (~info_full) | initialize_memories),
//    .ADDRB({6'h0, rd_info_pointer}),
//    .CLKB(clk),
//    .DIB(1'h0),
//    .ENB(1'b1),
//    .RSTB(1'b0),
//    .WEB(1'b0)
//  );


//`else
//`ifdef VIRTUALSILICON_RAM
//
//`ifdef CAN_BIST
//    vs_hdtp_64x8_bist fifo
//`else
//    vs_hdtp_64x8 fifo
//`endif
//    (
//        .RCK        (clk),
//        .WCK        (clk),
//        .RADR       (read_address),
//        .WADR       (wr_pointer),
//        .DI         (data_in),
//        .DOUT       (data_out),
//        .REN        (~fifo_selected),
//        .WEN        (~(wr & (~fifo_full)))
//    `ifdef CAN_BIST
//        ,
//        // debug chain signals
//        .mbist_si_i   (mbist_si_i),
//        .mbist_so_o   (mbist_s_0),
//        .mbist_ctrl_i   (mbist_ctrl_i)
//    `endif
//    );
//
//`ifdef CAN_BIST
//    vs_hdtp_64x4_bist info_fifo
//`else
//    vs_hdtp_64x4 info_fifo
//`endif
//    (
//        .RCK        (clk),
//        .WCK        (clk),
//        .RADR       (rd_info_pointer),
//        .WADR       (wr_info_pointer),
//        .DI         (len_cnt & {5{~initialize_memories}}),
//        .DOUT       (length_info),
//        .REN        (1'b0),
//        .WEN        (~(write_length_info & (~info_full) | initialize_memories))
//    `ifdef CAN_BIST
//        ,
//        // debug chain signals
//        .mbist_si_i   (mbist_s_0),
//        .mbist_so_o   (mbist_so_o),
//        .mbist_ctrl_i   (mbist_ctrl_i)
//    `endif
//    );
//
//    // overrun_info
//    always @ (posedge clk)
//    begin
//      if (write_length_info & (~info_full) | initialize_memories)
//        overrun_info[wr_info_pointer] <=#Tp (latch_overrun | (wr & fifo_full)) & (~initialize_memories);
//    end
//    
//    
//    // reading overrun
//    assign overrun = overrun_info[rd_info_pointer];
//
//`else
//`ifdef ARTISAN_RAM
//
//`ifdef CAN_BIST
//    art_hstp_64x8_bist fifo
//    (
//        .CLKR       (clk),
//        .CLKW       (clk),
//        .AR         (read_address),
//        .AW         (wr_pointer),
//        .D          (data_in),
//        .Q          (data_out),
//        .REN        (~fifo_selected),
//        .WEN        (~(wr & (~fifo_full))),
//        .mbist_si_i   (mbist_si_i),
//        .mbist_so_o   (mbist_s_0),
//        .mbist_ctrl_i   (mbist_ctrl_i)
//    );
//    art_hstp_64x4_bist info_fifo
//    (
//        .CLKR       (clk),
//        .CLKW       (clk),
//        .AR         (rd_info_pointer),
//        .AW         (wr_info_pointer),
//        .D          (len_cnt & {5{~initialize_memories}}),
//        .Q          (length_info),
//        .REN        (1'b0),
//        .WEN        (~(write_length_info & (~info_full) | initialize_memories)),
//        .mbist_si_i   (mbist_s_0),
//        .mbist_so_o   (mbist_so_o),
//        .mbist_ctrl_i   (mbist_ctrl_i)
//    );
//`else
//    art_hsdp_64x8 fifo
//    (
//        .CENA       (1'b0),
//        .CENB       (1'b0),
//        .CLKA       (clk),
//        .CLKB       (clk),
//        .AA         (read_address),
//        .AB         (wr_pointer),
//        .DA         (8'h00),
//        .DB         (data_in),
//        .QA         (data_out),
//        .QB         (),
//        .OENA       (~fifo_selected),
//        .OENB       (1'b1),
//        .WENA       (1'b1),
//        .WENB       (~(wr & (~fifo_full)))
//    );
//    art_hsdp_64x4 info_fifo
//    (
//        .CENA       (1'b0),
//        .CENB       (1'b0),
//        .CLKA       (clk),
//        .CLKB       (clk),
//        .AA         (rd_info_pointer),
//        .AB         (wr_info_pointer),
//        .DA         (4'h0),
//        .DB         (len_cnt & {4{~initialize_memories}}),
//        .QA         (length_info),
//        .QB         (),
//        .OENA       (1'b0),
//        .OENB       (1'b1),
//        .WENA       (1'b1),
//        .WENB       (~(write_length_info & (~info_full) | initialize_memories))
//    );
//`endif
//
//    // overrun_info
//    always @ (posedge clk)
//    begin
//      if (write_length_info & (~info_full) | initialize_memories)
//        overrun_info[wr_info_pointer] <=#Tp (latch_overrun | (wr & fifo_full)) & (~initialize_memories);
//    end
//    
//    
//    // reading overrun
//    assign overrun = overrun_info[rd_info_pointer];
//
//`else
//  // writing data to fifo
//  always @ (posedge clk)
//  begin
//    if (wr & (~fifo_full))
//      fifo[wr_pointer] <=#Tp data_in;
//  end
//
//  // reading from fifo
//  assign data_out = fifo[read_address];
//
//
//  // writing length_fifo
//  always @ (posedge clk)
//  begin
//    if (write_length_info & (~info_full) | initialize_memories)
//      length_fifo[wr_info_pointer] <=#Tp len_cnt & {4{~initialize_memories}};
//  end
//
//
//  // reading length_fifo
//  assign length_info = length_fifo[rd_info_pointer];
//
//  // overrun_info
//  always @ (posedge clk)
//  begin
//    if (write_length_info & (~info_full) | initialize_memories)
//      overrun_info[wr_info_pointer] <=#Tp (latch_overrun | (wr & fifo_full)) & (~initialize_memories);
//  end
//  
//  
//  // reading overrun
//  assign overrun = overrun_info[rd_info_pointer];
//
//
//`endif
//`endif
//`endif
//`endif
`endif





endmodule


//module spartan6_8bin_32bout_2kB
//		(
//			addr_out,
//			dout,
//			//
//			addra,
//			addrb,
//			clka,
//			clkb,
//			dia,
//			dib,
//			ena,
//			enb,
//			rsta,
//			rstb,
//			wea,
//			web
//
//		);
//		
//		parameter	wdth = 8;
//		
//			output /*reg*/ [wdth-1:0] doa;
//			output /*reg*/ [wdth-1:0] dob;
//			//
//			input [8:0] addra;
//			input [8:0] addrb;
//			input clka;
//			input clkb;
//			input [wdth-1:0] dia;
//			input [wdth-1:0] dib;
//			input ena;
//			input enb;
//			input rsta;
//			input rstb;
//			input wea;
//			input web;
//			
//	
//	bram_buff_8bin_32bout_2kB
//	BUFF(
//		.clka(),
//		.wea(),
//		.addra(),
//		.dina(),
//		.clkb(),
//		.addrb(),
//		.doutb()
//	);
//	BUFF(
//	.a(addra),
//	.d(dia),
//	.dpra(addrb),
//	.clk(clka),
//	.we(wea),
//	.qdpo_clk(clka),
//	.qspo(doa),
//	.qdpo(dob)
//	);
//			
//endmodule

module spartan6_ramb4_s8_s8
	(
		dob,
		addra,
		addrb,
		clk,
		dia,
		wea
	);
	
	parameter	size_base = 11;

	localparam 	wdtha = 8;
	localparam  wdthb = 32;
	localparam	addra_base = (size_base < 11) ? (6) : (size_base);
	localparam	addrb_base = (size_base < 11) ? (6) : (size_base);
	localparam	ram_size_bytes = (1 << addra_base);

	output [wdthb-1:0] dob;
	input [addra_base-1:0] addra;
	input [addrb_base-1:0] addrb;
	input clk;
	input [wdtha-1:0] dia;
	input wea;

	generate
	if (size_base < 11)
	begin

		slicebuf8b512wDualPort
		BRAM_BUFF(
			.a(addra),
			.d(dia),
			.dpra(addrb),
			.clk(clk),
			.we(wea),
			.qdpo_clk(clk),
			//.qspo(doa),
			.qdpo(dob[7:0])
		);
		assign dob[31:8] = 0;
	end
	else
	begin
	
		bram_buff_8bin_32bout_2kB
		BRAM_BUFF(
			.clka(clk),
			.wea(wea),
			.addra(addra),//TODO
			.dina(dia),//8bits
			.clkb(clk),
			.addrb(addrb[addrb_base-1:2]),//TODO
			.doutb(dob) //32 bits
		);
		
	end
	endgenerate
		
endmodule
