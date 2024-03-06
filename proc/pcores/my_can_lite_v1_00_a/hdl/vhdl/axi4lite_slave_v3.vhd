library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package pkg_axi4lite is
	function Get_Addr_Bits (constant base, high : std_logic_vector) return integer;
end package;

package body pkg_axi4lite is
	function Get_Addr_Bits (constant base, high : std_logic_vector) return integer is
	variable i : integer := 0;
	variable adr : std_logic_vector(31 downto 0) := (others=>'0');
    begin
		
	adr := base xor high;
	
	for i in 31 downto 0 loop
		if adr(i)='1' then
			return (i);
		end if;
	end loop;
	return 9;
	end function Get_Addr_Bits;

end package body;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_axi4lite.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_S_AXI_DATA_WIDTH           -- AXI4LITE slave: Data width
--   C_S_AXI_ADDR_WIDTH           -- AXI4LITE slave: Address Width
--   C_S_AXI_MIN_SIZE             -- AXI4LITE slave: Min Size
--   C_DPHASE_TIMEOUT             -- AXI4LITE slave: Data Phase Timeout
--   C_BASEADDR                   -- AXI4LITE slave: base address
--   C_HIGHADDR                   -- AXI4LITE slave: high address
--   C_FAMILY                     -- FPGA Family
--   C_NUM_REG                    -- Number of software accessible registers
--   C_NUM_MEM                    -- Number of address-ranges
--   C_SLV_AWIDTH                 -- Slave interface address bus width
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--
-- Definition of Ports:
--   S_AXI_ACLK                   -- AXI4LITE slave: Clock 
--   S_AXI_ARESETN                -- AXI4LITE slave: Reset
--   S_AXI_AWADDR                 -- AXI4LITE slave: Write address
--   S_AXI_AWVALID                -- AXI4LITE slave: Write address valid
--   S_AXI_WDATA                  -- AXI4LITE slave: Write data
--   S_AXI_WSTRB                  -- AXI4LITE slave: Write strobe
--   S_AXI_WVALID                 -- AXI4LITE slave: Write data valid
--   S_AXI_BREADY                 -- AXI4LITE slave: Response ready
--   S_AXI_ARADDR                 -- AXI4LITE slave: Read address
--   S_AXI_ARVALID                -- AXI4LITE slave: Read address valid
--   S_AXI_RREADY                 -- AXI4LITE slave: Read data ready
--   S_AXI_ARREADY                -- AXI4LITE slave: read addres ready
--   S_AXI_RDATA                  -- AXI4LITE slave: Read data
--   S_AXI_RRESP                  -- AXI4LITE slave: Read data response
--   S_AXI_RVALID                 -- AXI4LITE slave: Read data valid
--   S_AXI_WREADY                 -- AXI4LITE slave: Write data ready
--   S_AXI_BRESP                  -- AXI4LITE slave: Response
--   S_AXI_BVALID                 -- AXI4LITE slave: Resonse valid
--   S_AXI_AWREADY                -- AXI4LITE slave: Wrte address ready
------------------------------------------------------------------------------

entity axi4lite_slave_v3 is
  generic
  (
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 32;
    C_S_AXI_MIN_SIZE               : std_logic_vector     := X"000001FF";
    C_DPHASE_TIMEOUT               : integer              := 8;
    C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector     := X"00000000";
    C_FAMILY                       : string               := "virtex6"
--	C_IPIF_ABUS_WIDTH			   : integer			  := Get_Addr_Bits(C_BASEADDR, C_HIGHADDR)
--	C_IPIF_ABUS_WIDTH			   : integer			  := Get_Addr_Bits
  );
  port
  (
    -- Bus protocol ports, do not add to or delete
    S_AXI_ACLK                     : in  std_logic;
    S_AXI_ARESETN                  : in  std_logic;
    S_AXI_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID                  : in  std_logic;
    S_AXI_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID                   : in  std_logic;
    S_AXI_BREADY                   : in  std_logic;
    S_AXI_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID                  : in  std_logic;
    S_AXI_RREADY                   : in  std_logic;
    S_AXI_ARREADY                  : out std_logic;
    S_AXI_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_RVALID                   : out std_logic;
    S_AXI_WREADY                   : out std_logic;
    S_AXI_BRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_BVALID                   : out std_logic;
    S_AXI_AWREADY                  : out std_logic;
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
    Bus2IP_Clk          : out std_logic;
    Bus2IP_Resetn       : out std_logic;
    Bus2IP_Addr         : out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    Bus2IP_BE           : out std_logic_vector(((C_S_AXI_DATA_WIDTH/8) - 1) downto 0);
    Bus2IP_Wr	        : out  std_logic;
    Bus2IP_Rd	        : out  std_logic;
    Bus2IP_Data         : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
    IP2Bus_Data         : in  std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
	IP2Bus_rdAck		: in std_logic;
	IP2Bus_wrAck		: in std_logic
  );
