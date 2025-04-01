library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart is
generic (
CLK_FREQ 	: integer := 100_000_000;
BAUD_RATE	: integer := 115_200;
STOP_BIT	: integer := 1
);

port (
Tx_Done_Tick_O      : out  std_logic; --Signal indiquant que la transmission est terminée.
Tx_O				: out std_logic;-- Signal de transmission UART
Data_out			: out std_logic_vector(7 downto 0);--Données reçues sur 8 bits (lignes série)
Rx_Done_Tick_O      : out std_logic;--Signal indiquant que la réception est terminée.

Clk                 : in   std_logic;-- Horloge principale du système
Tx_Start_Tick_I     : in   std_logic := '0';-- Signal de démarrage de la transmission
D_in                : in   std_logic_vector(7 downto 0);--Données à transmettre (8 bits)
Rx_I				: in   std_logic);-- Signal d’entrée série pour la réception
end uart;


architecture Behavioral of uart is
type T_State is (Tx_IDLE,Tx_START,Tx_DATA,Tx_STOP);
signal Tx_State :T_State:=Tx_IDLE;

type R_State is (Rx_IDLE,Rx_START,Rx_DATA,Rx_STOP);
signal Rx_State :R_State:=Rx_IDLE;


constant bit_timer_lim 	    :integer   := CLK_FREQ/BAUD_RATE;-- Durée d'un bit en cycles d'horloge, calculée avec CLK_FREQ/BAUD_RATE 
constant halfbit_timer_lim  :integer   := bit_timer_lim/2;--Moitié de la durée d'un bit, utilisée pour échantillonner les signaux 
signal bit_timer_Tx			:integer   := 0;--Chronomètre pour la transmission
signal bit_cntr_Rx  		:integer   := 0;--Chronomètre pour la réception
signal bit_timer_Rx  	    :integer   := 0;-- Compteur de bits envoyés
signal tx_buffer            :std_logic_vector(7 downto 0);--Tampon pour stocker les données à transmettre
signal bit_cntr_Tx  		:integer    := 0;--Compteur de bits reçus




begin

uart_tx: process(Clk)
begin
 if rising_edge(Clk) then 
		if(Tx_Start_Tick_I = '0') then 
		Tx_State <= Tx_IDLE;
		else 
		
			bit_timer_Tx <= bit_timer_Tx +1;
			case Tx_State is 
				when Tx_IDLE =>
					Tx_O <= '1'; 
					Tx_Done_Tick_O <= '0';
					
					if(Tx_Start_Tick_I = '1') then
					
						tx_buffer <=D_in;--les données à transmettre (D_in) sont chargées dans (tx_buffer)
						Tx_O <= '0'; --signaler le début de la transmission
						Tx_State <= Tx_START;					
					
					end if;
				when Tx_START =>
					 
					 
					 if bit_timer_Tx = bit_timer_lim-1 then
					 
						bit_timer_Tx <= 0;
						Tx_State <= Tx_DATA;
					 end if;
				WHEN Tx_DATA =>
						 Tx_O <= tx_buffer(bit_cntr_Tx);--transmission séquentielle
					
					
						if bit_timer_Tx = bit_timer_lim-1 then
							 bit_timer_Tx <=0;
						     bit_cntr_Tx <= bit_cntr_Tx+1; 
                                 if bit_cntr_Tx = 7 then
						               bit_timer_Tx <=0;
						         
						               Tx_O <= '1';
						               Tx_State <= Tx_STOP;
						          end if ;
				 
						end if;
					
				WHEN Tx_STOP =>
				
				  
				 if(bit_timer_Tx = bit_timer_lim -1) then
					     bit_timer_Tx <= 0;
					     bit_cntr_Tx <= bit_cntr_Tx+1;

					     if bit_cntr_Tx=7 + STOP_BIT then 
					       
						   bit_timer_Tx <= 0;
					       bit_cntr_Tx <=0;
					       Tx_Done_Tick_O <= '1';  
					       Tx_State <= Tx_IDLE;	
						   
					    end if;				
				
					end if;
			END CASE;	
				
		end if;
	
	end if;

 
end process uart_tx; 

uart_rx: process(Clk) 
begin

	 if rising_edge(Clk) then
	  if(Rx_I='1') and bit_timer_Rx = 0 then 
		Rx_State <= Rx_IDLE;
	  else	
	  
		bit_timer_Rx <= bit_timer_Rx + 1;
		case Rx_State is
		when Rx_IDLE  => 
			Rx_Done_Tick_O <='0'; 
			
			if(Rx_I ='0') then
			
			Rx_State <= Rx_Start;
			
			end if;
		
		when Rx_Start => 
			if(bit_timer_Rx= halfbit_timer_lim-1) then 
			
			bit_timer_Rx <= halfbit_timer_lim;	
			 
			 Rx_State <= Rx_Data;
			
			end if;
		
		when Rx_Data  =>
			 
			 Data_out(bit_cntr_Rx)<= Rx_I;

			if(bit_timer_Rx = bit_timer_lim+halfbit_timer_lim-1)then 

					bit_timer_Rx <=halfbit_timer_lim;

					bit_cntr_Rx <= bit_cntr_Rx +1 ; 

			     if(bit_cntr_Rx =7) then

				    Rx_State <= Rx_Stop;
				
		           end if;
				 bit_cntr_Rx <= bit_cntr_Rx +1 ; 
						
			end if;

		when Rx_Stop  => 

				if bit_timer_Rx = bit_timer_lim - 1 then 

				bit_timer_Rx <= 0;

				Rx_Done_Tick_O <= '1';

				bit_cntr_Rx <= 0;

				Rx_State <= Rx_IDLE;
				
				end if;
		end case;
	  end if;
		
	 end if;


end process uart_rx;

end Behavioral;