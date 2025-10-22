
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_1 is
end test_1;

architecture Behavioral of test_1 is

component ALU is
    Port ( INT   :in STD_LOGIC;
           IOIN  :in STD_LOGIC_VECTOR (7 downto 0);
           RESET :in STD_LOGIC;
           CLK   :in STD_LOGIC;
           IOADR :out STD_LOGIC_VECTOR (7 downto 0);
           IOOUT :out STD_LOGIC_VECTOR (7 downto 0);
           IOWR  :out STD_LOGIC;
           IORD  :out STD_LOGIC);
end component;
   
    signal INT   :STD_LOGIC := '0' ;
    signal IOIN  :STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal RESET :STD_LOGIC := '0';
    signal CLK   :STD_LOGIC := '0';
    signal IOADR :STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal IOOUT :STD_LOGIC_VECTOR (7 downto 0) := x"00";
    signal IOWR  :STD_LOGIC := '0';
    signal IORD  :STD_LOGIC := '0';
    
        -- Clock period constant
    constant CLK_period : time := 10 ns;

begin
    b0: ALU port map(INT=>INT, IOIN=>IOIN, CLK=>CLK, RESET=>RESET, IOADR=>IOADR, IOOUT=>IOOUT, IOWR=>IOWR, IORD=>IORD );
    
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    stim_proc: process
        begin
            RESET <= '1';
            wait for 20 ns;
            RESET <= '0';
            wait for 27 ns;
            INT <='1';
            
            wait for 20 ns;
            INT <='0';
            
            wait for 102 ns;
            INT <= '1';
            
            wait for 20 ns;
            INT <='0';
                     
            wait;
        end process;
end Behavioral;
