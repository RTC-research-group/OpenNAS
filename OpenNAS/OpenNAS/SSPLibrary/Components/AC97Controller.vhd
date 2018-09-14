--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright © 2016  Ángel Francisco Jiménez-Fernández                     //
--//                                                                             //
--//    This file is part of OpenNAS.                                            //
--//                                                                             //
--//    OpenNAS is free software: you can redistribute it and/or modify          //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    OpenNAS is distributed in the hope that it will be useful,               //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity AC97Controller is
port (
	clock	: in std_logic;		
	reset				: in std_logic;
	-- AC Link
	ac97_bit_clock	: in std_logic;		
	ac97_sdata_in	: in std_logic;		-- Serial data from AC'97
	ac97_sdata_out	: out std_logic;		-- Serial data to AC'97
	ac97_synch		: out std_logic;		-- Defines boundries of AC'97 frames, controls warm reset
	audio_reset_b	: out std_logic;		-- AC'97 codec cold reset
	
	--PCM data

	Data_Ready		: out std_logic;
	left_in_data	: out std_logic_vector(19 downto 0);
	right_in_data	: out std_logic_vector(19 downto 0)

	);
end AC97Controller;

architecture AC97Controller_arq of AC97Controller is

signal reset_count : std_logic_vector(10 downto 0);
signal bit_count	 : std_logic_vector(7 downto 0);
signal frame_count : std_logic_vector(15 downto 0);

signal command : std_logic_vector(23 downto 0);
signal command_data : std_logic_vector(19 downto 0);
signal command_address : std_logic_vector(19 downto 0);   

signal Int_sync: std_logic;
signal Ready: std_logic;
signal Rst_cuenta: std_logic;

--Señales Internas
signal i_left_v, i_right_v: std_logic;
signal i_left_data, i_right_data : std_logic_vector(19 downto 0);
signal i_Data_Ready: std_logic;
--Latches de sincronizacion
signal l_left_data, l_right_data : std_logic_vector(19 downto 0);
signal l_Data_Ready: std_logic;


begin



ColdRst : process (clock, reset,i_left_data,l_left_data,i_right_data,l_right_data,i_Data_Ready,l_Data_Ready)
begin
	  if (reset = '0')then
	  	 audio_reset_b <= '0';
		 Rst_cuenta <= '0';
		 reset_count <= "00000000000";
		 l_left_data<=(others=>'0');
		 l_right_data<=(others=>'0');
		 l_Data_Ready<='0';
	  elsif (rising_edge(clock)) then   
		if (reset_count = 2047)then --minimo de 1 microseg la señal de audio_reset_b#
			audio_reset_b <= '1';
			Rst_cuenta <= '1';
		else 
			reset_count <= reset_count+1;
		end if;
		
		--DOBLE LACH PARA SINCRONIZAR
		l_left_data<=i_left_data;
		l_right_data<=i_right_data;
		l_Data_Ready<=i_Data_Ready;
		
		left_in_data <= l_left_data;
		right_in_data <= l_right_data;
		Data_Ready<=l_Data_Ready;
		
	end if;
end process;

ac97_synch <= Int_sync;

GenSync : process (ac97_bit_clock, Rst_cuenta,frame_count,bit_count,Int_sync)
begin
	  if (Rst_cuenta = '0')then
		 frame_count <= x"0000";
		 bit_count <= x"00";
		 Int_sync <= '0';
	  else
		  if (rising_edge(ac97_bit_clock)) then 
				if (bit_count = 255 and frame_count <x"000F" ) then
					frame_count <= frame_count+1;
				end if;
				
				if (bit_count = 254) then
					Int_sync <= '1';
				elsif ( bit_count = 14) then -- SYNC = '1' durante 16 bit_clk
					Int_sync <= '0';
				else
					Int_sync <= Int_sync;
				end if;		
				
				bit_count <= bit_count+1;
		  end if;
	 end if;
end process;

OutSlot	: process (ac97_bit_clock, Rst_cuenta,bit_count,command_address,frame_count) 
begin
  if (Rst_cuenta = '0')then
		ac97_sdata_out <= '0';
  else
  if (frame_count >0) then
  	if ((bit_count >= 0) and (bit_count <= 15))then
	-- Slot 0: Tags
	case (bit_count)is
	  when x"00" => ac97_sdata_out <= '1'; -- Frame valid

-- Primary Codec 
	  when x"01" => ac97_sdata_out <= '1'; -- Direccion Valida
	  when x"02" => ac97_sdata_out <= '1'; -- Datos validos
	  when x"0e" => ac97_sdata_out <= '0'; -- Codec ID1
	  when x"0f" => ac97_sdata_out <= '0'; -- Codec ID0	
-- Secundary Codec
--	  when x"0e" => ac97_sdata_out <= '0'; -- Codec ID1
--	  when x"0f" => ac97_sdata_out <= '1'; -- Codec ID0	1  
	  when others => ac97_sdata_out <= '0';
	end case;
	
   elsif ((bit_count >= 16) and (bit_count <= 35))then
		-- Slot 1: Command address
		ac97_sdata_out <= command_address(35-conv_integer(bit_count));
		
   elsif ((bit_count >= 36) and (bit_count <= 55))then
		-- Slot 2: Command data
		ac97_sdata_out <= command_data(55-conv_integer(bit_count));

	else 
		ac97_sdata_out <= '0';
	end if;
	
	else 
		ac97_sdata_out <= '0';
