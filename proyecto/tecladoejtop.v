module tecladoejtop(clk, columns, rows);
input clk;
input [3:0] columns;
input [3:0] rows;

wire clk_1;
wire [3:0] rows;
wire [3:0] num;

div_f div(clk, clk_1);
swept sp(clk_1, rows);
compt comp(clk_1, columns, rows, num);

endmodule