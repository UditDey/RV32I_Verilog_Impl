`timescale 1ns / 1ps

module control_unit(
    input  i_clock,
    input  i_reset,
    output o_fetch_1_enable,
    output o_fetch_2_enable,
    output o_exec_1_enable,
    output o_exec_2_enable,
    output o_writeback_1_enable,
    output o_writeback_2_enable
);
    reg [6:0] state;
    
    assign o_fetch_1_enable = state[0];
    assign o_fetch_2_enable = state[1];
    assign o_exec_1_enable = state[2];
    assign o_exec_2_enable = state[3];
    assign o_writeback_1_enable = state[4];
    assign o_writeback_2_enable = state[5];
    
    always @(posedge i_clock)
    begin
        if (i_reset)
            state <= 7'b1000000;
        else
            state <= state[6] || state[5] ? 7'b0000001 : state << 'd1;
    end
endmodule
