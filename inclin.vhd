----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use ieee.numeric_std.all;

entity inclin is
   port (
	--------------------------------
    -- board-side connections
    --
    clk        		: in  std_logic;
    rst        		: in  std_logic;
	 start_incl 		: in  std_logic;
	 incl_data_rdy	   : out  std_logic;
	 data_out		   : out  std_logic_vector(7 downto 0);
	 data_addr		   : in  std_logic_vector(4 downto 0);-- position of byte in message from inclin 
	 incl_cmd		   : in  std_logic_vector(7 downto 0);
	 incl_wr_data	   : in  std_logic_vector(31 downto 0);
    --
    rxflex           : in  std_logic; -- rx input    
    txflex           : out std_logic;  -- tx output
	 -----
	 ax               : out std_logic_vector (15 downto 0);
	 ay               : out std_logic_vector (15 downto 0);
	 az               : out std_logic_vector (15 downto 0);
	 hx               : out std_logic_vector (15 downto 0);
	 hy               : out std_logic_vector (15 downto 0);
	 hz               : out std_logic_vector (15 downto 0);
	 v                : out std_logic_vector (15 downto 0);
	 t                : out std_logic_vector (15 downto 0);
	 crc              : out std_logic_vector (15 downto 0);
	 -----
	 tf               : out std_logic_vector (15 downto 0);
	 mt               : out std_logic_vector (15 downto 0);
	 inc              : out std_logic_vector (15 downto 0);
	 bt               : out std_logic_vector (15 downto 0);
	 ad               : out std_logic_vector (15 downto 0);
	 gt               : out std_logic_vector (15 downto 0);
	 -----
	 flag             : in std_logic
	 -----
	 --status           : out std_logic_vector (15 downto 0)
	);
end inclin;

architecture Behavioral of inclin is
    signal sdin         : std_logic_vector (7 downto 0);-- from uarts
    signal rxrdy        : std_logic;                    -- from uarts
    signal rawrx        : std_logic;  
    signal sdout        : std_logic_vector(7 downto 0);  --data to uart and pc
    Type DmFSM_State is (Idle, Send_Cmd, Send_Data1, Send_Data2, Rcv_Data, Ending);
    signal DmFSM 		  : DmFSM_State;
 
    signal ld_sdout     : std_logic;
    signal TxBusy       : std_logic;

    subtype char is std_logic_vector(7 downto 0);
    type data is array(23 downto 0) of char;--Number of byte in message from inclinometr
    signal raw_data	  : data;
    type packet is array(5 downto 0) of char;
    signal incl_packet	  : packet;

    signal ByteCnt	  : integer range 0 to 44;
    signal Byte_to_Send : integer range 0 to 6;
	 
	 signal B_Recieve : integer range 0 to 127;
	 
	 signal stop : std_logic ;
	 
begin
     i_uarts : entity work.uarts(rtl)
     port map(
      clk    => clk,
      rst    => rst,
      din    => sdout,
      ld     => ld_sdout,
      rx     => rawrx,
      dout   => sdin,
	   TxBusy => TxBusy,
      rxrdy  => rxrdy,
      tx     => txflex
    );
----------------------------------------------------------------
    rawrx <= rxflex when rst='0' else '0'; 	 
----------------------------------------------------------------
  DM_FSM: process (RST, CLK)
--	variable inc : integer range 0 to 44;  
	variable inc_state : std_logic;  
--	variable Byte_to_Send : integer range 0 to 6;  
  begin
    if rst='1' then
      DmFSM    <= Idle;
      ByteCnt  <= 0;
      sdout    <= (others => '0');
      ld_sdout <= '0';
	   incl_data_rdy <= '0';
