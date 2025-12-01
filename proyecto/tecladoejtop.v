module tecladoejtop(clk, columns, rows, nume);
input clk;
input [3:0] columns;
input [3:0] rows;
output reg [3:0] nume;

wire clk_1;
wire [3:0] rows;


div_f div(clk, clk_1);
swept sp(clk_1, rows);
compt comp(clk_1, columns, rows, nume);

endmodule