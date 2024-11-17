class driver extends uvm_driver #(Item);

    `uvm_component_utils(driver)

    randc int delay; // Variable de retardo aleatorio

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual mul_if vif;

    // Restricción para el retardo entre transacciones
    constraint delay_c { delay inside {[1:50]}; }

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual mul_if)::get(this, "", "mul_if", vif))
            `uvm_fatal("DRV", "Could not get vif");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            Item m_item;
            `uvm_info("DRV", "Wait for Item from sequencer", UVM_HIGH);
            seq_item_port.get_next_item(m_item);

            // Aleatorizar el retardo antes de enviar la transacción
            if (!this.randomize() with { delay inside {10, 20, 30, 40}; }) begin
                `uvm_warning("DRV", "Randomization of delay failed, using default delay of 10 time units");
                delay = 10; // Valor predeterminado en caso de fallo de randomización
            end

            `uvm_info("DRV", $sformatf("Applying delay of %0d time units before sending item", delay), UVM_LOW);

            // Aplicar el retardo aleatorio
            #delay;

            // Enviar el ítem a la interfaz
            driver_item(m_item);

            // Notificar al sequencer que se completó el envío del ítem
            seq_item_port.item_done();
        end
    endtask

    virtual task driver_item(Item m_item);
        `uvm_info("DRV", "Sending item to interface", UVM_LOW);

        // Aserción para verificar que el valor de delay esté dentro del rango esperado
        assert(delay >= 10 && delay <= 40)
            else `uvm_error("ASSERTION FAILED", $sformatf("Delay value out of range: %0d", delay));

        // Asignar valores a la interfaz
        @(vif.cb);
        vif.cb.r_mode <= m_item.r_mode; 
        vif.cb.fp_X   <= m_item.fp_X;
        vif.cb.fp_Y   <= m_item.fp_Y;
    endtask

endclass
