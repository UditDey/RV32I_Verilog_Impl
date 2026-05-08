`timescale 1ns / 1ps

module branch_unit(
    input        i_branch_instr,
    input [31:0] i_val_1,
    input [31:0] i_val_2,
    input [5:0]  i_cmp_type,
    output       o_branch_taken
);
    wire signed_lt;
    wire signed_gte;
    
    signed_lessthan signed_lessthan(
        .i_val_1(i_val_1),
        .i_val_2(i_val_2),
        .o_lt(signed_lt)
    );

    signed_greaterthanequal signed_greaterthanequal(
        .i_val_1(i_val_1),
        .i_val_2(i_val_2),
        .o_gte(signed_gte)
    );

    wire cmp_result;
    
    assign cmp_result = i_cmp_type[0] ? i_val_1 == i_val_2 : // Equal
                        i_cmp_type[1] ? i_val_1 != i_val_2 : // Not Equal
                        i_cmp_type[2] ? signed_lt : // Less Than
                        i_cmp_type[3] ? signed_gte : // Greater Than/Equal
                        i_cmp_type[4] ? i_val_1 < i_val_2 : // Less Than (U)
                        i_cmp_type[5] ? i_val_1 >= i_val_2 : // Greater Than/Equal (U)
                        'b?;
                        
    assign o_branch_taken = i_branch_instr && cmp_result;
endmodule