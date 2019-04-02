-- mpeg_accel.vhd

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

entity mpeg_accel is
    port (
        clk       : in  std_logic                       := '0';             -- clock_sink.clk
        dst_data  : out std_logic_vector(1023 downto 0);                    --        dst.data
        dst_ready : in  std_logic                       := '0';             --           .ready
        dst_valid : out std_logic;                                          --           .valid
        reset     : in  std_logic                       := '0';             --      reset.reset
        y_data    : in  std_logic_vector(1023 downto 0) := (others => '0'); --      src_y.data
        y_ready   : out std_logic;                                          --           .ready
        y_valid   : in  std_logic                       := '0';             --           .valid
        cb_data   : in  std_logic_vector(1023 downto 0) := (others => '0'); --     src_cb.data
        cb_ready  : out std_logic;                                          --           .ready
        cb_valid  : in  std_logic                       := '0';             --           .valid
        cr_data   : in  std_logic_vector(1023 downto 0) := (others => '0'); --     src_cr.data
        cr_ready  : out std_logic;                                          --           .ready
        cr_valid  : in  std_logic                       := '0'              --           .valid
    );
end entity mpeg_accel;

architecture rtl of mpeg_accel is
  signal y_out          : std_logic_vector(511 downto 0);
  signal cb_out         : std_logic_vector(511 downto 0);
  signal cr_out         : std_logic_vector(511 downto 0);
  signal y_valid_int    : std_logic;
  signal cb_valid_int   : std_logic;
  signal cr_valid_int   : std_logic;
  signal combined_valid : std_logic;
  signal gated_ready    : std_logic;
  signal first_transfer : std_logic;
