module uart_lock_control (
    input wire clk,         // Reloj de 50 MHz
    input wire rst,         // Reset activo alto
    input wire rx_pin,      // Pin RX desde ESP32
    output reg lock_open    // Salida para controlar cerradura (1: abierta, 0: cerrada)
);

    // Parámetros UART
    localparam CLKS_PER_BIT = 434;  // Para 50 MHz y 115200 baud

    // Señales de uart_rx
    wire rx_valid;
    wire [7:0] rx_byte;

    // Instancia de uart_rx
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uart_rx_inst (
        .i_Clock(clk),
        .i_Rx_Serial(rx_pin),
        .o_Rx_DV(rx_valid),
        .o_Rx_Byte(rx_byte)
    );

    // Lógica de control de cerradura
    
always @(posedge clk or posedge rst) begin
        if (rst) begin
            lock_open <= 1'b0;
        end else if (rx_valid) begin
            if (rx_byte == "A")       lock_open <= 1'b1;
            else if (rx_byte == "C")  lock_open <= 1'b0;
        end
    end

endmodule