import uvm_pkg::*;
`include "uvm_macros.svh"
`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.svh"
`include "sequence_item.sv"
`include "sequence.sv"
`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"

module tb;
    reg clk;

    always #10 clk =~ clk;
    mul_if _if(clk);

    multiplicador_32_bits_FP_IEEE u0 (.clk(clk),
                .r_mode(_if.r_mode),
                .fp_X(_if.fp_X),
                .fp_Y(_if.fp_Y),
                .fp_Z(_if.fp_Z),
                .ovrf(_if.ovrf),
                .udrf(_if.udrf));

    initial begin
        clk <= 0;
        uvm_config_db#(virtual mul_if)::set(null,"uvm_test_top","mul_vif",_if);
        run_test(test);
    end
endmodule
