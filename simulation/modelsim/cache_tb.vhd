library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behaviour of cache_tb is

	component cache is
		generic(
			ram_size : INTEGER := 32768
		);
		port(
			clock : in std_logic;
			reset : in std_logic;

			-- Avalon interface --
			s_addr : in std_logic_vector (31 downto 0);
			s_read : in std_logic;
			s_readdata : out std_logic_vector (31 downto 0);
			s_write : in std_logic;
			s_writedata : in std_logic_vector (31 downto 0);
			s_waitrequest : out std_logic; 

			m_addr : out integer range 0 to ram_size-1;
			m_read : out std_logic;
			m_readdata : in std_logic_vector (7 downto 0);
			m_write : out std_logic;
			m_writedata : out std_logic_vector (7 downto 0);
			m_waitrequest : in std_logic
		);
	end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);	
				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process                                                 
begin      

	--Here are the 16 impossible cases
	--All the invalid cases are imposible except the read clean miss and write clean miss
	
	-- CASE 1:  (v=0, d=0, read,  miss)
	
	-- CASE 2:  (v=0, d=0, read,  hit ) imposible 
	
	-- CASE 3:  (v=0, d=0, write, miss) 
	
	-- CASE 4:  (v=0, d=0, write, hit ) imposible 
	
	-- CASE 5:  (v=0, d=1, read,  miss) imposible 
	
	-- CASE 6:  (v=0, d=1, read,  hit ) imposible 
	
	-- CASE 7:  (v=0, d=1, write, miss) imposible 
	
	-- CASE 8:  (v=0, d=1, write, hit ) imposible 
	
	-- CASE 9:  (v=1, d=0, read,  miss)
	
	-- CASE 10: (v=1, d=0, read,  hit )
	
	-- CASE 11: (v=1, d=0, write, miss)
	
	-- CASE 12: (v=1, d=0, write, hit )
	
	-- CASE 13: (v=1, d=1, read,  miss)
	
	-- CASE 14: (v=1, d=1, read,  hit )
	
	-- CASE 15: (v=1, d=1, write, miss)
	
	-- CASE 16: (v=1, d=1, write, hit )
	
                        
                   
	WAIT FOR clk_period;                                                                              
	
	-- INVALID  - WRITE MISS CLEAN and  VALID - READ HIT (CLEAN/DIRTY) 
	-- (v=0, d=0, write, miss) CASE 3
	-- (v=1, d=0, read,  hit ) CASE 10
	s_addr <= "11111111111111111111111111111111";--32 bits                        
	s_write <= '1';                                                      
	s_writedata <= x"12345678";                                          
	wait until rising_edge(s_waitrequest);                               
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	assert s_readdata = x"12345678" report "error 1" severity error;
	s_read <= '0';                                                       
	s_write <= '0';                                                      
	
	wait for clk_period;
	
	-- INVALID - READ CLEAN MISS
	-- (v=0, d=0, read, miss) CASE 1
	s_addr <= "11111111101111011111111110111111";                        
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_read <= '0';                                                       
	s_write <= '0';     
	
	wait for clk_period;

	-- VALID  READ CLEAN MISS 
	-- (v=1, d=0, read, miss) CASE 9
	s_addr <= "00000000000000000000000000000000";	
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_addr <= "00000000000000000000000010000000";	
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_read <= '0';                                                       
	s_write <= '0';
	
	wait for clk_period;

	-- VALID WRITE CLEAN HIT 
	-- (v=1, d=0, write, hit) CASE 12
	s_addr <= "10000000000000000000000000000000";	
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_write <= '1';
	s_read <= '0';
	s_writedata <= x"0000000B";
	wait until rising_edge(s_waitrequest);                               
	s_write <= '0';
	s_read <= '0';

	wait for clk_period;
		
	--VALID  WRITE CLEAN MISS
	-- (v=1, d=0, write, miss) CASE 11
	s_addr <= "11100000000000000000000000000000";	
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_addr <= "11100000000000000000001000000000";	
	s_write <= '1';
	s_read <= '0';
	s_writedata <= x"0000000D";
	wait until rising_edge(s_waitrequest);                               
	s_write <= '0';
	s_read <= '0';
	
	wait for clk_period;
	
	-- VALID WRITE DIRTY HIT 
	-- (v=1, d=1, write, hit) CASE 16
	s_addr <= "11000000000000000000000000000000";	
	s_write <= '1';
	s_read <= '0';
	s_writedata <= x"0000000B";
	wait until rising_edge(s_waitrequest);                               
	s_addr <= "11000000000000000000000000000000";	
	s_write <='0';
	wait for clk_period;
	s_write <= '1';
	s_read <= '0';
	s_writedata <= x"0000000C";
	wait until rising_edge(s_waitrequest);                               
	s_write <= '0';
	s_read <= '0';
	
	wait for clk_period;
	
	-- VALID - WRITE MISS DIRTY
	-- (v=1, d=1, write, miss) CASE 15
	WAIT FOR clk_period;
	s_addr <= "11111100000000000000000000000000";
	s_write <= '1';
	s_writedata <= x"04030201";
	wait until rising_edge(s_waitrequest);
	s_addr <= "00000000000000000000000100000000";
	s_write <= '1';
	s_writedata <= x"000000BA"; 	
	wait until rising_edge(s_waitrequest);
	s_read <= '1';
	s_write <= '0';
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"000000BA" report "write unsuccessful" severity error;
	s_read <= '0';
	s_write <= '0';

	wait for clk_period;

	-- VALID - READ MISS DIRTY
	-- (v=1, d=1, read, miss) CASE 13
	WAIT FOR clk_period;
	s_addr <= "11111110000000000000000000000000";
	s_write <= '1';
	s_writedata <= x"04030201";
	wait until rising_edge(s_waitrequest);
	s_addr <= "00000000000000000000100000000000";
	s_write <= '0';
	s_read <= '1';
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"03020100" report "write unsuccessful" severity error;
	s_read <= '0';
	s_write <= '0';

	wait;
	
end process;
	
end;