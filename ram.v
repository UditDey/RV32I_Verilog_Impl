`timescale 1ns / 1ps

module ram(
    input         i_clock,
    input         i_reset,
    input  [31:0] i_bus_addr,
    input  [31:0] i_bus_data,
    output [31:0] o_bus_data,
    input  [3:0]  i_bus_strobe,
    input         i_bus_valid
);
    parameter BASE_ADDR     = 0; // Base address in 
    parameter RAM_SIZE      = 0; // RAM storage size in bytes
    
    reg  [7:0]  ram_storage [RAM_SIZE-1:0];
    reg  [31:0] read_result;
    wire        read;
    wire        enable;
    wire [31:0] ram_storage_addr;
    
    integer i;
    
    // If no strobe bit set, its a read, else a write
    assign read = i_bus_strobe == 4'b0 ? 1 : 0;
    
    // Enable only if address is in our assigned range
    assign enable = i_bus_addr >= BASE_ADDR && i_bus_addr < BASE_ADDR + RAM_SIZE;
    
    // Address within the internal storage
    assign ram_storage_addr = i_bus_addr - BASE_ADDR;
    
    // Write read result to output bus
    assign o_bus_data = read_result;
    
    always @(posedge i_clock)
    begin
        if (i_reset)
        begin
            for (i = 0; i < RAM_SIZE - 1; i = i + 1)
                ram_storage[i] <= 'b0;
        end
        else if (i_bus_valid && enable)
        begin
            // Read data from storage
            if (read)
            begin
                read_result <= {
                    ram_storage[ram_storage_addr + 3],
                    ram_storage[ram_storage_addr + 2],
                    ram_storage[ram_storage_addr + 1],
                    ram_storage[ram_storage_addr]
                };
            end
            
            // Write data to storage
            else
            begin
                if (i_bus_strobe[0])
                    ram_storage[ram_storage_addr] <= i_bus_data[7:0];
                    
                if (i_bus_strobe[1])
                    ram_storage[ram_storage_addr + 1] <= i_bus_data[15:8];
                
                if (i_bus_strobe[2])
                    ram_storage[ram_storage_addr + 2] <= i_bus_data[23:16];
                
                if (i_bus_strobe[3])
                    ram_storage[ram_storage_addr + 3] <= i_bus_data[31:24];
            end
        end
    end
endmodule