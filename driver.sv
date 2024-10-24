class driver extends uvm_driver #(Item);

    `uvm_component_utils (driver)
    function new (string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual multiplicador_if vif;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual multiplicador_if)::get(this, "", "multiplicador_vif", vif)) begin
            `uvm_fatal("DRV", "Could not get vif");
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);
        forever begin
            Item m_item; //multiplicador_item
            `uvm_info("DRV", $sformatf("Wait for Item from sequencer"), UVM_HIGH);
            seq_item_port.get_next_item(m_item);
            driver_item(m_item);
            seq_item_port.item_done();
        end
    endtask

    virtual task driver_item (multiplicador_item m_item);
        @(vif.cb);
            vif.cb.r_mode  <=  m_item.r_mode; //preguntar esto que no lo entiendo
            vif.cb.fp_X     <=  m_item.fp_X;
            vif.cb.fp_Y     <=  m_item.fp_Y;
    endtask

    

endclass