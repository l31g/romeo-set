/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <alt_types.h>
#include <stdlib.h>
#include <system.h>
#include <io.h>

#define VGA_WIDTH   640LL
#define VGA_HEIGHT  480LL

#define RADIX_SHIFT 30

#define TOP_18_MASK 0xFFFFC0000LL
#define BOT_18_MASK 0x00003FFFFLL

int main()
{
    
    //configure our window
    alt_64 b_max = 3LL;
    b_max = b_max << (RADIX_SHIFT-1);
    alt_64 a_max = 2LL;
    a_max = a_max << (RADIX_SHIFT-0);
    alt_64 b_min = -3LL;
    b_min = b_min << (RADIX_SHIFT-1);
    alt_64 a_min = -2LL;
    a_min = a_min << (RADIX_SHIFT-0);
    
    alt_64 c_rea = 5LL;
    c_rea = c_rea << (RADIX_SHIFT-1);
    alt_64 c_img = 0LL;
    c_img = c_img << (RADIX_SHIFT-2);
    
    //a_min = 0xF80000000LL;
    //b_min = 0xFA0000000LL;
    c_rea = 0xFCA8F5C29LL;
    c_img = 0xFFF25460BLL;

    //set the constant

    
    //set our iteration params
    
    //to compute a and b, we will iterate through each pixel of the screen
    //adding win_dim/screen_dim to a sum that starts at win_dim_min
    
    //we will also have "leap" iterations, which are iterations in which
    //the sum must be incremented by 1 to keep it on track towards screen_dim
    
    
    /*
     * 
     *  signal a_min        : std_logic_vector(35 downto 0)     := X"F80000000";
    signal b_min        : std_logic_vector(35 downto 0)     := X"FA0000000";
    signal a_diff       : std_logic_vector(35 downto 0)     := X"000666666";
    signal b_diff       : std_logic_vector(35 downto 0)     := X"000666666";
    signal cr       : std_logic_vector(35 downto 0)         := X"FCA8F5C29";
    signal ci       : std_logic_vector(35 downto 0)         := X"FF125460B";
     * 
     */
    
    alt_64 a_delt = (a_max - a_min);
    alt_64 b_delt = (b_max - b_min);
    
    printf("Adelt   = %lld\n",a_delt);
    printf("Bdelt   = %lld\n",b_delt);

    //amount to add each iteration    
    alt_64 d_a = (a_delt/VGA_WIDTH);
    alt_64 d_b = (b_delt/VGA_HEIGHT);
    //d_a = 0x000666666LL;
    //d_b = 0x000666666LL;    
    
    //leap total is the number of times we'll need to increment our sum by 1
    alt_64 a_leap_total = a_delt%VGA_WIDTH;
    alt_64 b_leap_total = b_delt%VGA_HEIGHT;

    
    //leap interval is the number of cycles between leaps
    int a_leap_interval;
    if(a_leap_total != 0) 
        a_leap_interval = VGA_WIDTH/a_leap_total;
    else
        a_leap_interval = VGA_WIDTH;        
    int b_leap_interval;
    if(b_leap_total != 0)
        b_leap_interval = VGA_HEIGHT/b_leap_total;
    else
        b_leap_interval = VGA_HEIGHT;

    static int payload[15];
    payload[0] = ((a_min & TOP_18_MASK) >> 18);
    payload[1] = (a_min & BOT_18_MASK);
    payload[2] = ((b_min & TOP_18_MASK) >> 18);
    payload[3] = (b_min & BOT_18_MASK);
    payload[4] = ((d_a & TOP_18_MASK) >> 18);
    payload[5] = (d_a & BOT_18_MASK);
    payload[6] = ((d_b & TOP_18_MASK) >> 18);
    payload[7] = (d_b & BOT_18_MASK);
    payload[8] = (a_leap_interval);
    payload[9] = (b_leap_interval);
    payload[10] = ((c_rea & TOP_18_MASK) >> 18);
    payload[11] = (c_rea & BOT_18_MASK);
    payload[12] = ((c_img & TOP_18_MASK) >> 18);
    payload[13] = (c_img & BOT_18_MASK);
    payload[14] = 1;

    printf("A_MIN = %llx\n",a_min);
    printf("B_MIN = %llx\n",b_min);
    printf("D_A   = %llx\n",d_a);
    printf("D_B   = %llx\n",d_b);
    printf("A_LEAP= %x\n",a_leap_interval);
    printf("B_LEAP= %x\n",b_leap_interval);

    int i;    
    printf("________________________\n");
    for(i = 0; i < 14; i++){
        IOWR_32DIRECT(RAM_BASE, (i-0)*4, payload[i]);
        printf("0x%x\n", (payload[i]<<14));
        //printf("0x%d\n", (payload[i]);
    }
    //IOWR_32DIRECT(RAM_BASE, 0, payload[0]);
     
    /*while(1)
       IOWR_32DIRECT(FBUS_BASE, 0, payload[13]);*/ 
    
    alt_8 load = 63;
    
    IOWR_8DIRECT(RAM_SIGNAL_BASE, 0, load);
    
    return 0;
}