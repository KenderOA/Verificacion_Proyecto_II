class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)
    
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_analysis_imp = new("m_analysis_imp", this);
    endfunction
    
    bit signo;
    string signo_str;
    bit [7:0] exponente;
    bit [22:0] mantisa_result;
    bit [47:0] mantisa_product;
    bit [31:0] resultado_esperado;
    int exponente_result;
  	int aciertos, fallos;
    

    virtual function void write(Item item);
    
        signo = item.fp_X[31] ^ item.fp_Y[31];  
        exponente = item.fp_X[30:23] + item.fp_Y[30:23] - 127; 
        mantisa_product = {1'b1, item.fp_X[22:0]} * {1'b1, item.fp_Y[22:0]}; 

        resultado_esperado = {signo, exponente, mantisa_result};

        if (mantisa_product[47]) begin 
            mantisa_result = mantisa_product[46:24];
            exponente_result = exponente + 1;
            resultado_esperado = {signo, exponente_result, mantisa_result};

        end else begin 
            mantisa_result = mantisa_product[45:23];
            exponente_result = exponente;
        end

        if (signo) begin
            signo_str = "-";
        end else begin
            signo_str = "+";
        end

        // Verificar si el resultado es ±inf
        if (item.fp_X == 32'hFF800000 || item.fp_Y == 32'hFF800000 || item.fp_X == 32'h7F800000 || item.fp_Y == 32'h7F800000) begin
            if (item.fp_Z == 32'hFF800000 || item.fp_Z == 32'h7F800000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s inf = %h", signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos +1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s inf = %h", signo_str, item.fp_Z));
                    fallos = fallos +1;
                end
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±inf", item.fp_Z));
                fallos = fallos +1;
            end
        end

        // Verificar si el resultado es ±0
        if (item.fp_X == 0|| item.fp_Y == 0 || item.fp_X == 32'h80000000 || item.fp_Y == 32'h80000000) begin
            if (item.fp_Z == 0 || item.fp_Z == 32'h80000000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s 0 = %h", signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos +1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s 0 = %h", signo_str, item.fp_Z));
                    fallos = fallos +1;
                end
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±0", item.fp_Z));
                fallos = fallos +1;
            end
        end

        // Verificar si el resultado es NaN
        if (item.fp_X == 32'hFFC00000 || item.fp_Y == 32'hFFC00000 || item.fp_X == 32'h7FC00000 || item.fp_Y == 32'h7FC00000) begin
            if (item.fp_Z == 32'h7FC00000) begin
                    `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                    aciertos = aciertos +1;
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO CORRECTO | 7fc00000 != %h", item.fp_Z));
                fallos = fallos +1;
            end
        end 

	`uvm_info("SCBD", $sformatf("ACIERTOS: %d | FALLOS: %d", aciertos, fallos), UVM_LOW);

    endfunction
 
endclass
