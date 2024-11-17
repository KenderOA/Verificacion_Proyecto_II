// Class declaration for the agent, extending from uvm_agent
class agent extends uvm_agent;

    // Macro to register the agent with the UVM factory
    `uvm_component_utils(agent)
    
    // Constructor for the agent class
    function new(string name = "agent", uvm_component parent = null);
        // Call the parent class constructor
        super.new(name, parent);
    endfunction

    // Declaration of driver, monitor, and sequencer
    driver d0;
    monitor m0;
    uvm_sequencer #(Item) s0;

    // Build phase method to create and initialize components
    virtual function void build_phase(uvm_phase phase);
        // Call the parent class build_phase method
        super.build_phase(phase);
        // Create the sequencer instance
        s0 = uvm_sequencer#(Item)::type_id::create("s0", this);
        // Create the driver instance
        d0 = driver::type_id::create("d0", this);
        // Create the monitor instance
        m0 = monitor::type_id::create("m0", this);
    endfunction

    // Connect phase method to connect components
    virtual function void connect_phase(uvm_phase phase);
        // Call the parent class connect_phase method
        super.connect_phase(phase);
        // Connect the driver's seq_item_port to the sequencer's seq_item_export
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction
    
endclass
