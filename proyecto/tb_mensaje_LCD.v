`include "mensaje_Off_LCD.v"
`timescale 1ns / 1ps

module tb_mensaje_LCD();
    reg clk;
    reg rst;
    reg ready_i;
    reg distancia;
    reg [1:0] mns;

    mensaje_Off_LCD #(4, 16, 8, 50) uut (
        .clk(clk),
        .reset(rst),
        .ready_i(ready_i),
        .distancia(distancia),
        .mns(mns)
    );

    initial begin
        clk = 0;
        rst = 1;
        ready_i = 1;
        distancia = 1;
        mns = 2'b00;
        #10 rst = 0;
        #10 rst = 1;

        #200000;
        mns = 2'b00;
        #200000;
        mns = 2'b01;
        distancia <= 0;
        #200000;
        distancia <= 1;
        #200000;
        mns = 2'b10;
        #200000;
        mns = 2'b11;
        #200000;
    end

    always #10 clk = ~clk;

    initial begin
        $dumpfile("tb_mensaje.vcd");
        $dumpvars(-1, uut);
        #(1200000) $finish;
    end


endmodule