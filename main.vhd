----------------------------------------------------------------------------------
-- Company: PoliMi
-- Engineer: Lunardi Emanuele , Loria Luca
-- 
-- Create Date: 04.02.2019 17:14:30
-- Design Name: 
-- Module Name: 
-- Project Name: project_reti_logiche

----------------------------------------------------------------------------------
--Registro a 8 bit per memorizzare la maschera in input , la coordinata X e la coordinata Y del punto da valutare e il risultato da scrivere in memoria temporaneo
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register8Bit is
    port (
            inputR8 : in std_logic_vector ( 7 downto 0) ;
            clkR8 : in std_logic ;
            rstR8 : in std_logic;
            enableR8 : in std_logic;
            outputR8 : out std_logic_vector ( 7 downto 0));
end Register8Bit;

architecture behavioral of Register8Bit is 

begin 

--Salvataggio avviene solo se il segnale di enable ? alto e sul fronte di salita del clock
save_process : process ( clkR8 , rstR8 , enableR8 )
               begin
                if ( rstR8 = '1') then
                    outputR8 <= (others => '0');
                elsif (rising_edge(clkR8) and enableR8 = '1') then 
                    outputR8 <= inputR8;
                end if;
               end process;

end behavioral;
       
--Registro a 9 bit per memorizzare il risultato della sottrazione , il risultato dell'addizione tra le due sottrazioni e il  valore del minimo (addizione) attuale
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register9Bit is
    port (
            inputR9 : in std_logic_vector ( 8 downto 0) ;
            clkR9 : in std_logic ;
            rstR9 : in std_logic;
            outputR9 : out std_logic_vector ( 8 downto 0));
end Register9Bit;

architecture behavioral of Register9Bit is 

begin 

--Salvataggio avviene sul fronte di discesa del clock per essere sincronizzato correttamente con la FSM
save_process : process ( clkR9 , rstR9 , inputR9 )
               begin
                if ( rstR9 = '1') then
                    outputR9 <= (others => '0');
                elsif (falling_edge(clkR9)) then 
                    outputR9 <= inputR9;
                end if;
               end process;

end behavioral;            

--Registro a 4 bit per memorizzare l'indice , utile per scorrere i bit della maschera d'ingresso per vedere quali centroidi sono da considerare
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register4Bit is
    port (
            inputR4 : in unsigned ( 3 downto 0) ;
            clkR4 : in std_logic ;
            rstR4 : in std_logic;
            outputR4 : out unsigned ( 3 downto 0));
end Register4Bit;

architecture behavioral of Register4Bit is 

begin 

save_process : process ( clkR4 , rstR4 , inputR4 )
               begin
                if ( rstR4 = '1') then
                    outputR4 <= "0111";     --Indice inizialiazzato a 7 perch? il primo centroide che si valuta ? l'ottavo , l indice andr? a decrementarsi
                elsif (falling_edge(clkR4)) then 
                    outputR4 <= inputR4;
                end if;
               end process;

end behavioral; 

--Entit? che calcola la differenza tra la Y del punto di riferimento e la Y del centroide attualmente in esame
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CalculateDiffY is
    port (
            input_data :  in STD_LOGIC_VECTOR (7 downto 0);      --su input_data ci sar? la coordinata Y del centroide in esame
            en_diff : in std_logic ;
            clk_diff_y : in std_logic;
            rst_diff_y : in std_logic;
            index: in unsigned(3 downto 0);
            mask_in: in std_logic_vector(7 downto 0);
            y_point: in std_logic_vector(7 downto 0);
            output_diff : out std_logic_vector ( 8 downto 0 ));
end CalculateDiffY;

architecture behavioral of CalculateDiffY is 

begin 

diff_process : process ( clk_diff_y , rst_diff_y , input_data )
               begin
                if ( rst_diff_y = '1') then
                    output_diff <= "000000000";
                end if;
                if (rising_edge(clk_diff_y)) then 
                    if ( en_diff = '1' and mask_in(to_integer(index))= '1') then
                            if(unsigned(y_point)>unsigned(input_data))then 
                                output_diff <= '0' &  std_logic_vector(unsigned(y_point(7 downto 0)) - unsigned(input_data(7 downto 0)));
                            else
                                output_diff <= '0' & std_logic_vector(unsigned(input_data(7 downto 0)) -  unsigned(y_point(7 downto 0)));
                            end if;
                    end if;
                end if;
               end process;

