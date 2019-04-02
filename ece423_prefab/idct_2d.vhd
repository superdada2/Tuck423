-- IDCT_2D_hw.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IDCT_2D_hw is
	port (
		src_data  : in  std_logic_vector(1023 downto 0) := (others => '0'); --   src.data
		src_valid : in  std_logic                       := '0';             --      .valid
		src_ready : out std_logic;                                          --      .ready
		clk       : in  std_logic                       := '0';             -- clock.clk
		reset     : in  std_logic                       := '0';             -- reset.reset
		dst_data  : out std_logic_vector(511 downto 0);                     --   dst.data
		dst_ready : in  std_logic                       := '0';             --      .ready
		dst_valid : out std_logic                                           --      .valid
	);
end entity IDCT_2D_hw;

architecture rtl of IDCT_2D_hw is
	type t_state is (input_src, process_data, output_dst);
	signal state : t_state;
	signal pass : std_logic;
	signal counter : unsigned(4 downto 0);

	signal in_signal0 : std_logic_vector(15 downto 0);
	signal in_signal1 : std_logic_vector(15 downto 0);
	signal in_signal2 : std_logic_vector(15 downto 0);
	signal in_signal3 : std_logic_vector(15 downto 0);
	signal in_signal4 : std_logic_vector(15 downto 0);
	signal in_signal5 : std_logic_vector(15 downto 0);
	signal in_signal6 : std_logic_vector(15 downto 0);
	signal in_signal7 : std_logic_vector(15 downto 0);

	signal out_signal0 : std_logic_vector(15 downto 0);
	signal out_signal1 : std_logic_vector(15 downto 0);
	signal out_signal2 : std_logic_vector(15 downto 0);
	signal out_signal3 : std_logic_vector(15 downto 0);
	signal out_signal4 : std_logic_vector(15 downto 0);
	signal out_signal5 : std_logic_vector(15 downto 0);
	signal out_signal6 : std_logic_vector(15 downto 0);
	signal out_signal7 : std_logic_vector(15 downto 0);

	type t_matrix is array (7 downto 0, 7 downto 0) of std_logic_vector(15 downto 0);
	signal workspace : t_matrix;
