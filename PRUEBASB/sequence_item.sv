class Item extends uvm_sequence_item;

    rand bit    [2:0]   r_mode;
    rand bit    [31:0]  fp_X;
    rand bit    [31:0]  fp_Y; 
    bit         [31:0]  fp_Z;
    bit                 ovrf;
    bit                 udrf;

    `uvm_object_utils_begin(Item)
        `uvm_field_real(r_mode, UVM_DEFAULT)   
        `uvm_field_real(fp_X, UVM_DEFAULT)     
        `uvm_field_real(fp_Y, UVM_DEFAULT)     
        `uvm_field_real(fp_Z, UVM_DEFAULT)     
        `uvm_field_real(ovrf, UVM_DEFAULT)     
        `uvm_field_real(udrf, UVM_DEFAULT)     
    `uvm_object_utils_end

    virtual function string convert2str();
        return $sformatf("r_mode=%0d, fp_X=%0d, fp_Y=%0d, fp_Z=%0d, ovrf=%0d, udrf=%0d", r_mode, fp_X, fp_Y, fp_Z, ovrf, udrf);
    endfunction

    function new (string name = "Item");
        super.new(name);
        
        this.r_valid.constraint_mode(1);
        this.zero.constraint_mode(0);
        this.inf.constraint_mode(0);
        this.NaN.constraint_mode(0);
        this.r_invalid.constraint_mode(0);
        this.prueba.constraint_mode(0);
    endfunction

    constraint r_valid { 
        r_mode inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100}; 
    }

    constraint zero {
        fp_X == 0 || 
        fp_Y == 0 || 
        fp_X == 32'h80000000 || 
        fp_Y == 32'h80000000 || 
        (fp_X == 0 && fp_Y == 0) || 
        (fp_X == 32'h80000000 && fp_Y == 32'h80000000);
    }

    constraint inf {
        fp_X == 32'hFF800000 || 
        fp_Y == 32'hFF800000 || 
        fp_X == 32'h7F800000 || 
        fp_Y == 32'h7F800000 || 
        (fp_X == 32'hFF800000 && fp_Y == 32'hFF800000) || 
        (fp_X == 32'h7F800000 && fp_Y == 32'h7F800000);
    }

    constraint NaN {
        fp_X == 32'hFFC00000 || 
        fp_Y == 32'hFFC00000 ||
        fp_X == 32'h7FC00000 || 
        fp_Y == 32'h7FC00000; 
    }

     constraint r_invalid { 
        !(r_mode inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100}); 
    }

    constraint prueba {
        fp_X == 32'b01110011001010110111110111100110 && 
        fp_Y == 32'b01000111101001001110001110001111;
    }

endclass
