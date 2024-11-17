class driver extends uvm_driver #(Item); // Define the driver class extending uvm_driver with parameter Item

    `uvm_component_utils(driver) // Macro to register the driver class with UVM factory

    randc int delay; // Variable for random delay

    function new(string name = "driver", uvm_component parent = null); // Constructor for the driver class
        super.new(name, parent); // Call the base class constructor
    endfunction

    virtual mul_if vif; // Virtual interface handle

    // Constraint for the delay between transactions
    constraint delay_c { delay inside {[1:50]}; } // Constraint to limit delay values between 1 and 50

    virtual function void build_phase(uvm_phase phase); // Build phase function
        super.build_phase(phase); // Call the base class build_phase
        if (!uvm_config_db#(virtual mul_if)::get(this, "", "mul_if", vif)) // Get the virtual interface from the configuration database
            `uvm_fatal("DRV", "Could not get vif"); // Fatal error if the interface is not found
    endfunction

    virtual task run_phase(uvm_phase phase); // Run phase task
        super.run_phase(phase); // Call the base class run_phase
        forever begin // Infinite loop to keep the driver running
            Item m_item; // Declare an item of type Item
            `uvm_info("DRV", "Wait for Item from sequencer", UVM_HIGH); // Print info message
            seq_item_port.get_next_item(m_item); // Get the next item from the sequencer

            // Randomize the delay before sending the transaction
            if (!this.randomize() with { delay inside {10, 20, 30, 40}; }) begin // Randomize delay with specific values
                `uvm_warning("DRV", "Randomization of delay failed, using default delay of 10 time units"); // Warning if randomization fails
                delay = 10; // Default delay value if randomization fails
            end

            `uvm_info("DRV", $sformatf("Applying delay of %0d time units before sending item", delay), UVM_LOW); // Print info message with delay value

            // Apply the random delay
            #delay; // Delay for the randomized time

            // Send the item to the interface
            driver_item(m_item); // Call the driver_item task

            // Notify the sequencer that the item has been sent
            seq_item_port.item_done(); // Notify item done
        end
    endtask

    virtual task driver_item(Item m_item); // Task to drive the item to the interface
        `uvm_info("DRV", "Sending item to interface", UVM_LOW); // Print info message

        // Assertion to check that the delay value is within the expected range
        assert(delay >= 10 && delay <= 40) // Assert delay is within range
            else `uvm_error("ASSERTION FAILED", $sformatf("Delay value out of range: %0d", delay)); // Error if assertion fails

        // Assign values to the interface
        @(vif.cb); // Wait for a clock cycle
        vif.cb.r_mode <= m_item.r_mode; // Assign r_mode to the interface
        vif.cb.fp_X   <= m_item.fp_X; // Assign fp_X to the interface
        vif.cb.fp_Y   <= m_item.fp_Y; // Assign fp_Y to the interface
    endtask

endclass
