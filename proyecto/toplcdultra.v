module topultralcd (



       input wire clk,          // Reloj del sistema (ej: 50 MHz)
    input wire rst,          // Reset
    input wire echo,         // Pin ECHO del HC-SR04
    output  trigger,   // Pin TRIG del HC-SR04
    input reset,
    input ready_i,
    input [1:0] mns,      //Seleccionar mensaje
    output  rs,        //Register select: comando o dato   
    output  rw,        //Read/Write
    output enable,    
    output  [7:0] dat

  
);
wire alt;

hcsr04_distancia uls(
    .clk(clk),          // Reloj del sistema (ej: 50 MHz)
    .rst(rst),          // Reset
     .echo(echo),         // Pin ECHO del HC-SR04
    .trigger(trigger),      // Pin TRIG del HC-SR04
     .salida (alt)      // 1 si distancia < 20cm, 0 si >=20cm
);

mensaje_Off_LCD afu(
     .clk(clk),            
     .reset(reset),
     .ready_i(ready_i),
    .distancia(alt),      //Viene de ultrasonido    
     .mns(mns),      //Seleccionar mensaje
    .rs(rs),        //Register select: comando o dato   
    .rw(rw),        //Read/Write
     .enable(enable),    
    .dat(dat)
);




endmodule