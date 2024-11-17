
// Class definition for Item, extending uvm_sequence_item
class Item extends uvm_sequence_item;

    // Randomized 3-bit mode
    rand bit [2:0] r_mode;
    // Randomized 32-bit floating point X
    rand bit [31:0] fp_X;
    // Randomized 32-bit floating point Y
    rand bit [31:0] fp_Y; 
    // 32-bit floating point Z
    bit [31:0] fp_Z;
    // Overflow flag
    bit ovrf;
    // Underflow flag
    bit udrf;

    // Macro to begin UVM object utilities
    `uvm_object_utils_begin(Item)
        // Register r_mode as a real field with default settings
        `uvm_field_real(r_mode, UVM_DEFAULT)   
        // Register fp_X as a real field with default settings
        `uvm_field_real(fp_X, UVM_DEFAULT)     
        // Register fp_Y as a real field with default settings
        `uvm_field_real(fp_Y, UVM_DEFAULT)     
        // Register fp_Z as a real field with default settings
        `uvm_field_real(fp_Z, UVM_DEFAULT)     
        // Register ovrf as a real field with default settings
        `uvm_field_real(ovrf, UVM_DEFAULT)     
        // Register udrf as a real field with default settings
        `uvm_field_real(udrf, UVM_DEFAULT)     
    // Macro to end UVM object utilities
    `uvm_object_utils_end

    // Function to convert object to string representation
    virtual function string convert2str();
        // Format and return the string representation of the object
        return $sformatf("r_mode=%0d, fp_X=%0d, fp_Y=%0d, fp_Z=%0d, ovrf=%0d, udrf=%0d", r_mode, fp_X, fp_Y, fp_Z, ovrf, udrf);
    endfunction

    // Constructor for the Item class
    function new (string name = "Item");
        // Call the parent constructor
        super.new(name);
        
        // Set constraint modes for various constraints
        this.r_valid.constraint_mode(1);
        this.zero.constraint_mode(0);
        this.inf.constraint_mode(0);
        this.NaN.constraint_mode(0);
        this.r_invalid.constraint_mode(0);
        this.prueba.constraint_mode(0);
        this.zero_x_inf_y.constraint_mode(0);
        this.inf_x_NaN_y.constraint_mode(0);
        this.zero_x_NaN_y.constraint_mode(0);
    endfunction

    // Constraint to ensure r_mode is within valid values
    constraint r_valid { 
        r_mode inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100};  
    }

    // Constraint to ensure fp_X or fp_Y are zero or specific values
    constraint zero {
        fp_X == 0 || 
        fp_Y == 0 || 
        fp_X == 32'h80000000 || 
        fp_Y == 32'h80000000 || 
        (fp_X == 0 && fp_Y == 0) || 
        (fp_X == 32'h80000000 && fp_Y == 32'h80000000);
    }

    // Constraint to ensure fp_X or fp_Y are infinity values
    constraint inf {
        fp_X == 32'hFF800000 || 
        fp_Y == 32'hFF800000 || 
        fp_X == 32'h7F800000 || 
        fp_Y == 32'h7F800000 || 
        (fp_X == 32'hFF800000 && fp_Y == 32'hFF800000) || 
        (fp_X == 32'h7F800000 && fp_Y == 32'h7F800000);
    }

    // Constraint to ensure fp_X or fp_Y are NaN values
    constraint NaN {
        fp_X == 32'hFFC00000 || 
        fp_Y == 32'hFFC00000 ||
        fp_X == 32'h7FC00000 || 
        fp_Y == 32'h7FC00000; 
    }

    // Constraint to ensure r_mode is not within valid values
    constraint r_invalid { 
        !(r_mode inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100}); 
    }

    // Constraint for specific test values of fp_X and fp_Y
    constraint prueba {
        fp_X == 32'b01110011001010110111110111100110 && 
        fp_Y == 32'b01000111101001001110001110001111;
    }
  
    // Constraint to ensure fp_X is zero and fp_Y is infinity
    constraint zero_x_inf_y {
        (fp_X == 0 || 
        fp_X == 32'h80000000) &&
        (fp_Y == 32'hFF800000 || 
        fp_Y == 32'h7F800000 );
    }

    // Constraint to ensure fp_X is infinity and fp_Y is NaN
    constraint inf_x_NaN_y {
        (fp_X == 32'hFF800000 || 
        fp_X == 32'h7F800000)  &&
        (fp_Y == 32'hFFC00000 || 
        fp_Y == 32'h7FC00000);
    }

    // Constraint to ensure fp_X is zero and fp_Y is NaN
    constraint zero_x_NaN_y {
        (fp_X == 0 || 
        fp_X == 32'h80000000)  && 
        (fp_Y == 32'hFFC00000 || 
        fp_Y == 32'h7FC00000);
    }

endclass
