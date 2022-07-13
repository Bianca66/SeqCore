`include "opcode.v"
`timescale 1ns / 1ps

module Memory #(parameter D_SIZE = 32,
                parameter A_SIZE = 10,
                parameter M_SIZE = 32)
               (// General
                input               clk,
                // Data Memory
                input               read,  // active 1
                input               write, // active 1
                input  [A_SIZE-1:0] address,
                input  [D_SIZE-1:0] data_in,
                output reg [D_SIZE-1:0] data_out,
                output reg valid,
                output reg saved
               );
    
    reg [D_SIZE-1:0] mem [0:M_SIZE-1];
    
    initial
    begin
        $readmemb("data_memory.mem",mem);
    end
    
    always @(posedge clk)
    begin
        if(read)
        begin
            data_out <= mem[address];
            valid    <= 1;
        end
        else
        begin
            valid    <= 0;
        end
        if(write)
        begin
            mem[address] <= data_in;
            saved        <= 1;
        end
        else
        begin
            saved        <= 0;
        end
    end 
endmodule
