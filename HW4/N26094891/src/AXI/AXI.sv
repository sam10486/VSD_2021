//================================================
// Auther:      Chang Wan-Yun (Claire)
// Filename:    AXI.sv
// Description: Top module of AXI
// Version:     1.0 
//================================================
`include "../../include/AXI_define.svh"
`include "AW.sv"
`include "W.sv"
`include "B.sv"
`include "AR.sv"
`include "R.sv"
`include "DefaultSlave.sv"

module AXI(

  input ACLK,
  input ARESETn,
  //MASTER INTERFACE
  // M0
  // WRITE
  input [`AXI_ID_BITS-1:0]          AWID_M1,
  input [`AXI_ADDR_BITS-1:0]        AWADDR_M1,
  input [`AXI_LEN_BITS-1:0]         AWLEN_M1,
  input [`AXI_SIZE_BITS-1:0]        AWSIZE_M1,
  input [1:0]                       AWBURST_M1,
  input                             AWVALID_M1,
  output logic                      AWREADY_M1,
  input [`AXI_DATA_BITS-1:0]        WDATA_M1,
  input [`AXI_STRB_BITS-1:0]        WSTRB_M1,
  input                             WLAST_M1,
  input                             WVALID_M1,
  output logic                      WREADY_M1,
  output logic [`AXI_ID_BITS-1:0]   BID_M1,
  output logic [1:0]                BRESP_M1,
  output logic                      BVALID_M1,
  input                             BREADY_M1,
  // READ
  input [`AXI_ID_BITS-1:0]          ARID_M0,
  input [`AXI_ADDR_BITS-1:0]        ARADDR_M0,
  input [`AXI_LEN_BITS-1:0]         ARLEN_M0,
  input [`AXI_SIZE_BITS-1:0]        ARSIZE_M0,
  input [1:0]                       ARBURST_M0,
  input                             ARVALID_M0,
  output logic                      ARREADY_M0,
  output logic [`AXI_ID_BITS-1:0]   RID_M0,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
  output logic [1:0]                RRESP_M0,
  output logic                      RLAST_M0,
  output logic                      RVALID_M0,
  input                             RREADY_M0,
  // M1
  // READ
  input [`AXI_ID_BITS-1:0]          ARID_M1,
  input [`AXI_ADDR_BITS-1:0]        ARADDR_M1,
  input [`AXI_LEN_BITS-1:0]         ARLEN_M1,
  input [`AXI_SIZE_BITS-1:0]        ARSIZE_M1,
  input [1:0]                       ARBURST_M1,
  input                             ARVALID_M1,
  output logic                      ARREADY_M1,
  output logic [`AXI_ID_BITS-1:0]   RID_M1,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
  output logic [1:0]                RRESP_M1,
  output logic                      RLAST_M1,
  output logic                      RVALID_M1,
  input                             RREADY_M1,
  //SLAVE INTERFACE
  // S0
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S0,
  output [`AXI_ADDR_BITS-1:0]       ARADDR_S0,
  output [`AXI_LEN_BITS-1:0]        ARLEN_S0,
  output [`AXI_SIZE_BITS-1:0]       ARSIZE_S0,
  output [1:0]                      ARBURST_S0,
  output logic                      ARVALID_S0,
  input                             ARREADY_S0,
  input [`AXI_IDS_BITS-1:0]         RID_S0,
  input [`AXI_DATA_BITS-1:0]        RDATA_S0,
  input [1:0]                       RRESP_S0,
  input                             RLAST_S0,
  input                             RVALID_S0,
  output logic                      RREADY_S0,
  // S1
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S1,
  output [`AXI_ADDR_BITS-1:0]       AWADDR_S1,
  output [`AXI_LEN_BITS-1:0]        AWLEN_S1,
  output [`AXI_SIZE_BITS-1:0]       AWSIZE_S1,
  output [1:0]                      AWBURST_S1,
  output logic                      AWVALID_S1,
  input                             AWREADY_S1,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
  output logic                      WLAST_S1,
  output logic                      WVALID_S1,
  input                             WREADY_S1,
  input [`AXI_IDS_BITS-1:0]         BID_S1,
  input [1:0]                       BRESP_S1,
  input                             BVALID_S1,
  output logic                      BREADY_S1,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S1,
  output [`AXI_ADDR_BITS-1:0]       ARADDR_S1,
  output [`AXI_LEN_BITS-1:0]        ARLEN_S1,
  output [`AXI_SIZE_BITS-1:0]       ARSIZE_S1,
  output [1:0]                      ARBURST_S1,
  output logic                      ARVALID_S1,
  input                             ARREADY_S1,
  input [`AXI_IDS_BITS-1:0]         RID_S1,
  input [`AXI_DATA_BITS-1:0]        RDATA_S1,
  input [1:0]                       RRESP_S1,
  input                             RLAST_S1,
  input                             RVALID_S1,
  output logic                      RREADY_S1,
  // S2
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S2,
  output [`AXI_ADDR_BITS-1:0]       AWADDR_S2,
  output [`AXI_LEN_BITS-1:0]        AWLEN_S2,
  output [`AXI_SIZE_BITS-1:0]       AWSIZE_S2,
  output [1:0]                      AWBURST_S2,
  output logic                      AWVALID_S2,
  input                             AWREADY_S2,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
  output logic                      WLAST_S2,
  output logic                      WVALID_S2,
  input                             WREADY_S2,
  input [`AXI_IDS_BITS-1:0]         BID_S2,
  input [1:0]                       BRESP_S2,
  input                             BVALID_S2,
  output logic                      BREADY_S2,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S2,
  output [`AXI_ADDR_BITS-1:0]       ARADDR_S2,
  output [`AXI_LEN_BITS-1:0]        ARLEN_S2,
  output [`AXI_SIZE_BITS-1:0]       ARSIZE_S2,
  output logic [1:0]                ARBURST_S2,
  output logic                      ARVALID_S2,
  input                             ARREADY_S2,
  input [`AXI_IDS_BITS-1:0]         RID_S2,
  input [`AXI_DATA_BITS-1:0]        RDATA_S2,
  input [1:0]                       RRESP_S2,
  input                             RLAST_S2,
  input                             RVALID_S2,
  output logic                      RREADY_S2,
  // S3
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S3,
  output [`AXI_ADDR_BITS-1:0]       AWADDR_S3,
  output [`AXI_LEN_BITS-1:0]        AWLEN_S3,
  output [`AXI_SIZE_BITS-1:0]       AWSIZE_S3,
  output [1:0]                      AWBURST_S3,
  output logic                      AWVALID_S3,
  input                             AWREADY_S3,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
  output logic                      WLAST_S3,
  output logic                      WVALID_S3,
  input                             WREADY_S3,
  input [`AXI_IDS_BITS-1:0]         BID_S3,
  input [1:0]                       BRESP_S3,
  input                             BVALID_S3,
  output  logic                     BREADY_S3,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S3,
  output [`AXI_ADDR_BITS-1:0]       ARADDR_S3,
  output [`AXI_LEN_BITS-1:0]        ARLEN_S3,
  output [`AXI_SIZE_BITS-1:0]       ARSIZE_S3,
  output logic [1:0]                ARBURST_S3,
  output logic                      ARVALID_S3,
  input                             ARREADY_S3,
  input [`AXI_IDS_BITS-1:0]         RID_S3,
  input [`AXI_DATA_BITS-1:0]        RDATA_S3,
  input [1:0]                       RRESP_S3,
  input                             RLAST_S3,
  input                             RVALID_S3,
  output logic                      RREADY_S3,
  // S4
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S4,
  output [`AXI_ADDR_BITS-1:0]       AWADDR_S4,
  output [`AXI_LEN_BITS-1:0]        AWLEN_S4,
  output [`AXI_SIZE_BITS-1:0]       AWSIZE_S4,
  output [1:0]                      AWBURST_S4,
  output logic                      AWVALID_S4,
  input                             AWREADY_S4,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
  output logic                      WLAST_S4,
  output logic                      WVALID_S4,
  input                             WREADY_S4,
  input [`AXI_IDS_BITS-1:0]         BID_S4,
  input [1:0]                       BRESP_S4,
  input                             BVALID_S4,
  output logic                      BREADY_S4,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S4,
  output [`AXI_ADDR_BITS-1:0]       ARADDR_S4,
  output [`AXI_LEN_BITS-1:0]        ARLEN_S4,
  output [`AXI_SIZE_BITS-1:0]       ARSIZE_S4,
  output [1:0]                      ARBURST_S4,
  output logic                      ARVALID_S4,
  input                             ARREADY_S4,
  input [`AXI_IDS_BITS-1:0]         RID_S4,
  input [`AXI_DATA_BITS-1:0]        RDATA_S4,
  input [1:0]                       RRESP_S4,
  input                             RLAST_S4,
  input                             RVALID_S4,
  output logic                      RREADY_S4
);

// ROM   0x0000_0000 ~ 0x0000_1FFF
// IM    0x0001_0000 ~ 0x0001_FFFF
// DM    0x0002_0000 ~ 0x0002_FFFF
// Sctrl 0x1000_0000 ~ 0x1000_03FF
// DRAM  0x2000_0000 ~ 0x201F_FFFF
//---------------------------
	//READ ADDRESS_Default
	logic [`AXI_IDS_BITS-1:0] ARID_SD;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_SD;
	logic [`AXI_LEN_BITS-1:0] ARLEN_SD;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_SD;
	logic [1:0] ARBURST_SD;
	logic ARVALID_SD;
	logic ARREADY_SD;
	//READ DATA0
	logic [`AXI_IDS_BITS-1:0] RID_SD;
	logic [`AXI_DATA_BITS-1:0] RDATA_SD;
	logic [1:0] RRESP_SD;
	logic RLAST_SD;
	logic RVALID_SD;
	logic RREADY_SD;
	//WRITE ADDRESS_Default
	logic  [`AXI_IDS_BITS-1:0] AWID_SD;
	logic  [`AXI_ADDR_BITS-1:0] AWADDR_SD;
	logic  [`AXI_LEN_BITS-1:0] AWLEN_SD;
	logic  [`AXI_SIZE_BITS-1:0] AWSIZE_SD;
	logic  [1:0] AWBURST_SD;
	logic  AWVALID_SD;
	logic AWREADY_SD;
	//WRITE DATA0
	logic [`AXI_DATA_BITS-1:0] WDATA_SD;
	logic [`AXI_STRB_BITS-1:0] WSTRB_SD;
	logic WLAST_SD;
	logic WVALID_SD;
	logic WREADY_SD;
	//WRITE RESPONSE0
	logic [`AXI_IDS_BITS-1:0] BID_SD;
	logic [1:0] BRESP_SD;
	logic BVALID_SD;
	logic BREADY_SD;
    //---------- you should put your design here ----------//
	
