import uvm_pkg::*; // Import the UVM package
`include "uvm_macros.svh" // Include UVM macros
`include "multiplicador.sv" // Include the multiplicador module
`include "interface.sv" // Include the interface definition
`include "sequence_item.sv" // Include the sequence item definition
`include "sequence.sv" // Include the sequence definition
`include "monitor.sv" // Include the monitor definition
`include "driver.sv" // Include the driver definition
`include "scoreboard.sv" // Include the scoreboard definition
`include "agent.sv" // Include the agent definition
`include "environment.sv" // Include the environment definition
`include "test.sv" // Include the test definition

module test_bench; // Define the test bench module

        reg clk; // Declare a clock signal

        always #10 clk =~ clk; // Toggle the clock every 10 time units
        mul_if _if(clk); // Instantiate the interface with the clock signal

        multiplicador u0 (.clk(clk), // Instantiate the multiplicador module and connect signals
                        .r_mode(_if.r_mode),
                        .fp_X(_if.fp_X),
                        .fp_Y(_if.fp_Y),
                        .fp_Z(_if.fp_Z),
                        .ovrf(_if.ovrf),
                        .udrf(_if.udrf));

        initial begin // Initial block to initialize the clock and start the test
                clk <= 0; // Initialize the clock to 0
                uvm_config_db#(virtual mul_if)::set(null,"uvm_test_top","mul_if", _if); // Set the interface in the UVM configuration database
                run_test("test"); // Run the UVM test
        end
  
        initial begin // Initial block to dump waveform data
                $dumpfile("dump.vcd"); // Specify the dump file name
                $dumpvars(0, test_bench); // Dump all variables in the test bench
        end
        
endmodule // End of test bench module
