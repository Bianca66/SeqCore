`timescale 1ns/1ps


module seq_core_test #(parameter D_SIZE = 32,
                       parameter A_SIZE = 10);

    // General
    reg               rst;   // active 0
    reg               clk;
    // Program Memory
    wire [A_SIZE-1:0] pc;
    reg        [15:0] instruction;
    // Data Memory
    wire              read;  // active 1
    wire              write; // active 1
    wire [A_SIZE-1:0] address;
    wire [D_SIZE-1:0] data_in;
    wire [D_SIZE-1:0] data_out;
    
    wire valid;
    wire saved;
    
    
    // Program Memory
    reg [15:0] program_mem [0 : 1023];
    
    //  Instantiate Device Under Test
    seq_core dut ( // General
                  .rst        (rst),
                  .clk        (clk),
                  // Program Memory
                  .pc         (pc),
                  .instruction(instruction),
                  // Data Memory
                  .read       (read),
                  .write      (write),
                  .address    (address),
                  .data_out   (data_out),
                  .data_in    (data_in),
                  .valid      (valid),
                  .saved      (saved)
                  );
                  
    Memory dut_mem (// General
                  .clk(clk),
                  // Data Memory
                  .read       (read),  // active 1
                  .write      (write), // active 1
                  .address    (address),
                  .data_in    (data_out),
                  .data_out   (data_in),
                  .valid      (valid),
                  .saved      (saved)
                  );
     
    
   // Generate clock
   initial
   begin
    forever
        #10 
        clk = ~ clk; 
   end
   
   // Apply inputs one at a time
   initial
   begin
        rst   = 0;
        clk   = 0;
        program_mem[0]  = 0;
        // Initialize memory
        program_mem[0]  = {`LOADC,   `R0, 8'd0};
        program_mem[1]  = {`LOADC,   `R1, 8'd1};
        program_mem[2]  = {`LOAD,    `R2, 5'b00000, `R0};
        program_mem[3]  = {`ADD,     `R0, `R0, `R1};
        program_mem[4]  = {`LOAD,    `R3, 5'b00000, `R0};
        program_mem[5]  = {`ADD,     `R0, `R0, `R1};
        //program_mem[6]  = {`NOP};
        program_mem[6]   = {`FORN,     8'd19, `R2};
        program_mem[7]   = {`LOAD,    `R4, 5'b00000, `R0};
        program_mem[8]   = {`ADD,     `R0, `R0, `R1};
        program_mem[9]   = {`LOAD,    `R5, 5'b00000, `R0};
        program_mem[10]  = {`ADD,     `R0, `R0, `R1};
        program_mem[11]  = {`MUL,     `R6, `R4, `R5};
        program_mem[12]  = {`LOAD,    `R4, 5'b00000, `R0};
        program_mem[13]  = {`ADD,     `R0, `R0, `R1};
        program_mem[14]  = {`LOAD,    `R5, 5'b00000, `R0};
        program_mem[15]  = {`ADD,     `R0, `R0, `R1};
        program_mem[16]  = {`MUL,     `R7, `R4, `R5};
        program_mem[17]  = {`ADD,     `R6, `R6, `R7};
        program_mem[18]  = {`LOAD,    `R7, 5'b00000, `R0};
        program_mem[19]  = {`ADD,     `R0, `R0, `R1};
        program_mem[20]  = {`ADD,     `R6, `R7, `R6};
        program_mem[21]  = {`RELU,    `R6, 3'd0, `R6};
        program_mem[22]  = {`LOADC,   `R7, 8'd31};
        program_mem[23]  = {`SUB,     `R7, `R7, `R2};
        program_mem[24]  = {`STORE,   `R7, 5'b00000, `R6};
        program_mem[25]  = {`SUB,     `R2, `R2, `R1};
        //program_mem[26]  = {`ADD,     `R0, `R0, `R1};
        
       // program_mem[24]  = {`SUB,     `R7, `R7, `R1};
        program_mem[26] = {`HALT};
        //{`FORN,     6'd2, 6'd3};*/
     /*   program_mem[0]  = {`LOADC,   `R0, 8'd0};
        program_mem[1]  = {`LOADC,   `R1, 8'd1};
        program_mem[2]  = {`LOADC,   `R3, 8'd2};
        program_mem[3]  = {`LOAD,    `R2, 5'b00000, `R0};
        program_mem[4]  = {`FORN,     8'd2, `R2};
        program_mem[5]  = {`ADD,    `R0, `R1, `R0};
        program_mem[6]  = {`ADD,    `R3, `R1, `R3};
        //program_mem[6]  = {`FORN,     8'd3, `R2};
        program_mem[7]   = {`LOAD,    `R4, 5'b00000, `R0};
        program_mem[8]   = {`HALT};*/
        
   end 
   
  
   initial
   begin
        #110
        rst = 1; 
        instruction = program_mem[pc];
        while(instruction[15:9] != `HALT)
		begin
			@pc;
			instruction = program_mem[pc];
		end
		#20
		$stop;
   end  
    
endmodule