AR ARchannel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
  .RLAST_S0(RLAST_S0),
	.RLAST_S1(RLAST_S1),
	.RLAST_S2(RLAST_S2),
  .RLAST_S3(RLAST_S3),
  .RLAST_S4(RLAST_S4),
	.RLAST_SD(RLAST_SD),
//READ ADDRESS0
	//---input------
	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	//--output-----
	.ARREADY_M0(ARREADY_M0),
//READ ADDRESS1
	//---input------
	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	//--output-----
	.ARREADY_M1(ARREADY_M1),
//READ ADDRESS0
	//-----output-------
	.ARID_S1(ARID_S1),
	.ARADDR_S1(ARADDR_S1),
	.ARLEN_S1(ARLEN_S1),
	.ARSIZE_S1(ARSIZE_S1),
	.ARBURST_S1(ARBURST_S1),
	.ARVALID_S1(ARVALID_S1),
	//----input-----
	.RVALID_S1(RVALID_S1),
	.RREADY_S1(RREADY_S1),
	.ARREADY_S1(ARREADY_S1),
//READ ADDRESS1
	//-----output-------
	.ARID_S2(ARID_S2),
	.ARADDR_S2(ARADDR_S2),
	.ARLEN_S2(ARLEN_S2),
	.ARSIZE_S2(ARSIZE_S2),
	.ARBURST_S2(ARBURST_S2),
	.ARVALID_S2(ARVALID_S2),
	//----input-----
	.RVALID_S2(RVALID_S2),
	.RREADY_S2(RREADY_S2),
	.ARREADY_S2(ARREADY_S2),
