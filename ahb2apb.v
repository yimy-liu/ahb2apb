{\rtf1\ansi\ansicpg936\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 module ahb2apb #(\
		parameter AHB_DATA_WIDTH = 32,\
		parameter AHB_ADDR_WIDTH = 32,\
		parameter APB_DATA_WIDTH = 32,\
		parameter APB_ADDR_WIDTH = 32\
		)(\
		//AHB BUS\
		input                                                    ahb_hclk   ,\
		input                                                    ahb_hrstn  ,\
		input                                                    ahb_hsel   ,\
		input  [1:0]                                           ahb_htrans ,\
		input  [AHB_ADDR_WIDTH-1:0]         ahb_haddr  ,\
		input  [AHB_DATA_WIDTH-1:0]          ahb_hwdata ,\
		input                                                    ahb_hwrite ,\
		output                                                  ahb_hready ,\
		output reg [AHB_DATA_WIDTH-1:0]  ahb_hrdata ,\
		//APB BUS\
		input                                                    apb_pclk   ,\
		input                                                    apb_prstn  ,\
		output reg                                           apb_psel   ,\
		output reg                                           apb_pwrite ,\
		output reg                                           apb_penable,\
		output reg [APB_ADDR_WIDTH-1:0] apb_paddr  ,\
		output reg [APB_DATA_WIDTH-1:0]  apb_pwdata  ,\
		input                                                    apb_pready ,\
		input  [APB_DATA_WIDTH-1:0]          apb_prdata \
	);\
