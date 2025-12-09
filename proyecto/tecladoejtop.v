module tecladoejtop(clk, columns, nume);
input clk;
input [3:0] columns;
output [3:0] nume;

wire clk_1;
wire [3:0] rows;


div_f div(.clk(clk), .clk_1(clk_1));
swept sp(.clk_1(clk_1), .rows(rows));
compt comp(.clk_1(clk_1), .columns(columns), .rows(rows), .num(nume));

endmodule