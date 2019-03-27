module screen_drawer(
	input clk,
	input draw,
	input [4:0] player_x_pos_volitile,
	input [4:0] player_y_pos_volitile,
	input [11:0] map_address_volitile,
	input [7:0] rom_request_data,
	output reg [11:0] rom_request_address,
	output [7:0] vga_x_out_bus,
	output [7:0] vga_y_out_bus,
	output [23:0] vga_RGB_out_bus,
	output vga_draw_enable_bus,
	output reg active;
	);
	

	// init regs used for internal calcs 
	reg [4:0] player_x_pos, player_y_pos;

	// params for ease of reading
	localparam  S_INACTIVE 				= 8'd0,
				S_LOAD_INIT_VALUES 		= 8'd1,
				S_LOAD_NEXT_TILE 		= 8'd2,
				S_DRAW_TILE				= 8'd3,
				S_DONE 					= 8'd4;

	// state table for FSM of tiledrawer
	always @(*)
	begin: state_table 
			case (current_state)
				S_INACTIVE: next_state = draw ? S_LOAD_INIT_VALUES : S_INACTIVE; // check ? load if true : load if false
				S_LOAD_INIT_VALUES: next_state = S_LOAD_NEXT_TILE;
				S_LOAD_NEXT_TILE: next_state = S_DRAW_TILE;
				S_DRAW_TILE: next_state = active ? S_DRAW_TILE : S_DONE;
				S_DONE: next_state = active ? S_REQUEST_R : S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 


	tiledrawer gpu(
		.clk(~KEY[2]),
		.tile_address_volitile(12'b000000000000),
		.x_pos_volitile(SW[7:0]),
		.y_pos_volitile(8'b0110000),
		.rom_request_data(rom_data),
		.rom_request_address(rom_address),
		.vga_draw_enable_bus(writeEn),
		.vga_x_out_bus(x),
		.vga_y_out_bus(y),
		.vga_RGB_out_bus(colour),
		.draw(drawtile),
		.testout(LEDR[7:0])
		);


endmodule