\
localparam FIFO_DEPTH=16,\
                  FIFO_AFULL=FIFO_DEPTH-1;\
                  FIFO_AEMPTY=1;\
                  CMD_FIFO_DATA_WIDTH=AHB_DATA_WIDTH+AHB_ADDR_WIDTH+1'b1;\
                  DATA_FIFO_DATA_WIDTH=APB_DATA_WIDTH;\
\
wire ahb_wr_en;\
reg ahb_wr_en_dly;\
wire ahb_rd_en;\
reg ahb_rd_en_dly;\
reg [AHB_ADDR_WIDTH-1:0] ahb_haddr_reg;\
wire ahb_wr_hready;\
wire [CMD_FIFO_DATA_WIDTH-1:0] cmd_fifo_wr_data;\
wire cmd_fifo_wr_en;\
wire cmd_fifo_rd_en;\
reg ahb_cmd_flag;\
wire [CMD_FIFO_DATA_WIDTH-1:0] cmd_fifo_rd_data;\
wire cmd_fifo_full;\
wire cmd_fifo_empty;\
wire cmd_fifo_afull;\
wire cmd_fifo_aempty;\
\
reg ahb_rd_hready;\
wire data_fifo_wr_en;\
wire data_fifo_rd_en;\
wire [APB_DATA_WIDTH-1:0] data_fifo_rd_data;\
wire [APB_DATA_WIDTH-1:0] ahb_hready_dly;\
wire data_fifo_full;\
wire data_fifo_afull;\
wire data_fifo_empty;\
wire data_fifo_aempty;\
\
reg ahb_rd_hready;\
wire data_fifo_wr_en;\
wire data_fifo_rd_en;\
wire [APB_DATA_WIDTH-1:0] data_fifo_rd_data;\
wire [APB_DATA_WIDTH-1:0] ahb_hready_dly;\
wire data_fifo_full;\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 wire data_fifo_afull;\
wire data_fifo_empty;\
wire data_fifo_aempty;\
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0
\cf0 \
assign ahb_wr_en=ahb_hsel&&ahb_hwrite&&ahb_htrans[1]&&ahb_hready;\
assign ahb_rd_en=ahb_hsel&&ahb_hwrite&&ahb_htrans[1]&&ahb_hready;\
\
alwasy @ (posedge ahb_hclk or negedge ahb_hrstn)\
begin\
    if(!ahb_hrstn)begin\
        ahb_wr_en_dly <= 1'b0;\
        ahb_rd_en_dly <= 1'b0;\
        ahb_haddr_reg<= \{AHB_ADDR_WIDTH\{1'b0\}\};\
        end\
 else begin\
        ahb_wr_en_dly <= ahb_wr_en;\
        ahb_rd_en_dly <= ahb_rd_en;\
        ahb_haddr_reg<= ahb_haddr;\
     end\
end\
\
assign ahb_wr_hready = ~cmd_fifo_full;\
assign cmd_fifo_wr_data=\{ahb_wr_en_dly,ahb_haddr_reg,ahb_hwdata\};\
assgin cmd_fifo_wr_en=ahb_wr_en_dly|ahb_rd_en_dly;\
assign cmd_fifo_rd_en=~cmd_fifo_empty&& ~ahb_cmd_flag;\
\
alwasy @ (posedge apb_pclk or negedge apb_prstn)\
begin\
    if(!apb_prstn)\
         ahb_cmd_flag <= 1'b0;\
    else if (apb_penable&&apb_pready)\
        ahb_cmd_flag <= 1'b0;\
    else if (cmd_fifo_rd_en)\
        ahb_cmd_flag <= 1'b1;\
end\
\
alwasy @ (posedge apb_pclk or negedge apb_prstn)\
begin\
    if(!apb_prstn)\
        apb_penable <= 1'b0;\
    else if (apb_penable&&apb_pready)\
        apb_penable <= 1'b0;\
    else if (apb_psel)\
        apb_penable <= 1'b1;\
end\
\
alwasy @ (posedge apb_pclk or negedge apb_prstn)\
begin\
    if(apb_prstn)\
    begin\
        apb_psel<=1'b0;\
        apb_pwrite<=1'b0;\
        apb_paddr<=32'd0;\
        apb_pwdata<=32'd0;\
    end\
    else if(apb_penable&apb_pready)\
    begin\
        apb_psel<=1'b0;\
        apb_pwrite<=1'b0;\
    end\
    else if(cmd_fifo_rd_en)\
    begin\
        apb_psel <=1'b1;\
        apb_pwrite <=cmd_fifo_rd_data[64];\
        apb_paddr<=cmd_fifo_rd_data[63:32];\
        apb_pwdata<=cmd_fifo_rd_data[31:0];\
    end\
end\
\
assign data_fifo_wr_en=apb_penable&&apb_pready;\
assign data_fifo_rd_en=~data_fifo_empty;\
\
always @ (posedge ahb_hclk or negedge ahb_hrstn)\
begin\
    if(!ahb_hrstn)\
        ahb_rd_hready <= 1'b1;\
    else if(data_fifo_rd_en)\
        ahb_rd_hready<=1'b1;\
    else if(ahb_rd_en) \
        ahb_rd_hready<=1'b0;\
end\
\
assign ahb_hrdata_dly = data_fifo_rd_data;\
\
always @(posedge ahb_hclk or negedge ahb_hrstn)\
begin\
    if(!ahb_hrstn)\
         ahb_hrdata <= 32'd0;\
    else\
        ahb_hrdata<=ahb_hrdata_dly;\
end\
\
assign ahb_hready=ahb_wr_hready&&ahb_rd_hready;\
\
async_fifo #(\
.DATA_WIDTH (CMD_FIFO_DATA_WIDTH),\
.FIFO_DEPTH (FIFO_DEPTH),\
.FIFO_AFULL (FIFO_AFULL),\
.FIFO_AEMPTY (FIFO_AEMPTY)\
) async_fifo_send(\
    .wr_clk  (ahb_hclk),\
    .wr_rst_n(ahb_hrstn),\
    .wr_en   (cmd_fifo_wr_en),\
    .wr_data (cmd_fifo_wr_data),\
    .rd_clk  (apb_pclk),\
    .rd_rst_n(apb_prstn),\
    .rd_en   (cmd_fifo_rd_en),\
    .rd_data (cmd_fifo_rd_data),\
    .full    (cmd_fifo_full),\
    .afull   (cmd_fifo_afull), \
    .empty   (cmd_fifo_empty),\
    .aempty  (cmd_fifo_aempty)\
);\
\
async_fifo #(\
.DATA_WIDTH (DATA_FIFO_DATA_WIDTH),\
.FIFO_DEPTH (FIFO_DEPTH),\
.FIFO_AFULL (FIFO_AFULL),\
.FIFO_AEMPTY (FIFO_AEMPTY)\
) async_fifo_recv(\
    .wr_clk  (apb_pclk),\
    .wr_rst_n(apb_prstn),\
    .wr_en   (data_fifo_wr_en),\
    .wr_data (apb_prdata),\
    .rd_clk  (ahb_hclk),\
    .rd_rst_n(ahb_hrstn),\
    .rd_en   (data_fifo_rd_en),\
    .rd_data (data_fifo_rd_data),\
    .full (data_fifo_full),\
    .afull (data_fifo_afull),\
    .empty   (data_fifo_empty), \
    .aempty  (data_fifo_aempty)\
);\
\
endmodule}