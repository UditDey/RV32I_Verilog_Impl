`timescale 1ns / 1ps

module exec_unit(
    input         i_clock,
    input         i_enable_1,
    input         i_enable_2,
    output        o_bus_valid,
    output [3:0]  o_bus_strobe,
    output [31:0] o_bus_addr,
    input  [31:0] i_bus_data,
    input  [31:0] i_instr,
    input  [31:0] i_pc,
    output [4:0]  o_regfile_addr_1,
    input  [31:0] i_regfile_val_1,
    output [4:0]  o_regfile_addr_2,
    input  [31:0] i_regfile_val_2,
    output        o_reg_writeback,
    output        o_mem_writeback,
    output [31:0] o_writeback_val,
    output [3:0]  o_writeback_strobe,
    output [31:0] o_writeback_addr,
    output        o_pc_writeback,
    output [31:0] o_pc_writeback_val
);
    // Instruction decoder outputs
    wire        alu_instr;
    wire        alu_imm_instr;
    wire [9:0]  alu_op_type;
    wire        load_instr;
    wire        load_zero_ext;
    wire        store_instr;
    wire [3:0]  mem_strobe;
    wire        branch_instr;
    wire [5:0]  branch_cmp_type;
    wire        jump_link_instr;
    wire        jump_link_reg_instr;
    wire        lui_instr;
    wire        auipc_instr;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [4:0]  rd;
    wire [31:0] imm;
    
    instr_decoder instr_decoder(
        .i_instr(i_instr),
        .o_alu_instr(alu_instr),
        .o_alu_imm_instr(alu_imm_instr),
        .o_alu_op_type(alu_op_type),
        .o_load_instr(load_instr),
        .o_load_zero_ext(load_zero_ext),
        .o_store_instr(store_instr),
        .o_mem_strobe(mem_strobe),
        .o_branch_instr(branch_instr),
        .o_branch_cmp_type(branch_cmp_type),
        .o_jump_link_instr(jump_link_instr),
        .o_jump_link_reg_instr(jump_link_reg_instr),
        .o_lui_instr(lui_instr),
        .o_auipc_instr(auipc_instr),
        .o_rs1(rs1),
        .o_rs2(rs2),
        .o_rd(rd),
        .o_imm(imm)
    );
    
    // ALU inputs/outputs
    wire [31:0] alu_val_1;
    wire [31:0] alu_val_2;
    wire [31:0] alu_out;
    
    alu alu(
        .i_val_1(alu_val_1),
        .i_val_2(alu_val_2),
        .i_op_type(alu_op_type),
        .o_alu_out(alu_out)
    );
    
    // Branch unit outputs
    wire branch_taken;
    
    branch_unit branch_unit(
        .i_branch_instr(branch_instr),
        .i_val_1(i_regfile_val_1),
        .i_val_2(i_regfile_val_2),
        .i_cmp_type(branch_cmp_type),
        .o_branch_taken(branch_taken)
    );
    
    reg [31:0] load_val;
    
    assign o_regfile_addr_1 = rs1;
    assign o_regfile_addr_2 = rs2;
    
    assign alu_val_1 = i_regfile_val_1;
    assign alu_val_2 = alu_imm_instr ? imm : i_regfile_val_2;
    
    assign o_reg_writeback = ~branch_instr && ~store_instr;
    assign o_mem_writeback = store_instr;
    
    assign o_writeback_val = alu_instr || alu_imm_instr ? alu_out :
                             load_instr ? load_val :
                             store_instr ? i_regfile_val_2 :
                             jump_link_instr || jump_link_reg_instr ? i_pc + 32'h4 :
                             lui_instr ? imm << 32'd12 :
                             auipc_instr ? i_pc + (imm << 32'd12) :
                             'b?;
    
    assign o_writeback_strobe = o_mem_writeback ? mem_strobe : 'b?;
    assign o_writeback_addr = o_mem_writeback ? i_regfile_val_1 + imm : {27'b0, rd};
    
    assign o_pc_writeback = branch_taken || jump_link_instr || jump_link_reg_instr;
    
    assign o_pc_writeback_val = branch_instr || jump_link_instr ? i_pc + imm :
                                jump_link_reg_instr ? i_regfile_val_1 + imm :
                                'b?;
    
    // Load logic
    assign o_bus_strobe = (i_enable_1 || i_enable_2) && load_instr ? 'b0 : 'bz;
    assign o_bus_addr = (i_enable_1 || i_enable_2) && load_instr ? i_regfile_val_1 + imm : 'bz;
    assign o_bus_valid = (i_enable_1 || i_enable_2) && load_instr ? 'b1 : 'bz;
    
    /*always @(posedge i_clock)
    if(alu_imm_instr && alu_op_type[7] && ~alu_op_type[6])
        $display("%b %h %b", alu_val_1, alu_val_2, alu_out);*/
    
    always @(posedge i_clock)
    if (i_enable_2 && load_instr)
    begin  
        if (mem_strobe[3])
            load_val <= i_bus_data;
            
        else if (mem_strobe[1])
        begin
            load_val[15:0] <= i_bus_data[15:0];
            load_val[31:16] <= load_zero_ext ? 'b0 : i_bus_data[15];
        end
        
        else
        begin
            load_val[7:0] <= i_bus_data[7:0];
            load_val[31:8] <= load_zero_ext ? 'b0 : i_bus_data[7];
        end
    end
endmodule
