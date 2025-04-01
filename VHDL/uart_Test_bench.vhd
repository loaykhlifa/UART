library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity uart_Test_bench is
generic (
CLK_FREQ 	: integer := 100_000_000;
BAUD_RATE	: integer := 115_200;
STOP_BIT	: integer := 1
);
end uart_Test_bench;

architecture Behavioral of uart_Test_bench is

component UART 
generic (
CLK_FREQ 	: integer := 100_000_000;
BAUD_RATE	: integer := 115_200;
STOP_BIT	: integer := 1
);
port (
Tx_Done_Tick_O      : out  std_logic; 
Tx_O				: out std_logic;
Data_out			: out std_logic_vector(7 downto 0);
Rx_Done_Tick_O      : out std_logic;

Clk                 : in   std_logic;
Tx_Start_Tick_I     : in   std_logic := '0'; 
D_in                : in   std_logic_vector(7 downto 0);  
Rx_I				: in   std_logic);

end component UART;

signal Tx_Done_Tick_O_Test      : std_logic  ;
signal Tx_O_Test 			    : std_logic  ;
signal Data_out_Test 		    : std_logic_vector(7 downto 0)  ;
signal Rx_Done_Tick_O_Test      : std_logic  ;
						
signal Clk_Test                 : std_logic := '0' ;
signal Tx_Start_Tick_I_Test     : std_logic  := '0';
signal D_in_Test                : std_logic_vector(7 downto 0) := x"00" ;
signal Rx_I_Test 			    :  std_logic:='1' ;
constant data_b1				: std_logic_vector(7 downto 0) := x"b1";
constant data_be_rx				: std_logic_vector(9 downto 0) := '1' & x"BE" &'0';

begin

dev_to_test : UART
generic map(
CLK_FREQ => CLK_FREQ , 	
BAUD_RATE =>BAUD_RATE,
STOP_BIT=>	STOP_BIT) 
port map(

Tx_Done_Tick_O  =>Tx_Done_Tick_O_Test ,
Tx_O			=>Tx_O_Test ,
Data_out		=>Data_out_Test ,
Rx_Done_Tick_O  =>Rx_Done_Tick_O_Test ,
			
Clk             =>Clk_Test ,
Tx_Start_Tick_I =>Tx_Start_Tick_I_Test ,
D_in            =>D_in_Test ,
Rx_I			=>Rx_I_Test );

clk_stimulus : process 
-- CLK frequency is equal to 100MHZ which means CLK period is equal to 1e-8 = 10 e-9 (10 ns)
-- CLK should be high for 5 ns and low for 5 ns. 
begin 
wait  for 5 ns;

Clk_Test <= not Clk_Test;
end  process clk_stimulus;

data_tx_stimulus : process 
begin
wait for 20 us;
Tx_Start_Tick_I_Test <='1'; 
D_in_Test <=data_b1;

end process data_tx_stimulus;

data_rx_stimulus : process 
begin
wait for 20 us;
for i in 0 to 9 loop
Rx_i_Test <= data_be_rx(i); 
wait for 8.68 us;
end loop;
wait for 100 us;
assert false 
report "SIM DONE"
severity failure;

end process data_rx_stimulus;



end Behavioral;