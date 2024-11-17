interface mul_if (input bit clk); // Define an interface named mul_if with an input clock signal

    logic [2:0] r_mode; // 3-bit logic signal for mode
    logic [31:0] fp_X; // 32-bit logic signal for floating point X
    logic [31:0] fp_Y; // 32-bit logic signal for floating point Y

    logic [31:0] fp_Z; // 32-bit logic signal for floating point Z
    logic ovrf; // Logic signal for overflow
    logic udrf; // Logic signal for underflow

    clocking cb @(posedge clk); // Define a clocking block triggered on the positive edge of clk

        //default input #1step output #3ns; // Default timing skew for inputs and outputs (commented out)

        input fp_Z; // Input signal for floating point Z
        input ovrf; // Input signal for overflow
        input udrf; // Input signal for underflow

        output r_mode; // Output signal for mode
        output fp_X; // Output signal for floating point X
        output fp_Y; // Output signal for floating point Y

    endclocking // End of clocking block

endinterface // End of interface
