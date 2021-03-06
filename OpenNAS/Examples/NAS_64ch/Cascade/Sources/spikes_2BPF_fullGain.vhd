

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity spikes_2BPF_fullGain is
generic (GL: in integer:=11; SAT: in integer:=1023);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
		  FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
		  SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
          SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);				
		  SPIKES_DIV_BPF: in STD_LOGIC_VECTOR(15 downto 0);
          spike_in_slpf_p : in  STD_LOGIC;
          spike_in_slpf_n : in  STD_LOGIC;  
		  spike_in_shf_p : in  STD_LOGIC;
          spike_in_shf_n : in  STD_LOGIC;  
          spike_out_p : out  STD_LOGIC;
          spike_out_n : out  STD_LOGIC;
		  spike_out_lpf_p : out  STD_LOGIC;
          spike_out_lpf_n : out  STD_LOGIC);
end spikes_2BPF_fullGain;

architecture Behavioral of spikes_2BPF_fullGain is

	component AER_DIF is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SPIKES_IN_UP: in STD_LOGIC;
           SPIKES_IN_UN: in STD_LOGIC;
           SPIKES_IN_YP: in STD_LOGIC;
           SPIKES_IN_YN: in STD_LOGIC;
           HOLD_TIME_U:  in STD_LOGIC_VECTOR(15 downto 0);
           HOLD_TIME_Y:  in STD_LOGIC_VECTOR(15 downto 0);
		   SPIKES_OUT_P: out STD_LOGIC;
		   SPIKES_OUT_N: out STD_LOGIC);
	end component;


	component spikes_2LPF_fullGain is
	generic (GL: in integer:=16; SAT: in integer:=32536);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           FREQ_DIV: in STD_LOGIC_VECTOR(7 downto 0);
           SPIKES_DIV_FB: in STD_LOGIC_VECTOR(15 downto 0);
           SPIKES_DIV_OUT: in STD_LOGIC_VECTOR(15 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
	end component;

    component spikes_div_BW is
	 generic (GL: in integer:=16);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
		   spikes_div: in STD_LOGIC_VECTOR(GL-1 downto 0);
           spike_in_p : in  STD_LOGIC;
           spike_in_n : in  STD_LOGIC;
           spike_out_p : out  STD_LOGIC;
           spike_out_n : out  STD_LOGIC);
    end component;



	signal spikes_out_tmp_p: STD_LOGIC :='0';
	signal spikes_out_tmp_n: STD_LOGIC :='0';
	signal spikes_bpf_tmp_p: STD_LOGIC :='0';
	signal spikes_bpf_tmp_n: STD_LOGIC :='0';
	signal spikes_bpf_hf_tmp_p: STD_LOGIC :='0';
	signal spikes_bpf_hf_tmp_n: STD_LOGIC :='0';

begin
	spike_out_lpf_p<=spikes_out_tmp_p;
	spike_out_lpf_n<=spikes_out_tmp_n;


	U_LPF2: spikes_2LPF_fullGain 
	generic map (GL=>GL, SAT=>SAT)
    Port map ( CLK =>CLK,
           RST=>RST,
				FREQ_DIV=>FREQ_DIV,
				SPIKES_DIV_FB=>SPIKES_DIV_FB,
				SPIKES_DIV_OUT=>SPIKES_DIV_OUT,		
           spike_in_p=>spike_in_slpf_p,
           spike_in_n =>spike_in_slpf_n,
           spike_out_p =>spikes_out_tmp_p,
           spike_out_n=>spikes_out_tmp_n);
			  
			--La entrada de la seccion anterior, menos mi filtro

	U_DIF:AER_DIF
	port map (
			  CLK =>clk,
			  RST =>RST,
			  HOLD_TIME_U=>(others=>'1'),
           HOLD_TIME_Y=>(others=>'1'),
           SPIKES_IN_UP=>spike_in_shf_p,
			  SPIKES_IN_UN=>spike_in_shf_n,
           SPIKES_IN_YP=>spikes_out_tmp_p, 
			  SPIKES_IN_YN=>spikes_out_tmp_n, 
			  SPIKES_OUT_P=>spikes_bpf_tmp_p,
			  SPIKES_OUT_N=>spikes_bpf_tmp_n
			  );			  


    U_BPF_DIV: spikes_div_BW
	generic map(GL=>8)
	port map (
			  CLK =>clk,
			  RST =>RST,
		   spikes_div=>SPIKES_DIV_BPF(15 downto 8),
			  spike_in_p=>spikes_bpf_tmp_p,
           spike_in_n=>spikes_bpf_tmp_n,
           spike_out_p=>spike_out_p,
           spike_out_n=>spike_out_n);



end Behavioral;

