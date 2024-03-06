library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity UARTS is

  -- Notes :
  --   Nb of Stop bits = 1 (always)
  --   format "N81" is generic map(Fxtal,false,false), >> by default <<
  --   format "8E1" is generic map(Fxtal,true,true)

  Port (  CLK     : in  std_logic;  -- System Clock at Fqxtal
          RST     : in  std_logic;  -- Asynchronous Reset active high

          Din     : in  std_logic_vector (7 downto 0);
          LD      : in  std_logic;  -- Load, must be pulsed high
          Rx      : in  std_logic;

          Dout    : out std_logic_vector(7 downto 0);
          Tx      : out std_logic;
          TxBusy  : out std_logic;  -- '1' when Busy sending
          RxErr   : out std_logic;
          RxRDY   : out std_logic   -- '1' when Data available
       );
end UARTS;


Architecture RTL of UARTS is
 constant Fxtal   : integer  := 40000000;-- in Hertz
 constant Baud1   : positive := 115200;
 
  constant Debug : integer := 0;
  constant MaxFactor : positive := Fxtal /Baud1;
  
  constant Divisor1 : positive := (Fxtal / Baud1) / 2;
  
  Type TxFSM_State is (Idle, Load_Tx, Shift_TX, Stop_Tx  );
  signal TxFSM : TxFSM_State;
  
  Type RxFSM_State is (Idle, Start_Rx, Shift_RX, Edge_Rx,
                       Stop_Rx, RxOVF );
  signal RxFSM : RxFSM_State;
  
  signal Tx_Reg : std_logic_vector (8 downto 0);
  signal Rx_Reg : std_logic_vector (7 downto 0);
  
--  signal RxDivisor: integer range 0 to MaxFactor/2; -- Rx division factor
  constant RxDivisor: positive := Divisor1 - 1; -- Rx division factor
--  signal TxDivisor: integer range 0 to MaxFactor;   -- Tx division factor
  constant TxDivisor:  positive := (2 * Divisor1) - 1;   -- Tx division factor
  
  signal RxDiv : integer range 0 to MaxFactor/2;
  signal TxDiv : integer range 0 to MaxFactor;
  
  signal TopTx : std_logic;
  signal TopRx : std_logic;
  
  signal TxBitCnt : integer range 0 to 15;
  
  signal RxBitCnt : integer range 0 to 15;
  signal RxRDYi   : std_logic;
  
  signal Rx_r    : std_logic;  -- resync FlipFlop for Rx input

