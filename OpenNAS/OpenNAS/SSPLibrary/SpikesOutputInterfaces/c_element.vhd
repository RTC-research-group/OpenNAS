--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright ï¿½ 2016  Angel Francisco Jimenez-Fernandez                      //
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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY c_element IS
	PORT (
		i_reset : IN STD_LOGIC;
		i_src1_aer_ack : IN STD_LOGIC;
		i_src2_aer_ack : IN STD_LOGIC;
		o_global_aer_ack : OUT STD_LOGIC
	);
END c_element;

ARCHITECTURE Behavioral OF c_element IS
	
	SIGNAL r_ack_state : STD_LOGIC;
	
BEGIN

	main_process : process(i_reset, i_src1_aer_ack, i_src2_aer_ack)
	BEGIN
		IF (i_reset = '0') THEN
			r_ack_state <= '0';
		ELSE
			IF ((i_src1_aer_ack = '1') AND (i_src2_aer_ack = '1')) THEN
				r_ack_state <= '1';
			ELSIF ((i_src1_aer_ack = '0') AND (i_src2_aer_ack = '0')) THEN
				r_ack_state <= '0';
			ELSE
				
			END IF;
		END IF;
	END PROCESS main_process;
	
	o_global_aer_ack <= r_ack_state;

END Behavioral;