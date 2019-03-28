module test_collision(
    input [17:0] SW,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3
);
    wire [19:0] frame_counter;
    RateDivider_60frames framedivider(
        .clk(CLOCK_50),
        .counter(frame_counter)
    );
    wire frame_reset;
    assign frame_reset = frame_counter == 20'b0;


    reg [4:0] player_x_pos = 5'b1;
    reg [4:0] player_y_pos = 5'b1;

    // instantiate ps2 receiver
    ps2_rx ps2_rx_unit (
        .clk(CLOCK_50),
        .reset(frame_reset),
        .rx_en(1'b1),
        .ps2d(PS2_KBDAT),
        .ps2c(PS2_KBCLK),
        .rx_done_tick(scan_done_tick),
        .rx_data(scan_out)
    );

    wire [2:0] move_out; 
    // Get move
    move_control mymove(
        .keyboard_data(scan_out),
        .move(move_out)
    );


    collision_detector cdec(
        .current_x_pos(player_x_pos),
        .current_y_pos(player_y_pos),
        .move(move_out),
        .map(2'b00),
        .new_x_pos(player_new_x),
        .new_y_pos(player_new_y)
    );

    wire [4:0] player_new_x;
    wire [4:0] player_new_y;

    always @ (posedge CLOCK_50)
    begin
        player_x_pos <= player_new_x;
        player_y_pos <= player_new_y;
    end

    wire [7:0] player_x_pixel;
    wire [6:0] player_y_pixel;

    assign player_x_pixel = 8 * player_x_pos;
    assign player_y_pixel = 8 * player_y_pos;


    hex_decoder h0(
        .bin(player_y_pos[3:0]),
        .hex(HEX0)
    );

    hex_decoder h1(
        .bin(player_x_pos[3:0]),
        .hex(HEX1)
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