begin

    y_idct : entity work.IDCT_2D_hw(rtl)
        port map(
            src_data  => y_data,
            src_valid => y_valid,
            src_ready => y_ready,
            clk => clk,
            reset => reset,
            dst_data => y_out,
            dst_ready => gated_ready,
            dst_valid => y_valid_int
        );

    cb_idct : entity work.IDCT_2D_hw(rtl)
        port map(
            src_data  => cb_data,
            src_valid => cb_valid,
            src_ready => cb_ready,
            clk => clk,
            reset => reset,
            dst_data => cb_out,
            dst_ready => gated_ready,
            dst_valid => cb_valid_int
        );


    cr_idct : entity work.IDCT_2D_hw(rtl)
        port map(
            src_data  => cr_data,
            src_valid => cr_valid,
            src_ready => cr_ready,
            clk => clk,
            reset => reset,
            dst_data => cr_out,
            dst_ready => gated_ready,
            dst_valid => cr_valid_int
        );

        combined_valid <= y_valid_int and cb_valid_int and cr_valid_int;
        dst_valid <= combined_valid;

        gated_ready <= dst_ready when combined_valid = '1' and first_transfer = '1' else '0';

        dst_data <= "00000000" & cr_out(511 downto 504) & y_out(511 downto 504) & cb_out(511 downto 504) & "00000000" & cr_out(503 downto 496) & y_out(503 downto 496) & cb_out(503 downto 496) & "00000000" & cr_out(495 downto 488) & y_out(495 downto 488) & cb_out(495 downto 488) & "00000000" & cr_out(487 downto 480) & y_out(487 downto 480) & cb_out(487 downto 480) & "00000000" & cr_out(479 downto 472) & y_out(479 downto 472) & cb_out(479 downto 472) & "00000000" & cr_out(471 downto 464) & y_out(471 downto 464) & cb_out(471 downto 464) & "00000000" & cr_out(463 downto 456) & y_out(463 downto 456) & cb_out(463 downto 456) & "00000000" & cr_out(455 downto 448) & y_out(455 downto 448) & cb_out(455 downto 448) & "00000000" & cr_out(447 downto 440) & y_out(447 downto 440) & cb_out(447 downto 440) & "00000000" & cr_out(439 downto 432) & y_out(439 downto 432) & cb_out(439 downto 432) & "00000000" & cr_out(431 downto 424) & y_out(431 downto 424) & cb_out(431 downto 424) & "00000000" & cr_out(423 downto 416) & y_out(423 downto 416) & cb_out(423 downto 416) & "00000000" & cr_out(415 downto 408) & y_out(415 downto 408) & cb_out(415 downto 408) & "00000000" & cr_out(407 downto 400) & y_out(407 downto 400) & cb_out(407 downto 400) & "00000000" & cr_out(399 downto 392) & y_out(399 downto 392) & cb_out(399 downto 392) & "00000000" & cr_out(391 downto 384) & y_out(391 downto 384) & cb_out(391 downto 384) & "00000000" & cr_out(383 downto 376) & y_out(383 downto 376) & cb_out(383 downto 376) & "00000000" & cr_out(375 downto 368) & y_out(375 downto 368) & cb_out(375 downto 368) & "00000000" & cr_out(367 downto 360) & y_out(367 downto 360) & cb_out(367 downto 360) & "00000000" & cr_out(359 downto 352) & y_out(359 downto 352) & cb_out(359 downto 352) & "00000000" & cr_out(351 downto 344) & y_out(351 downto 344) & cb_out(351 downto 344) & "00000000" & cr_out(343 downto 336) & y_out(343 downto 336) & cb_out(343 downto 336) & "00000000" & cr_out(335 downto 328) & y_out(335 downto 328) & cb_out(335 downto 328) & "00000000" & cr_out(327 downto 320) & y_out(327 downto 320) & cb_out(327 downto 320) & "00000000" & cr_out(319 downto 312) & y_out(319 downto 312) & cb_out(319 downto 312) & "00000000" & cr_out(311 downto 304) & y_out(311 downto 304) & cb_out(311 downto 304) & "00000000" & cr_out(303 downto 296) & y_out(303 downto 296) & cb_out(303 downto 296) & "00000000" & cr_out(295 downto 288) & y_out(295 downto 288) & cb_out(295 downto 288) & "00000000" & cr_out(287 downto 280) & y_out(287 downto 280) & cb_out(287 downto 280) & "00000000" & cr_out(279 downto 272) & y_out(279 downto 272) & cb_out(279 downto 272) & "00000000" & cr_out(271 downto 264) & y_out(271 downto 264) & cb_out(271 downto 264) & "00000000" & cr_out(263 downto 256) & y_out(263 downto 256) & cb_out(263 downto 256) when first_transfer = '0' else "00000000" & cr_out(255 downto 248) & y_out(255 downto 248) & cb_out(255 downto 248) & "00000000" & cr_out(247 downto 240) & y_out(247 downto 240) & cb_out(247 downto 240) & "00000000" & cr_out(239 downto 232) & y_out(239 downto 232) & cb_out(239 downto 232) & "00000000" & cr_out(231 downto 224) & y_out(231 downto 224) & cb_out(231 downto 224) & "00000000" & cr_out(223 downto 216) & y_out(223 downto 216) & cb_out(223 downto 216) & "00000000" & cr_out(215 downto 208) & y_out(215 downto 208) & cb_out(215 downto 208) & "00000000" & cr_out(207 downto 200) & y_out(207 downto 200) & cb_out(207 downto 200) & "00000000" & cr_out(199 downto 192) & y_out(199 downto 192) & cb_out(199 downto 192) & "00000000" & cr_out(191 downto 184) & y_out(191 downto 184) & cb_out(191 downto 184) & "00000000" & cr_out(183 downto 176) & y_out(183 downto 176) & cb_out(183 downto 176) & "00000000" & cr_out(175 downto 168) & y_out(175 downto 168) & cb_out(175 downto 168) & "00000000" & cr_out(167 downto 160) & y_out(167 downto 160) & cb_out(167 downto 160) & "00000000" & cr_out(159 downto 152) & y_out(159 downto 152) & cb_out(159 downto 152) & "00000000" & cr_out(151 downto 144) & y_out(151 downto 144) & cb_out(151 downto 144) & "00000000" & cr_out(143 downto 136) & y_out(143 downto 136) & cb_out(143 downto 136) & "00000000" & cr_out(135 downto 128) & y_out(135 downto 128) & cb_out(135 downto 128) & "00000000" & cr_out(127 downto 120) & y_out(127 downto 120) & cb_out(127 downto 120) & "00000000" & cr_out(119 downto 112) & y_out(119 downto 112) & cb_out(119 downto 112) & "00000000" & cr_out(111 downto 104) & y_out(111 downto 104) & cb_out(111 downto 104) & "00000000" & cr_out(103 downto 96) & y_out(103 downto 96) & cb_out(103 downto 96) & "00000000" & cr_out(95 downto 88) & y_out(95 downto 88) & cb_out(95 downto 88) & "00000000" & cr_out(87 downto 80) & y_out(87 downto 80) & cb_out(87 downto 80) & "00000000" & cr_out(79 downto 72) & y_out(79 downto 72) & cb_out(79 downto 72) & "00000000" & cr_out(71 downto 64) & y_out(71 downto 64) & cb_out(71 downto 64) & "00000000" & cr_out(63 downto 56) & y_out(63 downto 56) & cb_out(63 downto 56) & "00000000" & cr_out(55 downto 48) & y_out(55 downto 48) & cb_out(55 downto 48) & "00000000" & cr_out(47 downto 40) & y_out(47 downto 40) & cb_out(47 downto 40) & "00000000" & cr_out(39 downto 32) & y_out(39 downto 32) & cb_out(39 downto 32) & "00000000" & cr_out(31 downto 24) & y_out(31 downto 24) & cb_out(31 downto 24) & "00000000" & cr_out(23 downto 16) & y_out(23 downto 16) & cb_out(23 downto 16) & "00000000" & cr_out(15 downto 8) & y_out(15 downto 8) & cb_out(15 downto 8) & "00000000" & cr_out(7 downto 0) & y_out(7 downto 0) & cb_out(7 downto 0);

    process begin
        wait until rising_edge(clk);
        if (reset = '1') then
            first_transfer <= '0';
        elsif (combined_valid = '1' and dst_ready = '1') then
            first_transfer <= not first_transfer;
        end if;
    end process;
end architecture rtl; -- of mpeg_accel
