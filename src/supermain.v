module supermain(
    input CLOCK_50,
    input PS2_KBCLK,    // Keyboard clock
    input PS2_KBDAT,    // Keyboard input data
    input [3:0] KEY,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [17:0] LEDR,

	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[9:0]	VGA_R,   				//	VGA Red[9:0]
	output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B   				//	VGA Blue[9:0]

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
    initial xpos = 5'b00000;
    reg [4:0] ypos;
    initial ypos = 5'b01000;
    reg [1:0] map;
    initial map = 2'b00;

    wire [4:0] new_xpos;
    wire [4:0] new_ypos;

    collision_detector cd(
        .current_x_pos(xpos),
        .current_y_pos(ypos),
        .move(move_out),
        .map(map),
        .clk(CLOCK_50),
        .new_x_pos(new_xpos),
        .new_y_pos(new_ypos)
    );

    always @ (posedge frame_reset)
    begin
        xpos <= new_xpos;
        ypos <= new_ypos;

        if (map == 2'b00 && xpos == 5'd13 && ypos == 5'd14)
        begin
            map <= map + 1'b1;
            xpos <=  5'b01000;
            ypos <=  5'b00000;
        end
        else if (map == 2'b01 && xpos == 5'd6 && ypos == 5'd8)
        begin
            map <= map + 1'b1;
            timer_enable <= 1'b1;
        end
        else if (map == 2'b10 && timeout)
        begin
            map <= 2'b01;
            timer_enable <= 1'b0;
        end
        else if (map == 2'b10 && xpos == 5'd13 && ypos == 5'd14)
        begin
            map <= 2'b11;
        end
    end

    wire [31:0] timer;
    reg timer_enable;
    initial timer_enable = 1'b0;
    Timer_8seconds t8(
        .clk(CLOCK_50),
        .enable(timer_enable),
        .counter(timer)
    );

    wire timeout;
    assign timeout = timer == 31'b0;

    // To handle scores

    wire [31:0] score_counter;
    reg [7:0] score;
    initial score = 8'b0;
    Timer_1seconds t1(
        .clk(CLOCK_50),
        .counter(score_counter)
    );

    always @ (CLOCK_50)
    begin
        if (score_counter == 32'd0)
        begin
            score = score + 1'b1;
        end
    end
    
   hex_decoder hd4(
        .bin(score[3:0]),
        .hex(HEX4)
    );

    hex_decoder hd5(
        .bin(score[7:4]),
        .hex(HEX5)
    );



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
    

    wire [7:0] x_pixel;
    wire [7:0] y_pixel;

    assign x_pixel = 8 * xpos;
    assign y_pixel = 8 * ypos;



	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [23:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	tri0 writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	

    wire [11:0] rom_address;
	wire [23:0] rom_data;
	wire drawtile;
    wire drawmap;

	rom4096x24 myrom(
		.address(rom_address),
		.clock(CLOCK_50),
		.q(rom_data)
	);

    wire [23:0] colourtest;

    map_drawer gpu(
        .clk(CLOCK_50),
        .tile_address_volitile(12'b000000000000),
        .rom_request_data(rom_data),
        .rom_request_address(rom_address),
        .vga_draw_enable_bus(writeEn),
        .vga_x_out_bus(x),
        .vga_y_out_bus(y),
        .vga_RGB_out_bus(colour),
        .draw(frame_reset),
        .done(drawmap)
        );

	tile_drawer gpu(
		.clk(CLOCK_50),
		.tile_address_volitile(12'b000000000000),
		.x_pos_volitile(x_pixel),
		.y_pos_volitile(y_pixel),
		.rom_request_data(rom_data),
		.rom_request_address(rom_address),
		.vga_draw_enable_bus(writeEn),
		.vga_x_out_bus(x),
		.vga_y_out_bus(y),
		.vga_RGB_out_bus(colour),
		.draw(drawtile),
		.statetestout(LEDR[7:0]),
		.rgbtestout(colourtest)
		);

	screen_refresh blackscreen(
		.clk(CLOCK_50),
		.enable(drawmap),
		.vga_x_out_bus(x),
		.vga_y_out_bus(y),
		.vga_RGB_out_bus(colour),
		.vga_draw_enable_bus(writeEn),
		.done(drawtile)
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

module Timer_8seconds(
	input clk,
    input enable,
	output reg [31:0] counter
);


	always @ (posedge clk)
	begin
		if (counter == 32'b0)
			counter <= 32'd400000000;		// 8 seconds
		else if (enable == 1'b1)
			counter <= counter - 1'b1;
	end


endmodule

module Timer_1seconds(
	input clk,
	output reg [31:0] counter
);


	always @ (posedge clk)
	begin
		if (counter == 32'b0)
			counter <= 32'd100000000;		// 8 seconds
		else
			counter <= counter - 1'b1;
	end


endmodule

