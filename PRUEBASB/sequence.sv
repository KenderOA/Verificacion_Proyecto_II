class gen_item_seq extends uvm_sequence;

    `uvm_object_utils(gen_item_seq);
    
    rand int num;
    string case_type;

    function new(string name = "gen_item_seq");
        super.new(name);
    endfunction

  constraint c1 { num inside {[1:15]}; }

    virtual task body();
        // Aserción para verificar que `num` cumple con la restricción `c1`
      assert((num >= 1) && (num <= 15)) 
            else `uvm_error("ASSERTION FAILED", $sformatf("The variable num=%0d does not satisfy constraint c1 [20:50]", num));

        case (case_type)
            "Zero": begin
                `uvm_info("SEQ", "Executing case: ZERO", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                    m_item.zero.constraint_mode(1);
                    m_item.randomize();
                    `uvm_info("SEQ", $sformatf("Generate new item in case Zero: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end

            "Infinity": begin
                `uvm_info("SEQ", "Executing case: INFINITY", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                    m_item.inf.constraint_mode(1);
                    m_item.randomize();
                    `uvm_info("SEQ", $sformatf("Generate new item in case Infinity: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end

            "NaN": begin
                `uvm_info("SEQ", "Executing case: NaN", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                    m_item.NaN.constraint_mode(1);
                    m_item.randomize();
                    `uvm_info("SEQ", $sformatf("Generate new item in case NaN: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end 

            "r_invalid": begin
                `uvm_info("SEQ", "Executing case: r_invalid", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                    m_item.r_valid.constraint_mode(0);
                    m_item.r_invalid.constraint_mode(1);
                    m_item.randomize();
                    `uvm_info("SEQ", $sformatf("Generate new item in case r_invalid: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end
                     
          "zero_x_inf_y": begin
            `uvm_info("SEQ", "Executing case: zero_x_inf_y", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                  	m_item.zero_x_inf_y.constraint_mode(1);
                    m_item.randomize();
                  `uvm_info("SEQ", $sformatf("Generate new item in Especial: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end
          	
          	"inf_x_NaN_y": begin
            `uvm_info("SEQ", "Executing case: inf_x_NaN_y", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                  	m_item.inf_x_NaN_y.constraint_mode(1);
                    m_item.randomize();
                  `uvm_info("SEQ", $sformatf("Generate new item in Especial: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end
          
          	"zero_x_NaN_y": begin
            `uvm_info("SEQ", "Executing case: zero_x_NaN_y", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                  	m_item.zero_x_NaN_y.constraint_mode(1);
                    m_item.randomize();
                  `uvm_info("SEQ", $sformatf("Generate new item in Especial: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end

            default: begin
                `uvm_info("SEQ", "Executing default case", UVM_LOW);
                for (int i = 0; i < num; i++) begin
                    Item m_item = Item::type_id::create("m_item");
                    start_item(m_item);
                    m_item.randomize();
                    `uvm_info("SEQ", $sformatf("Generate new item in default case: %s", m_item.convert2str()), UVM_HIGH);
                    finish_item(m_item);
                end
            end
        endcase

        `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW);
    endtask

endclass
