module uart_lock_control (
    input wire clk,
    input wire rst,
    input wire rx_pin,
    output reg lock_open
);

    // Parámetros UART
    localparam CLKS_PER_BIT = 434;  // Corregido a 434
    
    // Códigos ASCII
    localparam CHAR_A = 8'h41;  // 'A' = 0x41
    localparam CHAR_C = 8'h43;  // 'C' = 0x43

    // Señales de uart_rx
    wire rx_valid;
    wire [7:0] rx_byte;

    // Instancia de uart_rx
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx_inst (
        .i_Clock(clk),
        .i_Reset(rst),      // AÑADIDO
        .i_Rx_Serial(rx_pin),
        .o_Rx_DV(rx_valid),
        .o_Rx_Byte(rx_byte)
    );



    // Lógica de control de cerradura - CORREGIDA
    always @(posedge clk or posedge rst) begin
        if (!rst) begin
            lock_open <= 1'b0;
        end else if (rx_valid) begin
            if (rx_byte == CHAR_A)       // Comparación corregida
                lock_open <= 1'b1;
            else if (rx_byte == CHAR_C)  // Comparación corregida
                lock_open <= 1'b0;
        end
    end

endmodule