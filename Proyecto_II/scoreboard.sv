class scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(scoreboard)
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(mul_item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction

    virtual function write(mul_item item);
        if (item.fp_X == 0) begin
            `uvm_error("SCBD", "ERROR ! fp_X is 0")
        end else begin
            `uvm_info("SCBD", "PASS ! fp_X is not 0", UVM_HIGH)
        end
    endfunction
endclass
