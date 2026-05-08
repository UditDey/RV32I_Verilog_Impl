`timescale 1ns / 1ps

module alu(
    input  [31:0] i_val_1,
    input  [31:0] i_val_2,
    input  [9:0]  i_op_type,
    output [31:0] o_alu_out
);
    wire [31:0] signed_shift;
    wire signed_lt;
    
    signed_shifter signed_shifter(
        .i_val_1(i_val_1),
        .i_val_2(i_val_2),
        .o_shift(signed_shift)
    );
    
    signed_lessthan signed_lessthan(
        .i_val_1(i_val_1),
        .i_val_2(i_val_2),
        .o_lt(signed_lt)
    );

    assign o_alu_out = i_op_type[0] ? i_val_1 + i_val_2   :   // Add
                       i_op_type[1] ? i_val_1 - i_val_2   :   // Sub
                       i_op_type[2] ? i_val_1 ^ i_val_2   :   // XOR
                       i_op_type[3] ? i_val_1 | i_val_2   :   // OR
                       i_op_type[4] ? i_val_1 & i_val_2   :   // AND
                       i_op_type[5] ? i_val_1 << i_val_2  :   // Shift Left Logical
                       i_op_type[6] ? i_val_1 >> i_val_2  :   // Shift Right Logical
                       i_op_type[7] ? signed_shift :   // Shift Right Arithmetic
                       i_op_type[8] ? (signed_lt ? 'b1 : 'b0)   : // Set Less Than
                       i_op_type[9] ? (i_val_1 < i_val_2 ? 'b1 : 'b0) : // Set Less Than (U)
                       'b?;
endmodule

module signed_shifter(
    input signed [31:0] i_val_1,
    input signed [31:0] i_val_2,
    output       [31:0] o_shift
);
    assign o_shift = i_val_1 >>> i_val_2;
endmodule

module signed_lessthan(
    input signed [31:0] i_val_1,
    input signed [31:0] i_val_2,
    output              o_lt
);
    assign o_lt = i_val_1 < i_val_2;
endmodule

module signed_greaterthanequal(
    input signed [31:0] i_val_1,
    input signed [31:0] i_val_2,
    output              o_gte
);
    assign o_gte = i_val_1 >= i_val_2;
endmodule