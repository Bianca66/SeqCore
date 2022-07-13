`timescale 1ns / 1ps

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

//---------------------
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

//---------------------
//class B instructions
//---------------------
`define LOAD		5'b01000
`define LOADC		5'b01001
`define STORE		5'b01010
`define FORN        5'b01011
//---------------------

//---------------------
//class C instructions
//---------------------
`define JMP			4'b1000
`define JMPR        4'b1001
`define JMPCOND     4'b1010
`define JMPRCOND    4'b1011
//---------------------

//---------------------
//class D instructions
//---------------------
`define HALT		16'b1100_0000_0000_0000
`define NOP 		16'b1100_0000_0000_0001
//---------------------

//---------------------
`define less		 3'b000
`define greater	     3'b001
`define equal		 3'b010
`define different	 3'b011
`define with 	5'b0
`define to	 	9'b0
`define adding	6'b0
//---------------------


module seq_core #(parameter A_SIZE = 10,
	              parameter D_SIZE = 32)
	              ( // General
					 input 				 rst,   
					 input				 clk,
					 // Output
					 output [A_SIZE-1:0] pc,
					 input        [15:0] instruction,
					 // Data Memory
					 output 			 read,  
					 output 			 write, 
					 output [A_SIZE-1:0] address,
					 input  [D_SIZE-1:0] data_in,
					 output [D_SIZE-1:0] data_out,
					 input               valid,
					 input               saved
                    );
	
	
	//Register
	reg [D_SIZE-1:0] 	R [7:0];  		    // 8-element array of registers D_SIZE-bit wide
	
	//All outputs are registered
	reg [A_SIZE-1:0]    pc_value;	 		// program counter value
	reg					write_value;		// write register
	reg					read_value;			// read register
	reg [D_SIZE-1:0]	data_out_value;	    // data_out register
	reg [A_SIZE-1:0]	address_value;		// address register
	
	integer	i;				 	// iterator for R reset
	reg loadc;                  // signal for LOADC
	wire stall;                 // signal for stall
	
	reg [A_SIZE-1:0] max_pc, init_pc;  // register for hardware implementation of loop, where max_count = the last address of instruction and init_pc = first address of instruction in loop block 
    reg [D_SIZE-1:0] max_count;        // max number of iterations in loop = number of instruction in loop block * number of reps
    reg [D_SIZE-1:0] count;            // counter in loop
    reg forn;                          // active 1 - hardware loop implementation
    
	assign pc 		= pc_value;
	
	//LOAD and STORE insructions
	assign address  = (instruction[15:11] == `LOAD)?  R[instruction[2:0]][A_SIZE-1:0] :
                      (instruction[15:11] == `STORE)? R[instruction[10:8]][A_SIZE-1:0]: 10'bz;
    assign stall    = (valid || saved)? 0 : (instruction[15:11] == `LOAD || instruction[15:11] == `STORE)? 1 : 0;
    assign data_out = (instruction[15:11] == `STORE)? R[instruction[2:0]] : 32'bz;   
    assign write    = (instruction[15:11] == `STORE)? 1 : 0;
    assign read     = (instruction[15:11] == `LOAD)?  1 : 0;
	
	//FORN instruction
    always@(posedge clk)
    begin
        if(instruction[15:11] == `FORN)
        begin
            forn      <= 1;
            count     <= 0;
            max_count <= $signed(instruction[10:3]) * $signed(R[instruction[2:0]]);
            init_pc   <= pc_value;
            max_pc    <= pc_value + instruction[10:3];
        end
        if(count == max_count - 2)
        begin
            forn      <= 0;
        end
    end
    
	//Program Counter
	always @(posedge clk or negedge rst)
	begin
	   if(~rst)
	   begin
	       pc_value <= 0;
	       count    <= 0;
	   end
	   else 
	       if(stall)
	       begin
	           
	       end
	       else if(forn == 1)
            begin   
                count  <= count  + 1;
                pc_value <= (pc_value == max_pc)? init_pc + 1: pc_value + 1;
           end 
           // Class C instruction
           else if (instruction[15:14]==2'b10)
           begin
               case(instruction[15:12])
                   `JMP:
                   begin
                       pc_value <= R[instruction[2:0]];
                   end//end of JMP
                   `JMPR:
                   begin
                       if(instruction[5] == 0)
                           pc_value <= pc_value + instruction[4:0];
                       else
                           pc_value <= pc_value - instruction[4:0];
                   end//end of JMPR
                   `JMPCOND:
                   begin
                       case(instruction[11:9])
                           0:
                           begin
                               pc_value = (R[instruction[8:6]] < 0)? R[instruction[2:0]] : pc_value + 1;
                           end
                           1:
                           begin
                               pc_value = (R[instruction[8:6]] >= 0)? R[instruction[2:0]] : pc_value + 1;
                           end
                           2:
                           begin
                               pc_value = (R[instruction[8:6]] == 0)? R[instruction[2:0]] : pc_value + 1;
                           end
                           3:
                           begin
                               pc_value = (R[instruction[8:6]] != 0)? R[instruction[2:0]] : pc_value + 1;
                           end
                        endcase
                    end//end of JMPCOND
                   `JMPRCOND: //case to identify condition of jump and floating point operation to calculate pc_value
                   begin
                       case(instruction[11:9])
                           0:
                           begin
                               pc_value = (R[instruction[8:6]] < 0)? (instruction[5] == 0)? pc_value + instruction[4:0] 
                                                                                          : pc_value - instruction[4:0] 
                                                                   : pc_value + 1;
                           end
                           1:
                           begin
                               pc_value = (R[instruction[8:6]] >= 0)? (instruction[5] == 0)? pc_value + instruction[4:0] 
                                                                                          : pc_value - instruction[4:0] 
                                                                    : pc_value + 1;
                           end
                           2:
                           begin
                               pc_value = (R[instruction[8:6]] == 0)? (instruction[5] == 0)? pc_value + instruction[4:0] 
                                                                                          : pc_value - instruction[4:0] 
                                                                    : pc_value + 1;
                           end
                           3:
                           begin
                               pc_value = (R[instruction[8:6]] != 0)? (instruction[5] == 0)? pc_value + instruction[4:0] 
                                                                                          : pc_value - instruction[4:0] 
                                                                    : pc_value + 1;
                           end
                        endcase
                    end//end of JMPRCOND					  
               endcase
           end
           //class D instruction		
           else if(instruction == `HALT)
           begin
                pc_value <= pc_value;
                count    <= 0;
           end
           else 
           begin
                pc_value <= pc_value + 1;
                count    <= 0;
           end
           
	end

	
	always @(posedge clk or negedge rst)
	begin		
		if(~rst)
		begin
			//if reset -> clear registers, program counter and reset all outputs.
			for(i=0;i<8;i=i+1)
				R[i] <= 0;
		end
		else if(stall)
		begin
		
		end
		// LOAD data in register
		else if(read && valid)
            R[instruction[10:8]] <= data_in;
		else
	    begin
	       case(instruction[15:14])
	       //class A instruction 
	       2'b00:
	       begin
	           if(instruction[13] == 0)
	           begin
	               case(instruction[15:9])
                       `ADD:
                       begin
                           R[instruction[8:6]] <= R[instruction[5:3]] + R[instruction[2:0]];
                       end//end of ADD  
                       `ADDF:
                       begin
                           R[instruction[8:6]] <= R[instruction[5:3]] + R[instruction[2:0]];
                       end//end of ADDF 
                       `SUB:
                       begin
                           R[instruction[8:6]] <= R[instruction[5:3]] - R[instruction[2:0]];
                       end//end of SUB 
                       `SUBF:
                       begin
                           R[instruction[8:6]] <= R[instruction[5:3]] - R[instruction[2:0]];
                       end//end of SUBF 
                       `AND:
                       begin
                           R[instruction[8:6]] <= R[instruction[5:3]] & R[instruction[2:0]];
                       end//end of AND 
                       `OR:
                       begin
                           R[instruction[8:6]] <= R[instruction[5:3]] | R[instruction[2:0]];
                       end//end of OR 
                       `XOR:
                       begin
                            R[instruction[8:6]] <= R[instruction[5:3]] ^ R[instruction[2:0]];
                       end//end of XOR  
                       `NAND:
                       begin
                            R[instruction[8:6]] <= ~(R[instruction[5:3]] & R[instruction[2:0]]);
                       end//end of NAND    
                       `NOR:
                       begin
                            R[instruction[8:6]] <= ~(R[instruction[5:3]] | R[instruction[2:0]]);
                       end//end of NOR
                       `NXOR:
                       begin
                            R[instruction[8:6]] <= ~(R[instruction[5:3]] ^ R[instruction[2:0]]);
                       end//end of NXOR 
                       `MUL:
                       begin
                            R[instruction[8:6]] <= R[instruction[5:3]] * R[instruction[2:0]];
                       end//end of MUL
                       `RELU:
                       begin
                            R[instruction[8:6]] <= ($signed(R[instruction[2:0]]) > 0)? R[instruction[2:0]] : 0;
                       end//end of RELU
				    endcase
				end
				else
				begin
				    case(instruction[12:9])
				        `SHIFTR:
				        begin
				        R[instruction[8:6]] <= R[instruction[8:6]] >> instruction[5:0];
                        end//end of SHIFTR 
                        `SHIFTRA:
                        begin
                        R[instruction[8:6]] <= R[instruction[8:6]] >>> instruction[5:0];
                        end//end of SHIFTRA 
                        `SHIFTL:
                        begin
                            R[instruction[8:6]] <= R[instruction[8:6]] << instruction[5:0];
                        end//end of SHIFTL
					endcase
				end
			end
			
		   //class B instruction
		   2'b01:
		   begin
               case(instruction[15:11])
                   `LOADC:
                   begin  
                       R[instruction[10:8]] <= instruction[7:0];
                   end
               endcase
		   end
           endcase
		end 
	end
	
endmodule