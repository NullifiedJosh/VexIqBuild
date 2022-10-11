/*----------------------------------------------------------------------------*/
/*                                                                            */
/*    Module:       main.cpp                                                  */
/*    Author:       james                                                     */
/*    Created:      Thu Aug 05 2021                                           */
/*    Description:  XX project                                                */
/*                                                                            */
/*----------------------------------------------------------------------------*/
#define VEX_TOOLCHAIN_VERSION 2
#include "vex.h"

using namespace vex;

vex::brain Brain;

// define your global instances of motors and other devices here


int main() {
    int count = 0;
   
    Brain.Screen.clearScreen();
    Brain.Screen.setFont( vex::fontType::mono40 ); 

    Brain.Screen.printAt( 10, 30, "Hello IQ2 %d", count++ );
}
