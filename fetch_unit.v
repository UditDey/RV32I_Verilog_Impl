`timescale 1ns / 1ps

module fetch_unit(
    input             i_clock,
    input             i_enable_1,
    input             i_enable_2,
    input      [31:0] i_pc,
    output            o_bus_valid,
    output     [3:0]  o_bus_strobe,
    output     [31:0] o_bus_addr,
    input      [31:0] i_bus_data,
    output reg [31:0] o_instr
);
    assign o_bus_valid = i_enable_1 || i_enable_2 ? 'b1 : 'bz;
    assign o_bus_strobe = i_enable_1 || i_enable_2 ? 'b0 : 'bz;
    assign o_bus_addr = i_enable_1 || i_enable_2 ? i_pc : 'bz;
    
    always @(posedge i_clock)
    if (i_enable_2)
    begin
        //$display("[CPU] Fetched instruction %h @ %h", i_bus_data, i_pc);
        o_instr = i_bus_data;
    end
endmodule
