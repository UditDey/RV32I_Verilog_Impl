`timescale 1ns / 1ps

module serial_tx(
    input         i_clock,
    input         i_reset,
    input  [31:0] i_bus_addr,
    input  [31:0] i_bus_data,
    output [31:0] o_bus_data,
    input  [3:0]  i_bus_strobe,
    input         i_bus_valid
);
    parameter BASE_ADDR     = 'h0; // Base address in bytes
    parameter BLOCK_SIZE    = 'h1;   // Block size in bytes
    
    
    reg  [31:0] read_result;
    wire        read;
    wire        enable;
    wire [31:0] internal_addr;
    
    reg ack;
    
    // If no strobe bit set, its a read, else a write
    assign read = i_bus_strobe == 4'b0 ? 1 : 0;
    
    // Enable only if address is in our assigned range
    assign enable = i_bus_addr == BASE_ADDR;
    
    // Address within the block
    assign internal_addr = i_bus_addr - BASE_ADDR;
    
    // Write read result to output bus
    assign o_bus_data = enable ? read_result : 'bz;
    
    always @(posedge i_clock)
    begin
        if(i_reset)
            ack <= 'h0;
        else if (i_bus_valid && enable && !read)
        begin
            if(ack)
                ack <= 'h0;
            else
            begin
                $write("%c", i_bus_data[7:0]);
                ack <= 'h1;
            end
        end
    end
endmodule