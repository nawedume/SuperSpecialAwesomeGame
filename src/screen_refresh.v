module screen_refresh(
	input enable,
	input clk,
	output [7:0] vga_x_out_bus,
	output [7:0] vga_y_out_bus,
	output [23:0] vga_RGB_out_bus,
	output vga_draw_enable_bus,
	output reg done
);

	reg [16:0] counter_val;
	reg [7:0] x_out_buffer, y_out_buffer;
	reg draw_pixel;
	reg [7:0] current_state, next_state;
	reg active;

	reg [7:0] vga_x_out;
	reg [7:0] vga_y_out;
	reg [23:0] vga_RGB_out;
	reg vga_draw_enable;


	assign vga_x_out_bus = active ? vga_x_out : 8'bzzzzzzzz;
	assign vga_y_out_bus = active ? vga_y_out : 8'bzzzzzzzz;
	assign vga_RGB_out_bus = active ? vga_RGB_out : 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
	assign vga_draw_enable_bus = active ? vga_draw_enable : 1'bz;

	localparam  S_INACTIVE 				= 8'd0,
				S_DRAW       			= 8'd8,
				S_DONE					= 8'd9;

	// state table for FSM of tiledrawer
	always @(*)
	begin: state_table 
			case (current_state)
				S_INACTIVE: next_state = enable ? S_DRAW : S_INACTIVE; // check ? load if true : load if false
				S_DRAW: next_state = active ? S_DRAW : S_DONE;
				S_DONE: next_state = S_INACTIVE;
			default: next_state = S_INACTIVE;
		endcase
	end 

	// control path
	always @(*)
	begin: control
		// set load signals to 0 by default
		active = 1'b1;
		draw_pixel = 1'b0;
		done = 1'b0;
		case (current_state)

			// once all values for the pixel are loaded, draw the pixel
			S_DRAW: begin
				draw_pixel = 1'b1;
				x_out_buffer = counter_val[7:0];
				y_out_buffer = counter_val[15:8];
				if(counter_val == 17'b10000000000000000) begin
					active = 1'b0;
				end
			end

			S_DONE: begin
				done = 1'b1;
			end
			default:
			begin
				active = 1'b0;
				done = 1'b0;
			end
		endcase
	end

	always@(posedge clk) 
	begin: datapath


		// check if a pixel is being drawn this cycle
		if(draw_pixel == 1'b1) begin
			// if so, load the buffer values and update the pixel address to the next one
			vga_x_out <= x_out_buffer;
			vga_y_out <= y_out_buffer;
			counter_val <= counter_val  + 17'b00000000000000001;
			vga_RGB_out <= 24'h000000;
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

module counter_16bit(
	input enable,
	input clk,
	output reg [16:0] Q
);

	always @ (posedge clk)
	begin
		if (enable == 1'b1)
			Q <= Q + 1'b1;
	end

endmodule