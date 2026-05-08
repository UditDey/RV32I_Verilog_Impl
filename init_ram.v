`timescale 1ns / 1ps

module init_ram(
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
    parameter INIT_FILE     = "";
    
    reg  [7:0]  ram_storage [RAM_SIZE-1:0];
    reg  [31:0] read_result;
    wire        read;
    wire        enable;
    wire [31:0] ram_storage_addr;
    
    // If no strobe bit set, its a read, else a write
    assign read = i_bus_strobe == 4'b0 ? 1 : 0;
    
    // Enable only if address is in our assigned range
    assign enable = i_bus_addr >= BASE_ADDR && i_bus_addr < BASE_ADDR + RAM_SIZE;
    
    // Address within the internal storage
    assign ram_storage_addr = i_bus_addr - BASE_ADDR;
    
    // Write read result to output bus
    assign o_bus_data = enable ? read_result : 'bz;
    
    integer i;
    integer fd;
    reg [7:0] byte;
    
    initial begin
        fd = $fopen(INIT_FILE, "rb");
        
        if (fd == 0)
        begin
          $display("[ERROR] Cannot open ram initialization file %s", INIT_FILE);
          $finish;
        end
    
        $display("FD: %d", fd);
    
        for (i = 0; i < RAM_SIZE; i = i + 1)
        begin
            $display("%d %d", i, $fread(byte, fd));
            ram_storage[i] = byte;
        end
    end
    
    always @(posedge i_clock)
    begin
        if (i_reset)
        begin
        end
        else if (i_bus_valid && enable)
        begin
            // Read data fram storage
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