begin

	-- 1D idct entity
	idct : entity work.idct_1d(a_idct_1d)
		port map(
			clk => clk,				-- CPU system clock (always required)
			pass => pass,			-- 0: Pass 1; 1: Pass 2

			i0 => in_signal0,
			i1 => in_signal1,
			i2 => in_signal2,
			i3 => in_signal3,
			i4 => in_signal4,
			i5 => in_signal5,
			i6 => in_signal6,
			i7 => in_signal7,

			o0 => out_signal0,
			o1 => out_signal1,
			o2 => out_signal2,
			o3 => out_signal3,
			o4 => out_signal4,
			o5 => out_signal5,
			o6 => out_signal6,
			o7 => out_signal7
		);

		in_signal0 <= src_data(15 downto 0) when counter = 0 else src_data(143 downto 128) when counter = 1 else src_data(271 downto 256) when counter = 2 else src_data(399 downto 384) when counter = 3 else src_data(527 downto 512) when counter = 4 else src_data(655 downto 640) when counter = 5 else src_data(783 downto 768) when counter = 6 else src_data(911 downto 896) when counter = 7 else workspace(0, 0) when counter = 12 else workspace(1, 0) when counter = 13 else workspace(2, 0) when counter = 14 else workspace(3, 0) when counter = 15 else workspace(4, 0) when counter = 16 else workspace(5, 0) when counter = 17 else workspace(6, 0) when counter = 18 else workspace(7, 0) when counter = 19 else (others => '0');
		in_signal1 <= src_data(31 downto 16) when counter = 0 else src_data(159 downto 144) when counter = 1 else src_data(287 downto 272) when counter = 2 else src_data(415 downto 400) when counter = 3 else src_data(543 downto 528) when counter = 4 else src_data(671 downto 656) when counter = 5 else src_data(799 downto 784) when counter = 6 else src_data(927 downto 912) when counter = 7 else workspace(0, 1) when counter = 12 else workspace(1, 1) when counter = 13 else workspace(2, 1) when counter = 14 else workspace(3, 1) when counter = 15 else workspace(4, 1) when counter = 16 else workspace(5, 1) when counter = 17 else workspace(6, 1) when counter = 18 else workspace(7, 1) when counter = 19 else (others => '0');
		in_signal2 <= src_data(47 downto 32) when counter = 0 else src_data(175 downto 160) when counter = 1 else src_data(303 downto 288) when counter = 2 else src_data(431 downto 416) when counter = 3 else src_data(559 downto 544) when counter = 4 else src_data(687 downto 672) when counter = 5 else src_data(815 downto 800) when counter = 6 else src_data(943 downto 928) when counter = 7 else workspace(0, 2) when counter = 12 else workspace(1, 2) when counter = 13 else workspace(2, 2) when counter = 14 else workspace(3, 2) when counter = 15 else workspace(4, 2) when counter = 16 else workspace(5, 2) when counter = 17 else workspace(6, 2) when counter = 18 else workspace(7, 2) when counter = 19 else (others => '0');
		in_signal3 <= src_data(63 downto 48) when counter = 0 else src_data(191 downto 176) when counter = 1 else src_data(319 downto 304) when counter = 2 else src_data(447 downto 432) when counter = 3 else src_data(575 downto 560) when counter = 4 else src_data(703 downto 688) when counter = 5 else src_data(831 downto 816) when counter = 6 else src_data(959 downto 944) when counter = 7 else workspace(0, 3) when counter = 12 else workspace(1, 3) when counter = 13 else workspace(2, 3) when counter = 14 else workspace(3, 3) when counter = 15 else workspace(4, 3) when counter = 16 else workspace(5, 3) when counter = 17 else workspace(6, 3) when counter = 18 else workspace(7, 3) when counter = 19 else (others => '0');
		in_signal4 <= src_data(79 downto 64) when counter = 0 else src_data(207 downto 192) when counter = 1 else src_data(335 downto 320) when counter = 2 else src_data(463 downto 448) when counter = 3 else src_data(591 downto 576) when counter = 4 else src_data(719 downto 704) when counter = 5 else src_data(847 downto 832) when counter = 6 else src_data(975 downto 960) when counter = 7 else workspace(0, 4) when counter = 12 else workspace(1, 4) when counter = 13 else workspace(2, 4) when counter = 14 else workspace(3, 4) when counter = 15 else workspace(4, 4) when counter = 16 else workspace(5, 4) when counter = 17 else workspace(6, 4) when counter = 18 else workspace(7, 4) when counter = 19 else (others => '0');
		in_signal5 <= src_data(95 downto 80) when counter = 0 else src_data(223 downto 208) when counter = 1 else src_data(351 downto 336) when counter = 2 else src_data(479 downto 464) when counter = 3 else src_data(607 downto 592) when counter = 4 else src_data(735 downto 720) when counter = 5 else src_data(863 downto 848) when counter = 6 else src_data(991 downto 976) when counter = 7 else workspace(0, 5) when counter = 12 else workspace(1, 5) when counter = 13 else workspace(2, 5) when counter = 14 else workspace(3, 5) when counter = 15 else workspace(4, 5) when counter = 16 else workspace(5, 5) when counter = 17 else workspace(6, 5) when counter = 18 else workspace(7, 5) when counter = 19 else (others => '0');
		in_signal6 <= src_data(111 downto 96) when counter = 0 else src_data(239 downto 224) when counter = 1 else src_data(367 downto 352) when counter = 2 else src_data(495 downto 480) when counter = 3 else src_data(623 downto 608) when counter = 4 else src_data(751 downto 736) when counter = 5 else src_data(879 downto 864) when counter = 6 else src_data(1007 downto 992) when counter = 7 else workspace(0, 6) when counter = 12 else workspace(1, 6) when counter = 13 else workspace(2, 6) when counter = 14 else workspace(3, 6) when counter = 15 else workspace(4, 6) when counter = 16 else workspace(5, 6) when counter = 17 else workspace(6, 6) when counter = 18 else workspace(7, 6) when counter = 19 else (others => '0');
		in_signal7 <= src_data(127 downto 112) when counter = 0 else src_data(255 downto 240) when counter = 1 else src_data(383 downto 368) when counter = 2 else src_data(511 downto 496) when counter = 3 else src_data(639 downto 624) when counter = 4 else src_data(767 downto 752) when counter = 5 else src_data(895 downto 880) when counter = 6 else src_data(1023 downto 1008) when counter = 7 else workspace(0, 7) when counter = 12 else workspace(1, 7) when counter = 13 else workspace(2, 7) when counter = 14 else workspace(3, 7) when counter = 15 else workspace(4, 7) when counter = 16 else workspace(5, 7) when counter = 17 else workspace(6, 7) when counter = 18 else workspace(7, 7) when counter = 19 else (others => '0');

		dst_data <= workspace(7, 7)(7 downto 0) & workspace(6, 7)(7 downto 0) & workspace(5, 7)(7 downto 0) & workspace(4, 7)(7 downto 0) & workspace(3, 7)(7 downto 0) & workspace(2, 7)(7 downto 0) & workspace(1, 7)(7 downto 0) & workspace(0, 7)(7 downto 0) & workspace(7, 6)(7 downto 0) & workspace(6, 6)(7 downto 0) & workspace(5, 6)(7 downto 0) & workspace(4, 6)(7 downto 0) & workspace(3, 6)(7 downto 0) & workspace(2, 6)(7 downto 0) & workspace(1, 6)(7 downto 0) & workspace(0, 6)(7 downto 0) & workspace(7, 5)(7 downto 0) & workspace(6, 5)(7 downto 0) & workspace(5, 5)(7 downto 0) & workspace(4, 5)(7 downto 0) & workspace(3, 5)(7 downto 0) & workspace(2, 5)(7 downto 0) & workspace(1, 5)(7 downto 0) & workspace(0, 5)(7 downto 0) & workspace(7, 4)(7 downto 0) & workspace(6, 4)(7 downto 0) & workspace(5, 4)(7 downto 0) & workspace(4, 4)(7 downto 0) & workspace(3, 4)(7 downto 0) & workspace(2, 4)(7 downto 0) & workspace(1, 4)(7 downto 0) & workspace(0, 4)(7 downto 0) & workspace(7, 3)(7 downto 0) & workspace(6, 3)(7 downto 0) & workspace(5, 3)(7 downto 0) & workspace(4, 3)(7 downto 0) & workspace(3, 3)(7 downto 0) & workspace(2, 3)(7 downto 0) & workspace(1, 3)(7 downto 0) & workspace(0, 3)(7 downto 0) & workspace(7, 2)(7 downto 0) & workspace(6, 2)(7 downto 0) & workspace(5, 2)(7 downto 0) & workspace(4, 2)(7 downto 0) & workspace(3, 2)(7 downto 0) & workspace(2, 2)(7 downto 0) & workspace(1, 2)(7 downto 0) & workspace(0, 2)(7 downto 0) & workspace(7, 1)(7 downto 0) & workspace(6, 1)(7 downto 0) & workspace(5, 1)(7 downto 0) & workspace(4, 1)(7 downto 0) & workspace(3, 1)(7 downto 0) & workspace(2, 1)(7 downto 0) & workspace(1, 1)(7 downto 0) & workspace(0, 1)(7 downto 0) & workspace(7, 0)(7 downto 0) & workspace(6, 0)(7 downto 0) & workspace(5, 0)(7 downto 0) & workspace(4, 0)(7 downto 0) & workspace(3, 0)(7 downto 0) & workspace(2, 0)(7 downto 0) & workspace(1, 0)(7 downto 0) & workspace(0, 0)(7 downto 0);
		pass <= '0' when counter < 12 else '1';

