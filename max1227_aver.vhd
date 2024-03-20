library ieee;
	use ieee.std_logic_1164.all; 
	use ieee.numeric_std.all;

package pkg_max1227 is

constant NUM		:integer := 8;
type adc_mem is array (integer range  0 to NUM) of std_logic_vector (15 downto 0);	


component max1227_aver is
	Generic (
	AVER			:integer := 0		-- Averaging 2^aver
	);
	Port (
	--
	clk				:in std_logic;
	rst				:in std_logic;
	--
	cnvstn			:out std_logic;
	eocn			:in std_logic;
	csn				:out std_logic;
	sclk			:out std_logic;
	din				:in std_logic;
	dout			:out std_logic;
	--
	adr				:in std_logic_vector(3 downto 0);
	dat				:out std_logic_vector(15 downto 0)
	--
	);
end component;
end package; 


library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity max1227_aver is
	Generic (
	AVER			:integer := 0		-- Averaging 2^aver
	);
	Port (
	--
	clk				:in std_logic;
	rst				:in std_logic;
	--
	cnvstn			:out std_logic;
	eocn			:in std_logic;
	csn				:out std_logic;
	sclk			:out std_logic;
	din				:in std_logic;
	dout			:out std_logic;
	--
	adr				:in std_logic_vector(3 downto 0);
	dat				:out std_logic_vector(15 downto 0)
	--
	);
end entity;

architecture my of max1227_aver is

	constant NUM			:integer := 8;
	type ch_out_mem is array (integer range  0 to NUM) of std_logic_vector(15 downto 0);
	
	constant ST_MAX			:integer := 5;
	signal state			:integer range 0 to ST_MAX;
	signal busy				:std_logic;
	signal end_spi			:std_logic;
	signal sclk_q, sclk_qq	:std_logic;
	signal dout_q			:std_logic;
	signal din_q			:std_logic;
	signal eocn_q			:std_logic;
	
	signal read_buf			:std_logic_vector (7 downto 0);
	signal read_byte		:std_logic_vector (7 downto 0);
	signal read_byte_pr		:std_logic_vector (7 downto 0);
	signal read_word		:std_logic_vector (15 downto 0);
	signal ch_out			:ch_out_mem;
	signal count_ch			:integer range 0 to NUM;
	signal count_ch_q		:integer range 0 to NUM;
	
	signal end_cycle		:std_logic;
	signal in_ch			:std_logic_vector (15+AVER downto 0) := (others=>'0');
	
begin
	
	sclk <= sclk_qq;
	cnvstn <= '1';
	csn <= not busy;
	dout <= dout_q;
	
	main: process (rst, clk)
	--
		constant time_whait	:integer := 200;
		variable tmp_buf	:std_logic_vector (6 downto 0);
		variable cnt		:integer range 0 to 7 := 0;
		variable count		:integer range 0 to time_whait := 0;
		--
		procedure spi_p is
		begin
			if cnt /= 7 then
				cnt := cnt + 1;
				dout_q <= tmp_buf(6);
				tmp_buf := tmp_buf(5 downto 0) & '0';
			else
				busy <= '0';
				end_spi <= '1';
				cnt := 0;
				dout_q <= '0';
				tmp_buf := (others => '0');
				read_byte_pr <= read_byte;
				read_byte <= read_buf;
			end if;
		end procedure;
		
		-- процедура записи байта по SPI
		procedure spi_w (data :in std_logic_vector(7 downto 0)) is
		begin
			if busy = '0' and end_spi = '0' then
				busy <= '1';
				cnt := 0;
				dout_q <= data(7);
				tmp_buf := data(6 downto 0);
			else
				spi_p;
			end if;
		end procedure;
		-- процедура записи байта по SPI
		procedure spi_r is
		begin
			spi_w(X"00");
		end procedure;
		-- процедура переключения состояния
		procedure st_next (data :in integer) is
		begin
			if end_spi = '1' then
				state <= data;
			end if;
		end procedure;
		-- процедура ожидания преобразования
		procedure st_wait (data :in integer; max :in integer) is
		begin
			if count < max then
				count := count + 1;
			else
				state <= data;
				count := 0;
			end if;
			if eocn_q = '0' then
				state <= data;
				count := 0;
			end if;
		end procedure;
		--
	begin
		--
		if rst = '1' then
			busy <= '0';
			cnt := 0;
			tmp_buf := (others => '0');
			read_byte <= (others => '0');
			read_byte_pr <= (others => '0');
			dout_q <= '0';
			state <= 0;
			count := 0;
			end_spi <= '0';
			count_ch <= 0;
			count_ch_q <= 0;
-- synthesis translate_off
			ch_out <= (X"0111", X"0222", X"0333", X"0444", X"0555", X"0666", X"0777", X"0888", X"0999");
-- synthesis translate_on
		elsif rising_edge(clk) then
			if sclk_q = '1' and sclk_qq = '1' then
				--
				end_spi <= '0';
				--
				case state is
					when 0		=>	st_wait(1, time_whait);
