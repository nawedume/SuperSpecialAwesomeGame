module test_collision(
    input CLOCK_50,
    input PS2_KBCLK,    // Keyboard clock
    input PS2_KBDAT,    // Keyboard input data
    input [3:0] KEY,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [4:0] LEDR
);

    wire scan_done_tick;
    wire [7:0] scan_out;
    wire [2:0] move_out;
	
    // Rate divider that measures 1/60th of a second,
    // controls frame counter

    wire [19:0] frame_counter;
    wire frame_reset;

    RateDivider_60frames framedivider(
        .clk(CLOCK_50),
        .counter(frame_counter)
    );

    assign frame_reset = frame_counter == 20'b0;

    reg [4:0] xpos;
    initial xpos = 5'b00001;
    reg [4:0] ypos;
    initial ypos = 5'b00001;

    wire [4:0] new_xpos;
    wire [4:0] new_ypos;

    collision_detector cd(
        .current_x_pos(xpos),
        .current_y_pos(ypos),
        .move(move_out),
        .map(2'b00),
        .clk(CLOCK_50),
        .new_x_pos(new_xpos),
        .new_y_pos(new_ypos)
    );

    always @ (posedge frame_reset)
    begin
        xpos <= new_xpos;
        ypos <= new_ypos;
    end

    
    hex_decoder hd0(
        .bin(ypos[3:0]),
        .hex(HEX0)
    );

    hex_decoder hd1(
        .bin(xpos[3:0]),
        .hex(HEX1)
    );

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

    // Get move
    move_control mymove(
        .keyboard_data(scan_out),
        .move(move_out)
    );

    reg [4:0] l;


    always @ (posedge CLOCK_50)
        begin
        if (scan_done_tick == 1'b0)
        begin
            case (move_out)
                3'b001: l <= 5'b00001;
                3'b010: l <= 5'b00010;  
                3'b011: l <= 5'b00100;  
                3'b100: l <= 5'b01000;  
                3'b101: l <= 5'b10000; 
            default: l <= 5'b00000;
            endcase
        end
        else
        begin
            l <= 5'b00000;
        end
    end
    
    assign LEDR = l;

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