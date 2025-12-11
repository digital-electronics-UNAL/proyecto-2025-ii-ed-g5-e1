module codahexa (
    

    input [3:0] digdec,
    output reg [7:0] dighex
);

always @ ( * ) begin
     if (digdec == 4'b1111) dighex = 8'h30; // "0"
     if (digdec == 4'b1110) dighex = 8'h31; // "1"  
  	 if (digdec == 4'b1101) dighex = 8'h32; // "2"
     if (digdec == 4'b1100) dighex = 8'h33; // "3"
     if (digdec == 4'b1011) dighex = 8'h34; // "4"
     if (digdec == 4'b1010) dighex = 8'h35; // "5"
     if (digdec == 4'b1001) dighex = 8'h36; // "6"
     if (digdec == 4'b1000) dighex = 8'h37; // "7"
     if (digdec == 4'b0111) dighex = 8'h38; // "8"
     if (digdec == 4'b0110) dighex = 8'h39; // "9"
     if (digdec == 4'b0101) dighex = 8'h41; // "A"
     if (digdec == 4'b0100) dighex = 8'h42; // "B"
     if (digdec == 4'b0011) dighex = 8'h43; // "C"
     if (digdec == 4'b0010) dighex = 8'h44; // "D"
     if (digdec == 4'b0001) dighex = 8'h2A; // "*"
     if (digdec == 4'b0000) dighex = 8'h20; // " "
     

       
    
  end










endmodule