module div_f(clk, clk_1);

input clk;
output reg clk_1;
reg [27:0] cont;

initial begin
    cont = 28'd0;
    clk_1 = 0;
end

always @(posedge clk)
begin
    cont = cont + 28'd1;

    if(cont == 5000)
    begin
        cont = 0;
        clk_1 = ~clk_1;
    end
end

endmodule