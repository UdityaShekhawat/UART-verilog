module UART(
// common input
input clk,reset_n,

//special to each module
input Final_value,// baud rate generator
input rx, // receiver
input rd_uart, // receviver FIFO
input [7:0]w_data , // transmitter FIFO
input wr_uart , // transmittor fifo

//output
output tx , //transmittor
output [7:0]r_data,//recevior data
output rx_empty,// r_FIFO
output tx_full // t_FIFO

);
// baud rate generator connection
wire timer_done;
timer #()timer_gen(
.clk(clk),
.reset_n(reset_n),
.Final_value(Final_value),
.done(timer_done),
.enable(1'b1)
);

//receievr
wire rx_done_tick;
wire [7:0]rx_dout;
receiver rx_uart(
.clk(clk),
.reset_n(reset_n),
.rx(rx),
.s_tick(timer_done),
.rx_dout(rx_dout),
.rx_done_tick(rx_done_tick)
);

//transmitter
wire [7:0] tx_din;
wire tx_done_tick;
wire tx_start;
transmitter tx_uart(
.clk(clk),
.reset_n(reset_n),
.s_tick(timer_done),
.tx(tx),
.tx_din(tx_din),
.tx_done_tick(tx_done_tick),
.tx_start(tx_start)
);


fifo_uart rx_fifo(
  .clk(clk),      // input wire clk
  .srst(~reset_n),    // input wire srst
  .din(rx_dout),      // input wire [7 : 0] din
  .wr_en(rx_done_tick),  // input wire wr_en
  .rd_en(rd_uart),  // input wire rd_en
  .dout(r_data),    // output wire [7 : 0] dout
  .full(),    // output wire full
  .empty(rx_empty)  // output wire empty
);
fifo_uart tx_fifo(
  .clk(clk),      // input wire clk
  .srst(~reset_n),    // input wire srst
  .din(w_data),      // input wire [7 : 0] din
  .wr_en(wr_uart),  // input wire wr_en
  .rd_en(tx_done_tick),  // input wire rd_en
  .dout(tx_din),    // output wire [7 : 0] dout
  .full(tx_full),    // output wire full
  .empty(tx_start)  // output wire empty
);


endmodule