end entity axi4lite_slave_v3;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of axi4lite_slave_v3 is


  constant C_IPIF_ABUS_WIDTH			   : integer			  := Get_Addr_Bits(C_BASEADDR, C_HIGHADDR);
  constant ZEROS                : std_logic_vector((C_IPIF_ABUS_WIDTH-1) downto 0) := (others=>'0');
  signal bus2ip_addr_i			: std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
  type BUS_ACCESS_STATES is (SM_IDLE, SM_READ, SM_READE, SM_WRITE, SM_RESP);

  signal state 					: BUS_ACCESS_STATES;

  signal rst					: std_logic;
  signal s_axi_bvalid_i         : std_logic:= '0';
  signal s_axi_arready_i        : std_logic;
  signal s_axi_rvalid_i         : std_logic:= '0';
-- Intermediate IPIC signals
  signal timeout                : std_logic := '0';
  signal rd_done,wr_done        : std_logic;
  signal s_axi_bresp_i : std_logic_vector(1 downto 0):=(others => '0');
  signal s_axi_rresp_i : std_logic_vector(1 downto 0):=(others => '0');
  signal s_axi_rdata_i : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0):=(others => '0');
  signal s_axi_wdata_i : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0):=(others => '0');
  signal s_axi_be_i    : std_logic_vector(((C_S_AXI_DATA_WIDTH/8) - 1) downto 0);
  signal s_axi_rd,s_axi_wr        : std_logic;

begin
	
Bus2IP_Clk     <= S_AXI_ACLK;
Bus2IP_Resetn  <= S_AXI_ARESETN;
Bus2IP_BE      <= s_axi_be_i;
Bus2IP_Data    <= s_axi_wdata_i;
Bus2IP_Addr    <= bus2ip_addr_i;
Bus2IP_Wr	   <= s_axi_wr;
Bus2IP_Rd	   <= s_axi_rd;

