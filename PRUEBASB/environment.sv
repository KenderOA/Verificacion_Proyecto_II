// Class definition for the environment, extending from uvm_env
class env extends uvm_env;

    // Macro to register the component with the factory
    `uvm_component_utils(env)

    // Constructor for the environment class
    function new(string name = "env", uvm_component parent = null);
        // Call the parent class constructor
        super.new(name, parent);
    endfunction

    // Handle for the agent
    agent        a0;     
    // Handle for the scoreboard
    scoreboard   sb0;

    // Build phase function to create and configure components
    virtual function void build_phase(uvm_phase phase);
        // Call the parent class build_phase
        super.build_phase(phase);
        // Create an instance of the agent
        a0 = agent::type_id::create("a0", this);
        // Create an instance of the scoreboard
        sb0 = scoreboard::type_id::create("sb0", this);
    endfunction

    // Connect phase function to connect components
    virtual function void connect_phase(uvm_phase phase);
        // Call the parent class connect_phase
        super.connect_phase(phase);
        // Connect the monitor analysis port of the agent to the analysis imp of the scoreboard
        a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
    endfunction
  
endclass