--					when 1		=>	st_next(2);		spi_w("0001" & '0' & "000");		-- reset all
--					when 2		=>	st_next(3);		spi_w("001" & "000" & "00");		-- averaging off
					when 1		=>	st_next(2);		spi_w("01" & "10" & "10" & "00");	-- setup
																						--		"01"	select setup register.
																						--		"10"	CONVERSION CLOCK - Internal
																						--		"10"	VOLTAGE REFERENCE - Internal
																						--		"00"	No data follows the setup byte. Unipolar mode and bipolar mode registers remain unchanged.
					when 2		=>	st_next(3);		spi_w("1" & X"7" & "00"& "1");		-- conversion
																						--		"1"		Set to 1 to select conversion register
																						--		X"7"	Analog input channel select
																						--		"00"	Scan mode select - Scans channels 0 through N.
																						--		"1"		Set to 1 to take a single temperature measurement. The first conversion result of a scan contains temperature information
					when 3		=>	st_wait(4, time_whait);
					when 4		=>	spi_r;	st_next(5);
					when 5		=>	spi_r;
									if end_spi = '1' then
										if count_ch >= NUM then
											count_ch <= 0;
											st_next(1);
										else
											count_ch <= count_ch + 1;
											st_next(4);
										end if;
									end if;
				end case;
				-- 
				count_ch_q <= count_ch;
				--
				if end_cycle = '1' then
					ch_out(count_ch_q) <= in_ch(15+AVER downto AVER);					-- 0 - Temp, 1 - IN0, 2 - IN1, ..., 8 - IN7.
				end if;
				--
			end if;
		end if;
		--
	end process;
	
	read_word <= read_byte_pr & read_byte;
	
	gen_aver: if AVER /= 0 generate
		type ch_buf_mem is array (integer range  0 to NUM) of std_logic_vector (15+AVER downto 0);
		signal ch_buf		:ch_buf_mem;
		signal co_avr		:integer range 0 to 2**AVER-1;
		signal add_dat		:std_logic_vector (15+AVER downto 0);
	begin
	
		proc_aver: process (rst, clk)
		begin
			--
			if rst = '1' then
				end_cycle <= '0';
				co_avr <= 0;
				add_dat <= (others => '0');
				in_ch <= (others=>'0');
			elsif rising_edge(clk) then
				--
				in_ch <= std_logic_vector(unsigned(add_dat) + unsigned(read_word));
				--
				if sclk_q = '1' and sclk_qq = '1' then
					--
					end_cycle <= '0';
					--
					if co_avr = 0 then
						add_dat <= (others => '0');
					else
						add_dat <= ch_buf(count_ch);
					end if;
					--
					if state = ST_MAX then
						if end_spi = '1' then
							ch_buf(count_ch) <= in_ch;									-- 0 - Temp, 1 - IN0, 2 - IN1, ..., 8 - IN7.
							if count_ch >= NUM then
								if co_avr < 2**AVER-1 then
									co_avr <= co_avr + 1;
								else
									co_avr <= 0;
								end if;
							end if;
							if co_avr = 2**AVER-1 then
								end_cycle <= '1';
							end if;
						end if;
					end if;
					--
				end if;
				--
			end if;
		end process;
		
	end generate;
	
	gen_no_aver: if AVER = 0 generate
		proc_aver: process (rst, clk)
		begin
			--
			if rst = '1' then
				end_cycle <= '0';
			elsif rising_edge(clk) then
				--
				in_ch <= read_word;
				--
				if sclk_q = '1' and sclk_qq = '1' then
					--
					end_cycle <= '0';
					--
					if state = ST_MAX then
						if end_spi = '1' then
							end_cycle <= '1';
						end if;
					end if;
					--
				end if;
				--
			end if;
		end process;
	
	end generate;
	
	out_q: process (clk)
		variable adr_q		:integer range 0 to NUM;
	begin
		if rising_edge(clk) then
			if to_integer(unsigned(adr)) > NUM then
				adr_q := 0;
			else
				adr_q := to_integer(unsigned(adr));
			end if;
			dat <= ch_out(adr_q);
		end if;
	end process;
	
	-- чтение данных с DIN и запись в буфер
	r_spi: process (rst, clk)
	begin
		if rst = '1' then
			read_buf <= X"00";
		elsif rising_edge(clk) then
			if sclk_q = '1' and sclk_qq = '0' then
				read_buf <= read_buf(6 downto 0) & din_q;
--read_buf <= X"11";
--read_buf <= std_logic_vector(to_unsigned(count_ch+1, 8));
			end if;
		end if;
	end process;
	
	-- стробирование DIN и EOCN
	strob: process (clk)
	begin
		if rising_edge(clk) then
			din_q <= din;
			eocn_q <= eocn;
		end if;
	end process;
	
	-- формирования SCLK
	sclock: process (rst, clk)
		constant CO_MAX			:integer := 20;
		variable count			:integer range 0 to CO_MAX-1;
	begin
		if rst = '1' then
			count := 0;
			sclk_q <= '0';
			sclk_qq <= '0';
		elsif rising_edge(clk) then
			sclk_q <= '0';
			if sclk_q = '1' then
				sclk_qq <= not sclk_qq;
			end if;
			if count < CO_MAX-1 then
				count := count + 1;
			else
				count := 0;
				sclk_q <= '1';
			end if;
		end if;
	end process;
	
end architecture;