//READ ADDRESS Default	
	//-----output-------
	.ARID_SD(ARID_SD),
	.ARADDR_SD(ARADDR_SD),
	.ARLEN_SD(ARLEN_SD),
	.ARSIZE_SD(ARSIZE_SD),
	.ARBURST_SD(ARBURST_SD),
	.ARVALID_SD(ARVALID_SD),
	//----input-----
	.RVALID_SD(RVALID_SD),
	.RREADY_SD(RREADY_SD),
	.ARREADY_SD(ARREADY_SD),

  //---------ROM-------------
  .ARID_S0(ARID_S0),
  .ARADDR_S0(ARADDR_S0),
  .ARLEN_S0(ARLEN_S0),
  .ARSIZE_S0(ARSIZE_S0),
  .ARBURST_S0(ARBURST_S0),
  .ARVALID_S0(ARVALID_S0),
  .RVALID_S0(RVALID_S0),
  .RREADY_S0(RREADY_S0),
  .ARREADY_S0(ARREADY_S0),
  //--------DRAM-------------
  .ARID_S4(ARID_S4),
  .ARADDR_S4(ARADDR_S4),
  .ARLEN_S4(ARLEN_S4),
  .ARSIZE_S4(ARSIZE_S4),
  .ARBURST_S4(ARBURST_S4),
  .ARVALID_S4(ARVALID_S4),
  .RVALID_S4(RVALID_S4),
  .RREADY_S4(RREADY_S4),
  .ARREADY_S4(ARREADY_S4),
  //--------sensor-------------
  .ARID_S3(ARID_S3),
  .ARADDR_S3(ARADDR_S3),
  .ARLEN_S3(ARLEN_S3),
  .ARSIZE_S3(ARSIZE_S3),
  .ARBURST_S3(ARBURST_S3),
  .ARVALID_S3(ARVALID_S3),
  .RVALID_S3(RVALID_S3),
  .RREADY_S3(RREADY_S3),
  .ARREADY_S3(ARREADY_S3)
);	
	