process begin
	wait until rising_edge(clk);
	if reset = '1' then
		state <= input_src;
		src_ready <= '0';
		dst_valid <= '0';
		counter <= (others => '0');
	else
		case state is
			when input_src =>
				if src_valid = '1' then
					src_ready <= '0';
					state <= process_data;
				end if;
			when process_data =>
				if ((counter > 3) and (counter < 12)) then
					workspace(0, to_integer(counter - 4)) <= out_signal0;
					workspace(1, to_integer(counter - 4)) <= out_signal1;
					workspace(2, to_integer(counter - 4)) <= out_signal2;
					workspace(3, to_integer(counter - 4)) <= out_signal3;
					workspace(4, to_integer(counter - 4)) <= out_signal4;
					workspace(5, to_integer(counter - 4)) <= out_signal5;
					workspace(6, to_integer(counter - 4)) <= out_signal6;
					workspace(7, to_integer(counter - 4)) <= out_signal7;
				elsif counter > 15 then
					workspace(to_integer(counter - 16), 0) <= out_signal0;
					workspace(to_integer(counter - 16), 1) <= out_signal1;
					workspace(to_integer(counter - 16), 2) <= out_signal2;
					workspace(to_integer(counter - 16), 3) <= out_signal3;
					workspace(to_integer(counter - 16), 4) <= out_signal4;
					workspace(to_integer(counter - 16), 5) <= out_signal5;
					workspace(to_integer(counter - 16), 6) <= out_signal6;
					workspace(to_integer(counter - 16), 7) <= out_signal7;
				end if;
				if counter = 23 then
					state <= output_dst;
					dst_valid <= '1';
				end if;
				counter <= counter + 1;

			when output_dst =>
				if dst_ready = '1' then
					dst_valid <= '0';
					counter <= (others => '0');
					state <= input_src;
					src_ready <= '1';
				end if;
		end case;
	end if;

end process;

end architecture rtl; -- of IDCT_2D_hw
