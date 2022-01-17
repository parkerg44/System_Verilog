/*SystemVerilog Interfaces: A way to encapsulate signals into a block,
related signals are grouped together to form an interface block so that this 
interface can be reused,allowing for easier connection to the CUT.
*/

//APB Bus protocol signals
interface apb_if(input pclk);
logic [31:0] paddr;
logic [31:0] pwdata;
logic [31:0] prdata;
logic penable;
logic pwrite;
logic psel;
endinterface; 

/*Signals are declared as logic to allow for driving signals in assignment 
statements and procedural block, allow for values 0,1,X,Z
Verilog: Reg used only in procedural bloc
Verilog: wire used only in assignment statement 
Should always been created in the top testbench module where the DUT is 
instantiated.
*/

module dut(myBus busIf);
    always @ (posedge busIf.clk);
    if(busIf.enable)
        busIf.data <= busIf.data+1;
    else
        busIf.data <= 0; 
endmodule

module tb_top;  //top module
    bit clk;
    always #10 clk = ~clk; //set clock 
    mybus busIf(clk)   //create interface object
    dut dut0 (busIf.DUT);   //Instantiate the DUT, pass modport DUT of busIF

    initial begin 
        busIf.enable <= 0;
        #10 busIf.enable <= 1; 
        #40 busIf.enable <= 0; 
        #20 busIf.enable <= 1;
        #100 $finish; 
    end
endmodule


/*
Interface could contain tasks, functions, parameters, variables, functional
coverage, assertions, allows to record transactions via interface, 
*/

/*clocking blocks: singles inside this block will be driven with respect 
to input clock, can be many clocking blocks in an interface, for tb signals.
*/
interface my_int (input bit clk)
    //...

    clocking cb_clk@(posedge clk);
        default input #3ns output #2ns;
        input enable;
        output data; 
    endclocking;
endinterface;

/*  
interface [name] ([port_list]);
    [list_of_signals]
endinterface]*/

//Module cannot be instantiated in an interface, interface can be instantiated in a module 


interface interfaceInput #(parameter WIDTH = 32)(input wire clk, rst);
    logic ready_out;
    wire valid_in;
    wire data_in[WIDTH - 1 : 0];
    wire sop_in;
    wire eop_in;
endinterface;


interface interfaceOutput#(parameter WIDTH = 7)(input wire clk, rst)
    logic valid_out;
    logic data_out[WIDTH - 1 : 0];
    logic sop_out;
    logic eop_out;
endinterface; 


module packerInput (interfaceInput in);
    //design functon 
    //in.ready_out & in.valid_in;
    if(in.ready_out == 1)       //room to accept a new word,
        $display("Ready for new word");
    else if(valid_in == 1)
        $display("word received: begin processing");
    else
        continue; //?
endmodule


module packerOutput(interfaceOutput out);
    //design function 
    //...
endmodule


module unpacker (input clk, rst);
    //create instances of input/output interface
    interfaceInput input_inst (.clk(.clk), .rst(rst));
    interfaceOutput output_inst(.clk(clk), .rst(rst));
    
    //create instances of design modules based on interface
    packetInput input_packer(.in(input_inst));
    packerOutput output_packer(.out(output_inst));

//design functionality?

endmodule


/*
modport defined in an interface to impose restrictions on access
within a module, modport keyword indicated that dircetions are declared. 
Interface modport example: 
*/
interface newInterface; 
    logic ready_out;
    logic data_in;
    logic data_out;
    logic sop; 

    modport cut0(
        input data_in, ready_out
        output data_out, sop  
    );

    modport cut1(
        input data_in, sop
        output data_out, ready_out
    );
endinterface
//Useful for placing resitrictions on a direction of a value

/* Example use for communication system between master and slave
one interface for both slave and master. 
*/
interface ms_if(input clk);
    logic sready;
    logic rstn;
    logic [1:0] addr;
    logic [7:0] data; 

    modport slave (
        input addr, data, rstn, clk
        output sready
    );

    modport master(
        output addr, data
        input clk, sready, rstn 
    );
endinterface

/*
Modports and interfaces do not specify any timing requirements
or synchronization schemes between signals, thus the clocking block is 
useful. Clocking block contains signals synchronous with a chosen clock 
and specifies the timing requirements between clock and signals. 
TB can include many clocking blocks but only one clock per block. 
Ex: 
*/

clocking ck1@(posedge clk);
    default input #5ns output #2ns;
    input data, valid, ready = top.ele.ready;
    output negedge grant;
    inout #1step addr;
endclocking; 

//signals inside block are with respect to test bench not DUT 