end behavioral;

--Entit? che calcola la manhattan distance come somma tra la differenza delle coordinate Y e la differenza delle coordinate X
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CalculateDistance is
    port (
            input_data :  in STD_LOGIC_VECTOR (7 downto 0);    --su input_data ci sar? la coordinata X del centroide in esame
            en_diff : in std_logic ;
            clk_diff_x : in std_logic;
            rst_diff_x : in std_logic;
            index: in unsigned(3 downto 0);
            mask_in: in std_logic_vector(7 downto 0);
            x_point: in std_logic_vector(7 downto 0);
            suby: in std_logic_vector ( 8 downto 0 );          --differenza calcolata dalla entit? CalculateDiffY
            output_diff : out std_logic_vector ( 8 downto 0 ));
end CalculateDistance;

architecture behavioral of CalculateDistance is 

begin 

sum_process : process ( clk_diff_x , rst_diff_x , input_data )
               begin
                if ( rst_diff_x = '1') then
                    output_diff <= (others => '1');      --inizializzato ad un valore impossibile da avere che sar? sicuramente maggiore del valore pi? alto che il minimo pu? assumere
                end if;
                if (rising_edge(clk_diff_x)) then 
                    if ( en_diff = '1' ) then
                        if(mask_in(to_integer(index))= '1') then
                            if(unsigned(x_point)>unsigned(input_data))then
                                output_diff <=  std_logic_vector(unsigned(suby)+unsigned(x_point(7 downto 0)) - unsigned(input_data(7 downto 0))); 
                            else
                                output_diff <= std_logic_vector( unsigned(suby)+unsigned(input_data(7 downto 0)) - unsigned(x_point(7 downto 0)));
                            end if;
                        else
                            output_diff <= (others => '1'); 
                        end if;
                    end if;
                end if;
               end process;

end behavioral;

--Entit? che confronta la somma calcolata dall'entit? precedente e vede se ? minore del minimo attuale
--Inoltre aggiorna il vettore che andr? scritto in memoria
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MinCheck is
    port (
            en_min : in std_logic ;
            clk_min : in std_logic;
            rst_min : in std_logic;
            end_comp: out std_logic;
            min: in std_logic_vector (8 downto 0);    --valore del minimo attuale (uscita del relativo registro)
            min_tmp: out std_logic_vector (8 downto 0); --ingresso del registro che memorizza il minimo attuale
            output_data: in std_logic_vector ( 7 downto 0 ); -- valore temporaneo del vettore che verr? scritto su o_data
            output_data_tmp: out std_logic_vector ( 7 downto 0 ); --ingresso del registro che contiene il valore temporaneo che verr? scritto su o_data
            index: in unsigned(3 downto 0);  --indice che indica quale centroide ? attualmente in esame ( uscita del relativo registro)
            index_tmp: out unsigned(3 downto 0);  --ingresso del registro che memorizza l 'indice 
            out_result : in std_logic_vector ( 8 downto 0 )); --somma delle differenze calcolata nella entity precedente da confrontare con il minimo attuale (min)
end MinCheck;

architecture behavioral of MinCheck is 

begin 

min_process : process ( clk_min , rst_min )
               begin
                if ( rst_min = '1') then
                    output_data_tmp <= (others => '0');      
                    index_tmp <="0111";
                    min_tmp<="111111110";  --massimo valore che il minimo pu? assumere (510 = 255 + 255)
                end if;
                if (rising_edge(clk_min)) then 
                    if ( en_min = '1') then 
                        if(unsigned(min)>unsigned(out_result)) then   --condizione in cui si ? trovati un nuovo minimo
                            output_data_tmp <= (others => '0');
                            output_data_tmp(to_integer(index)) <= '1';
                            min_tmp <= out_result; -- out_result diventa il nuovo minimo 
                        elsif( min = out_result) then   -- condizione in cui c'? pi? di un punto equidistante dal punto di riferimento
                            output_data_tmp <= output_data;
                            output_data_tmp(to_integer(index))<='1';
                        end if;    --se il valore di out_result ? maggiore del minimo attuale non si fa niente dato che il bit ? gi? a 0 nel vettore output_data
                        if(index > "0000") then
                            index_tmp <= index -1;
                            end_comp<='0';
                        else
                            end_comp<='1';
                        end if;
                    end if;
                end if;
               end process;

end behavioral;



--Entity principale del progetto che si interfaccia con la memoria RAM
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

