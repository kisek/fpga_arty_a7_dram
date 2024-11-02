# fpga_arty_a7_dram

This is a DDR3 SDRAM (**MT41K128M16JT-125**) sample project for Arty A7-35T FPGA board.

The recommented version is **Vivado 2024.1**. 
When creating a Vivado project, please select **xc7a35ticsg324-1L** as an FPGA. 
Please add **main.v** and **main.xdc** to your Vivado project. 


![arty_a7](https://github.com/user-attachments/assets/4ed408a0-54ab-46a5-bcc2-693168814cb5)

This code will explain what this Verilog code tries to do.
First, write 1 to all 32-bit words in the DRAM, then read all the words and display the sum of them in VIO.
The final sum will be **33,554,432** for FPGA run.

```c
#include <stdio.h>
#define N  (1 << 25)
int dram[N];
int main() {
    for (int addr = 0; addr < N; addr++) dram[addr] = 1; /// WRITE

    int sum = 0;
    for (int addr = 0; addr < N; addr++) sum += dram[addr]; /// READ

    printf("%x %d\n", sum, sum);
    return 0;
}
```

The following code is for simulation using a small data set. The final sum will be **131,071**.

```c
#include <stdio.h>
#define N  (1 << 17)
int dram[N];
int main() {
    for (int addr = 0; addr < N; addr++) dram[addr] = 1; /// WRITE

    int sum = 0;
    for (int addr = 0; addr < N; addr++) sum += dram[addr]; /// READ

    printf("%x %d\n", sum, sum);
    return 0;
}
```


## Clocking Wizard

- Clocking Options, Input Clock Information : **100.000** MHz Input Frequency
- Output Clocks, clk_out1 : **160** MHz Output Freq is Requested
- Output Clocks, clk_out2 : **200** MHz Output Freq is Requested
- Output Clocks: disable **reset**, power_down, input_clk_stopped, **locked**, clksbstopped

## VIO (Virtual Input/Output)

- Component Name, General Options, Input Probe Count: **2**
- Component Name, General Options, Output Probe Count: **0**
- Component Name, PROBE_IN_Ports, PROBE_IN1 : **28**
- Component Name, PROBE_IN_Ports, PROBE_IN2 : **32**


## MIG (Memory Interface Generator)

- (1) MIG Output Options: check **Create Design**
- (1) MIG Output Options, Component Name: **mig_7series_0**
- (1) MIG Output Options, Multi-Controller: **1**
- (1) MIG Output Options, AXI4 Interface: **uncheck**
- (2) Pin Compatible FPGAs: **uncheck** 
- (3) Memory Selection: check **DDR3 SDRAM**
- (4) Options for Controller 0, Clock Period: **3125 (320.0 MHz)**  _Note that one-fourth of this 320MHz clock is used as the operating frequency of w_ui_clk, which is 80MHz._
- (4) Options for Controller 0, Memory Type: **MT41K128M16XX-15E**
- (4) Options for Controller 0, Memory Type: Create Custom Part
- (4) Options for Controller 0, Memory Voltage: **1.35V**
- (4) Options for Controller 0, Data Width: **16**
- (4) Options for Controller 0, Data Mask: **check**
- (4) Options for Controller 0, Number of Bank Machines: **4**
- (4) Options for Controller 0, Ordering: **Strict**
- (5) Memory Options C0, Input Clock Period: **6250 ps (160 MHz)**
- (5) Memory Options C0, Read Burst Type and Length: **Sequential**
- (5) Memory Options C0, Output Driver Impedance Control: **RZQ/6**
- (5) Memory Options C0, RTT: **RZQ/6**
- (5) Memory Options C0, Controller Chip Select Pin: **Enable**
- (5) Memory Options C0, Memory Address Mapping Selection: check **below (BANK, ROW, COKUMN)**
- (6) FPGA Options, System Clock: **No Buffer**
- (6) FPGA Options, Reference Clock: **No Buffer**
- (6) FPGA Options, System Reset Polarity: **ACTIVE HIGH**
- (6) FPGA Options, Debug Signals for Memory Controller: **OFF**
- (6) FPGA Options, Internal Vref: **Check**
- (6) FPGA Options, IO Power Reduction: **ON**
- (6) FPGA Options, XADC Instantiation: **Enabled**
- (7) Extended FPGA Options, Internal Termination Impedance: **50 Ohms**
- (8) IO Planning Options: check **Fixed Pin Out: Pre-existing pin out is known and fixed**
- (9) Pin Selection: click **Read XDC/UCF**, and select a file named **arty_a7_mig.ucf**, and click **Validate**
- (10) System Signals Selection, sys_rst: **No connect**
- (10) System Signals Selection, init_calib_complete: **No connect**
- (10) System Signals Selection, tg_compare_error: **No connect**

