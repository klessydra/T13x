// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the âLicenseâ); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an âAS ISâ BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module sp_ram
  #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_WORDS  = 256
  )(
    // Clock and Reset
    input  logic                    clk,

    input  logic                    en_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    input  logic                    we_i,
    input  logic [DATA_WIDTH/8-1:0] be_i
  );

  localparam words = NUM_WORDS/(DATA_WIDTH/8);
	
	
  logic [DATA_WIDTH/8-1:0][7:0] mem[words];
  logic [DATA_WIDTH/8-1:0][7:0] wdata;
  logic [ADDR_WIDTH-1-$clog2(DATA_WIDTH/8):0] addr;

  
  integer i;
  
  /*-------------------------------------------*/
	
	localparam size_subber = 2+ADDR_WIDTH-1-$clog2(DATA_WIDTH/8)+1; // corretto, deve essere dinamicamente esteso tanto quanto
	//la width del segnale "addr_i", che di per se è già un bit in meno rispetto allo spazio di indirizzamento necessario
	//per puntare all'ultima locazione della memoria globale
	logic [(size_subber-1):0] subber; // corretto
	assign subber = 1048576;	//corretto, valore da mettere in decimale

	logic [(size_subber-1):0] intercept;
	assign intercept = addr_i - subber;

	logic [ADDR_WIDTH-1-$clog2(DATA_WIDTH/8):0] addr_mask; //stessa dimensione di addr, che non si prende i due ultimi bit
	assign addr_mask = addr_i[ADDR_WIDTH-1:$clog2(DATA_WIDTH/8)]-intercept[(size_subber-1):0];//lo posso pure cancellare
	
	/*	
	logic [ADDR_WIDTH-1-$clog2(DATA_WIDTH/8):0] test_copy; //stessa dimensione di addr, che non si prende i due ultimi bit
	*/
	/*-------------------------------------------*/
	
  assign addr = intercept[ADDR_WIDTH-1:$clog2(DATA_WIDTH/8)]; // per scartare i 2 lsb


  always @(posedge clk)
  begin
    if (en_i && we_i)
    begin
      for (i = 0; i < DATA_WIDTH/8; i++) begin
        if (be_i[i])
          mem[addr][i] <= wdata[i];
      end
    end

    rdata_o <= mem[addr];
  end

  genvar w;
  generate for(w = 0; w < DATA_WIDTH/8; w++)
    begin
      assign wdata[w] = wdata_i[(w+1)*8-1:w*8];
    end
  endgenerate

endmodule