--Stati della macchina generale
type state_type is (Reset, EnableCounter, ReadMaskIn, ReadXPoint, ReadYPoint, CalculateDiffY, CalculateDistance, MinCheck, WriteMaskOut, Done);
signal current_state , next_state : state_type;

signal save_current_state : state_type;

--Counter a 5 bit con 20 stati , s0 ? lo stato di reset: serve per generare gli indirizzi di memoria di cui si vuole leggere il contenuto
type state_counter is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19);
signal next_counter , current_counter : state_counter; 
signal current_address : std_logic_vector(4 downto 0); -- uscita del contatore che produce l'indirizzo che si vuole leggere dalla RAM
signal en_counter : std_logic := '0'; -- segnale che se vale '1' deve fare procedere il contatore , se vale 0 rimane nello stato attuale

signal save_current_counter : state_counter;

--Signal per memorizzare la maschera di ingresso , le coordinate X e Y del punto da valutare e i segnali di enable relativi a ciascun registro
signal mask_in : std_logic_vector (7 downto 0);
signal en_mask_in : std_logic := '0';

signal x_point : std_logic_vector(7 downto 0);
signal en_x_point : std_logic := '0';

signal y_point : std_logic_vector(7 downto 0);
signal en_y_point : std_logic := '0';

--Signal per  le operazioni
signal temp_sub : std_logic_vector (8 downto 0); -- ingresso del registro che contiene la differenza tra la coordinata Y del punto principale e la coordinata Y dell ' attuale centroide che si sta valutando
signal suby : std_logic_vector ( 8 downto 0 ); -- uscita del registro a 9 bit

signal out_result_tmp : std_logic_vector (8 downto 0); -- ingresso registro che contiene la somma tra la differenza delle coordinate Y ( temp_sub) e la differenza delle coordinate X
signal out_result : std_logic_vector (8 downto 0); --uscita registro

signal min_tmp: std_logic_vector(8 downto 0); -- ingresso del registro che memorizza il minimo attuale
signal min : std_logic_vector (8 downto 0); -- uscita del registro che memorizza il minimo attuale

signal index_tmp: unsigned(3 downto 0) ; --input del registro che memorizza  l indice
signal index : unsigned(3 downto 0); --uscita del registro  che memorizza l indice

signal output_data_tmp: STD_LOGIC_VECTOR (7 downto 0); --input registro che contiene il valore della maschera di uscita temporaneo
signal output_data: STD_LOGIC_VECTOR (7 downto 0); --output registro , alla fine andr? scritto in o_data
signal en_data : std_logic := '1';

constant zero_vector : std_logic_vector(10 downto 0) := (others => '0'); --sar? concatenato con l'uscita del contatore per scrivere in o_address

--Signal per comunicare tra gli stati della FSM 
signal en_diffY : std_logic := '0';
signal en_add_diff : std_logic := '0';
signal en_min : std_logic := '0'; 

signal end_comp : std_logic := '0'; --segnale posto a 1 quando si esamina l'ultimo punto , segnala la fine dei calcoli

begin

--PORT MAP :

--Port map Register8
mask_register: entity work.Register8Bit
    port map ( inputR8 => i_data , clkR8 => i_clk , rstR8 => i_rst , enableR8 => en_mask_in , outputR8 => mask_in) ;

x_register : entity work.Register8Bit
    port map ( inputR8 => i_data , clkR8 => i_clk , rstR8 => i_rst , enableR8 => en_x_point , outputR8 => x_point) ;
    
y_register : entity work.Register8Bit
    port map ( inputR8 => i_data , clkR8 => i_clk , rstR8 => i_rst , enableR8 => en_y_point , outputR8 => y_point) ;

data_register : entity work.Register8Bit
    port map ( inputR8 => output_data_tmp , clkR8 => i_clk , rstR8 => i_rst , enableR8 => en_data , outputR8 => output_data);

--Port map Register9
sub_register: entity work.Register9Bit
    port map ( inputR9 => temp_sub , clkR9 => i_clk , rstR9 => i_rst , outputR9 => suby );
    
result_register: entity work.Register9Bit
    port map ( inputR9 => out_result_tmp , clkR9 => i_clk , rstR9 => i_rst , outputR9 => out_result );

min_register: entity work.Register9Bit
    port map ( inputR9 => min_tmp , clkR9 => i_clk , rstR9 => i_rst , outputR9 => min );

