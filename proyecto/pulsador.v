module pulsador(clk, j, k);
    input clk;
    input b;
    output reg k;


    always @(posedge clk) begin
        if (b == 1 ) begin //b es el boton de adentro. Si es 1, se va al estado de apertura de puerta. Si es 0, se mantiene en s_0
            t <= 1;     //esto se debe hacer con maquinas de estado
        end else if (b == 0 ) begin
            t <= 0;
            end 
       
    end
endmodule