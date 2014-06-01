library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity VGAControler is
	PORT(
		clk_i : in STD_LOGIC;
      Addres : INOUT std_logic_vector(0 to 13):="10111111110110";
		blu_o : out std_logic;
		grn_o : out std_logic;
		red_o : out std_logic;
		en_o : inout STD_LOGIC;
		hs_o : out STD_LOGIC;
		vs_o : out STD_LOGIC
);
end VGAControler;

architecture Behavioral of VGAControler is

signal pixel_clk : STD_LOGIC:='0';
signal pColor : std_logic_vector(2 downto 0):="000";

constant clock_freq : integer := 50_000_000;
constant pixel_clock_freq : integer := 25_175_000;

constant HV : integer := 640;
constant VV : integer := 480;
constant Back : integer :=192;

constant hSP : integer := 95;
constant hBP : integer := 48;
constant hFP : integer := 16;
constant Hpixeltime: integer := HV + hSP + hBP + hFP;

constant vSP : integer := 2;
constant vBP : integer := 29;
constant vFP : integer := 10;
constant Vpixeltime : integer := VV + vSP + vBP + vFP;

begin

process(clk_i)
variable count: integer range 0 to clock_freq/pixel_clock_freq:=0;
begin
	if rising_edge(clk_i) then
	if (count<clock_freq/pixel_clock_freq/2) then
		count:=count+1;
	else
		pixel_clk<=not pixel_clk;
		count:=0;
	end if;
	end if;
end process;


process(pixel_clk)

	variable h_count : integer range 0 to Hpixeltime-1 :=0;
	variable v_count : integer range 0 to Vpixeltime-1 :=0;
	variable p_count : integer range 0 to 1:=0;
	
	begin
		if rising_edge(pixel_clk) then
			--counters
			if(h_count < Hpixeltime-1) then
				h_count := h_count + 1;
			else
				h_count := 0;
				if (v_count < Vpixeltime-1) then
					v_count:=v_count+1;
				else
					v_count:=0;
				end if;
			end if;
			
		--H_sync
			if(h_count< HV + hFP or h_count > HV + hFP + hSP) then
				hs_o<='1';
			else 
				hs_o<='0';
			end if;
		
		--V_sync
			if(v_count< VV + vFP or v_count> VV + vFP + vSP) then
				vs_o<='1';
			else
				vs_o<='0';
			end if;
		
		--display
			if(h_count<HV and v_count<VV) then
				if(h_count<Back or h_count>Back+256) then
					red_o <= pColor(0);
					grn_o <= pColor(1);
					blu_o <= pColor(2);
				elsif(v_count<Back or v_count>Back+96) then
					red_o <= pColor(0);
					grn_o <= pColor(1);
					blu_o <= pColor(2);
				end if;
				
				--Tu kiedyœ bd wczytywa³ sie obrazek.
				if (h_count = Back+257 and v_count=Back+97) then
							Addres<="10111111110110";
				end if;
				
				if(h_count>=Back and h_count<=Back+256 and v_count>=Back and v_count<=Back+96 ) then
					en_o<='1';
					
					if p_count<1 then
						p_count:=p_count+1;
					elsif p_count=1 then
						p_count:=0;
						Addres<=Addres+1;
					end if;
					
					if h_count = Back+256 then
						Addres<=Addres-255;
					end if;
					
				else 
					en_o<='0';
				end if;
				
				
			end if;
		
		end if;


end process;
end Behavioral;
