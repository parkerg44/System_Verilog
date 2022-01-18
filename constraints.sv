/*
SystemVerilog Contstrains review: 
Direct Tests: Designers create a verification plan that details all features of the design to be testing in RTL sims, and how 
each test will target a certain feature. 
Randomized tests are usually the best idea for testing as they target corner cases and lead to faster testing. 

Constraints: 
Used to genereate random variables which satisfy particular constraints. Allow assignment of legal values to 
randomly generated values.

*/

class Pkt: 
    rand bit [7:0] addr; 
    rand bit [7:0] data;

    constraint addr_limit {addr <= 8'hB;}
endclass


/*
SystemVerilog rand variables: 
Random variables declared using rand or randc can be used on arrays, queues or variables. 
Function randomize() is used to randomize all rand type variables in class object. 
*/

class Packet;
    rand bit [2:0] data; 
endclass

module tb;
    initial begin
        Packet pkt = new();
        for(int i = 0; i < 10; i++)begin 
            pkt.randomize(); 
            $display ("itr=%0d data=0x%oh", i , pkt.data);
        end
    end
endmodule

/*
Randc: random -cyclic value, loops through all numbers in it's range before repeating any value. 
randc int count; 
*/

/*
Constraint Blocks: class members like variables used to limit the values of random
variables to certain values. 
Syntax: 
constraint [name] {[expression 1]; [expression N]}
*/

constraint valid_addr {
    addr [1:0] == 2'b0;
    addr <= 32'hfaceface; 
    addr >= 32'hf0000000;
    len >= 64; 
    size >= 128;
}

constraint valid2 {addr <= 32'hf4000000; }//valid constraint

/*
Array Randomization: 
Randomize static array:
*/

class Packet;
    rand bit [3:0] s_arry[7];
endclass

module tb;
    Packet pkt; 

    initial begin 
        pkt = new();
        pkt.randomize();
        $display("Queue = %p", pkt.s_array);
    end
endmodule

//Dynamic arrays, size not pre-determined during array delaration, 
//Randomize Queue

class Packet;
    rand bit [3:0] queue [$];
    
    //constrain queue
    constraint c_array {queue.size == 4};
endclass

module tb;
    Packet pkt;

    initial begin 
        pkt = new();
        pkt.randomize();

        $display("Queue = %p", pkt.queue); 
    end
endmodule

/*
Common constraints: 
*/

class myClass;
    rand bit [7:0] min,typ,max;
    constraint my_range{0 < min; typ < max, typ > min; max < 128}

endclass

//Set variables to a certain value using constranits
constraint c_fixed {fixed == 5};//fixed will always be set to 5

//Inside operator: used to specific an upper and lower limit
constraint range {typ > 32; typ < 256;}
//equal to 
constraint new_range {typ inside{[32,256]};}
//choose from following values
constraint next_range {typ inside {32,64,128}; }
//Inverted inside to choose all values except a certain range 
constraint inv_range { ! (typ inside {[3:6]})}
//Weighted distributions: 
rand bit [2:0] typ;
constaint dist1 {typ dist {0:=20, [1:5]:=50, 6:=40, 7:=10}}

//Implication constraints
constraint c_mode { mode == 2 -> len > 10}
//Same thing, len should be greater than 10 if mode == 2; 
constraint c_mode {if(mode == 2) 
                    len > 10;}

//if -> is true then constraint will be satisfied otherwise it will not. 
//for each is used to constrain arrays: 
//Static contraints: shared acrross all class instances 
//Memory Partitioning example with constraints: 
class MemoryBlock;
    bit [31:0] m_ram_start;
    bit [31:0] m_ram_end;

    rand bit [31:0] m_start_addr;
    rand bit [31:0] m_end_addr;
    rand int m_block_size;

    constraint c_addr { m_start_addr >- m_ram_start; m_start_addr < m_ram_end; m_start_addr %4 == 0; 
        m_end_addr == m_start_addr + m_block_size -1};

    constraint c_blk_size {m_block_size inside {64,128,512}; };

    function void display();
        $display("RAM startADDr = 0x%0h", m_ram_start);
        //... print other vars
    endfunction 
endclass

module tb;
    initial begin 
        MemoryBlock mb = new();
        mb.m_ram_start = 32'h0;
        mb.m_ram_end = 32'h7FF; //2KB RAM 
        mb.randomize();
        mb.display();
    end
endmodule//prints all build RAM memory

//Bus protocol constraints: 
//Randomization methods: 
//soft constraints specify default values for random varaibles
constraint c_data {soft data >= 4; data <= 12};
//if 
abc.randomize() with {data == 2}; //this will run fine and overwrite the soft constraint

//disable constraints 
constraint.mode(0) //off
constraint.mode(1) //on 
//turn on or off randomization
rand_mode(0) //off
rand_mode(1) //on
