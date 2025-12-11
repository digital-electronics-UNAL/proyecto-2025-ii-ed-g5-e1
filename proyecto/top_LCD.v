module top_LCD(
    input wire clk,
    input wire reset,
    input wire ready_i,
    input distance,
    output wire rs,
    output wire rw,
    output wire enable,
    output wire [7:0] data,
    output wire p

);

localparam ESPERA = 2'b00;
localparam GUARDA = 2'b01;
localparam LLENO = 2'b10;

wire key_detected;

LCD1602_controller lcd_controller_inst (
    .clk(clk),
    .reset(reset),
    .ready_i(ready_i),
    .message_change(message_change),
    .sel_msg(2'b01),
    .data_in(data_keypad),
    // Salidas
    .rs(rs),
    .rw(rw),
    .enable(enable),
    .data(data)
);
teclado teclado_inst (
    .clk(clk),
    .rst(reset),
    .column(4'b1111), // Asumiendo que no hay pulsaciones
    .row(),
    .digito(),
    .key_detected(key_detected),
    .p(p)
);
codahexa codahexa_inst (
    .digdec(data_keypad[3:0]),
    .dighex()
);


reg message_change;
reg [1:0] sel_msg;
reg [6:0] data_keypad;

initial begin
    message_change = 0;
    sel_msg = 2'b00;
    data_keypad = 8'h20;
end

reg [1:0] estado_actual, estado_siguiente;
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        estado_actual <= ESPERA;
    end else begin
        estado_actual <= estado_siguiente;
    end
end

always @(*) begin
    // Lógica de transición de estados
    case (estado_actual)
        ESPERA: (key_detected && data_keypad != 8'h20) ? : ;
    endcase
end

endmodule