module test_collision(
    input [17:0] SW,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3
);

    wire [2:0] move_control;
    assign move_control = SW[17:15];

    wire [4:0] x_pos;
    assign x_pos = SW[4:0];
    wire [4:0] y_pos;
    assign y_pos = SW[9:5];

    wire [4:0] new_x_pos;
    wire [4:0] new_y_pos;

    collision_detector cd(
        .current_x_pos(x_pos),
        .current_y_pos(y_pos),
        .move(move_control),
        .map(2'b00),
        .new_x_pos(new_x_pos),
        .new_y_pos(new_y_pos)
    );

    hex_decoder h0(
        .bin(y_pos[3:0]),
        .hex(HEX0)
    );

    hex_decoder h1(
        .bin(x_pos[3:0]),
        .hex(HEX1)
    );

    hex_decoder h2(
        .bin(new_y_pos[3:0]),
        .hex(HEX2)
    );

    hex_decoder h3(
        .bin(new_x_pos[3:0]),
        .hex(HEX3)
    );
    
endmodule


module hex_decoder(bin, hex);
    input [3:0] bin;
	output reg [6:0] hex;
	 
	 always @(*)
	 begin
		case(bin[3:0])
			4'b0000: hex = 7'b1000000;
			4'b0001: hex = 7'b1111001;
			4'b0010: hex = 7'b0100100;
			4'b0011: hex = 7'b0110000;
			4'b0100: hex = 7'b0011001;
			4'b0101: hex = 7'b0010010;
			4'b0110: hex = 7'b0000010;
			4'b0111: hex = 7'b1111000;
			4'b1000: hex = 7'b0000000;
			4'b1001: hex = 7'b0011000;
			4'b1010: hex = 7'b0001000;
			4'b1011: hex = 7'b0000011;
			4'b1100: hex = 7'b1000110;
			4'b1101: hex = 7'b0100001;
			4'b1110: hex = 7'b0000110;
			4'b1111: hex = 7'b0001110;
			
			default: hex = 7'b0111111;
		endcase

	end
endmodule
