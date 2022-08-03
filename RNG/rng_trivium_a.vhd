

--
--  Pseudo Random Number Generator "Trivium".
--
--  Author: Joris van Rantwijk <joris@jorisvr.nl>
-- Modifier : Dr. Rourab Paul, Siksha O Anusandhan

-- Description :  The initial code was designed by Joris van Rantwijk. Dr. Rourab Paul added controlling signals to store generated random numbers to memory 
--This block is used to generate error polynomila required for RLWE
--  See <https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use work.rlwe_pkg.all;

entity rng_trivium_a is

    generic (
        -- Number of output bits per clock cycle.
        -- Must be a power of two: either 1, 2, 4, 8, 16, 32 or 64.
        num_bits:   integer range 1 to 64;

        -- Default key.
        init_key:   std_logic_vector(79 downto 0);

        -- Default initialization vector.
        init_iv:    std_logic_vector(79 downto 0) );

    port (

        -- Clock, rising edge active.
        clk:        in  std_logic;

        -- Synchronous reset, active high.
        rst:        in  std_logic;

        -- High to request re-seeding of the generator.
        reseed:     in  std_logic;

        -- New key value (must be valid when reseed = '1').
        newkey:     in  std_logic_vector(79 downto 0);

        -- New initialization vector (must be valid when reseed = '1').
        newiv:      in  std_logic_vector(79 downto 0);

        -- High when the user accepts the current random data word
        -- and requests new random data for the next clock cycle.
        out_ready:  in  std_logic;

        -- High when valid random data is available on the output.
        -- This signal is low during the first (1152/num_bits) clock cycles
        -- after reset and after re-seeding, and high in all other cases.
        mem_ctrl:  out  std_logic_vector(1 downto 0);
        smux:  out  std_logic_vector(1 downto 0);
        addr:  out  std_logic_vector(7 downto 0);
        out_valid:  out std_logic;

        -- Random output data (valid when out_valid = '1').
        -- A new random word appears after every rising clock edge
        -- where out_ready = '1'.
        out_data:   out std_logic_vector(num_bits-1 downto 0) );

end entity;


architecture trivium_arch of rng_trivium_a is

    -- Prepare initial state vector for given key and IV.
    --
    -- NOTE: Elements 0 .. 79 from the key vector are mapped to
    --       to state elements s_80 .. s_1.
    --       Elements 0 .. 79 from the IV vector are mapped
    --       to state elements s_173 .. s_94.
    --
    --       This deviates from the original Trivium specification
    --       but is in line with the phase-3, API-compliant implementation
    --       of Trivium as published on the ECRYPT website.
    --
    function make_initial_state(nkey, niv: in std_logic_vector)
        return std_logic_vector
    is
        variable s: std_logic_vector(287 downto 0);
    begin
        assert nkey'length = 80;
        assert niv'length = 80;

        s := (others => '0');

        for k in 0 to 79 loop
            s(79-k) := nkey(k);
        end loop;

        for k in 0 to 79 loop
            s(93+79-k) := niv(k);
        end loop;

        s(288-1 downto 288-3) := "111";

        return s;
    end function;

    -- Internal state of RNG.
    signal reg_state:       std_logic_vector(287 downto 0) :=
        make_initial_state(init_key, init_iv);

    signal reg_valid_wait:  unsigned(10 downto 0) := (others => '0');

    -- Output register.
    signal reg_valid, op_valid:       std_logic := '0';
    signal reg_output:      std_logic_vector(num_bits-1 downto 0);
    signal addr_reg:    std_logic_vector(7 downto 0):= std_logic_vector(to_unsigned(base_addr_a, 8));

begin

    -- Check that num_bits is a power of 2.
    assert (64 / num_bits) * num_bits = 64;

    -- Drive output signal.
    out_valid   <= op_valid;
    out_data    <= reg_output;
    addr        <=addr_reg;

    -- Synchronous process.
    process (clk) is
        variable t1, t2, t3: std_logic_vector(num_bits-1 downto 0);
    begin
        if rising_edge(clk) then

            -- Determine valid output state.
            -- Delay by 4*288/num_bits clock cycles after re-seeding.
            if reg_valid_wait = 4*288/num_bits then
                reg_valid   <= '1';
            end if;

            if reg_valid = '0' then
                reg_valid_wait  <= reg_valid_wait + 1;
            end if;

            if out_ready = '1' or reg_valid = '0' then

                -- Prepare output word.
                t1 := reg_state(66-1 downto 66-num_bits) xor
                      reg_state(93-1 downto 93-num_bits);
                t2 := reg_state(162-1 downto 162-num_bits) xor
                      reg_state(177-1 downto 177-num_bits);
                t3 := reg_state(243-1 downto 243-num_bits) xor
                      reg_state(288-1 downto 288-num_bits);

                -- Create output word such that index 0 of the output
                -- contains the earliest-generated bit and index (num_bits-1)
                -- of the output contains the last-generated bit.
                for k in 0 to num_bits-1 loop
                    reg_output(num_bits-1-k) <= t1(k) xor t2(k) xor t3(k);
                end loop;

                -- Update internal state.
                t1 := t1 xor (reg_state(91-1 downto 91-num_bits) and
                              reg_state(92-1 downto 92-num_bits)) xor
                             reg_state(171-1 downto 171-num_bits);
                t2 := t2 xor (reg_state(175-1 downto 175-num_bits) and
                              reg_state(176-1 downto 176-num_bits)) xor
                             reg_state(264-1 downto 264-num_bits);
                t3 := t3 xor (reg_state(286-1 downto 286-num_bits) and
                              reg_state(287-1 downto 287-num_bits)) xor
                             reg_state(69-1 downto 69-num_bits);

                reg_state(93-1 downto 0) <=
                    reg_state(93-1-num_bits downto 0) & t3;
                reg_state(177-1 downto 94-1) <=
                    reg_state(177-1-num_bits downto 94-1) & t1;
                reg_state(288-1 downto 178-1) <=
                    reg_state(288-1-num_bits downto 178-1) & t2;

            end if;

            -- Re-seed function.
            if reseed = '1' then
                reg_valid       <= '0';
                reg_valid_wait  <= (others => '0');
                reg_state       <= make_initial_state(newkey, newiv);
            end if;

            -- Synchronous reset.
            if rst = '1' then
                reg_valid       <= '0';
                op_valid       <= '0';
                smux<=(others => '0');
                addr_reg<= std_logic_vector(to_unsigned(base_addr_a, 8));
                reg_valid_wait  <= (others => '0');
                reg_state       <= make_initial_state(init_key, init_iv);
                reg_output      <= (others => '0');
            end if;
            
            
            if (reg_valid='1') then
             if(addr_reg < base_addr_e2+n) then
                op_valid       <= '1';
                mem_ctrl<="11";
                smux<="01";
                addr_reg<=addr_reg+1;
             else
                addr_reg<=std_logic_vector(to_unsigned(base_addr_e2+n, 8));
                mem_ctrl<="00";
                op_valid       <= '0';
             end if;
           end if;

        end if;
    end process;

end architecture;
