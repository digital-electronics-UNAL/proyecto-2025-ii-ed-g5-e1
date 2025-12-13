module lcd_tecl(

    input wire clk,
    input wire rst,
    input [3:0] column,
    output wire [3:0] row,
	 input [1:0] sel_msg,
   
    input reset,          
    input ready_i,

  //  input message_change,

    //input [1:0] sel_msg,

    // Numero de 4 digitos correspondiente a la contraseña
    output wire rs,        
    output wire rw,
    output enable,    
    output wire [7:0] data
);

    wire [3:0] digito1;
    wire key1;

    wire [3:0] column_clean;
	 
	 antirrebote anti1 (
        .clk(clk),
        .btn(column[0]),
        .clean(column_clean[0])
	 );

     antirrebote anti2 (
        .clk(clk),
        .btn(column[1]),
        .clean(column_clean[1])
	 );

     antirrebote anti3 (
        .clk(clk),
        .btn(column[2]),
        .clean(column_clean[2])
	 );

     antirrebote anti4 (
        .clk(clk),
        .btn(column[3]),
        .clean(column_clean[3])
	 );
	 
teclado teclas(
    .clk(clk),
    .rst(rst),
    .column(column_clean),
    .row(row),
    .digito(digito1),
    .key_detected(key1)

);

LCD1602_controller controla(
    .clk(clk),            
    .reset(reset),          
    .ready_i(ready_i),
    .message_change(),
    .sel_msg(sel_msg),
    .data_in({4'b0000, digito1}), // Numero de 4 digitos correspondiente a la contraseña
    .rs(rs),        
    .rw(rw),
    .enable(enable),    
    .data(data)
);













endmodule