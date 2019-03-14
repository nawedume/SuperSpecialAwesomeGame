module tiledrawer(
	input clk,
	input [7:0] tile_address_volitile,
	input [7:0] x_pos_volitile,
	input [7:0] y_pos_volitile,
	input draw,
	input [7:0] rom_request_data,
	output reg [11:0] rom_request_address,
	output reg vga_draw_enable,
	output reg [7:0] vga_x_out,
	output reg [7:0] vga_y_out,
	output reg active
	);

	reg [7:0] x_in, y_in;
	reg [7:0] R_buffer, G_buffer, B_buffer;
	reg finished_pixel;
	reg [7:0] tile_address:

	localparam  S_INACTIVE 				= 8'd0,
				S_LOAD_STATIC_VALUES 	= 8'd1,
				S_REQUEST_R				= 8'd2,
				S_REQUEST_G				= 8'd3,
				S_REQUEST_B 			= 8'd4,
				S_SAVE_VALUE			= 8'd5;
				S_DRAW       			= 8'd6;
				S_CHECK_FINISHED_TILE   = 8'd7;

	begin: state_table 
			case (current_state)
			 	S_INCATIVE: next_state = draw ? S_LOAD_VALUES : S_INACTIVE; // check ? load if true : load if false
			 	S_LOAD_STATIC_VALUES: next_state = S_REQUEST_R;
			 	S_REQUEST_R: next_state = S_REQUEST_G;
			 	S_REQUEST_G: next_state = S_REQUEST_B;
			 	S_REQUEST_B: next_state = S_SAVE_VALUE;
			 	S_SAVE_VALUE: next_state = S_DRAW;
			 	S_DRAW: next_state = finished_pixel ? S_DRAW : S_CHECK_FINISHED_TILE; 
			 	S_CHECK_FINISHED_TILE: active ? S_REQUEST_R : S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 
	
	always@(posedge clk)
    begin: state_FFs
    	current_state <= next_state;

    end
	
    always @(*)
	begin: enable_signals
		case (current_state)

			S_LOAD_STATIC_VALUES: begin
				x_in = x_pos_volitile;
				y_in = y_pos_volitile;
				tile_address = tile_address_volitile;
			end

			S_REQUEST_R: begin
				rom_request_address = tile_address;
			end

			S_REQUEST_G: begin
				rom_request_address = tile_address + 2'b01;
				R_buffer = rom_request_data; 
			end

			S_REQUEST_B: begin
				rom_accces_address = tile_address + 2'b10;
				G_buffer = rom_request_data; 
			end

			default: begin
				x_buffer = 7'b0;
				y_buffer = 7'b0;
				x_progress = 2'b0;
				y_progress = 2'b0;
				active_buffer = 1'b0;
				end
		endcase
	end // enable_signals
	
endmodule