end if;
 end if;

end process;


InSlot : process (ac97_bit_clock, Rst_cuenta,bit_count,ready, frame_count) 
begin
	if (Rst_cuenta = '0') then 
		Ready<= '0';
		--disp0(0)<= '1';
		--disp0(1)<= '1';
		i_left_v <= '0';
		i_right_v <= '0';
		i_left_data <= x"00000";
		i_right_data <= x"00000";
		i_Data_Ready <= '0';
	else
	if (falling_edge(ac97_bit_clock)) then 
	 if (frame_count = 5) then 
      if ( bit_count = 0) then -- Slot 0: Codec_ready = '1' Preparado
			Ready <= ac97_sdata_in;
		elsif (bit_count = 1)then-- slot 1 valid: valid read back address
			--disp0(0) <= ac97_sdata_in;
			Ready <= Ready;
		elsif (bit_count = 2)then-- slot 2 valid: valid register read data
			--disp0(1) <= ac97_sdata_in;
			Ready <= Ready;				
		elsif (bit_count = 43)then-- 18-bit ADC
			--disp0(5) <= ac97_sdata_in;
			Ready <= Ready;
		elsif (bit_count = 44)then-- 20-bit DAC
			--disp0(6) <= ac97_sdata_in;	
			Ready <= Ready;
		end if;
	 elsif (frame_count = 6) then 
	   if ( bit_count = 0) then -- Slot 0: Codec_ready = '1' Preparado
			Ready <= ac97_sdata_in;
		elsif (bit_count = 1)then-- slot 1 valid: valid read back address
			--disp0(0) <= ac97_sdata_in;
			Ready <= Ready;
		elsif (bit_count = 2)then-- slot 2 valid: valid register read data
			--disp0(1) <= ac97_sdata_in;
			Ready <= Ready;				
		elsif (bit_count = 54)then-- DAC ready status
			--disp0(3) <= ac97_sdata_in;
			Ready <= Ready;
		elsif (bit_count = 55)then-- ADC ready status
			--disp0(4) <= ac97_sdata_in;	
			Ready <= Ready;
		end if;
	 elsif (frame_count > 10) then -- ya se han enviado todos los comandos
	   if ( bit_count = 0) then -- Slot 0: Codec_ready = '1' Preparado
			Ready <= ac97_sdata_in;
		elsif (bit_count = 128 and i_left_v = '1' and i_right_v = '1')then
			i_Data_Ready <= '1';
			--disp0(5)<= '1';
			Ready <= Ready;
		elsif (bit_count = 2)then
			i_Data_Ready <= '0';
			--disp0(5)<= '0';			
			Ready <= Ready;
		elsif (bit_count = 3)then-- slot 3 valid: pcm left
			--disp0(2) <= ac97_sdata_in;
			i_left_v <= ac97_sdata_in;
			Ready <= Ready;
		elsif (bit_count = 4)then-- slot 4 valid: pcm right
			--disp0(2) <= ac97_sdata_in;
			i_right_v <= ac97_sdata_in;
			Ready <= Ready;
     elsif (i_left_v = '1' and (bit_count >= 56) and (bit_count <= 75))then

        -- Slot 3: Left channel
        i_left_data <= i_left_data(18 downto 0) & ac97_sdata_in ;
      elsif (i_right_v = '1' and( bit_count >= 76) and (bit_count <= 95))then
        -- Slot 4: Right channel
        i_right_data <= i_right_data(18 downto 0) & ac97_sdata_in ;
			
		end if;
			
	 else
			Ready <= Ready;
			i_Data_Ready <= '0';
			i_left_v <= '0';
			i_right_v <= '0';			
			i_left_data  <= x"00000";
			i_right_data <= x"00000";
	 end if;
   end if;
	end if;
end process;	

Frame	: process (ac97_bit_clock,frame_count) 
begin
     case (frame_count)is
		when x"0004" => command <= X"800000"; -- Resolucion de ADC/DAC (16,18 o 20)
		when x"0005" => command <= X"A60000"; -- Status register: ADC/DAC ready?

\--MIC Source
		when x"0006" => command <= X"0E8048"; -- set +20db mic gain
		when x"0007" => command <= X"1A0000"; -- Record source select:MIC
		when x"0008" => command <= X"1C0F0F"; -- Record gain max

\--Line Source
		when x"0006" => command <= X"100808"; -- Line In Volume
		when x"0007" => command <= X"1A0404"; -- Record source select:Line In
		when x"0008" => command <= X"1C0000"; -- Record gain 0db - no mute

\--Sample Rate
		when x"0002" => command <= X"32BB80"; -- sample rate 48K
		when x"0009" => command <= X"B20000"; -- sample rate 48K

		

      when others => command <= X"800000"; -- Read vendor ID
     end case;

end process;
	

command_address <= command(23 downto 16) & X"000";
command_data <= command(15 downto 0) & X"0";
end AC97Controller_arq;

