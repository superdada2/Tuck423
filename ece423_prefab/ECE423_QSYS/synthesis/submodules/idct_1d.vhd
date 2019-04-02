-- 1D IDCT
--
-- Computes the 1D IDCT with 8bits color components
-- This implementation performs all 12 multiplications in parallel,
-- and thus computes the output values in one clock cycle
--
-- Port usage:
---- i0, ..., i7: input coefficients, signed 16 bits
---- o0, ..., o7: output coefficients, signed 16 bits
---- pass: determine the pass: 0 = Pass1, 1 = Pass2
--
-- See Section 4.3 in the Lab Manual for a detailed explanation
-- of how the 1D IDCT is used to compute the 2D IDCT, and how
-- the bits scaling is performed between passes.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity idct_1D is
generic(
	CONST_BITS: integer := 13;
	PASS1_BITS: integer := 2
);
port(
	signal clk: in std_logic;				-- CPU system clock (always required)

	signal pass : in std_logic;			-- 0: Pass 1; 1: Pass 2

	signal i0: in std_logic_vector(15 downto 0);
	signal i1: in std_logic_vector(15 downto 0);
	signal i2: in std_logic_vector(15 downto 0);
	signal i3: in std_logic_vector(15 downto 0);
	signal i4: in std_logic_vector(15 downto 0);
	signal i5: in std_logic_vector(15 downto 0);
	signal i6: in std_logic_vector(15 downto 0);
	signal i7: in std_logic_vector(15 downto 0);

	signal o0: out std_logic_vector(15 downto 0);
	signal o1: out std_logic_vector(15 downto 0);
	signal o2: out std_logic_vector(15 downto 0);
	signal o3: out std_logic_vector(15 downto 0);
	signal o4: out std_logic_vector(15 downto 0);
	signal o5: out std_logic_vector(15 downto 0);
	signal o6: out std_logic_vector(15 downto 0);
	signal o7: out std_logic_vector(15 downto 0)
);
end entity idct_1D;

