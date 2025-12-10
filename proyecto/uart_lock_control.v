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
    always @(posedge clk or posedge ~rst) begin
        if (!rst) begin
            lock_open <= 1'b0;  // Cerrada por defecto
        end else begin
            if (rx_valid) begin
                case (rx_byte)
                    8'h41: lock_open <= 1'b1;  // 'A' -> Abrir
                    8'h43: lock_open <= 1'b0;  // 'C' -> Cerrar
                    default: lock_open <= lock_open;  // Ignora otros caracteres
                endcase
            end
        end
    end

endmodule