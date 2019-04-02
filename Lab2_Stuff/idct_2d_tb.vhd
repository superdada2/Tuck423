-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity idct_2D_tb is
	-- Default is starting with COLUMNS, if you start with ROWS change to TRUE
	generic(row_first : boolean := FALSE);
end idct_2D_tb;

architecture behavior of idct_2D_tb is

	component idct_2D port(
		clk:			in std_logic;
		reset:		in std_logic;

		dst_data:		out std_logic_vector(511 downto 0);
		dst_valid:	out std_logic;
		dst_ready:	in std_logic;

		src_data:		in std_logic_vector(1023 downto 0);
		src_valid:	in std_logic;
		src_ready:	out std_logic
    );
    end component;

    signal clk : std_logic;
	signal reset : std_logic := '1';

    signal dst_valid : std_logic := '0';
    signal dst_ready : std_logic := '0';
    signal dst_data : std_logic_vector(511 downto 0);

    signal src_valid : std_logic := '0';
    signal src_ready : std_logic := '0';
    signal src_data: std_logic_vector(1023 downto 0);

	signal dst_data_t : std_logic_vector(511 downto 0);
    signal src_data_t : std_logic_vector(1023 downto 0);


	signal block_i_no : integer := 1;
	signal block_o_no : integer := 1;

    type t_block_i is array (0 to 7, 0 to 7) of std_logic_vector(15 downto 0);
    type t_block_o is array (0 to 7, 0 to 7) of std_logic_vector(7 downto 0);

		-- input block 1 (before IDCT)
    signal block1_i : t_block_i := ((x"0064", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
    								(x"0000", x"0064", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
                                    (x"0000", x"0000", x"0064", x"0000", x"0000", x"0000", x"0000", x"0000"),
                                    (x"0000", x"0000", x"0000", x"0064", x"0000", x"0000", x"0000", x"0000"),
                                    (x"0000", x"0000", x"0000", x"0000", x"0064", x"0000", x"0000", x"0000"),
                                    (x"0000", x"0000", x"0000", x"0000", x"0000", x"0064", x"0000", x"0000"),
                                    (x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0064", x"0000"),
                                    (x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0064"));

		-- output block 1 (after IDCT)
    signal block1_o : t_block_o := ((x"64", x"00", x"00", x"00", x"00", x"00", x"00", x"00"),
    								(x"00", x"64", x"00", x"00", x"00", x"00", x"00", x"00"),
                                    (x"00", x"00", x"64", x"00", x"00", x"00", x"00", x"00"),
                                    (x"00", x"00", x"00", x"64", x"00", x"00", x"00", x"00"),
                                    (x"00", x"00", x"00", x"00", x"64", x"00", x"00", x"00"),
                                    (x"00", x"00", x"00", x"00", x"00", x"64", x"00", x"00"),
                                    (x"00", x"00", x"00", x"00", x"00", x"00", x"64", x"00"),
                                    (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"64"));

	-- input block 2 (before IDCT)
	signal block2_i : t_block_i := ((x"04D8", x"0000", x"FFF6", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"FFE8", x"FFF4", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"FFF2", x"FFF3", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"),
									(x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"));

	-- output block 2 (after IDCT) - Row first
	signal block2_o_row : t_block_o := ((x"8D", x"8F", x"92", x"95", x"97", x"99", x"99", x"99"),
										(x"91", x"93", x"95", x"97", x"99", x"99", x"99", x"99"),
										(x"98", x"99", x"9A", x"9B", x"9B", x"9B", x"99", x"98"),
										(x"9D", x"9E", x"9E", x"9F", x"9E", x"9C", x"9A", x"98"),
										(x"A0", x"A0", x"A1", x"A0", x"9F", x"9D", x"9A", x"99"),
										(x"A0", x"A0", x"A1", x"A0", x"9F", x"9D", x"9B", x"9A"),
										(x"9D", x"9E", x"9F", x"9F", x"9F", x"9E", x"9C", x"9B"),
										(x"9B", x"9C", x"9E", x"9E", x"9F", x"9E", x"9C", x"9B"));


	-- output block 2 (after IDCT) - Col first
	signal block2_o_col : t_block_o := ((x"8D", x"8F", x"92", x"95", x"97", x"99", x"99", x"99"),
										(x"91", x"93", x"95", x"97", x"99", x"99", x"99", x"99"),
										(x"98", x"99", x"9A", x"9B", x"9B", x"9B", x"99", x"98"),
										(x"9D", x"9E", x"9E", x"9F", x"9E", x"9C", x"9A", x"98"),
										(x"A0", x"A0", x"A1", x"A0", x"9F", x"9D", x"9A", x"99"),
										(x"A0", x"A0", x"A1", x"A1", x"9F", x"9D", x"9B", x"9A"),
										(x"9D", x"9E", x"9F", x"9F", x"9F", x"9E", x"9C", x"9B"),
										(x"9B", x"9C", x"9E", x"9E", x"9F", x"9E", x"9C", x"9B"));

	signal block2_o : t_block_o;

	function block_i_to_slv(slvv : t_block_i) return std_logic_vector is
		variable slv : std_logic_vector((64 * 16) - 1 downto 0);
		begin
			for i in slvv'range(1) loop
				for j in slvv'range(2) loop
				slv(128*i + 16*j + 15 downto 128*i + 16*j)	:= slvv(i, j);
				end loop;
			end loop;

			return slv;
	end function;

	function block_o_to_slv(slvv : t_block_o) return std_logic_vector is
		variable slv : std_logic_vector(64* 8 - 1 downto 0);
		begin
			for i in slvv'range(1) loop
				for j in slvv'range(2) loop
				slv(64*i + 8*j + 7 downto 64*i + 8*j)	:= slvv(i, j);
				end loop;
			end loop;
			return slv;
	end function;

begin

	block2_o <= block2_o_row when row_first else block2_o_col;

	unt : idct_2D port map(
    	clk => clk,
        reset => reset,

        dst_data => dst_data,
        dst_valid => dst_valid,
        dst_ready => dst_ready,

        src_data => src_data,
        src_valid => src_valid,
        src_ready => src_ready
    );

	-- concatenating 4 8-bit elements from the output block into 32-bit word
	src_data <= block_i_to_slv(block1_i) when block_i_no mod 2 = 1 else block_i_to_slv(block2_i);
	dst_data_t <= block_o_to_slv(block1_o) when block_o_no mod 2 = 1 else block_o_to_slv(block2_o);

	-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	-- clock generator
    clk_process : process
    begin
		clk <= '0';
        wait for 5 ns;
        clk <= '1';
    	wait for 5 ns;
    end process;


	-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	-- reset generator
    reset_process : process
    begin
		-- reset
        reset <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        reset <= '0';
		wait;
    end process;

	-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	-- sending the blocks to the IDCT component
	block_in_process : process
	begin
		-- initialization
		block_i_no <= 1;
		src_valid <= '0';
		wait until reset = '0' and rising_edge(clk);

		-- Loop over blocks
		loop
            ------------------- Send Block -----------------------
			report "------------------- Sending Block  " & integer'image(block_i_no);
			-- Stream the input
			src_valid <= '1';
			wait until src_ready = '1' and rising_edge(clk);
			block_i_no <= block_i_no + 1;
            report "------------------- (Block " & integer'image(block_i_no) & " Sent)";
            if block_i_no = 1 then
            	src_valid <= '0';
            	wait until block_o_no = 2;
                for i in 1 to 10 loop
            		wait until rising_edge(clk);
            	end loop;
            elsif block_i_no mod 2 = 0 then
				src_valid <= '0';
                for i in 1 to 10 loop
                	wait until rising_edge(clk);
                end loop;
            end if;
		end loop;
	end process;

	-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	-- receiving the blocks from the IDCT component
	block_out_process : process
	begin
        dst_ready <= '1';
		block_o_no <= 1;
		wait until reset = '0';

			------------------- Receive Block -----------------------
		loop
			report "------------------- Receiving Block  " & integer'image(block_o_no);
			-- Check the output
			wait until dst_valid = '1' and rising_edge(clk);
			report "------------------- (Block " & integer'image(block_o_no) & " Recieved)";
            assert dst_data = dst_data_t report " --- INCORRECT" severity FAILURE;
           	if dst_ready = '0' then
              if block_o_no = 2 then
                for i in 1 to 10 loop
                  wait until rising_edge(clk);
                end loop;
              end if;
              if dst_valid = '0' then
              	report "dst_valid is deasserted before dst_ready = '1'" severity FAILURE;
              end if;
              dst_ready <= '1';
            else
              dst_ready <= '0';
            end if;

            wait until rising_edge(clk);
			block_o_no <= block_o_no + 1;

            exit when block_o_no = 5;

		end loop;

        report "OK   ### Sim end: OK :-) (This is not a acutal FAILURE)"  severity FAILURE;
	end process;

	-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

end architecture;