architecture a_idct_1D of idct_1D is

	-- local signals

	constant FIX_0_298631336 : signed (15 downto 0) := TO_SIGNED(2446, 16);
	constant FIX_M0_390180644 : signed (14 downto 0) := TO_SIGNED(-3196, 15);
	constant FIX_0_541196100 : signed (14 downto 0) := TO_SIGNED(4433, 15);
	constant FIX_0_765366865 : signed (14 downto 0) := TO_SIGNED(6270, 15);
	constant FIX_M0_899976223 : signed (14 downto 0) := TO_SIGNED(-7373, 15);
	constant FIX_1_175875602 : signed (14 downto 0) := TO_SIGNED(9633, 15);
	constant FIX_1_501321110 : signed (15 downto 0) := TO_SIGNED(12299, 16);
	constant FIX_M1_847759065 : signed (14 downto 0) := TO_SIGNED(-15137, 15);
	constant FIX_M1_961570560 : signed (14 downto 0) := TO_SIGNED(-16069, 15);
	constant FIX_2_053119869 : signed (15 downto 0) := TO_SIGNED(16819, 16);
	constant FIX_M2_562915447 : signed (15 downto 0) := TO_SIGNED(-20995, 16);
	constant FIX_3_072711026 : signed (15 downto 0) := TO_SIGNED(25172, 16);

	signal roundP1 : signed (31 downto 0);
	signal roundP2 : signed (31 downto 0);

	signal zm26 : signed (31 downto 0);
	signal zm26m6 : signed (31 downto 0);
	signal zm26m2 : signed (31 downto 0);
	signal zm26m6tmp : signed (31 downto 0);
	signal zm26m2tmp : signed (31 downto 0);
	signal z04 : signed (CONST_BITS+16 downto 0);
	signal z40 : signed (CONST_BITS+16 downto 0);

	signal tmp10 : signed (31 downto 0);
	signal tmp13 : signed (31 downto 0);
	signal tmp11 : signed (31 downto 0);
	signal tmp12 : signed (31 downto 0);

	signal tmp10_r : signed (31 downto 0);
	signal tmp13_r : signed (31 downto 0);
	signal tmp11_r : signed (31 downto 0);
	signal tmp12_r : signed (31 downto 0);

	signal z71 : signed (16 downto 0);
	signal z53 : signed (16 downto 0);
	signal z73 : signed (16 downto 0);
	signal z51 : signed (16 downto 0);

	signal zm7351 : signed (31 downto 0);
	signal zm7 : signed (31 downto 0);
	signal zm5 : signed (31 downto 0);
	signal zm3 : signed (31 downto 0);
	signal zm1 : signed (31 downto 0);
	signal zm71 : signed (31 downto 0);
	signal zm53 : signed (31 downto 0);
	signal zm73 : signed (31 downto 0);
	signal zm51 : signed (31 downto 0);
	signal zm73m : signed (31 downto 0);
	signal zm51m : signed (31 downto 0);

	signal zm7351tmp : signed (32 downto 0);
	signal zm53tmp : signed (32 downto 0);

	signal tmp0 : signed (31 downto 0);
	signal tmp1 : signed (31 downto 0);
	signal tmp2 : signed (31 downto 0);
	signal tmp3 : signed (31 downto 0);

	signal tmp0_r : signed (31 downto 0);
	signal tmp1_r : signed (31 downto 0);
	signal tmp2_r : signed (31 downto 0);
	signal tmp3_r : signed (31 downto 0);

	signal out0 : signed (31 downto 0);
	signal out1 : signed (31 downto 0);
	signal out2 : signed (31 downto 0);
	signal out3 : signed (31 downto 0);
	signal out4 : signed (31 downto 0);
	signal out5 : signed (31 downto 0);
	signal out6 : signed (31 downto 0);
	signal out7 : signed (31 downto 0);

	signal out0P1 : signed (31 downto 0);
	signal out1P1 : signed (31 downto 0);
	signal out2P1 : signed (31 downto 0);
	signal out3P1 : signed (31 downto 0);
	signal out4P1 : signed (31 downto 0);
	signal out5P1 : signed (31 downto 0);
	signal out6P1 : signed (31 downto 0);
	signal out7P1 : signed (31 downto 0);

	signal out0P2 : signed (31 downto 0);
	signal out1P2 : signed (31 downto 0);
	signal out2P2 : signed (31 downto 0);
	signal out3P2 : signed (31 downto 0);
	signal out4P2 : signed (31 downto 0);
	signal out5P2 : signed (31 downto 0);
	signal out6P2 : signed (31 downto 0);
	signal out7P2 : signed (31 downto 0);

	signal o0_tmp : std_logic_vector (15 downto 0);
	signal o1_tmp : std_logic_vector (15 downto 0);
	signal o2_tmp : std_logic_vector (15 downto 0);
	signal o3_tmp : std_logic_vector (15 downto 0);
	signal o4_tmp : std_logic_vector (15 downto 0);
	signal o5_tmp : std_logic_vector (15 downto 0);
	signal o6_tmp : std_logic_vector (15 downto 0);
	signal o7_tmp : std_logic_vector (15 downto 0);

	-- Registers

	signal zm26_r : signed (31 downto 0);
	signal zm26m6tmp_r : signed (31 downto 0);
	signal zm26m2tmp_r : signed (31 downto 0);
	signal z04_r : signed (CONST_BITS+16 downto 0);
	signal z40_r : signed (CONST_BITS+16 downto 0);

	signal zm7351_r : signed (31 downto 0);
	signal zm7_r : signed (31 downto 0);
	signal zm5_r : signed (31 downto 0);
	signal zm3_r : signed (31 downto 0);
	signal zm1_r : signed (31 downto 0);
	signal zm71_r : signed (31 downto 0);
	signal zm53_r : signed (31 downto 0);
	signal zm73_r : signed (31 downto 0);
	signal zm51_r : signed (31 downto 0);

	signal out0_r : signed (31 downto 0);
	signal out1_r : signed (31 downto 0);
	signal out2_r : signed (31 downto 0);
	signal out3_r : signed (31 downto 0);
	signal out4_r : signed (31 downto 0);
	signal out5_r : signed (31 downto 0);
	signal out6_r : signed (31 downto 0);
	signal out7_r : signed (31 downto 0);

	signal i0_r: std_logic_vector(15 downto 0);
	signal i1_r: std_logic_vector(15 downto 0);
	signal i2_r: std_logic_vector(15 downto 0);
	signal i3_r: std_logic_vector(15 downto 0);
	signal i4_r: std_logic_vector(15 downto 0);
	signal i5_r: std_logic_vector(15 downto 0);
	signal i6_r: std_logic_vector(15 downto 0);
	signal i7_r: std_logic_vector(15 downto 0);

