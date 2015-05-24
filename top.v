`timescale 1ns/1ps
module top(
	input wire clk,
	input wire [7:0] address,
	input wire switch,
	input wire wen,
	input wire [7:0] btn,
	output wire [3:0] anode,
	output wire [7:0] segment)
); 
//clock, address(use switches), switch(could use a button), wen could use a button, btn could use 8 btns

	wire wen_out;
	wire [3:0] btn_out;
	reg [31:0] indata;
	wire [31:0] outdata;
	wire [31:0] wdata;
	wire [31:0] rdata;
	wire [31:0] showdata;
	wire btns;
	
	initial begin
		indata=32'h00000000;
	end
	pbdebounce p0(clk,btn[0],btn_out[0]);
	pbdebounce p1(clk,btn[1],btn_out[1]);
	pbdebounce p2(clk,btn[2],btn_out[2]);
	pbdebounce p3(clk,btn[3],btn_out[3]);
	pbdebounce p4(clk,btn[4],btn_out[4]);
	pbdebounce p5(clk,btn[5],btn_out[5]);
	pbdebounce p6(clk,btn[6],btn_out[6]);
	pbdebounce p7(clk,btn[7],btn_out[7]);
	pbdebounce p8(clk,wen,wen_out);
	
	assign btns=btn_out[0]|btn_out[1]|btn_out[2]|btn_out[3]|btn_out[4]|btn_out[5]|btn_out[6]|btn_out[7];
	
	mem m0(clk,wen_out,(address+3)/4,wdate[31:24],rdata[31:24]);
	mem m1(clk,wen_out,(address+2)/4,wdata[23:16],rdata[23:16]);
	mem m2(clk,wen_out,(address+1)/4,wdata[15:8],rdata[15:8]);
	mem m3(clk,wen_out,address/4,wdata[7:0],rdata[7:0]);
	
	assign outdata[31:24]=(address%4==0)?rdata[31:24]:(address%4==1)?rdata[23:16]:(address%4==2)?rdata[15:8]:rdata[7:0];
	assign outdata[23:16]=(address%4==0)?rdata[23:16]:(address%4==1)?rdata[15:8]:(address%4==2)?rdata[7:0]:rdata[31:24];
	assign outdata[15:8]=(address%4==0)?rdata[15:8]:(address%4==1)?rdata[7:0]:(address%4==2)?rdata[31:24]:rdata[23:16];
	assign outdata[7:0]=(address%4==0)?rdata[7:0]:(address%4==1)?rdata[31:24]:(address%4==2)?rdata[23:16]:rdata[15:8];
	
	assign wdata[31:24]=(address%4==0)?indata[31:24]:(address%4==1)?indata[7:0]:(address%4==2)?indata[15:8]:indata[23:16];
	assign wdata[23:16]=(address%4==0)?indata[23:16]:(address%4==1)?indata[31:24]:(address%4==2)?indata[7:0]:indata[15:8];
	assign wdata[15:8]=(address%4==0)?indata[15:8]:(address%4==1)?indata[23:16]:(address%4==2)?indata[31:24]:indata[7:0];
	assign wdata[7:0]=(address%4==0)?indata[7:0]:(address%4==1)?indata[15:8]:(address%4==2)?indata[23:16]:indata[31:24];
	
	always@(posedge btns) begin
		if(btn_out[0]&&!switch) indata[31:28]<=indata[31:28]+1;
		else if(btn_out[1]&&!switch) indata[27:24]<=indata[27:24]+1;
		else if(btn_out[2]&&!switch) indata[23:20]<=indata[23:20]+1;
		else if(btn_out[3]&&!switch) indata[19:16]<=indata[19:16]+1;
		else if(btn_out[4]&&!switch) indata[15:12]<indata[15:12]+1;
		else if(btn_out[5]&&!switch) indata[11:8]<indata[11:8]+1;
		else if(btn_out[6]&&!switch) indata[7:4]<indata[7:4]+1;
		else if(btn_out[7]&&!switch) indata[3:0]<indata[3:0]+1;
	end
	assign showdata=switch?outdata:indata;
	
	display32bits(clk,showdata,anode,segment);
endmodule

module display32bits(

    input clk,
    input wire [31:0] disp_num,

    output reg [3:0] digit_anode,

    output reg [7:0] segment

);
	reg [12:0] cnt=0;
	reg [3:0] num;
	always@(posedge clk)begin
		case(cnt[12:10])
			3'b000:begin
				digit_anode <= 8'b1110;
				num <= disp_num[3:0];
			end
			3'b001:begin
				digit_anode <= 8'b1101;
				num <= disp_num[7:4];
			end
			3'b010:begin
				digit_anode <= 8'b1011;
				num <= disp_num[11:8];
			end
			3'b011:begin
				digit_anode <= 8'b0111;
				num <= disp_num[15:12];
			end
			3'b100:begin
				digit_anode <= 8'b1110;
				num <= disp_num[19:16];
			end
			3'b101:begin
				digit_anode <= 8'b1101;
				num <= disp_num[23:20];
			end
			3'b110:begin
				digit_anode <= 8'b1011;
				num <= disp_num[27:24];
			end
			3'b111:begin
				digit_anode <= 8'b0111;
				num <= disp_num[31:28];
			end
		endcase

		case(num)
			4'b0000:segment<=8'b11000000;
			4'b0001:segment<=8'b11111001;
			4'b0010:segment<=8'b10100100;
			4'b0011:segment<=8'b10110000;
			4'b0100:segment<=8'b10011001;
			4'b0101:segment<=8'b10010010;
			4'b0110:segment<=8'b10000010;
			4'b0111:segment<=8'b11111000;
			4'b1000:segment<=8'b10000000;
			4'b1001:segment<=8'b10010000;
			4'b1010:segment<=8'b10001000;
			4'b1011:segment<=8'b10000011;
			4'b1100:segment<=8'b11000110;
			4'b1101:segment<=8'b10100001;
			4'b1110:segment<=8'b10000110;
			4'b1111:segment<=8'b10001110;
		endcase
	end
	
	always@(posedge clk) begin
		cnt[11:0]<=cnt[11:0]+1;
	end
endmodule


module timer_1ms

	(input wire clk,

	output reg clk_1ms);



	reg [15:0] cnt;

	initial begin

		cnt [15:0] <=0;

		clk_1ms <= 0;

	end

	always@(posedge clk)

		if(cnt>=25000) begin

			cnt<=0;

			clk_1ms <= ~clk_1ms;

		end

		else begin

			cnt<=cnt+1;

		end

endmodule



module pbdebounce

	(input wire clk,

	input wire button,

	output reg pbreg);



	reg [7:0] pbshift;

	wire clk_1ms;

	timer_1ms m0(clk, clk_1ms);

	always@(posedge clk_1ms) begin

		pbshift=pbshift<<1;

		pbshift[0]=button;

		if (pbshift==0)

			pbreg=0;

		if (pbshift==8'hFF)

			pbreg=1;

	end

endmodule

	
	