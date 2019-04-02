-- IDCT_2D_hw.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

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
constant RES: std_logic_vector(511 downto 0) := (others => '1');
signal busy: std_logic:= '0';
begin

	-- TODO: Auto-generated HDL template
	src_ready <= '1';
	dst_valid <= '1';
	dst_data <= RES and "111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000111000";

end architecture rtl; -- of IDCT_2D_hw
