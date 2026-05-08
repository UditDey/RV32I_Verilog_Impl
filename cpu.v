`timescale 1ns / 1ps

module cpu(
    input         i_clock,
    input         i_reset,
    output [31:0] o_bus_addr,
    output [31:0] o_bus_data,
    input  [31:0] i_bus_data,
    output [3:0]  o_bus_strobe,
    output        o_bus_valid
);
    integer i;

    // PC register
    reg [31:0] pc;
    
    // General purpose register file
    reg [31:0] regfile [30:0];
    
    // Reset logic
    always @(posedge i_clock)
    if (i_reset)
    begin
        pc <= 'b0;
    
        for (i = 0; i < 31; i = i + 1)
            regfile[i] <= 'b0;
    end

    // Control unit
    wire fetch_1_enable;
    wire fetch_2_enable;
    wire exec_1_enable;
    wire exec_2_enable;
    wire writeback_1_enable;
    wire writeback_2_enable;

    control_unit control_unit(
        .i_clock(i_clock),
        .i_reset(i_reset),
        .o_fetch_1_enable(fetch_1_enable),
        .o_fetch_2_enable(fetch_2_enable),
        .o_exec_1_enable(exec_1_enable),
        .o_exec_2_enable(exec_2_enable),
        .o_writeback_1_enable(writeback_1_enable),
        .o_writeback_2_enable(writeback_2_enable)
    );
    
    // Fetch unit
    wire [31:0] instr;
    
    fetch_unit fetch_unit(
        .i_clock(i_clock),
        .i_enable_1(fetch_1_enable),
        .i_enable_2(fetch_2_enable),
        .i_pc(pc),
        .o_bus_valid(o_bus_valid),
        .o_bus_strobe(o_bus_strobe),
        .o_bus_addr(o_bus_addr),
        .i_bus_data(i_bus_data),
        .o_instr(instr)
    );
    
    // Exec unit
    wire [4:0]  regfile_addr_1;
    wire [4:0]  regfile_addr_2;
    wire        reg_writeback;
    wire        mem_writeback;
    wire [31:0] writeback_val;
    wire [3:0]  writeback_strobe;
    wire [31:0] writeback_addr;
    wire        pc_writeback;
    wire [31:0] pc_writeback_val;
    
    wire [31:0] regfile_val_1;
    wire [31:0] regfile_val_2;
    
    assign regfile_val_1 = regfile_addr_1 == 'h0 ? 'h0 : regfile[regfile_addr_1 - 'h1];
    assign regfile_val_2 = regfile_addr_2 == 'h0 ? 'h0 : regfile[regfile_addr_2 - 'h1];
    
    exec_unit exec_unit(
        .i_clock(i_clock),
        .i_enable_1(exec_1_enable),
        .i_enable_2(exec_2_enable),
        .o_bus_valid(o_bus_valid),
        .o_bus_strobe(o_bus_strobe),
        .o_bus_addr(o_bus_addr),
        .i_bus_data(i_bus_data),
        .i_instr(instr),
        .i_pc(pc),
        .o_regfile_addr_1(regfile_addr_1),
        .i_regfile_val_1(regfile_val_1),
        .o_regfile_addr_2(regfile_addr_2),
        .i_regfile_val_2(regfile_val_2),
        .o_reg_writeback(reg_writeback),
        .o_mem_writeback(mem_writeback),
        .o_writeback_val(writeback_val),
        .o_writeback_strobe(writeback_strobe),
        .o_writeback_addr(writeback_addr),
        .o_pc_writeback(pc_writeback),
        .o_pc_writeback_val(pc_writeback_val)
    );
    
    // Writeback logic
    assign o_bus_strobe = (writeback_1_enable || writeback_2_enable) && mem_writeback ? writeback_strobe : 'bz;
    assign o_bus_addr = (writeback_1_enable || writeback_2_enable) && mem_writeback ? writeback_addr : 'bz;
    assign o_bus_data = (writeback_1_enable || writeback_2_enable) && mem_writeback ? writeback_val : 'bz;
    assign o_bus_valid = (writeback_1_enable || writeback_2_enable) && mem_writeback ? 'b1 : 'bz;
    
    always @(posedge i_clock)
    if(writeback_2_enable)
    begin
        if (reg_writeback && writeback_addr != 'h0)
        begin
            regfile[writeback_addr - 'h1] <= writeback_val;
        end
            
        if (pc_writeback)
        begin
            pc <= pc_writeback_val;
        end
        else
            pc <= pc + 'h4;
    end
endmodule