-- For AXI Lite interface, interconnect will duplicate the addresses on both the
-- read and write channel. so onlyone address is used for decoding as well as
-- passing it to IP.

	
	REGISTERING_RESET_P : process (S_AXI_ACLK) is
	begin
		if S_AXI_ACLK'event and S_AXI_ACLK = '1' then
    		rst <=  not S_AXI_ARESETN;
		end if;
	end process REGISTERING_RESET_P;


	Access_Control : process (S_AXI_ACLK) is
	begin
	if S_AXI_ACLK'event and S_AXI_ACLK = '1' then
		if rst = '1' then
	    	state <= SM_IDLE;
			bus2ip_addr_i <= (others=>'0');
			s_axi_be_i <= (others=>'0');
			s_axi_wdata_i <= (others=>'0');
			s_axi_rdata_i <=  (others=>'0');
			s_axi_rd <= '0';
			s_axi_wr <= '0';
       		s_axi_bvalid_i <= '0';
       		s_axi_rvalid_i <= '0';
			rd_done <= '0';
			wr_done	<= '0';
	    else
			rd_done <= '0';
			wr_done	<= '0';
			case state is
				when SM_IDLE =>
					if (S_AXI_ARVALID = '1') then  -- Read precedence over write
						bus2ip_addr_i(C_IPIF_ABUS_WIDTH downto 0)  <= S_AXI_ARADDR(C_IPIF_ABUS_WIDTH downto 0);
						s_axi_be_i	   <= (others=>'1');
						s_axi_rd <= '1';
						state <= SM_READ;
					elsif (S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
						bus2ip_addr_i(C_IPIF_ABUS_WIDTH downto 0)  <= S_AXI_AWADDR(C_IPIF_ABUS_WIDTH downto 0);
						s_axi_wdata_i  <= S_AXI_WDATA;
						s_axi_be_i	   <= S_AXI_WSTRB;
						s_axi_wr 	   <= '1';
						state <= SM_WRITE;
					else
						state <= SM_IDLE;
					end if;
				when SM_READ => 
					if (IP2Bus_rdAck = '1') then
--						state <= SM_READE;
						s_axi_rd <= '0';
						rd_done <= '1';
        				s_axi_rdata_i <=  IP2Bus_Data;
			       		s_axi_rvalid_i <= '1';
						state <= SM_RESP;
					end if;
				-- when SM_READE => 
						-- s_axi_rd <= '0';
						-- rd_done <= '1';
        				-- s_axi_rdata_i <=  IP2Bus_Data;
			       		-- s_axi_rvalid_i <= '1';
						-- state <= SM_RESP;
		        when SM_WRITE=>
					if (IP2Bus_wrAck = '1') then
						s_axi_wr <= '0';
						wr_done	<= '1';
		         		s_axi_bvalid_i <= '1';
						state <= SM_RESP;
				    else
						state <= SM_WRITE;
					end if;
				when SM_RESP =>
					if ((s_axi_bvalid_i and S_AXI_BREADY) or (s_axi_rvalid_i and S_AXI_RREADY)) = '1' then
		         		if s_axi_bvalid_i = '1' then
							 s_axi_bvalid_i <= '0';
						end if;
		         		if s_axi_rvalid_i = '1' then
							 s_axi_rvalid_i <= '0';
						end if;
						state <= SM_IDLE;
					else
						state <= SM_RESP;
					end if;
	  			when others =>  state <= SM_IDLE;
    		end case;
	    end if;
   	end if;
	end process Access_Control;


	S_AXI_RRESP 	<= (others=>'0');
	S_AXI_BRESP 	<= (others => '0');
	S_AXI_RDATA 	<= s_axi_rdata_i;
	S_AXI_BVALID 	<= s_axi_bvalid_i;
	S_AXI_RVALID 	<= s_axi_rvalid_i;

	S_AXI_ARREADY 	<= rd_done;
	S_AXI_AWREADY 	<= wr_done;
	S_AXI_WREADY  	<= wr_done;

-- INCLUDE_DPHASE_TIMER: Data timeout counter included only when its value is non-zero.
--------------
--INCLUDE_DPHASE_TIMER: if C_DPHASE_TIMEOUT /= 0 generate
--
--  constant COUNTER_WIDTH        : integer := clog2((C_DPHASE_TIMEOUT));
--  signal dpto_cnt               : std_logic_vector (COUNTER_WIDTH downto 0);
--    -- dpto_cnt is one bit wider then COUNTER_WIDTH, which allows the timeout
--    -- condition to be captured as a carry into this "extra" bit.
--begin
--
--  DPTO_CNT_P : process (S_AXI_ACLK) is
--    begin
--      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
--        if ((state = SM_IDLE) or (state = SM_RESP)) then
--           dpto_cnt <= (others=>'0');
--        else
--           dpto_cnt <= dpto_cnt + 1;
--        end if;
--      end if;
--  end process DPTO_CNT_P;
--
--  timeout <= dpto_cnt(COUNTER_WIDTH);
--
--end generate INCLUDE_DPHASE_TIMER;
--
--EXCLUDE_DPHASE_TIMER: if C_DPHASE_TIMEOUT = 0 generate
--  timeout <= '0';
--end generate EXCLUDE_DPHASE_TIMER;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-------------------------------------------------------------------------------

--  ipif_IP2Bus_Data <= user_IP2Bus_Data;
--  ipif_IP2Bus_WrAck <= user_IP2Bus_WrAck;
--  ipif_IP2Bus_RdAck <= user_IP2Bus_RdAck;
--  ipif_IP2Bus_Error <= user_IP2Bus_Error;
--
--  user_Bus2IP_RdCE <= ipif_Bus2IP_RdCE(USER_NUM_REG-1 downto 0);
--  user_Bus2IP_WrCE <= ipif_Bus2IP_WrCE(USER_NUM_REG-1 downto 0);

end IMP;
