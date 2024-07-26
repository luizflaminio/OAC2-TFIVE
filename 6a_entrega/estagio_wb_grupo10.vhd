------------------------------------------------------------------------------------------------------------
------------MODULO ESTAGIO WRITE-BACK-----------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- Especifica�ao do est�gio WRITE-BACK - wb: Declara�ao de entidade
-- Este est�gio  seleciona a informa�ao que deve ser gravada nos registradores, 
-- cuja grava�ao ser� executada no est�gio id
-- Os sinais de entrada e sa�da deste est�gio encontram-es definidos nos coment�rios 
-- da declara�ao de entidade estagio_wb.


entity estagio_wb_grupo10 is
    port(
		-- Entradas
        BWB				: in std_logic_vector(103 downto 0); -- Informa�oes vindas do estagi mem
		COP_wb			: in instruction_type := NOP;		 -- Mnem�nico da instru�ao no estagio wb
		
		-- Sa�das
        writedata_wb	: out std_logic_vector(31 downto 0); -- Valor a ser escrito emregistradores
        rd_wb			: out std_logic_vector(04 downto 0); -- Endere�o do registrador a ser escrito
		RegWrite_wb		: out std_logic						 -- Sinal de escrita nos registradores
    );
end entity;

architecture behav of estagio_wb_grupo10 is
    signal MemToReg: std_logic_vector(1 downto 0);
    signal RegWrite: std_logic;
    signal NPC: std_logic_vector(31 downto 0);
    signal ula: std_logic_vector(31 downto 0);
    signal Memval: std_logic_vector(31 downto 0);
    signal rd: std_logic_vector(4 downto 0);
begin
    process(BWB)
    begin
        MemToReg <= BWB(103 downto 102);
        RegWrite <= BWB(101);
        NPC <= BWB(100 downto 69);
        ula <= BWB(68 downto 38);
        Memval <= BWB(37 downto 6);
        rd <= BWB(5 downto 1);
    end process;

    rd_wb <= rd;
    RegWrite_wb <= RegWrite;

    mux: process(MemToReg, NPC, ula, Memval)
    begin
        if(MemToReg = "00") then -- tipo R, I, SW, B e NOP
            writedata_wb <= ula;
        elsif (MemToReg = "01") then -- tipo LW
            writedata_wb <= Memval;
        elsif (MemToReg = "10") then -- tipo JAL e JALR
            writedata_wb <= NPC;
        else
            writedata_wb <= (others => '0');
        end if;
    end process;
end architecture;