library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity pipeline is 
port ( 
	clr, t3, c, z : in std_logic ; 
	swcba, w : in std_logic_vector (3 downto 1) ; 
	ir : in std_logic_vector (3 downto 0);
	drw, pcinc, lpc, lar, pcadd, arinc, memw, stop, lir, ldz, ldc, short, cin, m, abus, sbus, mbus, selctl : out std_logic ;
	s, sel : out std_logic_vector(3 downto 0) 
) ; 
end pipeline ; 

architecture rule of pipeline is 
	signal run, wmem, rmem, rreg, wreg, st0, nop, add, sub, aand, inc, ld, st, jc, jz, jmp, oout, mov, xxor, oor, dec, stp : std_logic ; 
begin

	-- first check swcba
	run<='1' when swcba="000" else '0' ; 
	wmem<='1' when swcba="001" else '0' ; 
	rmem<='1' when swcba="010" else '0' ; 
	rreg<='1' when swcba="011" else '0' ; 
	wreg<='1' when swcba="100" else '0' ; 
	
	-- if run and st0=1, then check ir
	nop <= '1' when ( ir="0000" and run='1' and st0='1') else '0' ; 
	add <= '1' when ( ir="0001" and run='1' and st0='1') else '0' ; 
	sub <= '1' when ( ir="0010" and run='1' and st0='1') else '0' ; 
	aand <= '1' when ( ir="0011" and run='1' and st0='1') else '0' ; 
	inc <= '1' when ( ir="0100" and run='1' and st0='1') else '0' ; 
	ld <= '1' when ( ir="0101" and run='1' and st0='1') else '0' ; 
	st <= '1' when ( ir="0110" and run='1' and st0='1') else '0' ; 
	jc <= '1' when ( ir="0111" and run='1' and st0='1') else '0' ; 
	jz <= '1' when ( ir="1000" and run='1' and st0='1') else '0' ; 
	jmp <= '1' when ( ir="1001" and run='1' and st0='1') else '0' ; 
	oout <= '1' when ( ir="1010" and run='1' and st0='1') else '0' ; 
	mov <= '1' when ( ir="1011" and run='1' and st0='1') else '0' ; 
	xxor <= '1' when ( ir="1100" and run='1' and st0='1') else '0' ; 
	oor <= '1' when ( ir="1101" and run='1' and st0='1') else '0' ; 
	dec <= '1' when ( ir="1110" and run='1' and st0='1') else '0' ; 
	stp <= '1' when ( ir="1111" and run='1' and st0='1') else '0' ; 
	
	-- deal with st0
	-- st0 needs to be changed when clr and some parts of wmem, rmem, wreg
	process(clr, w, t3)
	begin
		-- if and only if you hit clear, st0 will be 0
		if clr='0' then 
			st0 <= '0' ;
		-- st0 will be 1 at the falling edge of t3 of w1 or w2, depending on the choice
		elsif falling_edge(t3) then 
			if st0='0' and  ( (w(2)='1' and wreg='1') or (w(1)='1' and (wmem='1' or rmem='1' or run='1') ) )  then 
			st0 <= not st0 ; 
			end if ; 
		end if ; 
		
	end process ;
	
			
	-- jc, jz, jmp, ld, st 需要第二个阶段执行取指令,非流水
	-- write the expressions of out signals based on the translation table
	drw <= (wreg and (w(1) or w(2))) or (w(1) and (add or sub or aand or xxor or oor or inc or dec or mov)) or (w(2) and ld) ; 
	pcinc <= (w(1) and (nop or add or sub or aand or inc or oout or mov or xxor or oor or dec or (jc and not c) or (jz and not z))) or (w(2) and ((jc and c) or (jz and z) or jmp or ld or st)) ; 
	lpc <= (run and (not st0) and w(1)) or (jmp and w(1)) ; 
	lar <= ((not st0) and w(1) and (wmem or rmem)) or (w(1) and (ld or st)) ; 
	pcadd <= (w(1) and ((jc and c) or (jz and z)))  ; 
	arinc <= (st0 and w(1) and (wmem or rmem)) ;
	memw <= (st0 and w(1) and wmem) or (w(2) and st) ; 
	stop <= ((not st0) and w(1) and run) or (w(1) and (wmem and rmem)) or ((w(1) or w(2)) and (rreg or wreg)) or (w(1) and stp) ;
	lir <= (w(1) and (nop or add or sub or aand or inc or oout or mov or xxor or oor or dec or (jc and not c) or (jz and not z))) or (w(2) and ((jc and c) or (jz and z) or jmp or ld or st)) ;
	ldz <= w(1) and (add or sub or aand or xxor or oor or inc or dec) ; 
	ldc <= w(1) and (add or sub or inc or dec) ; 
	short <= w(1) and (wmem or rmem or (not st0 and run) or nop or add or sub or aand or inc or oout or mov or xxor or oor or dec) ; 
	cin <= (w(1) and (add or dec or mov)) ; 
	m <= (w(1) and (aand or xxor or oor or ld or jmp or oout)) or ((w(1) or w(2)) and st) ; 
	abus <= (w(1) and (add or sub or aand or xxor or oor or inc or dec or mov or ld or jmp or oout)) or ((w(1) or w(2)) and st) ; 
	sbus <= ((not st0) and w(1) and (run or rmem)) or (w(1) and wmem) or ((w(1) or w(2)) and wreg) ; 
	mbus <= (st0 and w(1) and rmem) or (w(2) and ld) ; 
	selctl <= (w(1) and (wmem or rmem)) or ((w(1) or w(2)) and (rreg or wreg)) ; 
	sel(3) <= (w(2) and rreg) or (st0 and (w(1) or w(2)) and wreg) ; 
	sel(2) <= w(2) and wreg ; 
	sel(1) <= (w(2) and rreg) or (((st0 and w(2)) or ((not st0) and w(1))) and wreg) ; 
	sel(0) <= ((w(1) or w(2)) and rreg) or (w(1) and wreg) ; 
	s(3) <= (w(1) and (add or aand or oor or dec or ld or jmp or oout)) or ((w(1) or w(2)) and st) ; 
	s(2) <= (w(1) and (sub or xxor or oor or dec or st or jmp)) ; 
	s(1) <= (w(1) and (sub or aand or xxor or oor or dec or ld or jmp or oout)) or ((w(1) or w(2)) and st) ; 
	s(0) <= (w(1) and (add or aand or dec or st or jmp)) ;
	
end rule ; 