--Port map Register4
index_register : entity work.Register4Bit
    port map ( inputR4 => index_tmp , clkR4 => i_clk , rstR4 => i_rst , outputR4 => index );

--Port map CalculateDiffY
calculate_diff_y: entity work.CalculateDiffY
    port map(input_data => i_data,
            en_diff => en_diffY,
            clk_diff_y => i_clk,
            rst_diff_y => i_rst,
            index => index,
            mask_in => mask_in,
            y_point => y_point,
            output_diff => temp_sub);

--Port map CalculateDistance
calculate_distance: entity work.CalculateDistance
    port map(input_data => i_data,
            en_diff => en_add_diff,
            clk_diff_x => i_clk,
            rst_diff_x => i_rst,
            index => index,
            mask_in => mask_in,
            x_point => x_point,
            suby=> suby,
            output_diff => out_result_tmp);

--Port map MinCheck            
min_check: entity work.MinCheck
    port map(en_min => en_min,
            clk_min => i_clk,
            rst_min => i_rst,
            end_comp => end_comp,
            min => min,
            min_tmp => min_tmp,
            output_data => output_data,
            output_data_tmp => output_data_tmp,
            index => index,
            index_tmp => index_tmp,
            out_result => out_result_tmp);
            
--FINE PORT MAP.

--PROCESSES:

--Processo che tiene salvato lo stato corrente del contatore e lo stato corrente della FSM (si evita cos? un inferring latch)
counter_and_state_holder: process(i_clk, i_rst)
                            begin
                                    if(i_rst='1') then
                                         save_current_counter <= s0;
                                         save_current_state <= Reset;
                                    elsif rising_edge(i_clk) then
                                        save_current_counter <= current_counter;
                                        save_current_state <= current_state;
                                    end if;
                            end process;

--Processo del contatore che definisce lo stato di reset e l'assegnazione dello stato successivo allo stato corrente
state_reg_counter : process(i_start, i_clk , i_rst)
            begin
                if(i_rst='1') then
                    current_counter <= S0;
                elsif falling_edge(i_clk) then
                    if( i_start='1' and en_counter='1') then
                        current_counter <= next_counter;
                    else 
                        current_counter <= save_current_counter;
                    end if;
                end if;
            end process;
            
-- Processo del contatore che descrive per ogni stato il suo successivo e l indirizzo di memoria che si vuole leggere.
-- Il contatore ha come ciclo di conteggio il seguente : 0 (mask_in ) , 17 (x_point) , 18 ( y_point) , 16 ( y dell'ottavo centroide) , 15 (x dell'ottavo centroide),
-- 14( y del settimo centroide) , 13 (x del settimo centroide) e cos? via fino al primo centroide (Il primo centroide esaminato ? l'ottavo punto mentre l'ultimo ? 
-- il primo). L' ultimo indirizzo che genera ? 19 che sar? quello in cui si scriver? o_data.
counter_function : process (current_counter)
                        begin
                            case current_counter is
                                when S0 =>
                                    current_address <= "00000";
                                    next_counter <= S1;
                                when S1 =>
                                    current_address <= "10001";
                                    next_counter <= S2;
                                when S2 =>
                                    current_address <= "10010";
                                    next_counter <= S3;
                                when S3 =>
                                    current_address <= "10000";
                                    next_counter <= S4;
                                when S4 =>
                                    current_address <= "01111";
                                    next_counter <= S5;
                                when S5 =>
                                    current_address <= "01110";
                                    next_counter <= S6;
                                when S6 =>
                                    current_address <= "01101";
                                    next_counter <= S7;
                                when S7 =>
                                    current_address <= "01100";
                                    next_counter <= S8;
                                when S8 =>
                                    current_address <= "01011";
                                    next_counter <= S9;
                                when S9 =>
                                    current_address <= "01010";
                                    next_counter <= S10;
                                when S10 =>
                                    current_address <= "01001";
                                    next_counter <= S11;
                                when S11 =>
                                    current_address <= "01000";
                                    next_counter <= S12;
                                when S12 =>
                                    current_address <= "00111";
                                    next_counter <= S13;
                                when S13 =>
                                    current_address <= "00110";
                                    next_counter <= S14;
                                when S14 =>
                                    current_address <= "00101";
                                    next_counter <= S15;
                                when S15 =>
                                    current_address <= "00100";
                                    next_counter <= S16;
                                when S16 =>
                                    current_address <= "00011";
                                    next_counter <= S17;
                                when S17 =>
                                    current_address <= "00010";
                                    next_counter <= S18;
                                when S18 =>
                                    current_address <= "00001";
                                    next_counter <= S19;
                                when S19 =>
                                    current_address <= "10011"; --stato 19 in cui scriviamo la mask out
                                    next_counter <= S19;
                            end case;
                        end process;
                        
                
