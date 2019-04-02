library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity byte_order_adapter is
	generic (
		Width : integer := 32
	);
	port (
		clk		   : in  std_logic;
		reset	   : in  std_logic;
		src_ready  : in  std_logic                     := '0';             --  src.ready
		src_valid  : out std_logic;                                        --     .valid
		src_data   : out std_logic_vector(Width-1 downto 0);                    --     .data
		sink_valid : in  std_logic                     := '0';             -- sink.valid
		sink_data  : in  std_logic_vector(Width-1 downto 0) := (others => '0'); --     .data
		sink_ready : out std_logic                                         --     .ready
	);
end entity byte_order_adapter;

architecture rtl of byte_order_adapter is
	-- changes the endianess BIG <-> LITTLE
	function ChangeEndian(vec : std_logic_vector) return std_logic_vector is
		variable vRet      : std_logic_vector(vec'range);
		constant cNumBytes : natural := vec'length / 8;
		begin
			for i in 0 to cNumBytes-1 loop
				for j in 7 downto 0 loop
					vRet(8*i + j) := vec(8*(cNumBytes-1-i) + j);
				end loop;  -- j
			end loop;  -- i
		return vRet;
	end function ChangeEndian;
begin

	src_valid <= sink_valid;
	sink_ready <= src_ready;

	src_data <= ChangeEndian(sink_data);

end architecture rtl; -- of byte_order_adapter
