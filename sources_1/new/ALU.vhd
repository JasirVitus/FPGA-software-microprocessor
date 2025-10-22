
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity ALU is
    Port ( INT   :in STD_LOGIC;
           IOIN  :in STD_LOGIC_VECTOR (7 downto 0);
           RESET :in STD_LOGIC;
           CLK   :in STD_LOGIC;
           IOADR :out STD_LOGIC_VECTOR (7 downto 0);
           IOOUT :out STD_LOGIC_VECTOR (7 downto 0);
           IOWR  :out STD_LOGIC;
           IORD  :out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
                                                      
                    -- Command codes
                            --
constant C_NOP:   std_logic_vector(7 downto 0) := "11000000"; 
constant C_OUTP8: std_logic_vector(7 downto 0) := "11000001";
constant C_BZ:    std_logic_vector(7 downto 0) := "11000010"; 
constant C_B8:    std_logic_vector(7 downto 0) := "11000011";

constant C_MOV:  std_logic_vector(9 downto 0) := "0000000000";
constant C_LD:   std_logic_vector(9 downto 0) := "0000000001";
constant C_LDI:  std_logic_vector(4 downto 0) := "00001";
constant C_LDS:  std_logic_vector(4 downto 0) := "00010";
constant C_ST:   std_logic_vector(9 downto 0) := "0000000010";
constant C_STS:  std_logic_vector(4 downto 0) := "00011";
             
constant C_ADC:  std_logic_vector(9 downto 0) := "0000000011";
constant C_ADCI: std_logic_vector(4 downto 0) := "00100";
constant C_SBC:  std_logic_vector(9 downto 0) := "0000000100";
constant C_SBCI: std_logic_vector(4 downto 0) := "00101";
constant C_MUL:  std_logic_vector(9 downto 0) := "0000000101";
constant C_MULS: std_logic_vector(9 downto 0) := "0000000110";

constant C_AND:  std_logic_vector(9 downto 0) := "0000000111";
constant C_ANDI: std_logic_vector(4 downto 0) := "00110";
constant C_OR:   std_logic_vector(9 downto 0) := "0000001000";
constant C_ORI:  std_logic_vector(4 downto 0) := "00111";
constant C_XOR:  std_logic_vector(9 downto 0) := "0000001001";
constant C_XORI: std_logic_vector(4 downto 0) := "01000";

constant C_BSET: std_logic_vector(7 downto 0)  := "01001000";
constant C_BCLR: std_logic_vector(7 downto 0)  := "01010000";

constant C_B   : std_logic_vector(7 downto 0)  := "01011000";
constant C_RB  : std_logic_vector(7 downto 0)  := "01100000";
constant C_BRBS: std_logic_vector(4 downto 0)  := "01101";
constant C_BRBC: std_logic_vector(4 downto 0)  := "01110";

constant C_CP:   std_logic_vector(4 downto 0)  := "01111";
constant C_CPI:  std_logic_vector(4 downto 0)  := "10000";
 
constant C_INP:    std_logic_vector(4 downto 0)   := "10001";
constant C_OUTP:   std_logic_vector(4 downto 0)   := "10010";
constant C_CALL:   std_logic_vector(7 downto 0)   := "10011000";
constant C_RCALL:  std_logic_vector(7 downto 0)   := "10100000";
constant C_RET:    std_logic_vector(15 downto 0)  := "1010100000000000";
constant C_RETI:   std_logic_vector(15 downto 0)  := "1011000000000000";
--INP, OUTP, CALL, RCALL, RET, RETI.

                    -- Masks
                        --
constant MC_NOP:  std_logic_vector(15 downto 0)  := "11000000--------"; 
constant MC_OUTP8: std_logic_vector(15 downto 0) := "11000001--------";
constant MC_BZ:   std_logic_vector(15 downto 0)  := "11000010--------"; 
constant MC_B8:   std_logic_vector(15 downto 0)  := "11000011--------";

constant MC_MOV:  std_logic_vector(15 downto 0) := "0000000000------";
constant MC_LD:   std_logic_vector(15 downto 0) := "0000000001------";
constant MC_LDI:  std_logic_vector(15 downto 0) := "00001-----------";
constant MC_LDS:  std_logic_vector(15 downto 0) := "00010-----------";
constant MC_ST:   std_logic_vector(15 downto 0) := "0000000010------";
constant MC_STS:  std_logic_vector(15 downto 0) := "00011-----------";
             
constant MC_ADC:  std_logic_vector(15 downto 0) := "0000000011------";
constant MC_ADCI: std_logic_vector(15 downto 0) := "00100-----------";
constant MC_SBC:  std_logic_vector(15 downto 0) := "0000000100------";
constant MC_SBCI: std_logic_vector(15 downto 0) := "00101-----------";
constant MC_MUL:  std_logic_vector(15 downto 0) := "0000000101------";
constant MC_MULS: std_logic_vector(15 downto 0) := "0000000110------";
 
constant MC_AND:  std_logic_vector(15 downto 0) := "0000000111------";
constant MC_ANDI: std_logic_vector(15 downto 0) := "00110-----------";
constant MC_OR:   std_logic_vector(15 downto 0) := "0000001000------";
constant MC_ORI:  std_logic_vector(15 downto 0) := "00111-----------";
constant MC_XOR:  std_logic_vector(15 downto 0) := "0000001001------";
constant MC_XORI: std_logic_vector(15 downto 0) := "01000-----------";

constant MC_BSET: std_logic_vector(15 downto 0) := "01001000--------";
constant MC_BCLR: std_logic_vector(15 downto 0) := "01010000--------";

constant MC_B   : std_logic_vector(15 downto 0) := "01011000--------";
constant MC_RB  : std_logic_vector(15 downto 0) := "01100000--------";
constant MC_BRBS: std_logic_vector(15 downto 0) := "01101-----------";
constant MC_BRBC: std_logic_vector(15 downto 0) := "01110-----------";

constant MC_CP:   std_logic_vector(15 downto 0) := "01111-----------";
constant MC_CPI:  std_logic_vector(15 downto 0) := "10000-----------";

constant MC_INP:    std_logic_vector(15 downto 0)  := "10001-----------";
constant MC_OUTP:   std_logic_vector(15 downto 0)  := "10010-----------";
constant MC_CALL:   std_logic_vector(15 downto 0)  := "10011000--------";
constant MC_RCALL:  std_logic_vector(15 downto 0)  := "10100000--------";
constant MC_RET:    std_logic_vector(15 downto 0)  := "1010100000000000";
constant MC_RETI:   std_logic_vector(15 downto 0)  := "1011000000000000";

constant Interrupt_Adress: std_logic_vector(7 downto 0) := x"0C";
                    -- 
signal IR: std_logic_vector(15 downto 0);

-- 8-bit codes
alias OPCODE: std_logic_vector(7 downto 0) is IR(15 downto 8);
alias ARG: std_logic_vector(7 downto 0) is IR(7 downto 0);

                    -- Aliases
alias RRS:     std_logic_vector(2 downto 0) is IR(2 downto 0);
alias RRD:     std_logic_vector(2 downto 0) is IR(5 downto 3);

alias IRD:     std_logic_vector(2 downto 0) is IR(10 downto 8);
alias K:       std_logic_vector(7 downto 0) is IR(7 downto 0);

-- ROM memory
type rom_array is array (0 to 255) of std_logic_vector(15 downto 0);
    constant ROM: rom_array := ( 
    

        C_LDI & "001" & x"03", --
        C_LDI & "001" & x"04", --
        C_OUTP & "001" & x"05", --
        C_INP & "001" & x"05", --
        C_LDI & "001" & x"05", --
        C_B & x"00",
    
    
others => x"0000");

                        -- Memories
--RAM                    
type ram_array is array (0 to 255) of std_logic_vector(7 downto 0);
    signal RAM: ram_array;

-- Register block
type reg_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal R: reg_array;

signal SREG:  std_logic_vector(7 downto 0) := x"00";
signal SREGM: std_logic_vector(7 downto 0) := x"00";
alias SREG_C: std_logic is SREG(0);
alias SREG_Z: std_logic is SREG(1);
alias SREG_S: std_logic is SREG(4);    
alias SREG_I: std_logic is SREG(7);

--Stack     
type stack_array is array (0 to 15) of std_logic_vector(7 downto 0); 
    signal STACK: stack_array;
    signal SPTR: std_logic_vector(3 downto 0) := x"0";
--

-- State Machine
type state_t is (S_FETCH, S_EX);
signal state: state_t;
signal ports: std_logic_vector(2 downto 0) := "000";
signal INPUT_REGISTER: std_logic_vector(2 downto 0) := "000";
alias OUTPUT_FLAG: std_logic is ports(0);
alias INPUT_FLAG0: std_logic is ports(1);
alias INPUT_FLAG1: std_logic is ports(2);
begin

    process(CLK,RESET)
        variable PC: std_logic_vector(7 downto 0);

        variable src1, src2: signed(7 downto 0);
        variable res_16: unsigned(15 downto 0);
        variable res_16s: signed(15 downto 0);
        variable res: signed(8 downto 0);
        begin
        
             if RESET = '1' then
                PC := x"00";
          --      GPIO <= x"00";

            elsif rising_edge(CLK) then
                  
                  if INPUT_FLAG0 = '1' then
                    IORD <= '1';
                    INPUT_FLAG0 <= '0';
                    INPUT_FLAG1 <= '1';
                  else
                    IORD <= '0';
                  end if;
                  
                  if INPUT_FLAG1 = '1' then
                     R(to_integer(unsigned(INPUT_REGISTER))) <= IOIN;
                     INPUT_FLAG1 <= '0';
                  end if;
                  
                  if OUTPUT_FLAG = '1' then
                    IOWR <= '1';
                    OUTPUT_FLAG <= '0';
                  else
                    IOWR <= '0';
                  end if;
                  
                  
               if state = S_FETCH then
                   -- Interrupt handling
                 if SREG_I = '1' then
                     if INT = '1' then
                     STACK(to_integer(unsigned(SPTR))) <= std_logic_vector(unsigned(PC)); --STACK(SPTR)<-PC
                     SPTR <= std_logic_vector(unsigned(SPTR)+1);                          --SPTR<-SPTR+1
                    
                     SREGM <= SREG; --SREGM<-SREG 
                     SREG_I <= '0'; --SREG(INT)<-0
              
                     PC:= std_logic_vector(unsigned(Interrupt_Adress));  --PC<-31(adres ostatniej kom�rki pami�ci ROM) 
                     end if;  
                     
                  end if;
                  
                  IR <= ROM(to_integer(unsigned(PC)));
                  state <= S_EX;
               else
                    state <= S_FETCH;               
                    
                            -- 8-bit commands

                    if std_match(IR, MC_OUTP8) then
                  --      GPIO <= ARG;
                        PC:= std_logic_vector(unsigned(PC)+1);

                    elsif std_match(IR, MC_BZ) then
                    --    if Z = '1' then
                     --       PC := ARG;
                      --  else
                            PC:= std_logic_vector(unsigned(PC)+1);
                       -- end if;

                    elsif std_match(IR, MC_B8) then
                        PC := ARG;
                        

                            -- I/0 commands
                    elsif std_match(IR, MC_MOV) then
                        R(to_integer(unsigned(RRD))) <= R(to_integer(unsigned(RRS)));
                        PC:= std_logic_vector(unsigned(PC)+1);
                        
                    elsif std_match(IR, MC_LDI) then
                        R(to_integer(unsigned(IRD))) <= K;
                        PC:= std_logic_vector(unsigned(PC)+1);  
                                                    
                    elsif std_match(IR, MC_LD) then
                        R(to_integer(unsigned(RRD))) <= RAM(to_integer(unsigned(R(to_integer(unsigned(RRS)))))) ;
                        PC:= std_logic_vector(unsigned(PC)+1);
                                                
                    elsif std_match(IR, MC_LDS) then
                        R(to_integer(unsigned(IRD))) <= RAM(to_integer(unsigned(K)));
                        PC:= std_logic_vector(unsigned(PC)+1);
                        
                    elsif std_match(IR, MC_ST) then
                        RAM(to_integer(unsigned(R(to_integer(unsigned(RRD)))))) <= R(to_integer(unsigned(RRS)));
                        PC:= std_logic_vector(unsigned(PC)+1);
                        
                    elsif std_match(IR, MC_STS) then
                        RAM(to_integer(unsigned(K))) <= R(to_integer(unsigned(IRD)));
                        PC:= std_logic_vector(unsigned(PC)+1);


                             -- Arithmetical commands
                    -- ADC 
                    elsif std_match(IR, MC_ADC) then
                        src1 := signed(R(to_integer(unsigned(RRD))));
                        src2 := signed(R(to_integer(unsigned(RRS))));
                        
                        res := x"00" & SREG_C;
                        res := res + ('0' & src1) + ('0' & src2);

                        -- CARRY FLAG
                        SREG_C <= res(8);

                        -- ZERO FLAG
                        if res(7 downto 0) = x"00" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;
                        
                        -- Result
                        R(to_integer(unsigned(RRD))) <= std_logic_vector(res(7 downto 0));
                        PC:= std_logic_vector(unsigned(PC)+1);
                        
                    -- ADCI
                    elsif std_match(IR, MC_ADCI) then
                        src1 := signed(R(to_integer(unsigned(IRD))));
                        
                        res := x"00" & SREG_C;
                  --      res := res + ('0' & src1) + ('0' & signed(K));
                        res:= '0' & x"55";
                        -- CARRY FLAG
                        SREG_C <= res(8);

                        -- ZERO FLAG
                        if res(7 downto 0) = x"00" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;
                        
                        -- Result
                        R(to_integer(unsigned(IRD))) <= std_logic_vector(res(7 downto 0));
                        PC:= std_logic_vector(unsigned(PC)+1);
                    
                    --SBC
                    elsif std_match(IR, MC_SBC) then
                        src1 := signed(R(to_integer(unsigned(RRD))));
                        src2 := signed(R(to_integer(unsigned(RRS))));
                        
                        res := ('0' & src1) - ('0' & src2) - (x"00" & SREG_C);
                        
                        -- CARRY FLAG
                        SREG_C <= res(8);

                        -- ZERO FLAG
                        if res(7 downto 0) = x"00" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;
                        
                        -- Result
                        R(to_integer(unsigned(RRD))) <= std_logic_vector(res(7 downto 0));
                        PC:= std_logic_vector(unsigned(PC)+1);
                    
                    --SBCI
                    elsif std_match(IR, MC_SBCI) then
                        src1 := signed(R(to_integer(unsigned(IRD))));
                        
                        res := ('0' & src1) - ('0' & signed(K)) - (x"00" & SREG_C);
                        
                        -- CARRY FLAG
                        SREG_C <= res(8);

                        -- ZERO FLAG
                        if res(7 downto 0) = x"00" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;
                        
                        -- Result
                        R(to_integer(unsigned(IRD))) <= std_logic_vector(res(7 downto 0));
                        PC:= std_logic_vector(unsigned(PC)+1);
                    
                    --MUL   
                    elsif std_match(IR, MC_MUL) then
                        src1 := signed(R(to_integer(unsigned(RRD))));
                        src2 := signed(R(to_integer(unsigned(RRS))));
                        res_16 := unsigned(src1) * unsigned(src2);

                        R(to_integer(unsigned(RRD)))   <= std_logic_vector(unsigned(res_16(7 downto 0)));
                        R(to_integer(unsigned(RRD)+1)) <= std_logic_vector(unsigned(res_16(15 downto 8)));
                        PC:= std_logic_vector(unsigned(PC)+1);
                        
                    --MULS
                    elsif std_match(IR, MC_MULS) then
                        src1 := signed(R(to_integer(unsigned(RRD))));
                        src2 := signed(R(to_integer(unsigned(RRS))));
                        res_16s := src1 * src2;
                        
                        -- NEGATIVE BIT
                       -- res_16s(14) := src1(7) XOR src2(7);
                        
                        -- ZERO FLAG
                        if res_16s(15 downto 0) = x"0000" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;
                        
                        R(to_integer(unsigned(RRD)))   <= std_logic_vector(unsigned(res_16s(7 downto 0)));
                        R(to_integer(unsigned(RRD)+1)) <= std_logic_vector(unsigned(res_16s(15 downto 8)));
                        PC:= std_logic_vector(unsigned(PC)+1);
                        
                                         -- Logical commands    
                    -- AND                                                  
                    elsif std_match(IR, MC_AND) then
                        R(to_integer(unsigned(RRD))) <= R(to_integer(unsigned(RRD))) AND R(to_integer(unsigned(RRS)));
                        PC:= std_logic_vector(unsigned(PC)+1); 
                    -- ANDI
                    elsif std_match(IR, MC_ANDI) then
                        R(to_integer(unsigned(IRD))) <= R(to_integer(unsigned(IRD))) AND K;
                        PC:= std_logic_vector(unsigned(PC)+1); 
                    -- OR
                    elsif std_match(IR, MC_OR) then
                        R(to_integer(unsigned(RRD))) <= R(to_integer(unsigned(RRD))) OR R(to_integer(unsigned(RRS)));
                        PC:= std_logic_vector(unsigned(PC)+1); 
                    -- ORI
                    elsif std_match(IR, MC_ORI) then
                        R(to_integer(unsigned(IRD))) <= R(to_integer(unsigned(IRD))) OR K;
                        PC:= std_logic_vector(unsigned(PC)+1); 
                    -- XOR
                    elsif std_match(IR, MC_XOR) then
                        R(to_integer(unsigned(RRD))) <= R(to_integer(unsigned(RRD))) XOR R(to_integer(unsigned(RRS)));
                        PC:= std_logic_vector(unsigned(PC)+1); 
                    -- XORI
                    elsif std_match(IR, MC_XORI) then
                        R(to_integer(unsigned(IRD))) <= R(to_integer(unsigned(IRD))) XOR K;
                        PC:= std_logic_vector(unsigned(PC)+1);
                    
                                        -- SREG commands

                    elsif std_match(IR, MC_BSET) then
                        SREG <= SREG or K;
                        PC:= std_logic_vector(unsigned(PC)+1);

                    elsif std_match(IR, MC_BCLR) then
                        SREG <= SREG and not K;
                        PC:= std_logic_vector(unsigned(PC)+1);

                                -- Rozkazy skoku(LAB10)
                    elsif std_match(IR, MC_B) then
                        PC:= std_logic_vector(unsigned(K));

                    elsif std_match(IR, MC_RB) then
                        res:= signed('0' & unsigned(PC)) + signed(K) ;
                        PC:= std_logic_vector(unsigned(res(7 downto 0))); 

                    elsif std_match(IR, MC_BRBC) then
                        if SREG(to_integer(unsigned(IRD))) = '0' then
                            res:= signed('0' & unsigned(PC)) + signed(K) ;
                            PC:= std_logic_vector(unsigned(res(7 downto 0))); 
                        else
                            PC:= std_logic_vector(unsigned(PC)+1);
                        end if;  
                        
                    elsif std_match(IR, MC_BRBS) then
                        if SREG(to_integer(unsigned(IRD))) = '1' then
                            res:= signed('0' & unsigned(PC)) + signed(K) ;
                            PC:= std_logic_vector(unsigned(res(7 downto 0))); 
                        else
                            PC:= std_logic_vector(unsigned(PC)+1);
                        end if;  
                        
                                -- Comparison commands
                    elsif std_match(IR, MC_CP) then
                        src1 := signed(R(to_integer(unsigned(RRD))));
                        src2 := signed(R(to_integer(unsigned(RRS))));
                        
                        res := ('0' & src1) - ('0' & src2);

                        -- ZERO FLAG
                        if res(7 downto 0) = x"00" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;

                        PC:= std_logic_vector(unsigned(PC)+1); 

                    elsif std_match(IR, MC_CPI) then
                        src1 := signed(R(to_integer(unsigned(IRD))));
                        
                        res := ('0' & src1) - ('0' & signed(K));

                        -- ZERO FLAG
                        if res(7 downto 0) = x"00" then
                            SREG_Z <= '1';
                        else
                            SREG_Z <= '0';
                        end if;

                        PC:= std_logic_vector(unsigned(PC)+1); 


                    -- Commands --INP, OUTP, CALL, RCALL, RET, RETI.
                    elsif std_match(IR, MC_INP) then
                        IOADR <= std_logic_vector(unsigned(K));
                        INPUT_FLAG0 <= '1';
                        
                        INPUT_REGISTER <= IRD;
                        PC:= std_logic_vector(unsigned(PC)+1);
                    elsif std_match(IR, MC_OUTP) then
                        IOADR <= std_logic_vector(unsigned(K));
                        IOOUT <= R(to_integer(unsigned(IRD)));
                        OUTPUT_FLAG <= '1';
                        
                        PC:= std_logic_vector(unsigned(PC)+1); 
                    elsif std_match(IR, MC_CALL) then                      
                        STACK(to_integer(unsigned(SPTR))) <= std_logic_vector(unsigned(PC)+1);    
                        SPTR <= std_logic_vector(unsigned(SPTR)+1);
                        
                        PC:= std_logic_vector(unsigned(K));
                    
                    elsif std_match(IR, MC_RCALL) then
                        STACK(to_integer(unsigned(SPTR))) <= std_logic_vector(unsigned(PC)+1);
                        
                        SPTR <= std_logic_vector(unsigned(SPTR)+1);
                        
                        res:= signed('0' & unsigned(PC)) + signed(K) ;                       
                        PC:= std_logic_vector(unsigned(res(7 downto 0)));
                
                    elsif std_match(IR, MC_RET) then 
                        SPTR <= std_logic_vector(unsigned(SPTR)-1);
                    
                        PC:= std_logic_vector(unsigned(STACK(to_integer(unsigned(SPTR)-1))));
                    
                    elsif std_match(IR, MC_RETI) then 
                        PC:= std_logic_vector(unsigned(STACK(to_integer(unsigned(SPTR)-1))));
                        SPTR <= std_logic_vector(unsigned(SPTR)-1);
                        
                        SREG <= SREGM;
                    else
                        PC:= std_logic_vector(unsigned(PC)+1); 

                    end if;
                  end if;
              end if;
    end process;

end Behavioral;
