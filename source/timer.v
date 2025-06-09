
module timer(
input clk,
input reset_n,
input enable,
input [7:0]Final_value,
output done

    );
    
    
reg[7:0] Q,Q_next;
//sequ. logic
always@(posedge clk or negedge reset_n)
begin
   if(~reset_n) Q<=8'b0;
   else if(enable)Q<=Q_next;
   else Q<=Q;
end

//next state logic
always@(*)
begin
    Q_next= done?1'b0:Q+1;
end
// output logic
assign done = Q==Final_value;
endmodule