R Rchannel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.ARVALID_M0(ARVALID_M0),
	.ARVALID_M1(ARVALID_M1),
  .ARLEN_S0(ARLEN_S0),
  .ARLEN_S4(ARLEN_S4),
  .ARLEN_S3(ARLEN_S3),
	.ARLEN_S2(ARLEN_S2),
	.ARLEN_S1(ARLEN_S1),
//READ DATA0
	//output
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	//input 
	.RREADY_M0(RREADY_M0),
//READ DATA1
	//output
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	//input 
	.RREADY_M1(RREADY_M1),
//READ DATA0
	//input
	.RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),
	//output 	
	.RREADY_S1(RREADY_S1),
//READ DATA1
	//input
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),
	//output 	
	.RREADY_S2(RREADY_S2),
//READ Data_Default		
	//input
	.RID_SD(RID_SD),
	.RDATA_SD(RDATA_SD),
	.RRESP_SD(RRESP_SD),
	.RLAST_SD(RLAST_SD),
	.RVALID_SD(RVALID_SD),
	//output 	
	.RREADY_SD(RREADY_SD),

  //--------ROM------
  .RID_S0(RID_S0),
  .RDATA_S0(RDATA_S0),
  .RRESP_S0(RRESP_S0),
  .RLAST_S0(RLAST_S0),
  .RVALID_S0(RVALID_S0),
  .RREADY_S0(RREADY_S0),
  //-----------DRAM---------
  .RID_S4(RID_S4),
  .RDATA_S4(RDATA_S4),
  .RRESP_S4(RRESP_S4),
  .RLAST_S4(RLAST_S4),
  .RVALID_S4(RVALID_S4),
  .RREADY_S4(RREADY_S4),
  //-----------sensor---------
  .RID_S3(RID_S3),
  .RDATA_S3(RDATA_S3),
  .RRESP_S3(RRESP_S3),
  .RLAST_S3(RLAST_S3),
  .RVALID_S3(RVALID_S3),
  .RREADY_S3(RREADY_S3)
);

