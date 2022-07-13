//registers
`define R0 3'b000
`define R1 3'b001
`define R2 3'b010
`define R3 3'b011
`define R4 3'b100
`define R5 3'b101
`define R6 3'b110
`define R7 3'b111

//operations

//class A instructions
//---------------------
`define ADD 		7'b0000000
`define ADDF		7'b0000001
`define SUB			7'b0000010
`define SUBF		7'b0000011
`define AND			7'b0000100
`define OR			7'b0000101
`define XOR			7'b0000110
`define NAND		7'b0000111
`define NOR			7'b0001000
`define NXOR		7'b0001001
`define MUL         7'b0001010
`define RELU        7'b0001011

`define SHIFTR		7'b0010000
`define SHIFTRA	    7'b0010000
`define SHIFTL		7'b0010000

//class B instructions
//---------------------
`define LOAD		5'b01000
`define LOADC		5'b01001
`define STORE		5'b01010
`define FORN        5'b01011
//---------------------

//class C instructions
//---------------------
`define JMP			4'b1000
`define JMPR        4'b1001
`define JMPCOND     4'b1010
`define JMPRCOND    4'b1011
//---------------------

//class D instructions
//---------------------
`define HALT		16'b1100_0000_0000_0000
`define NOP 		16'b1100_0000_0000_0001
//---------------------


`define less		 3'b000
`define greater	     3'b001
`define equal		 3'b010
`define different	 3'b011


`define with 	5'b0
`define to	 	9'b0
`define adding	6'b0