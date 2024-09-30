# fifo-verification-systemverilog
**In this project, I developed a SystemVerilog testbench to verify the behavior of a given FIFO
module design (`fifo.sv`).**
The testbench generates randomized input transactions, drives them into the FIFO, and monitors the output. A verification monitor captures the transactions, while a reference model checks the output to ensure the FIFO is functioning correctly according to its specifications.

## FIFO Specification

![FIFO Module Diagram](./assets/fifo_diagram.png)

* The FIFO has the following interface ports:
  - clk
  - rstn
  - rd_req
  - wr_req
  - wr_data[WIDTH – 1:0] 
  - rd_data[WIDTH – 1:0]
  - full_o
  - empty_o

  
* The FIFO has 2 parameters: WIDTH, describing the number of bits in each vector element, and 
DEPTH, describing how many element slots are in the FIFO. The defaults are WIDTH = 32, DEPTH 
= 4.

* The FIFO is a synchronous module reacting to the clk and rstn signals. All activity is synchronized to 
the positive edge of the clock and the FIFO will reset when rstn goes low.

***Assumptions***
* There are never parallel read and write requests.
* There will always be a gap of at least 1 idle clock cycle between a read and the following 
request.

## Testbanch Components

### Transaction Definition
The file `item.sv` contains the item class, which represents a FIFO transaction. Each transaction includes the following fields:
* wr_req
* rd_req
* wr_data
* rd_data
* full
* empty
* Randomizable delay

In addition, constraints are applied to ensure that all transactions are valid and align with the design assumptions.

### Interface
The testbench and the design module communicate through a well-defined interface. This interface serves as the bridge between the two components, allowing for the exchange of signals and data. It facilitates various operations, such as sending write requests, receiving read requests, and monitoring the FIFO's status indicators (e.g., full and empty flags).

The file `interface.sv` contains the interface definition, and its instantiation can be found in `fifo_tb.sv`. 

### Generator 
The Generator is implemented as a task insdie `fifo_tb.sv` and responsible for creating and randomizing transactions of the item class.
Once the transactions are created and randomized, the Generator sends them to the Driver.

### Driver
The driver task receives transactions from the Generator and drive the module's ports through the defined interface.
After one clock cycle, the Driver resets the inputs to ensure a clean state for the next transaction. 

### Monitor
the Monitor Task continuously checks the output signals, including the data read from the FIFO and the status indicators (e.g., full and empty flags). 
As it collects the output signals, the Monitor also retrieves the relevant input signals from the interface. It then packages these inputs and outputs as a transaction, creating a representation of the FIFO's state during each cycle. This transaction is subsequently sent to a reference FIFO Model for verification against expected results.

### Model
The Model Task implements the expected functionality of the FIFO RTL by reflacting the expected outputs based on the transactions it receives.
Upon receiving transactions from the Monitor, the Model Task processes the input data and simulates the FIFO's behavior according to its specifications. 
By comparing the actual outputs from the FIFO module with those produced by the Model Task, mismatches can be identified, allowing for thorough verification of the design. 




 




 