AW AWchannel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
//WRITE ADDRESS
	//input
	.AWID_M1(AWID_M1),
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1),
	.AWSIZE_M1(AWSIZE_M1),
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	//output
	.AWREADY_M1(AWREADY_M1),

  /*//------ROM-----------
  .AWID_S0(AWID_S0),
  .AWADDR_S0(AWADDR_S0),
  .AWLEN_S0(AWLEN_S0),
  .AWSIZE_S0(AWSIZE_S0),
  .AWBURST_S0(AWBURST_S0),
  .AWVALID_S0(AWVALID_S0),
  .AWREADY_S0(AWREADY_S0),*/

//WRITE ADDRESS1
	//output
	.AWID_S1(AWID_S1),
	.AWADDR_S1(AWADDR_S1),
	.AWLEN_S1(AWLEN_S1),
	.AWSIZE_S1(AWSIZE_S1),
	.AWBURST_S1(AWBURST_S1),
	.AWVALID_S1(AWVALID_S1),
	//input
	.AWREADY_S1(AWREADY_S1),
//WRITE ADDRESS2
	//output
	.AWID_S2(AWID_S2),
	.AWADDR_S2(AWADDR_S2),
	.AWLEN_S2(AWLEN_S2),
	.AWSIZE_S2(AWSIZE_S2),
	.AWBURST_S2(AWBURST_S2),
	.AWVALID_S2(AWVALID_S2),
	//input
	.AWREADY_S2(AWREADY_S2),	

  //--------DRAM--------
  .AWID_S4(AWID_S4),
  .AWADDR_S4(AWADDR_S4),
  .AWLEN_S4(AWLEN_S4),
  .AWSIZE_S4(AWSIZE_S4),
  .AWBURST_S4(AWBURST_S4),
  .AWVALID_S4(AWVALID_S4),
  .AWREADY_S4(AWREADY_S4),  

//WRITE ADDRESS_Defalut
	//output
	.AWID_SD(AWID_SD),
	.AWADDR_SD(AWADDR_SD),
	.AWLEN_SD(AWLEN_SD),
	.AWSIZE_SD(AWSIZE_SD),
	.AWBURST_SD(AWBURST_SD),
	.AWVALID_SD(AWVALID_SD),
	//input
	.AWREADY_SD(AWREADY_SD),
  //WRITE ADDRESS_3
	//output
	.AWID_S3(AWID_S3),
	.AWADDR_S3(AWADDR_S3),
	.AWLEN_S3(AWLEN_S3),
	.AWSIZE_S3(AWSIZE_S3),
	.AWBURST_S3(AWBURST_S3),
	.AWVALID_S3(AWVALID_S3),
	//input
	.AWREADY_S3(AWREADY_S3)
);

W Wchannel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.AWADDR_M1(AWADDR_M1),
	.AWVALID_M1(AWVALID_M1),
//WRITE DATA
	//input
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	//output
	.WREADY_M1(WREADY_M1),

  /*//-------ROM------
  .WDATA_S0(WDATA_S0),
  .WSTRB_S0(WSTRB_S0),
  .WLAST_S0(WLAST_S0),
  .WVALID_S0(WVALID_S0),
  .WREADY_S0(WREADY_S0),*/