--	   inc			:= 0;
	   inc_state		:= '0';
	   Byte_to_Send	<= 0;
	   incl_packet(0)<= (others => '0');
	   incl_packet(1)<= (others => '0');
	   incl_packet(2)<= (others => '0');
	   incl_packet(3)<= (others => '0');
	   incl_packet(4)<= (others => '0');
	   incl_packet(5)<= (others => '0');
		--status <= (others => '0');
		B_Recieve <= 0;
		stop <= '0';
	elsif rising_edge(CLK) then
      --if flag = '0' then
		case DmFSM is
	        when Idle =>			  
			     incl_data_rdy <= '0';
	           if start_incl = '1' then
				     -- if stop = '0' then
	               DmFSM 	<= Send_Cmd;
				      --sdout 	<= incl_cmd;	-- команда инклинометру. если С7, то затем посылаем 1В
            	   --ld_sdout <= '1';
					   --ld_sdout <= '0';
				      inc_state := '0';
				      --incl_packet(3) <= incl_wr_data(31 downto 24);
				      --ncl_packet(2) <= incl_wr_data(23 downto 16);
				      --incl_packet(1) <= incl_wr_data(15 downto 8);
				      --incl_packet(0) <= incl_wr_data(7 downto 0);
				      --case incl_cmd is
				      --ByteCnt <= 1; Byte_to_Send <= 1;  incl_packet(Byte_to_Send - 1) <= incl_cmd;
					   
						--ByteCnt <= 24; Byte_to_Send <= 1;  incl_packet(0) <= incl_cmd;
						ByteCnt <= 24; Byte_to_Send <= 1;  incl_packet(0) <= incl_cmd;
						
						
					   --when x"83" => ByteCnt <= 1; Byte_to_Send <= 1;  incl_packet(Byte_to_Send - 1) <= x"83";
				   	--when x"FE" => ByteCnt <= 8;	 Byte_to_Send<=0; incl_packet(5) <= incl_wr_data(31 downto 24); incl_packet(4) <= incl_wr_data(23 downto 16); --inc := 0;
				      --when x"17" => ByteCnt <= 5;	 Byte_to_Send<=4; incl_packet(5) <= incl_wr_data(31 downto 24); incl_packet(4) <= incl_wr_data(23 downto 16);--inc := 0;
					   --when x"E0" => ByteCnt <= 4;	 Byte_to_Send<=6; incl_packet(5) <= x"C1"; incl_packet(4) <= x"29";--  inc := 0;
					   --when x"E8" => ByteCnt <= 4;	 Byte_to_Send<=3; incl_packet(5) <= x"55"; incl_packet(4) <= x"AA";--  inc := 0; 
					   --when x"FB" => ByteCnt <= 4;	 Byte_to_Send<=3; incl_packet(5) <= x"AA"; incl_packet(4) <= x"55";--  inc := 0; 
					   --when x"01" => ByteCnt <= 1;	 Byte_to_Send<=0; incl_packet(5) <= x"C1"; incl_packet(4) <= x"29";--  inc := 0;
					   --when OTHERS => ByteCnt <= 0; Byte_to_Send <= 0;--  inc := 0;
				    --end case;	
                --end if;					
	          end if;
	        when Send_Cmd =>
			     ld_sdout <= '0';
				  if TxBusy = '0' then
					  if Byte_to_Send = 0 then
						  DmFSM <= Rcv_Data;
					  else
					     DmFSM <= Send_Data1;
					  end if;
				  end if;				  
	        when Send_Data1 =>
              ld_sdout <= '0';
			     if TxBusy = '0' then
					  DmFSM <= Send_Data2;
				  end if;				  
	        when Send_Data2 =>
			     --status(3) <= '1';
   			  ld_sdout <= '0';
				  if TxBusy = '0' then
				     if Byte_to_Send = 0 then
				        DmFSM <= Rcv_Data;
				     else
				        DmFSM <= Send_Data1;
					     sdout 	<= incl_packet(0);	--
						  --sdout 	<= x"55";	--
						  --sdout 	<= x"83";	--
					     Byte_to_Send <= Byte_to_Send - 1;
		              ld_sdout <= '1';
					  end if;
				  end if;
	        when Rcv_Data =>
			  --status(4) <= '1';
			if rxrdy = '1' then  -- memorize the incoming char
			    --status(4) <= '1';
					--if inc_state = '1' then
         		--		raw_data(ByteCnt+44) <= sdin;
					--else
         		raw_data(ByteCnt) <= sdin;
					B_Recieve <= B_Recieve + 1;
					if B_Recieve = 1 then
					--status(5) <= '1';
					end if;
					--end if;
--         			raw_data(ByteCnt+inc) <= sdin;
					ByteCnt <= ByteCnt - 1;
					--status(15 downto 8) <= B_Recieve(7 downto 0);--std_logic_vector(to_unsigne
				end if;
				if (ByteCnt = 0) then
				   ---------------------------------
					if sdout = x"80" then
						DmFSM <= Send_Cmd;
            		ld_sdout <= '1';  
						Byte_to_Send <= 1;
						sdout <= x"83";		-- get raw data
						--ByteCnt <= 40;
						ByteCnt <= 24;
						inc_state := '1';
--						inc		:= 44;
					else
						DmFSM <= Ending;
						incl_data_rdy <= '1';
						sdout <= x"AA";		-- to avoid warnings
					end if;
					---------------------------------
				   if flag = '0' then
					   if(inc_state = '0') then
						   hx(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(20));
							hx(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(19));
						else
						   tf(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(20));
							tf(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(19));
                  end if;			
					   
					   ax(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(18));
					   ax(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(17));
					   hy(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(16));
					   hy(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(15));
					   ay(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(14));
					   ay(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(13));
					   hz(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(12));
					   hz(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(11));
					   az(15 downto 8)  <= STD_LOGIC_VECTOR(raw_data(10));
					   az(7 downto 0)   <= STD_LOGIC_VECTOR(raw_data(9));
					   t(15 downto 8)   <= STD_LOGIC_VECTOR(raw_data(8));
					   t(7 downto 0)    <= STD_LOGIC_VECTOR(raw_data(7));
					   v(15 downto 8)   <= STD_LOGIC_VECTOR(raw_data(6));
					   v(7 downto 0)    <= STD_LOGIC_VECTOR(raw_data(5));
					   crc(15 downto 8) <= STD_LOGIC_VECTOR(raw_data(4));
					   crc(7 downto 0)  <= STD_LOGIC_VECTOR(raw_data(3));
					end if;
					--stop <= '1';
--					if sdout = x"C7" then
--						DmFSM <= Send_Cmd;
--            			ld_sdout <= '1';  
--						sdout <= x"1B";		-- get raw data
--						ByteCnt <= 40;
--						inc_state := '1';
----						inc		:= 44;
--					else
						DmFSM <= Ending;
						incl_data_rdy <= '1';
						--sdout <= x"AA";		-- to avoid warnings
					end if;
				--end if;	
	        when Ending =>
			      --status(15 downto 8) <= std_logic_vector(to_unsigner
					--status(15 downto 8) <=STD_LOGIC_VECTOR(character'pos(raw_data(15)),8);
					--status(15 downto 8) <=STD_LOGIC_VECTOR(raw_data(16));
					--status(15 downto 8) <=STD_LOGIC_VECTOR(raw_data(6));
					--status(15 downto 8) <=STD_LOGIC_VECTOR(B_Recieve);
			      --status(7) <= '1';					
               DmFSM <= Idle;
   			   ld_sdout <= '0';
				--sdout <= x"55";		-- to avoid warnings	

		end case;
		--end if;
	end if;
end process;
end Behavioral;

