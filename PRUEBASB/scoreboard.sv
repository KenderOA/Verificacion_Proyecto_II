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
  	bit [31:0] resultado_esperado_r;
    bit [7:0] exponente_result;
    int aciertos, fallos;
  	bit [2:0] r_mode;
  	bit guard_bit;
	bit  round_bit;
  	bit sticky_bit;
    
    virtual function void write(Item item);
        signo = item.fp_X[31] ^ item.fp_Y[31]; 
        exponente = item.fp_X[30:23] + item.fp_Y[30:23] - 127; 
        mantisa_product = {1'b1, item.fp_X[22:0]} * {1'b1, item.fp_Y[22:0]}; 

        if (mantisa_product[47]) begin 
            mantisa_result = mantisa_product[46:24];
            exponente_result = exponente + 1;
          	
            // Asignación de bits de redondeo
          	round_bit = mantisa_product[23]; 
          	guard_bit = mantisa_product[22];
      		sticky_bit =mantisa_product[21];
          
        end else begin 
          
            mantisa_result = mantisa_product[45:23];
            exponente_result = exponente;
          	// Asignación de bits de redondeo
          	round_bit = mantisa_product[22];
          	guard_bit = mantisa_product[21]; 
          	sticky_bit =mantisa_product[20];
          
        end
      
     resultado_esperado = {signo, exponente_result, mantisa_result};

    // Redondeo basado en r_mode y los bits de la tabla
    case (r_mode)
          3'b000: begin
              // Redondeo a la unidad más cercana, ties to even
              if (round_bit == 0) begin
                  // Si round_bit es 0, no se redondea
                  resultado_esperado_r = resultado_esperado;
              end else if (round_bit == 1) begin
                  // Si round_bit es 1, chequeamos el valor de guard_bit y sticky_bit
                  if (guard_bit || sticky_bit) begin
                      // Si guard_bit o sticky_bit son 1, redondeamos hacia arriba
                      resultado_esperado_r = resultado_esperado + 1;
                  end else begin
                      // Si guard_bit y sticky_bit son 0, comparo los dos valores posibles
                    if (resultado_esperado[0] == 1) begin
                          // Si mantisa_result es impar, el valor de mantisa_result + 1 será par
                          resultado_esperado_r = resultado_esperado + 1;
                      end else begin
                          // Si mantisa_result es par, no hace falta cambiarlo
                          resultado_esperado_r = resultado_esperado;
                      end
                  end
              end
          end
        3'b001: begin
            // Round to zero (truncate)
            resultado_esperado_r = resultado_esperado; // No cambios, simplemente truncar
        end
        3'b010: begin
            // Round towards -∞
             if (signo == 0) begin
                resultado_esperado_r = resultado_esperado;
            end else begin
            resultado_esperado_r = resultado_esperado + 2;
        	end
        end
        3'b011: begin
            // Round towards +∞
          if (signo == 0) begin
                resultado_esperado_r = resultado_esperado + 1;
            end else begin
            resultado_esperado_r = resultado_esperado;
        	end
        end
        3'b100: begin
            // Round to nearest, ties away from zero
          if (round_bit == 0) begin
                resultado_esperado_r = resultado_esperado;
            end else begin
            resultado_esperado_r = resultado_esperado +1;
        	end
        end
        default: begin
            `uvm_error("SCBD", "Modo de redondeo desconocido");
        end
    endcase
      
        if (!(item.fp_X inside {32'hFF800000, 32'h7F800000, 0, 32'h80000000, 32'hFFC00000, 32'h7FC00000}) && 
            !(item.fp_Y inside {32'hFF800000, 32'h7F800000, 0, 32'h80000000, 32'hFFC00000, 32'h7FC00000})) begin
            `uvm_info("SCBD", $sformatf("Exp esp: %h | Exp sal: %h | Man esp: %h | Man sal: %h | Res Esp: %h | Res Sal: %h | R_modo: %b | signo: %b " , exponente_result, item.fp_Z[30:23], mantisa_result, item.fp_Z[22:0],  item.fp_Z, resultado_esperado_r , item.r_mode, signo), UVM_LOW);
          if (resultado_esperado_r == item.fp_Z) begin
                `uvm_info("SCBD", $sformatf("PASS: RESULTADO ESPERADO: %h | RESULTADO OBTENIDO: %h", item.fp_Z, resultado_esperado_r), UVM_LOW);
            end else begin
              if(item.udrf == 1 &&  item.fp_Z inside {0, 32'h80000000}) begin
                  `uvm_info("SCBD", $sformatf("PASS: RESULTADO ESPERADO: ± 0 | RESULTADO OBTENIDO: %h", item.fp_Z), UVM_LOW);
                end else if (item.ovrf == 1 && item.fp_Z inside {32'hFF800000, 32'h7F800000}) begin
                    `uvm_info("SCBD", $sformatf("PASS: RESULTADO ESPERADO: ± inf | RESULTADO OBTENIDO: %h", item.fp_Z), UVM_LOW);
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: RESULTADO ESPERADO: %h | RESULTADO OBTENIDO: %h", resultado_esperado, item.fp_Z));
                end
            end
        end

        if (signo) begin
            signo_str = "-";
        end else begin
            signo_str = "+";
        end

        // Verificar si el resultado es ±inf
        if ((item.fp_X inside {32'hFF800000, 32'h7F800000}) || 
            (item.fp_Y inside {32'hFF800000, 32'h7F800000})) begin
            if (item.fp_Z == 32'hFF800000 || item.fp_Z == 32'h7F800000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s inf = %h", 
                                signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s inf = %h", 
                                signo_str, item.fp_Z));
                    fallos = fallos + 1;
                end
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±inf", item.fp_Z));
                fallos = fallos + 1;
            end
        end

        // Verificar si el resultado es ±0
        if ((item.fp_X inside {0, 32'h80000000}) || 
            (item.fp_Y inside {0, 32'h80000000})) begin
            if (item.fp_Z == 0 || item.fp_Z == 32'h80000000) begin
                if (signo == item.fp_Z[31]) begin
                    `uvm_info("SCBD", $sformatf("PASS: SIGNO CORRECTO Y RESULTADO CORRECTO | %s 0 = %h", 
                                signo_str, item.fp_Z), UVM_LOW);
                    aciertos = aciertos + 1;
                end else begin
                    `uvm_error("SCBD", $sformatf("ERROR: SIGNO INCORRECTO Y RESULTADO CORRECTO | %s 0 = %h", 
                                signo_str, item.fp_Z));
                    fallos = fallos + 1;
                end
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO INCORRECTO fp_Z = %h != ±0", item.fp_Z));
                fallos = fallos + 1;
            end
        end

        // Verificar si el resultado es NaN
        if ((item.fp_X inside {32'hFFC00000, 32'h7FC00000}) || 
            (item.fp_Y inside {32'hFFC00000, 32'h7FC00000})) begin
            if (item.fp_Z == 32'h7FC00000) begin
                `uvm_info("SCBD", $sformatf("PASS:  RESULTADO CORRECTO | 7fc00000 = %h", item.fp_Z), UVM_LOW);
                aciertos = aciertos + 1;
            end else begin
                `uvm_error("SCBD", $sformatf("ERROR: RESULTADO CORRECTO | 7fc00000 != %h", item.fp_Z));
                fallos = fallos + 1;
            end
        end 

        //`uvm_info("SCBD", $sformatf("ACIERTOS: %d | FALLOS: %d", aciertos, fallos), UVM_LOW);

    endfunction
 
endclass