o_address <= zero_vector & current_address;  
o_data <= output_data;  
  
--Process che setta lo stato iniziale della FSM e aggiorna lo stato corrente ad ogni fronte di salita del clock
state_reg_FSM : process (i_clk , i_rst , i_start)
                begin
                    if(i_rst='1') then
                        current_state <= Reset;
                    elsif rising_edge(i_clk)  then
                        if(i_start= '1') then
                            current_state <= next_state;
                        else 
                            current_state <= save_current_state;
                        end if;
                    end if;
                end process;
                
            
--Process che definisce lo stato prossimo e le funzionalit? dello stato corrente della FSM.
state_function_FSM : process (current_state, i_start , end_comp )
                    begin
                        case current_state is 
                            when Reset =>
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                en_data <= '1';
                                
                                --Segnale di enable del contatore
                                en_counter <= '0';
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_add_diff <= '0';
                                en_min <= '0';
                                
                                next_state <= EnableCounter; 
                                 
                                
                            when EnableCounter => 
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '1';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore
                                en_counter <= '1';
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_add_diff <= '0';
                                en_min <= '0';
                                
                                next_state <= ReadMaskIn;  
                                 
                            when ReadMaskIn =>
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '1';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore
                                en_counter <= '1';
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_add_diff <= '0';
                                en_min <= '0';
                                
                                next_state <= ReadXPoint;
                                
                            when ReadXPoint =>
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '1';
                                
                                --Segnale di enable del contatore
                                en_counter <= '1';
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_add_diff <= '0';
                                en_min <= '0';
                                
                                next_state <= ReadYPoint;
                                
                            when ReadYPoint =>
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore
                                en_counter <= '1';

                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_add_diff <= '0';
                                en_min <= '0';
                                en_diffY <= '1';  -- nel prossimo ciclo si calcoler? la differenza delle coordinate Y
                                
                                next_state <= CalculateDiffY;
                                
                            when CalculateDiffY =>
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore
                                en_counter <= '1';
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_min <= '0';
                                en_add_diff <= '1';
                                  
                                next_state <= CalculateDistance;
                                
                            when CalculateDistance => 
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore
                                en_counter <= '0'; 
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_min <= '1';
                                en_add_diff <= '0';
                                next_state <= MinCheck;
                                
                            when MinCheck =>
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '0';
                                o_done <= '0';
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore
                                en_counter <= '1';
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_add_diff <= '0';
                                en_min <= '0';
                                if(end_comp = '0') then
                                        next_state <= CalculateDiffY;
                                        en_diffY <= '1';
                                else 
                                        next_state <= WriteMaskOut;
                                        en_diffY <= '0';
                                end if; 

                                
                            when WriteMaskOut => 
                                --Segnali per comunicare con la RAM
                                o_en <= '1';
                                o_we <= '1';   --si setta a 1 per poter scrivere in memoria
                                o_done <= '0';   
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore                           
                                en_counter <= '0'; --il contatore smette di contare
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_add_diff <= '0';
                                en_min <= '0';
                                
                                next_state <= Done;
                                
                            when Done => 
                                --Segnali per comunicare con la RAM
                                
                                o_we <= '0'; 
                                if(i_start = '1') then
                                    o_done <= '1';
                                    o_en <= '1';
                                    next_state <= Done;
                                elsif(i_start = '0') then
                                    o_done <= '0';
                                    o_en <= '0';
                                    next_state <= Reset;
                                end if; 
                                
                                --Segnali di enable dei registri per memorizzare la maschera di ingresso , x e y 
                                en_mask_in <= '0';
                                en_x_point <= '0';
                                en_y_point <= '0';
                                
                                --Segnale di enable del contatore                  
                                en_counter <= '0'; 
                                
                                --Segnali di enable per abilitare i circuiti di calcolo descritti nelle altre entit?
                                en_diffY <= '0';
                                en_add_diff <= '0';
                                en_min <= '0';
                         end case;
                    end process;
                                   
end Behavioral;

