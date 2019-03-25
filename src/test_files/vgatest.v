// Part 2 skeleton

module vgatest
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		LEDR,
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [15:0] LEDR;
	assign LEDR[15] = writeEn;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[2];
	
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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

	wire [11:0] rom_address;
	wire [7:0] rom_data;
	wire drawtile;

	rom4096x8 myrom(
		.address(rom_address),
		.clock(CLOCK_50),
		.q(rom_data)
	);


	tiledrawer gpu(
		.clk(CLOCK_50),
		.tile_address_volitile(12'b000000000000),
		.x_pos_volitile(SW[7:0]),
		.y_pos_volitile(8'b0110000),
		.rom_request_data(rom_data),
		.rom_request_address(rom_address),
		.vga_draw_enable(writeEn),
		.vga_x_out(x),
		.vga_y_out(y),
		.vga_RGB_out(colour),
		.draw(drawtile),
		.testout(LEDR[7:0])
		);

	screen_refresh blackscreen(
		.clk(CLOCK_50),
		.enable(~KEY[1]),
		.vga_x_out_bus(x),
		.vga_y_out_bus(y),
		.vga_RGB_out_bus(colour),
		.vga_draw_enable_bus(writeEn),
		.done(drawtile)
		);
    
    // Instansiate datapath
	// datapath d0(...);

    // Instansiate FSM control
    // control c0(...);
    
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