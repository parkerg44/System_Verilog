/*
Assertions: used to validate the behavior of a system defined as properties and can be used in function coverage. 
Properties of a design: 
if a design property being checked doesn't behavior in the specified way the assertion will fail. 
*/


//normal verilog based assertation 
always@ (posedge clk) begin
    if(!(a && b))
        $display("Assertion Failed");
end

//Systemverilog assertions 
assert property@((posedge clk) a && b); 

/*
Types of assertion statements: 
assert: specifiy given design property is true in the simulation. 
assume: specifiy given design property is an assumption and used by tools to generate input stimulus
cover: to evaluate the property for function coverage
restrict: specify the property as a constraint on formal verification computations and is ignored by simulators
*/

//Property represented as a sequence/ number of sequences can create more complex sequences/properties 
property <name>
    <test expression> or
    <sequence expressions>
endproperty

assert property(name);
//Immediate assertion: executed like statement in procedural block, follow simulation event semantics, used
//to verify an immediate property during simulation. 

always @ (SomeEvent) begin
        $assert(!fifo_empty);   //assert fifo is not empty at only this point 
end

//Concurrent Assertions
property p_ack;
    @(posedge clk) gnt ##[1:4] ack; 
endproperty

assert property(p_ack); 

/*How to create assertions:
1. create boolean expressions
2. create sequence expressions
3. create property
4. assert property
Test Bench Example: 
*/

module tb;
    bit a,c,b,d; 
    bit clk; 

    always@ clk = ~clk;
    initial begin
        for(int i = 0; i < 20; i++)begin
            {a,b,c,d} = $random; 
            $display("%0t a=%0d b=%0d c=%0d d=%0d", $time, a,b,c,d);
            @(posedge clk);
        end
        #10 $finish;
    end 

    sequence s_ab;
        a ##1 b; 
    endsequence

    sequence s_cd;
        c ##2 d; 
    endsequence

    property p_expr;
        @(posedge clk) s_ab ##1 s_cd;
    endproperty

    assert property(p_expr);
endmodule


/*More on immediate assertions: 
executed based on simulation event semantics and are required to be specified in procedual block. 
Will pass if expression holds true at the time the statement is executed.
*/

assert(<expression>)    //simple assert

assert(<expression>)begin 
    if (something true)
        //do this
    else
        //false condition do this 
end

/*
More on concurrent Assertions 
describe behavior which spans over simulation time and evaluated only at clk edge. 
$rose and $fell are used to detect pos/neg edges on a given signal
$stable is used to determine that the signal doesn't have a postive or negative clock edge
*/

/*
Time delay specified by ##
sequence saying b should be high 2 clock cycles after a is high
*/
sequence s_ab
    @(posedge clk) a ## b; 
endsequence