//WRITE DATA0
	//output
	.WDATA_S1(WDATA_S1),
	.WSTRB_S1(WSTRB_S1),
	.WLAST_S1(WLAST_S1),
	.WVALID_S1(WVALID_S1),
	//input
	.WREADY_S1(WREADY_S1),	
//WRITE DATA1	
	//output
	.WDATA_S2(WDATA_S2),
	.WSTRB_S2(WSTRB_S2),
	.WLAST_S2(WLAST_S2),
	.WVALID_S2(WVALID_S2),
	//input
	.WREADY_S2(WREADY_S2),	


  //--------DRAM---------
  .WDATA_S4(WDATA_S4),
  .WSTRB_S4(WSTRB_S4),
  .WLAST_S4(WLAST_S4),
  .WVALID_S4(WVALID_S4),
  .WREADY_S4(WREADY_S4),

//WRITE DATA_S
	//output
	.WDATA_SD(WDATA_SD),
	.WSTRB_SD(WSTRB_SD),
	.WLAST_SD(WLAST_SD),
	.WVALID_SD(WVALID_SD),
	//input
	.WREADY_SD(WREADY_SD),
  //WRITE DATA_3
	//output
	.WDATA_S3(WDATA_S3),
	.WSTRB_S3(WSTRB_S3),
	.WLAST_S3(WLAST_S3),
	.WVALID_S3(WVALID_S3),
	//input
	.WREADY_S3(WREADY_S3)	
);

B Bchannel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.AWADDR_M1(AWADDR_M1),
//WRITE RESPONSE
	//output
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	//input 
	.BREADY_M1(BREADY_M1),

  /*//---------ROM------------
  .BID_S0(BID_S0),
  .BRESP_S0(BRESP_S0),
  .BVALID_S0(BVALID_S0),
  .BREADY_S0(BREADY_S0),*/

//WRITE RESPONSE0
	//input
	.BID_S1(BID_S1),
	.BRESP_S1(BRESP_S1),
	.BVALID_S1(BVALID_S1),
	//output
	.BREADY_S1(BREADY_S1),
//WRITE RESPONSE1
	//input
	.BID_S2(BID_S2),
	.BRESP_S2(BRESP_S2),
	.BVALID_S2(BVALID_S2),
	//output
	.BREADY_S2(BREADY_S2),	

  //-------DRAM---------
  .BID_S4(BID_S4),
  .BRESP_S4(BRESP_S4),
  .BVALID_S4(BVALID_S4),
  .BREADY_S4(BREADY_S4),
  //-------sensor---------
  .BID_S3(BID_S3),
  .BRESP_S3(BRESP_S3),
  .BVALID_S3(BVALID_S3),
  .BREADY_S3(BREADY_S3),


//WRITE RESPONSE_Defalut
	//input
	.BID_SD(BID_SD),
	.BRESP_SD(BRESP_SD),
	.BVALID_SD(BVALID_SD),
	//output
	.BREADY_SD(BREADY_SD)
);

DefaultSlave DefaultSlave(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.AWID_SD(AWID_SD),
	.ARLEN_SD(ARLEN_SD),
	.AWVALID_SD(AWVALID_SD),
	.AWREADY_SD(AWREADY_SD),
	.WLAST_SD(WLAST_SD),
	.WVALID_SD(WVALID_SD),
	.WREADY_SD(WREADY_SD),
	.BID_SD(BID_SD),
	.BRESP_SD(BRESP_SD),
	.BVALID_SD(BVALID_SD),
	.BREADY_SD(BREADY_SD),
	.ARID_SD(ARID_SD),
	.ARVALID_SD(ARVALID_SD),
	.ARREADY_SD(ARREADY_SD),
	.RID_SD(RID_SD),
	.RDATA_SD(RDATA_SD),
	.RRESP_SD(RRESP_SD),
	.RLAST_SD(RLAST_SD),
	.RVALID_SD(RVALID_SD),
	.RREADY_SD(RREADY_SD)
	
);



endmodule
