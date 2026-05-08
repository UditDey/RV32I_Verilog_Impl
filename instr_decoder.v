`timescale 1ns / 1ps

module instr_decoder(
    input  [31:0] i_instr,
    output        o_alu_instr,
    output        o_alu_imm_instr,
    output [9:0]  o_alu_op_type,
    output        o_load_instr,
    output        o_load_zero_ext,
    output        o_store_instr,
    output [3:0]  o_mem_strobe,
    output        o_branch_instr,
    output [5:0]  o_branch_cmp_type,
    output        o_jump_link_instr,
    output        o_jump_link_reg_instr,
    output        o_lui_instr,
    output        o_auipc_instr,
    output [4:0]  o_rs1,
    output [4:0]  o_rs2,
    output [4:0]  o_rd,
    output [31:0] o_imm
);
    wire [4:0] opcode;
    wire [6:0] funct7; // Applicable only for R format instructions
    wire [2:0] funct3;
    
    wire i_format;
    wire i_shift_format;
    wire s_format;
    wire b_format;
    wire j_format;
    wire u_format;
    
    assign opcode = i_instr[6:2];
    assign funct7 = i_instr[31:25];
    assign funct3 = i_instr[14:12];
    
    // Register addresses
    assign o_rs1 = i_instr[19:15];
    assign o_rs2 = i_instr[24:20];
    assign o_rd = i_instr[11:7]; // Applicable only for alu and alu_imm instructions
    
    // ALU instruction decoding
    assign o_alu_instr = opcode == 5'b01100;
    assign o_alu_imm_instr = opcode == 5'b00100;
    
    assign o_alu_op_type[0] = funct3 == 'h0 && ((o_alu_instr && ~funct7[5]) || o_alu_imm_instr);  // Add
    assign o_alu_op_type[1] = funct3 == 'h0 && o_alu_instr && funct7[5];   // Sub
    assign o_alu_op_type[2] = funct3 == 'h4;                // XOR
    assign o_alu_op_type[3] = funct3 == 'h6;                // OR
    assign o_alu_op_type[4] = funct3 == 'h7;                // AND
    assign o_alu_op_type[5] = funct3 == 'h1;                // Shift Left Logical
    assign o_alu_op_type[6] = funct3 == 'h5 && ~funct7[5];  // Shift Right Logical
    assign o_alu_op_type[7] = funct3 == 'h5 && funct7[5];   // Shift Right Arithmetic
    assign o_alu_op_type[8] = funct3 == 'h2;                // Set Less Than
    assign o_alu_op_type[9] = funct3 == 'h3;                // Set Less Than (U)
    
    // Load/Store instruction decoding
    assign o_load_instr = opcode == 5'b00000;
    assign o_load_zero_ext = funct3[2:2];
    
    assign o_store_instr = opcode == 5'b01000;
    
    assign o_mem_strobe = funct3[1:0] == 2'b00 ? 4'b0001 :  // Load/Store Byte
                          funct3[1:0] == 2'b01 ? 4'b0011 :  // Load/Store Halfword
                          funct3[1:0] == 2'b10 ? 4'b1111 :  // Load/Store Word
                          'b?;
    
    // Branch instruction decoding
    assign o_branch_instr = opcode == 5'b11000;
    
    assign o_branch_cmp_type[0] = funct3 == 'h0;    // Equal
    assign o_branch_cmp_type[1] = funct3 == 'h1;    // Not Equal
    assign o_branch_cmp_type[2] = funct3 == 'h4;    // Less Than
    assign o_branch_cmp_type[3] = funct3 == 'h5;    // Greater Than/Equal
    assign o_branch_cmp_type[4] = funct3 == 'h6;    // Less Than (U)
    assign o_branch_cmp_type[5] = funct3 == 'h7;    // Greater Than/Equal (U)
    
    // Jump instruction decoding
    assign o_jump_link_instr = opcode == 5'b11011;
    assign o_jump_link_reg_instr = opcode == 5'b11001;
    
    // Upper Immediate instruction decoding
    assign o_lui_instr = opcode == 5'b01101;
    assign o_auipc_instr = opcode == 5'b00101;
    
    assign i_format = o_alu_imm_instr || o_load_instr || o_jump_link_reg_instr;
    assign i_shift_format = i_format && funct3 == 'h5;
    assign s_format = o_store_instr;
    assign b_format = o_branch_instr;
    assign j_format = o_jump_link_instr;
    assign u_format = o_lui_instr || o_auipc_instr;
    
    // Immediate value generation
    assign o_imm = i_shift_format ? {27'b0, i_instr[24:20]} :
                   i_format ? {{20{i_instr[31]}}, i_instr[31:20]} :
                   s_format ? {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]} :
                   b_format ? {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0} :
                   j_format ? {{11{i_instr[31]}}, i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0} :
                   u_format ? {{12{i_instr[31]}}, i_instr[31:12]} :
                   'h?;
endmodule
