module transmitter(
input clk,reset_n,
input s_tick,
input [7:0] tx_din,
input tx_start,
output tx, 
output reg tx_done_tick
    );
    reg [1:0] Q,Q_next;
   localparam s_idle=0,s_start=1,s_data=2,s_stop=3;
   reg[3:0]count,count_next;
   reg[$clog2(8)-1:0]n,n_next;
   reg[7:0] b_reg,b_next;
   reg tx_reg,tx_next;
   
   always@(posedge clk or negedge reset_n)
   begin
        if(~reset_n)
         begin 
            Q<= s_idle;
            count<=0;
            n<=0;
            b_reg<=0;
            tx_reg<=1'b1;
         end
        else
         begin
             Q<= Q_next;
            count<=count_next;
             n<=n_next;
             b_reg<=b_next;
             tx_reg<=tx_next;
         end   
   end
    
   always@(*)
   begin
    Q_next= Q;
    n_next=n;
    b_next=b_reg;
   count_next=count;
   tx_done_tick=1'b0;
        case(Q)
            s_idle: begin tx_next=1'b1;
                        if(tx_start)
                             begin
                             count_next=0;
                             b_next=tx_din;
                             Q_next=s_start;
                             end
                    end
            s_start:begin tx_next=1'b0;
                            if(s_tick==1)
                              begin
                                    if(count==15) 
                                    begin
                                        count_next=0;
                                        n_next=0;
                                        Q_next=s_data;
                                    
                                    end
                                    else 
                                    begin
                                    count_next=count+1;                                 
                                    end
                               end
                   end
            s_data:begin tx_next=b_reg[0];
                        if(s_tick==1)
                        begin
                              if(count==15)
                              begin
                                count_next=0;
                                b_next={1'b0,b_reg[7:1]};
                                                if(n==7) Q_next=s_stop;
                                                else n_next=n+1;
                              end
                              else count_next=count+1;
                        end
                    end
            s_stop:begin tx_next=1'b1;
                     if(s_tick==1)
                     begin
                        if(count==15)
                        begin
                          tx_done_tick=1;
                          Q_next=s_idle;
                        end
                        else count_next=count+1;
                                     
                     end
                    end
            default: Q_next=s_idle;
        endcase
   
   end
    
   // output
   assign tx= tx_reg;
endmodule

    
    

