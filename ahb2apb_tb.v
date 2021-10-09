{\rtf1\ansi\ansicpg936\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 `timescale 1ns/1ps\
module ahb2apb_tb();\
     	        parameter AHB_DATA_WIDTH = 32;\
		parameter AHB_ADDR_WIDTH = 32;\
		parameter APB_DATA_WIDTH = 32;\
		parameter APB_ADDR_WIDTH = 32;\
                 reg                       ahb_hclk;\
                 reg                       ahb_hrstn;\
                 reg                       ahb_hsel;\
                 reg                       ahb_htrans;\
 	        reg  [1:0]                ahb_htrans ;\
		reg  [AHB_ADDR_WIDTH-1:0] ahb_haddr  ;\
		reg  [AHB_DATA_WIDTH-1:0] ahb_hwdata ;\
		reg                       ahb_hwrite ;\
		wire                      ahb_hready ;\
		wire [AHB_DATA_WIDTH-1:0] ahb_hrdata ;\
\
		reg                       apb_pclk  ;\
		reg                       apb_prstn ;\
		wire                      apb_psel  ;\
		wire                      apb_pwrite;\
		wire                      apb_penable;\
		wire [APB_ADDR_WIDTH-1:0] apb_paddr;\
		wire [APB_DATA_WIDTH-1:0] apb_wdata ;\
		reg                       apb_pready;\
		reg  [APB_DATA_WIDTH-1:0] apb_prdata ; \
\
ahb2apb #(\
.AHB_DATA_WIDTH (AHB_DATA_WIDTH),\
.AHB_ADDR_WIDTH (AHB_ADDR_WIDTH),\
.APB_DATA_WIDTH (APB_DATA_WIDTH),\
.APB_ADDR_WIDTH (APB_ADDR_WIDTH)\
) inst_ahb2apb(\
    .ahb_hclk   (ahb_hclk),\
    .ahb_hrstn  (ahb_hrstn),\
    .ahb_hsel   (ahb_hsel),\
    .ahb_htrans (ahb_htrans),\
    .ahb_haddr  (ahb_haddr),\
    .ahb_hwdata (ahb_hwdata),\
    .ahb_hwrite (ahb_hwrite),\
    .ahb_hready (ahb_hready),\
    .ahb_hrdata (ahb_hrdata),\
    .apb_pclk   (apb_pclk), \
    .apb_prstn  (apb_prstn),\
    .apb_psel   (apb_psel),\
    .apb_pwrite (apb_pwrite),\
    .apb_penable(apb_penable),\
    .apb_paddr  (apb_paddr),\
    .apb_wdata  (apb_wdata),\
    .apb_pready (apb_pready),\
    .apb_prdata (apb_prdata)\
);\
\
initial begin\
    #0\
    ahb_hclk =1'b0;\
    ahb_hrstn=1'b0;\
    apb_pclk=1'b0;\
    apb_prstn=1'b0;\
        #10;\
    ahb_hrstn=1'b1;\
    apb_prstn=1'b1;\
    end\
initial begin\
    #0\
    ahb_hsel=1'b0;\
    ahb_htrans=2'd0;\
    ahb_haddr=32'd0;\
    ahb_hwdata=32'd0;\
    ahb_hwrite=1'b0;\
    apb_pready=1'b0;\
    apb_prdata=32'd0;\
\
end\
\
always #3 ahb_hclk=~ahb_hclk;\
always #5 apb_pclk=~apb_pclk;\
\
initial begin\
    #30;\
    ahb_write();\
    #1000;\
    ahb_read();\
    #1000;\
    $finish;\
    end\
\
\
task ahb_write;\
begin\
    @(posedge ahb_hclk) begin\
    ahb_hwrite <= 1'b1;\
    ahb_hsel<=1'b1;\
    ahb_htrans<=2'b10;\
    ahb_haddr<=32'd100;\
    end\
    #1;\
    wait(ahb_hready==1'b1);\
     @(posedge ahb_hclk) begin\
    ahb_htrans <= 2'b11;\
    ahb_hwdata<=32'ha1a1;\
    ahb_haddr<=32'd104;\
    end\
     #1;\
    wait(ahb_hready==1'b1);\
     @(posedge ahb_hclk) begin\
    ahb_htrans <= 2'b11;\
    ahb_hwdata<=32'ha2a2;\
    ahb_haddr<=32'd108;\
    end\
    wait(ahb_hready==1'b1);\
     @(posedge ahb_hclk) begin\
    ahb_htrans <= 2'b11;\
    ahb_hwdata<=32'ha3a3;\
    ahb_haddr<=32'd112;\
    end\
    #1;\
    wait(ahb_hready==1'b1);\
     @(posedge ahb_hclk) begin\
    ahb_htrans <= 2'b11;\
    ahb_hwdata<=32'ha4a4;\
    ahb_haddr<=32'd112;\
    ahb_hsel<=1'b0;\
    end\
    #1;\
    wait(ahb_hready<=1'b1);\
     @(posedge ahb_hclk) begin\
     ahb_hwdata<=32'ha5a5;\
    end\
  \
    begin\
    repeat(4)begin\
     @(posedge apb_pclk)\
     apb_pready <= 1'b1;\
      repeat(10)@(posedge apb_pclk);\
       @(posedge apb_pclk)\
       apb_pready<=1'b1;\
       end\
    end\
    end\
    endtask\
\
task ahb_read;\
fork\
begin\
    @(posedge ahb_hclk) begin\
    ahb_hwrite <= 1'b0;\
    ahb_hsel<=1'b1;\
    ahb_htrans<=2'b10;\
    ahb_haddr<=32'ha1a1;\
    ahb_hwdata<=32\'92d0;\
    end\
#1;\
wait(ahb_hready==1\'92b1);\
    ahb_hsel<=1'b0;\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0     ahb_htrans<=2'b00;\
    ahb_haddr<=32'h0;\
end\
end\
begin\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0     @(posedge apb_penable) begin\
    apb_prdata <= 32'ha6a6;\
   end\
      @(posedge apb_pclk) begin\
    apb_pready <= 1'b1;\
end\
end\
join\
endtask\
\
initial begin\
$fsdbDumpfile("soc.fsdb");\
$fsdbDumpvars;\
end\
\
endmodule}