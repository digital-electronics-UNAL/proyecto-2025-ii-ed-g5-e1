module buzzer(clk, j, k);
    input clk;
    input [1:0] j;
    output reg k;


    always @(posedge clk) begin
        if (j == 2'b11 ) begin //j es el contador de intentos, que se reinicia en el top al no detectar por ultra
            k <= 1; //k es el buzzer
        end else if (j == 2'b10 ) begin
            k <= 0;
            end else if (j == 2'b01 ) begin
            k <= 0;
            end else if (j == 2'b00 ) begin
            k <= 0;
        end
       
    end
endmodule