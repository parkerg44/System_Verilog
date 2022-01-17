/*
Class: user defined data type to encapsulate data and tasks/functions. 
Example
*/

class myPacket;
    bit [2:0] header;
    bit encode;
    bit [2:0] mode;
    bit [7:0] data;
    bit stop; 

    function new (bit [2:0] header = 3'h1, bit [2:0] mode = 5);
        this.header = header;
        this.encode = 0;
        this.mode = mode; 
        this.stop = 1; 
    endfunction

    function display();
        $display("Header = 0x%0h, Encode = %0b, Mode = 0x%0h, Stop = %0b", this.header, this.encode, this.mode, this.stop);
    endfunction
endclass

/*
Function new is the constructor, called automatically upon creation. 
this keyword referes to the current class to refer properties/methods, only used with non-static methods
display is a function which does not consume simulation time 
*/

//Accessing signals of class
module tb_top;
    mypacket ptk0, pkt1; 

    initial begin
        ptk0 = new (3'h2, 2'h3);
        ptk0.display();

        ptk1 = new();
        ptk1.display();
    end
endmodule


//Inheritance: 

class networkpkt extends myPacket;
    bit parity;
    bit [1:0] crc; 

    function new ();
        super.new();
        this.parity = 1;
        this.crc = 3;
    endfunction 

    function display();
        super.display();
        $display("Parity = %0b, CRC = 0x%0h", this.parity, this.crc);
    endfunction
endclass

//Abstract/Virtual class: Cannot create an instance of this class if virtual keyword is used
//Useful to force users to keep the abstract class as the base and extend child classes from it. 
virtual class packetBase;
    bit [7:0] data;
    bit enable; 
endclass

class packetChild extends packetBase;
    //define
endclass


/*
An instance of a class is only created when the classes new() function is invoked. 
using:
packetChild = new();
*/


/*
Constructors: Capable of simple object construction and automatic garbage collection. 
new(), if not created a new implicit method will be automatically used:
childpacket newPtk = new; 

For inherited classes, the new function must first call the new method of the parent using 
super.new(), super call only be used in derived classes. 
*/

//If defining two classes based on each other, one must use a forward declaration to tell 
//the complier the class will be found later in the same file.

typedef class DEF; //or use typedef DEF

class ABC;
    DEF def; 
endclass;

class DEF;
    ABC abc;
endclass

/*
Polymorphism: Allows for a variable of the base class to hold sub class types and reference those methods 
directly from a superclass variable. Allows child class method to have a different definition than it's
parents class if parent class method is virtual in nature. 

class handle = container to hold parent or child class objects
*/
// assign child class to base class
module tb;
    Packet bc;
    ExtPacket sc; 

    initial begin
        sc = new (32'hfeed_feed, 32'h1234_5678);

        //assign subclass to base class handle
        bc = sc; 

        bc.display();   //displays feed_feed
        sc.display();   //displays feed_feed 12345678
    end
endmodule 

//assigning a varible of superclass type to cariable of subclass type gives an error 
//sc = bc = error


/*
Virtual Methods: 
bc = sc //base handle points to subclss
bc.display(); //calls display of base class and not of sub class even though it is assigned to subclass
Use virtual functions to all for display of subclass to be called using:
*/
virtual function void display();
    $display("[Base] addr = 0x%0h", addr);
endfunction
//Best practice to declare your base class methods as virtual 


/*Static variables and functions
When variable is declared as static that varible will be the only copy in all 
class instances 
static int X = 0; 
Static can be useful for determining the total number of packets generate at a time 

Static Functions: 
can be called outside of the class with no instantiation. Has no access to non static members,
but can directly access static class properties or call static static methods. (cannot be virtual) 
*/


/*
Copying objects: 
Shallow copy:
*/
Packet pkt, pkt2;

pkt = new();
pkt2 = new pkt;
//Shallow as all variables are copied but nested objects arent entirely copied, only handles
//are assigned to new object but both point to the same object instance
//Note A. if ptk.data = 10 then pkt2 will also equal 10 

//Deep copy: everything is copied, custom code usually required
Packet p1 = new;
Packet p2 = new; 
p2.copy(p1); 

function copy(Packet p)
    this.adder = p.addr;
    this.data = p.data; 
    this.hdr.id = p.hdr.id;
endfunction
//This will prevent Note A from happening. 

/*
Parameterized Classes: 
allows for quick change of parameters in tb or elsewhere 
*/
class test#(int size = 10);
    bit [size - 1 : 0] out;
endclass


/*
extern: allows for method to be defined outside of class body 
*/
class eTest;
extern function void display();
endclass

/*
Abstract class: class which cannot be instatiated directly,but allows subclass to extend and instatinate it. 
*/

virtual class baseClass;
    int data;

    function new();
        data = 32'hdead_beef;
    endfunction
endclass

class ChildClass extends BaseClass;
    function new()
        data = 32'hfeed_feed;
    endfunction; 
endclass

module tb;
    ChildClass child;
    initial begin
        child = new();
        $display("Data=0x%0h", child.data);
    end
endmodule

//Pure Virtual Function: 
//only requires a prototype as implementation is left to the sub-classes. 
virtual class BaseClass;
    int data;
    pure virtual function int getData();
endclass


/*
Randomization: useful for tests as we can generate random ranges and apply them to signals.
Use constraits to create valid configurations for testing. 
Constrained Random Verifiction (CRV)

To enable randomization on a variable you must declare variables as rand or randc, 
randc will only pick the same value twice after all other values have been applied. 
rand is pure randomness

use assert to determine successful randomization. 
*/

class myPacket; 

    rand bit [1:0] mode;
    randc bit [2:0] key;

    Constraint c_model1 {mode < 3;} constraint c_key1 {key > 2; key < 7}

    function display(); //display current random variables
        $display("Mode: 0x%oh Key : 0x%0h", mode, key);
    endfunction
endclass

//test bench 
module tb_top;
    myPacket pkt; 

    initial begin
        pkt = new();

        for(int i = 0; i < 15; i++)
        begin 
            assert(pkt.randomize());
            pkt.display();
        end 
    end
endmodule 

//If contraints contradict each other randomization will fail at run time 