begin

  RxRDY <= RxRDYi;

  --------------------------------------------------------------
  -- Rx input resynchronization  
  process (RST, CLK)
  begin
    if RST='1' then
      Rx_r  <= '1';  -- avoid false start bit at powerup
    elsif rising_edge(CLK) then
      Rx_r <= Rx;
    end if;
  end process;
  --------------------------------------------------------------
  --  Rx Clock Generation
  --
  -- Periodicity : bit time / 2
  
  process (RST, CLK)
  begin
    if RST='1' then
      RxDiv <= 0;
      TopRx <= '0';
    elsif rising_edge(CLK) then
      TopRx <= '0';
      if RxFSM = Idle then
        RxDiv <= 0;
      elsif RxDiv = RxDivisor then
        RxDiv <= 0;
        TopRx <= '1';
      else
        RxDiv <=  RxDiv + 1;
      end if;
    end if;
  end process;
  
  
  --------------------------------------------------------------
  --  Tx Clock Generation
  --
  -- Periodicity : bit time
  process (RST, CLK)
  begin
    if RST='1' then
      TxDiv <= 0;
      TopTx <= '0';
    elsif rising_edge(CLK) then
      TopTx <= '0';
      if TxDiv = TxDivisor then
        TxDiv <= 0;
        TopTx <= '1';
      else
        TxDiv <=  TxDiv + 1;
      end if;
    end if;
  end process;
  --------------------------------------------------------------
  --  TRANSMIT State Machine  --
  TX <= Tx_Reg(0); -- LSB first  
  Tx_FSM: process (RST, CLK)
  begin
    if RST='1' then
      Tx_Reg   <= (others => '1'); -- Line=Vcc when no Xmit
      TxFSM    <= Idle;
      TxBitCnt <= 0;
      TxBusy   <= '0';
    elsif rising_edge(CLK) then
      TxBusy <= '1';  -- Except when explicitly '0'
      case TxFSM is
        when Idle =>
          if LD='1' then
            Tx_Reg <= Din & '1';      -- Latch input data immediately.
            TxBusy <= '1';
            TxFSM <= Load_Tx;
          else
            TxBusy <= '0';
          end if;
        when Load_Tx =>
          if TopTx='1' then
            TxFSM  <= Shift_Tx;
            Tx_Reg(0) <= '0'; -- Start bit
            TxBitCnt <= 9;
          end if;
        when Shift_Tx =>
          if TopTx='1' then     -- Shift Right with a '1'
            TxBitCnt <= TxBitCnt - 1;
           Tx_Reg <= '1' & Tx_Reg (Tx_Reg'high downto 1);
            if TxBitCnt=1 then
                TxFSM <= Stop_Tx;
            end if;
          end if;
        when Stop_Tx =>         -- Stop bit
          if TopTx='1' then
            TxFSM <= Idle;
          end if;
        --!!MDA when others =>
        --!!MDA  TxFSM <= Idle;
      end case;
    end if;
  end process;
  
  --------------------------------------------------------------
  --  RECEIVE State Machine  
  Rx_FSM: process (RST, CLK)
  
  begin
    if RST='1' then
      Rx_Reg   <= (others => '0');
      Dout     <= (others => '0');
      RxBitCnt <= 0;
      RxFSM    <= Idle;
      RxRdyi   <= '0';
      RxErr    <= '0';
    elsif rising_edge(CLK) then
      if RxRdyi='1' then  -- Clear error bit when a word has been received...
        RxErr  <= '0';
        RxRdyi <= '0';
      end if;
      case RxFSM is
        when Idle =>      -- Wait until start bit occurs
          RxBitCnt <= 0;
          if Rx_r = '0' then
            RxFSM  <= Start_Rx;
          end if;
        when Start_Rx =>  -- Wait on first data bit
          if TopRx = '1' then
            if Rx_r='1' then -- framing error
              RxFSM <= RxOVF;
              -- pragma translate_off
              assert (debug < 1) report "Start bit error."
                severity warning;
              -- pragma translate_on
            else
              RxFSM <= Edge_Rx;
            end if;
          end if;
        when Edge_Rx =>   -- should be near Rx edge
          if TopRx = '1' then
            RxFSM <= Shift_Rx;
            if RxBitCnt = 8 then
               RxFSM <= Stop_Rx;
            else
              RxFSM <= Shift_Rx;
            end if;
          end if;
        when Shift_Rx =>  -- Sample data !
          if TopRx = '1' then
            RxBitCnt <= RxBitCnt + 1;
            Rx_Reg   <= Rx_r & Rx_Reg (Rx_Reg'high downto 1); -- shift right
            RxFSM    <= Edge_Rx;
          end if;
        when Stop_Rx =>   -- here during Stop bit
          if TopRx = '1' then
            if Rx_r='1' then
              Dout <= Rx_reg;
              RxRdyi <='1';
              RxFSM <= Idle;
              -- pragma translate_off
              assert (debug < 1)
                report "Character received in decimal is : "
                  & integer'image(to_integer(unsigned(Rx_Reg)))
                  & " - '" & character'val(to_integer(unsigned(Rx_Reg))) & "'"
                  severity note;
              -- pragma translate_on
            else
              RxFSM <= RxOVF;
            end if;
          end if;
        -- ERROR HANDLING COULD BE IMPROVED :
        -- Here, we could try to re-synchronize !
        when RxOVF =>     -- Overflow / Error : should we RxRDY ?
          RxRdyi <= '0'; -- or '1' : to be defined by the project
          RxErr  <= '1';
          if Rx = '1' then  -- return to idle as soon as Rx goes inactive
          -- pragma translate_off
          report "Error in character received. " severity warning;
          -- pragma translate_on
            RxFSM <= Idle;
          end if;
        --!!MDA when others => -- in case it would be encoded as safe + binary
        --!!MDA   RxFSM <= Idle;
      end case;
    end if;
  end process;
  
end RTL;