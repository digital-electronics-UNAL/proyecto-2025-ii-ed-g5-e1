module swept(clk_1, rows);
input clk_1;
output reg [3:0] rows;

reg [1:0] cont;

always @(posedge clk_1)
begin
    case(cont)
    2'b00: begin 
        rows <= 4'b1000;  
        end
    2'b01: begin 
        rows <= 4'b0100;  
        end
    2'b10: begin 
        rows <= 4'b0010;  
        end
    2'b11: begin 
        rows <= 4'b0001;  
        end
    endcase

    cont = cont + 2'b1;
end
endmodule