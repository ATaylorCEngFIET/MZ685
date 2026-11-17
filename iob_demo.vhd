-- iob_demo.vhd
-- MicroZed Chronicles: IOB register packing demonstrator.
--
-- Five 16-bit output buses and one 16-bit input bus, each coded in a different
-- style so the placement of the register can be compared after place_design.
--
--   pad_a  register drives the pad and nothing else           -> packs (OLOGIC)
--   pad_b  gate between the register and the pad              -> cannot pack
--   pad_c  register drives the pad and internal logic         -> conflict
--   pad_d  fix for pad_b: gate moved in front of the register -> packs
--   pad_e  fix for pad_c: register duplicated by hand         -> packs
--   din    input capture register fed only by the pad         -> packs (ILOGIC)
--
-- d_in and din_q are registered in the fabric on the far side of each I/O
-- register so that every register carrying IOB TRUE touches exactly one pad.
library ieee;
use ieee.std_logic_1164.all;

entity iob_demo is
  port (
    clk      : in  std_logic;
    d_in     : in  std_logic_vector(15 downto 0);
    oe_n     : in  std_logic;
    pad_a    : out std_logic_vector(15 downto 0);
    pad_b    : out std_logic_vector(15 downto 0);
    pad_c    : out std_logic_vector(15 downto 0);
    pad_d    : out std_logic_vector(15 downto 0);
    pad_e    : out std_logic_vector(15 downto 0);
    parity_c : out std_logic;
    parity_e : out std_logic;
    din_pad  : in  std_logic_vector(15 downto 0);
    din_q    : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of iob_demo is

  -- fabric side pipeline registers
  signal src      : std_logic_vector(15 downto 0) := (others => '0');
  signal oe_n_r   : std_logic := '1';
  signal din_r    : std_logic_vector(15 downto 0) := (others => '0');
  signal par_c_r  : std_logic := '0';
  signal par_e_r  : std_logic := '0';

  -- I/O registers
  signal ra, rb, rc, rd : std_logic_vector(15 downto 0) := (others => '0');
  signal re_pad         : std_logic_vector(15 downto 0) := (others => '0');
  signal re_int         : std_logic_vector(15 downto 0) := (others => '0');
  signal ri             : std_logic_vector(15 downto 0) := (others => '0');

  attribute IOB : string;
  attribute IOB of ra     : signal is "TRUE";
  attribute IOB of rc     : signal is "TRUE";  -- asks for packing, but rc has internal fanout
  attribute IOB of rd     : signal is "TRUE";
  attribute IOB of re_pad : signal is "TRUE";
  attribute IOB of ri     : signal is "TRUE";

  -- re_pad and re_int are logically identical. KEEP stops synthesis merging
  -- them back into one register. Do not use DONT_TOUCH here, the placer still
  -- needs to be free to move re_pad into the I/O logic.
  attribute KEEP : string;
  attribute KEEP of re_pad : signal is "TRUE";
  attribute KEEP of re_int : signal is "TRUE";

begin

  process (clk)
  begin
    if rising_edge(clk) then
      -- fabric registers
      src      <= d_in;
      oe_n_r   <= oe_n;
      din_r    <= ri;
      par_c_r  <= xor rc;
      par_e_r  <= xor re_int;

      -- I/O registers
      ra <= src;
      rb <= src;
      rc <= src;
      if oe_n_r = '0' then          -- same function as pad_b, gate before the register
        rd <= src;
      else
        rd <= (others => '0');
      end if;
      re_pad <= src;
      re_int <= src;
      ri     <= din_pad;
    end if;
  end process;

  pad_a    <= ra;
  pad_b    <= rb when oe_n_r = '0' else (others => '0');  -- LUT between register and pad
  pad_c    <= rc;
  pad_d    <= rd;
  pad_e    <= re_pad;
  parity_c <= par_c_r;
  parity_e <= par_e_r;
  din_q    <= din_r;

end architecture;
