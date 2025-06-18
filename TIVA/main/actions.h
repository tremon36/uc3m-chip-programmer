#ifndef _ACTIONS_H
#define _ACTIONS_H

// Pin definitions
#define data_out PB_1       // Data out (SDI)
#define clk_out PB_4        // Clock out (SCLK)
#define chipSelectPin PB_6  // Chip Select (CS)

// Function declarations
void runReset(void);
void toggle_hiz(void);
void programChip(byte* data, int byteAmount);
inline void iosetup(void);

#endif // _ACTIONS_H
