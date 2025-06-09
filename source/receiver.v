module receiver(
input clk,reset_n,
input rx,s_tick,

output [7:0]rx_dout,
output reg rx_done_tick

    );
   reg [1:0] Q,Q_next;
   localparam s_idle=0,s_start=1,s_data=2,s_stop=3;
   reg[3:0]count,count_next;
   reg[$clog2(8)-1:0]n,n_next;
   reg[7:0] b_reg,b_next;
   
   always@(posedge clk or negedge reset_n)
   begin
        if(~reset_n)
         begin 
            Q<= s_idle;
            count<=0;
            n<=0;
            b_reg<=0;
         end
        else
         begin
             Q<= Q_next;
            count<=count_next;
             n<=n_next;
             b_reg<=b_next;
         end   
   end
    
   always@(*)
   begin
    Q_next= Q;
    n_next=n;
    b_next=b_reg;
   count_next=count;
   rx_done_tick=1'b0;
        case(Q)
            s_idle: 
                if(rx==0)
                    begin
                    count_next=0;
                    Q_next=s_start;
                    end
            s_start:if(s_tick==1)
                              begin
                                    if(count==7) 
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
            
            s_data: if(s_tick==1)
                        begin
                              if(count==15)
                              begin
                                count_next =0;
                                b_next={rx,b_reg[7:1]};
                                                if(n==7) Q_next=s_stop;
                                                else n_next=n+1;
                              end
                              else count_next=count+1;
                        end
            s_stop:if(s_tick==1)
                    begin
                      if(count==15)
                       begin
                         rx_done_tick=1;
                         Q_next=s_idle;
                       end
                       else count_next=count+1;
                                     
                    end
                    
            default: Q_next=s_idle;
        endcase
   
   end
    
   // output
   assign rx_dout=b_reg;
endmodule
