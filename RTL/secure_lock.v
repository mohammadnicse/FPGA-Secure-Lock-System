module secure_lock (
    input wire clk,             
    input wire rst,             
    input wire [3:0] entry,     
    input wire enter_btn,       
    output reg unlock,          
    output reg alarm            
);

    // Hardcoded Password: 1 -> 2 -> 3 -> 4
    parameter PASS1 = 4'd1;
    parameter PASS2 = 4'd2;
    parameter PASS3 = 4'd3;
    parameter PASS4 = 4'd4;

    // States
    parameter IDLE  = 3'b000;
    parameter S1    = 3'b001; 
    parameter S2    = 3'b010; 
    parameter S3    = 3'b011; 
    parameter OPEN  = 3'b100; 
    parameter ERROR = 3'b101; 

    reg [2:0] current_state, next_state;
    reg [1:0] error_count;    

    // State Transition Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            error_count <= 0;
            alarm <= 0;
        end else begin
            current_state <= next_state;
            
            // Security Logic: Count errors whenever we enter ERROR state
            if (current_state == ERROR) begin
                if (error_count >= 2) 
                    alarm <= 1; // Trigger hardware alarm
                else 
                    error_count <= error_count + 1;
            end
        end
    end

    // Next State Logic
    always @(*) begin
        next_state = current_state; 
        unlock = 0;

        case (current_state)
            IDLE: begin
                if (enter_btn && entry == PASS1) next_state = S1;
                else if (enter_btn) next_state = ERROR;
            end
            
            S1: begin
                if (enter_btn && entry == PASS2) next_state = S2;
                else if (enter_btn) next_state = ERROR;
            end

            S2: begin
                if (enter_btn && entry == PASS3) next_state = S3;
                else if (enter_btn) next_state = ERROR;
            end

            S3: begin
                if (enter_btn && entry == PASS4) next_state = OPEN;
                else if (enter_btn) next_state = ERROR;
            end

            OPEN: begin
                unlock = 1; 
            end

            ERROR: begin
                if (alarm) next_state = ERROR; // Stuck in alarm
                else next_state = IDLE; // Reset to try again
            end
        endcase
    end
endmodule