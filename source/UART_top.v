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
module fifo_uart1(
    input clk,
    input srst,
    input [7:0] din,
    input wr_en,
    input rd_en,
    output reg [7:0] dout,
    output full,
    output empty
);
    parameter DEPTH = 16;
    parameter ADDR_WIDTH = 4;
    
    reg [7:0] memory [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr, rd_ptr;
    
    assign full = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && 
                  (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
    assign empty = (wr_ptr == rd_ptr);
    
    always @(posedge clk) begin
        if (srst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            dout <= 0;
        end else begin
            if (wr_en && !full) begin
                memory[wr_ptr[ADDR_WIDTH-1:0]] <= din;
                wr_ptr <= wr_ptr + 1;
            end
            if (rd_en && !empty) begin
                dout <= memory[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end
endmodule
