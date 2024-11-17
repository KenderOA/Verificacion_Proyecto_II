
// Class definition for gen_item_seq which extends uvm_sequence
class gen_item_seq extends uvm_sequence;

  // Macro to register the gen_item_seq class with the UVM factory
  `uvm_object_utils(gen_item_seq);
  
  // Random integer variable
  rand int num;
  // String variable to hold the case type
  string case_type;

  // Constructor for the gen_item_seq class
  function new(string name = "gen_item_seq");
    // Call to the parent class constructor
    super.new(name);
  endfunction

  // Constraint to ensure num is within the range [1:15]
  constraint c1 { num inside {[1:15]}; }

  // Virtual task that defines the body of the sequence
  virtual task body();
    // Assertion to verify that `num` satisfies the constraint `c1`
    assert((num >= 1) && (num <= 15)) 
      else `uvm_error("ASSERTION FAILED", $sformatf("The variable num=%0d does not satisfy constraint c1 [20:50]", num));

    // Case statement to handle different case types
    case (case_type)
      // Case for "Zero"
      "Zero": begin
        `uvm_info("SEQ", "Executing case: ZERO", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.zero.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in case Zero: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end

      // Case for "Infinity"
      "Infinity": begin
        `uvm_info("SEQ", "Executing case: INFINITY", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.inf.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in case Infinity: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end

      // Case for "NaN"
      "NaN": begin
        `uvm_info("SEQ", "Executing case: NaN", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.NaN.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in case NaN: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end 

      // Case for "r_invalid"
      "r_invalid": begin
        `uvm_info("SEQ", "Executing case: r_invalid", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.r_valid.constraint_mode(0);
          m_item.r_invalid.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in case r_invalid: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end
           
      // Case for "zero_x_inf_y"
      "zero_x_inf_y": begin
        `uvm_info("SEQ", "Executing case: zero_x_inf_y", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.zero_x_inf_y.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in Especial: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end
      
      // Case for "inf_x_NaN_y"
      "inf_x_NaN_y": begin
        `uvm_info("SEQ", "Executing case: inf_x_NaN_y", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.inf_x_NaN_y.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in Especial: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end
      
      // Case for "zero_x_NaN_y"
      "zero_x_NaN_y": begin
        `uvm_info("SEQ", "Executing case: zero_x_NaN_y", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Apply constraints and randomize the item
          m_item.zero_x_NaN_y.constraint_mode(1);
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in Especial: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end

      // Default case
      default: begin
        `uvm_info("SEQ", "Executing default case", UVM_LOW);
        for (int i = 0; i < num; i++) begin
          // Create and start a new item
          Item m_item = Item::type_id::create("m_item");
          start_item(m_item);
          // Randomize the item without additional constraints
          m_item.randomize();
          `uvm_info("SEQ", $sformatf("Generate new item in default case: %s", m_item.convert2str()), UVM_HIGH);
          finish_item(m_item);
        end
      end
    endcase

    // Log the completion of item generation
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW);
  endtask

endclass
