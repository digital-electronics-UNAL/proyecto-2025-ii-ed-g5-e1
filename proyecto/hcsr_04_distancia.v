module hcsr04_distancia (
    input wire clk,          // Reloj del sistema (ej: 50 MHz)
    input wire rst,          // Reset
    input wire echo,         // Pin ECHO del HC-SR04
    output reg trigger,      // Pin TRIG del HC-SR04
    output reg salida        // 1 si distancia < 20cm, 0 si >=20cm
);

    // Parámetros (para reloj de 50 MHz)
    localparam CICLOS_10US  = 500;         // 10 us @ 50MHz
    localparam CICLOS_60MS  = 3_000_000;   // 60 ms @ 50MHz
    localparam DIST_20CM    = 5800 * 20;   // 1cm ≈ 5800 ciclos a 50MHz

    reg [31:0] contador;
    reg [31:0] tiempo_echo;
    reg [2:0] estado;

    localparam IDLE      = 3'd0;
    localparam TRIG      = 3'd1;
    localparam ESPERA    = 3'd2;
    localparam MIDIR     = 3'd3;
    localparam FIN       = 3'd4;

    always @(posedge clk or posedge ~rst) begin
        if (~rst) begin
            trigger <= 0;
            salida <= 0;
            contador <= 0;
            tiempo_echo <= 0;
            estado <= IDLE;
        end else begin
            case (estado)
                IDLE: begin
                    contador <= 0;
                    trigger <= 0;
                    estado <= TRIG;
                end

                TRIG: begin
                    if (contador < CICLOS_10US) begin
                        trigger <= 1;
                        contador <= contador + 1;
                    end else begin
                        trigger <= 0;
                        contador <= 0;
                        estado <= ESPERA;
                    end
                end

                ESPERA: begin
                    if (echo) begin
                        contador <= 0;
                        estado <= MIDIR;
                    end
                end

                MIDIR: begin
                    if (echo) begin
                        contador <= contador + 1;
                    end else begin
                        tiempo_echo <= contador;
                        estado <= FIN;
                    end
                end

                FIN: begin
                    if (tiempo_echo < (5800 * 20)) begin
                        salida <= 1;
                    end else begin
                        salida <= 0;
                    end

                    contador <= 0;
                    estado <= IDLE;
                end
            endcase
        end
    end

endmodule