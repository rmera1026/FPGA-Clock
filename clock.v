module clock (
  input clk,
  input reset,
  input switch,
  output [6:0] led_a,
  output [6:0] led_b,
  output [6:0] led_c,
  output [6:0] led_d,
  output [6:0] led_e,
  output [6:0] led_f
);

// Variable to store the current second of the day; the number of elapsed
// seconds since our program started.
// Our clock program starts at time 00:00:00 (format is HH:MM:SS)

// There are 60 seconds in a minute, 60 minutes in an hour, 24 hours in an day
// To represent a 24 hr clock in seconds we need to be able to
// represent the number of seconds in a day (60 * 60 * 24 = 86_400)
// We need 17 bits (2 ^ 17 = 131_072) to represent the number of seconds in a day.
// 2 ^ 16 = 65_536 is too small
reg [16:0] elapsed_seconds;

// Represents the current second (the 'SS' part of our clock)
// 01 - 59 => We need 8 bits to represent 60 digits (2 ^ 8 = 64)
reg [7:0] current_second;

// Represents the current minute (the 'MM' part of our clock)
// 01 - 59 => We need 8 bits to represent 60 digits (2 ^ 8 = 64)
reg [7:0] current_minute;

// Represents the current hour (the 'HH' part of our clock)
// 01 - 23 => We need 5 bits to represent 24 digits (2 ^ 5 = 32)
reg [4:0] current_hour;

// Represents the number of CPU cycles
// On a 50MHz processor we perform 50_000_000 cycles per second
// Said differently: Every 50_000_000 cycles = 1 second
// We need 26 bits to count that many cycles
// 2 ^ 26 = 67_108_864
reg [25:0] cycles;

// Represents which lights to turn on/off for each decimal digit in our clock
//
//  __
// |__|
// |__|
//
reg [6:0] seg_data0;
reg [6:0] seg_data1;
reg [6:0] seg_data2;
reg [6:0] seg_data3;
reg [6:0] seg_data4;
reg [6:0] seg_data5;

always @ (posedge clk) begin
  if (reset == 0) begin
    cycles <= 0;
    elapsed_seconds <= 0;//(12 * 60 * 60) + (59 * 60); this would set time to 12:59:00
  end

  if (elapsed_seconds == 86_400)
    elapsed_seconds <= 0;

  if (cycles == (50_000_000)) begin
    // one second has passed
    elapsed_seconds <= elapsed_seconds + 1;
    // start counting the cycles for the next second
    cycles <= 0;
  end
  else
    // count this cycle
    cycles <= cycles + 1;
end

always @ (elapsed_seconds) begin
  // calculate SS as a decimal digit (0-59)
  current_second <= elapsed_seconds % 60;

  // Calculate the FIRST 'S' in SS
  // For example: 36 % 10 = 6
  // set seg_data0 to the proper binary representation of that number
  case (current_second % 10)
    0:
      seg_data0 = 7'b0000001;
    1:
      seg_data0 = 7'b1001111;
    2:
      seg_data0 = 7'b0010010;
    3:
      seg_data0 = 7'b0000110;
    4:
      seg_data0 = 7'b1001100;
    5:
      seg_data0 = 7'b0100100;
    6:
      seg_data0 = 7'b0100000;
    7:
      seg_data0 = 7'b0001111;
    8:
      seg_data0 = 7'b0000000;
    9:
      seg_data0 = 7'b0000100;
  endcase

  // Calculate the SECOND 'S' in SS
  // For example: 36 / 10 = 3
  // set seg_data1 to the proper binary representation of that number
  case (current_second / 10)
    0:
      seg_data1 = 7'b0000001;
    1:
      seg_data1 = 7'b1001111;
    2:
      seg_data1 = 7'b0010010;
    3:
      seg_data1 = 7'b0000110;
    4:
      seg_data1 = 7'b1001100;
    5:
      seg_data1 = 7'b0100100;
  endcase

  current_minute <= (elapsed_seconds / 60) % 60;

  // Calculate the FIRST 'M' in MM
  // For example: 25 % 10 = 5
  // set seg_data2 to the proper binary representation of that number
  case (current_minute % 10)
    0:
      seg_data2 = 7'b0000001;
    1:
      seg_data2 = 7'b1001111;
    2:
      seg_data2 = 7'b0010010;
    3:
      seg_data2 = 7'b0000110;
    4:
      seg_data2 = 7'b1001100;
    5:
      seg_data2 = 7'b0100100;
    6:
      seg_data2 = 7'b0100000;
    7:
      seg_data2 = 7'b0001111;
    8:
      seg_data2 = 7'b0000000;
    9:
      seg_data2 = 7'b0000100;
  endcase

  // Calculate the SECOND 'M' in MM
  // For example: 25 / 10 = 2
  // set seg_data3 to the proper binary representation of that number
  case (current_minute / 10)
    0:
      seg_data3 = 7'b0000001;
    1:
      seg_data3 = 7'b1001111;
    2:
      seg_data3 = 7'b0010010;
    3:
      seg_data3 = 7'b0000110;
    4:
      seg_data3 = 7'b1001100;
    5:
      seg_data3 = 7'b0100100;
  endcase

  current_hour = (elapsed_seconds / 3_600) % 24;
  if (switch) begin // when switch is down, military time is activated
    if (current_hour % 12 == 0)
      current_hour = 12;
    else
      current_hour = current_hour % 12;
  end

  // Calculate the FIRST 'H' in HH
  // For example: 19 % 10 = 9
  // set seg_data4 to the proper binary representation of that number
  case (current_hour % 10)
    0:
      seg_data4 = 7'b0000001;
    1:
      seg_data4 = 7'b1001111;
    2:
      seg_data4 = 7'b0010010;
    3:
      seg_data4 = 7'b0000110;
    4:
      seg_data4 = 7'b1001100;
    5:
      seg_data4 = 7'b0100100;
    6:
      seg_data4 = 7'b0100000;
    7:
      seg_data4 = 7'b0001111;
    8:
      seg_data4 = 7'b0000000;
    9:
      seg_data4 = 7'b0000100;
  endcase

  // Calculate the SECOND 'H' in HH
  // For example: 21 / 10 = 2
  // set seg_data5 to the proper binary representation of that number
  case (current_hour / 10)
    0:
      seg_data5 = 7'b0000001;
    1:
      seg_data5 = 7'b1001111;
    2:
      seg_data5 = 7'b0010010;
  endcase
end

assign led_a = seg_data0;
assign led_b = seg_data1;
assign led_c = seg_data2;
assign led_d = seg_data3;
assign led_e = seg_data4;
assign led_f = seg_data5;

endmodule
