module map_drawer(
	input clk,
	input [15:0] tile_address_volitile,
	input draw,
	input [23:0] rom_request_data,
	output [15:0] rom_address_bus,
	output vga_draw_enable_bus,
	output [7:0] vga_x_out_bus,
	output [7:0] vga_y_out_bus,
	output [23:0] vga_RGB_out_bus,
	output reg active,
	output reg done
	);
	// init regs used for internal calcs 
	reg [7:0] x_out_buffer, y_out_buffer;
	reg [7:0] current_x;
	reg [7:0] current_y;
	reg [23:0] RGB_out_buffer;
	reg [15:0] tile_address;
	reg request_data, reset_xy_load_tile_address;
	reg [1:0] draw_pixel;
	reg [7:0] current_state, next_state;
	reg [15:0] rom_request_address_buffer;
	reg [15:0] rom_request_address;

	reg [7:0] vga_x_out;
	reg [7:0] vga_y_out;
	reg [23:0] vga_RGB_out;
	reg vga_draw_enable;

	reg row_end;

	assign vga_x_out_bus = active ? vga_x_out : 8'bzzzzzzzz;
	assign vga_y_out_bus = active ? vga_y_out : 8'bzzzzzzzz;
	assign vga_RGB_out_bus = active ? vga_RGB_out : 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
	assign vga_draw_enable_bus = active ? vga_draw_enable : 1'bz;
	assign rom_address_bus = active ? rom_request_address : 16'bzzzzzzzzzzzzzzzz;

	// params for ease of reading
	localparam  S_INACTIVE 				= 8'd0,
				S_LOAD_INIT_VALUES 		= 8'd1,
				S_REQUEST_RGB			= 8'd2,
				S_SAVE_RGB				= 8'd3,
				S_DRAW					= 8'd4,
				S_CHECK_FINISHED_TILE   = 8'd5,
				S_DONE					= 8'd6;

	// state table for FSM of tiledrawer
	always @(*)
	begin: state_table 
			case (current_state)
				S_INACTIVE: next_state = draw ? S_LOAD_INIT_VALUES : S_INACTIVE; // check ? load if true : load if false
				S_LOAD_INIT_VALUES: next_state = S_REQUEST_RGB;
				S_REQUEST_RGB: next_state = S_SAVE_RGB;
				S_SAVE_RGB: next_state = S_DRAW;
				S_DRAW: next_state = S_CHECK_FINISHED_TILE; 
				S_CHECK_DONE: next_state = active ? S_REQUEST_RGB : S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 


	// control path
	always @(*)
	begin: control
		// set load signals to 0 by default
		request_data = 1'b0;
		draw_pixel = 2'b00;
		reset_xy_load_tile_address = 1'b0;
		rom_request_address_buffer = 16'b0000000000000000;
		row_end = 1'b0;
		active = 1'b1;
		done = 1'b0;
		case (current_state)

			S_INACTIVE: begin
				active = 1'b0;
			end
			// at start of every tile, load the relative x/y and tile address, then reset the internal counters
			S_LOAD_INIT_VALUES: begin
				reset_xy_load_tile_address = 1'b1;
			end

			S_REQUEST_RGB: begin
				rom_request_address_buffer = tile_address;
			end

			S_SAVE_RGB: begin
				rom_request_address_buffer = tile_address;
				request_data = 1'b1;
				RGB_out_buffer = rom_request_data;
			end

			// once all values for the pixel are loaded, draw the pixel
			S_DRAW: begin
				draw_pixel = 1'b1;
				y_out_buffer = current_y;
				x_out_buffer = current_x;
				if(current_x == 8'b10011111) begin
					row_end = 1'b1;
				end
			end
			// and once the pixel is drawn, check to see if the row or tile is finished
			S_CHECK_DONE: begin
				if(current_y == 8'b01111000) begin
					active = 1'b0;
					done = 1'b1;
				end
			end

			default: begin
				end
		endcase
	end


	always@(posedge clk)
	begin: datapath

		if(request_data) begin
			rom_request_address <= rom_request_address_buffer;
		end
		else begin
			rom_request_address <= rom_request_address;
		end


		if(reset_xy_load_tile_address) begin
			current_x <= 8'b00000000;
			current_y <= 8'b00000000;
			tile_address <= tile_address_volitile;
		end
		else begin
			current_x <= current_x;
			current_y <= current_y;
			tile_address <= tile_address;
		end

		if(row_end == 1'b0) begin
			current_y <= current_y;
			current_x <= current_x + 8'b00000001;
		end
		else begin
			current_y <= current_y + 8'b00000001;
			current_x <= 8'b00000000;
		end

		
		if(draw_pixel == 1'b1) begin
			vga_x_out <= x_out_buffer;
			vga_y_out <= y_out_buffer;
			vga_RGB_out <= RGB_out_buffer;
			tile_address <= tile_address + 16'b0000000000000001;
			vga_draw_enable <= 1'b1;
		end
		else begin
			// if not, disable the vga draw output
			vga_draw_enable <= 1'b0;
		end
		
		// move to next state after all logic
		current_state <= next_state;
		
	end
	
endmodule