begin

	roundP1(31 downto CONST_BITS-PASS1_BITS) <= (others => '0');
	roundP1(CONST_BITS-PASS1_BITS-1) <= '1';
	roundP1(CONST_BITS-PASS1_BITS-2 downto 0) <= (others => '0');

	roundP2(31 downto CONST_BITS+PASS1_BITS+3) <= (others => '0');
	roundP2(CONST_BITS+PASS1_BITS+2) <= '1';
	roundP2(CONST_BITS+PASS1_BITS+1 downto 0) <= (others => '0');

	-- even part

	zm26 <= (signed(i2_r(15) & i2_r) + signed(i6_r(15) & i6_r)) * FIX_0_541196100;
	zm26m6tmp <= signed(i6_r(15) & i6_r) * FIX_M1_847759065;
	zm26m2tmp <= signed(i2_r(15) & i2_r) * FIX_0_765366865;

	z04(CONST_BITS+16 downto CONST_BITS) <= signed(i0_r(15) & i0_r) + signed(i4_r(15) & i4_r);
	z04(CONST_BITS-1 downto 0) <= (others => '0');
	z40(CONST_BITS+16 downto CONST_BITS) <= signed(i0_r(15) & i0_r) - signed(i4_r(15) & i4_r);
	z40(CONST_BITS-1 downto 0) <= (others => '0');

	zm26m6 <= zm26_r + zm26m6tmp_r;
	zm26m2 <= zm26_r + zm26m2tmp_r;

	tmp10 <= z04_r + zm26m2;
	tmp13 <= z04_r - zm26m2;
	tmp11 <= z40_r + zm26m6;
	tmp12 <= z40_r - zm26m6;

	-- odd part

	z71 <= (signed(i7_r(15) & i7_r) + signed(i1_r(15) & i1_r));
	z53 <= (signed(i5_r(15) & i5_r) + signed(i3_r(15) & i3_r));
	z73 <= (signed(i7_r(15) & i7_r) + signed(i3_r(15) & i3_r));
	z51 <= (signed(i5_r(15) & i5_r) + signed(i1_r(15) & i1_r));

	zm7351tmp <= ((z73(16) & z73) + (z51(16) & z51)) * FIX_1_175875602;
	zm7351 <= zm7351tmp(31 downto 0);

	zm7 <= signed(i7_r) * FIX_0_298631336;
	zm5 <= signed(i5_r) * FIX_2_053119869;
	zm3 <= signed(i3_r) * FIX_3_072711026;
	zm1 <= signed(i1_r) * FIX_1_501321110;

	zm71 <= z71 * FIX_M0_899976223;
	zm53tmp <= z53 * FIX_M2_562915447;
	zm53 <= zm53tmp(31 downto 0);
	zm73 <= z73 * FIX_M1_961570560;
	zm51 <= z51 * FIX_M0_390180644;

	zm73m <= zm73_r + zm7351_r;
	zm51m <= zm51_r + zm7351_r;

	tmp0 <= zm7_r + zm71_r + zm73m;
	tmp1 <= zm5_r + zm53_r + zm51m;
	tmp2 <= zm3_r + zm53_r + zm73m;
	tmp3 <= zm1_r + zm71_r + zm51m;


	-- final

	out0 <= tmp10_r + tmp3_r;
	out7 <= tmp10_r - tmp3_r;
	out1 <= tmp11_r + tmp2_r;
	out6 <= tmp11_r - tmp2_r;
	out2 <= tmp12_r + tmp1_r;
	out5 <= tmp12_r - tmp1_r;
	out3 <= tmp13_r + tmp0_r;
	out4 <= tmp13_r - tmp0_r;

	out0P1 <= out0_r + roundP1;
	out1P1 <= out1_r + roundP1;
	out2P1 <= out2_r + roundP1;
	out3P1 <= out3_r + roundP1;
	out4P1 <= out4_r + roundP1;
	out5P1 <= out5_r + roundP1;
	out6P1 <= out6_r + roundP1;
	out7P1 <= out7_r + roundP1;

	out0P2 <= out0_r + roundP2;
	out1P2 <= out1_r + roundP2;
	out2P2 <= out2_r + roundP2;
	out3P2 <= out3_r + roundP2;
	out4P2 <= out4_r + roundP2;
	out5P2 <= out5_r + roundP2;
	out6P2 <= out6_r + roundP2;
	out7P2 <= out7_r + roundP2;

	o0_tmp <= 		std_logic_vector(out0P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out0P2(31) = '1' else
					"0000000011111111" when out0P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out0P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o1_tmp <= 		std_logic_vector(out1P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out1P2(31) = '1' else
					"0000000011111111" when out1P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out1P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o2_tmp <= 		std_logic_vector(out2P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out2P2(31) = '1' else
					"0000000011111111" when out2P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out2P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o3_tmp <= 		std_logic_vector(out3P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out3P2(31) = '1' else
					"0000000011111111" when out3P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out3P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o4_tmp <= 		std_logic_vector(out4P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out4P2(31) = '1' else
					"0000000011111111" when out4P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out4P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o5_tmp <= 		std_logic_vector(out5P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out5P2(31) = '1' else
					"0000000011111111" when out5P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out5P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o6_tmp <= 		std_logic_vector(out6P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out6P2(31) = '1' else
					"0000000011111111" when out6P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out6P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	o7_tmp <= 		std_logic_vector(out7P1(15+CONST_BITS-PASS1_BITS downto CONST_BITS-PASS1_BITS)) when pass = '0' else
					(others=>'0') when out7P2(31) = '1' else
					"0000000011111111" when out7P2(8+CONST_BITS+PASS1_BITS+3) = '1' else
					std_logic_vector("00000000" & out7P2(7+CONST_BITS+PASS1_BITS+3 downto CONST_BITS+PASS1_BITS+3));

	-------------------------------------------------------------
	process begin
		wait until rising_edge(clk);
		i0_r	<= i0;
		i1_r	<= i1;
		i2_r	<= i2;
		i3_r	<= i3;
		i4_r	<= i4;
		i5_r	<= i5;
		i6_r	<= i6;
		i7_r	<= i7;

		zm26_r			<= zm26;
		zm26m6tmp_r	<= zm26m6tmp;
		zm26m2tmp_r	<= zm26m2tmp;
		z04_r       <= z04;
		z40_r       <= z40;

		zm7351_r		<= zm7351;
		zm7_r       <= zm7;
		zm5_r       <= zm5;
		zm3_r       <= zm3;
		zm1_r       <= zm1;
		zm71_r      <= zm71;
		zm53_r      <= zm53;
		zm73_r			<= zm73;
		zm51_r			<= zm51;

		out0_r      <= out0;
		out1_r      <= out1;
		out2_r      <= out2;
		out3_r      <= out3;
		out4_r      <= out4;
		out5_r      <= out5;
		out6_r      <= out6;
		out7_r      <= out7;

		o0	<= o0_tmp;
		o1	<= o1_tmp;
		o2	<= o2_tmp;
		o3	<= o3_tmp;
		o4	<= o4_tmp;
		o5	<= o5_tmp;
		o6	<= o6_tmp;
		o7	<= o7_tmp;
	end process;

	tmp0_r			<= tmp0;
	tmp1_r			<= tmp1;
	tmp2_r			<= tmp2;
	tmp3_r			<= tmp3;

	tmp10_r			<= tmp10;
	tmp11_r			<= tmp11;
	tmp12_r			<= tmp12;
	tmp13_r			<= tmp13;

end architecture a_idct_1D;
