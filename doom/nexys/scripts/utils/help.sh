#!/bin/bash

function help-header(){
echo " Doom Nexys Makefile                                                              "
echo "                                                                                  "
echo " Usage: make [targets] [options]                                                  "
}

function help-targets-header(){
echo " ---------------------------------------------------------------------------------"
echo " targets:                                                 Files generated:        "
echo " ---------------------------------------------------------------------------------"
}

function help-options-header(){
echo " ---------------------------------------------------------------------------------"
echo " options:                                                 Possible values:        "
echo " ---------------------------------------------------------------------------------"
}

function help-build(){
echo "  clean               Deletes build directory.                                    " 
echo "                                                                                  "
echo "  all                 Default target. When there are no   <All built files>       "
echo "                      specified options, builds, loads,                           "
echo "                      and runs Doom on Nexys-A7. Board                            "
echo "                      must be plugged through microUSB                            "
echo "                      to host prior to using this target.                         "
echo "                      Must be run with root privileges.                           "
echo "                                                                                  "
echo "  gen_rom             Compiles SwerVolfX Bootrom.         doom_nexys_rom.elf      "
echo "                                                          doom_nexys_rom.bin      "
echo "                                                          doom_nexys_rom.vh       "
echo "                                                          doom_nexys_rom.mem      "
echo "                                                                                  "
echo "  gen_bin             Compiles Doom's source code.        doom_nexys.elf          "
echo "                                                          doom_nexys.bin          "
echo "                                                                                  "
echo "  gen_ub              Generates U-Boot image with         doom_nexys.ub           "
echo "                      doom_nexys.bin and WAD file.                                "
echo "                                                                                  "
echo "  flash               Loads Nexys-A7 with proxy           <N/A>                   "
echo "                      bitstream which programs onboard                            "
echo "                      QSPI flash with U-Boot image                                "
echo "                      through JTAG.                                               "
echo "                                                                                  "
echo "  program             Loads Nexys-A7 with                 <N/A>                   "
echo "                      doom_nexys.bit through JTAG.                                "
echo "                                                                                  "
echo "  serial              Opens Nexys-A7 UART serial          <N/A>                   "
echo "                      output. Must be run with root                               "
echo "                      privileges.                                                 "
echo "                                                                                  "
echo "  sd                  Formats FAT32 SD card connected     <N/A>                   "
echo "                      to host a loads doom_nexys.bit.                             "
echo "                      Must be run with root privileges.                           "
echo "                                                                                  "
}

function help-sim(){
echo "  gen_rom_sim         Compiles SwerVolfX initial ram      doom_nexys_rom_sim.elf  "
echo "                      contents for Verilator simulation.  doom_nexys_rom_sim.bin  "
echo "                                                          doom_nexys_rom_sim.vh   "
echo "                                                          doom_nexys_rom_sim.mem  "
echo "                                                                                  "
echo "  verilator           'Verilates' the projects RTL for    <All verilated files>   "
echo "                      simulation and opens waveforms      trace.vcd               "
echo "                      in GTKwave.                                                 "
echo "                                                                                  "
echo "  wave                Opens trace.vcd generated by        <N/A>                   "
echo "                      Verilator in GTKwave.                                       "
echo "                                                                                  "
}

function help-docker(){
echo " ---------------------------------------------------------------------------------"
echo " WARNING: Each one of the following targets must be run with root privileges.     "
echo " ---------------------------------------------------------------------------------"
echo "  docker-install-deps Installs the needed dependencies    <N/A>                   "
echo "                      to run Docker on Debian/Ubuntu                              "
echo "                      hosts.                                                      "
echo "                                                                                  "
echo "  docker-build        Builds the Docker image for         <N/A>                   "
echo "                      building Doom Nexys.                                        "
echo "                                                                                  "
echo "  docker-start        Start the Docker container.         <N/A>                   "
echo "                                                                                  "
echo "  docker-stop         Stops the Docker container.         <N/A>                   "
echo "                                                                                  "
echo "  docker-shell        Opens a shell session on the        <N/A>                   "
echo "                      Docker container.                                           "
echo "                                                                                  "
echo "  docker-vcode        Opens a Visual-Studio Code          <N/A>                   "
echo "                      session on the Docker container                             "
echo "                                                                                  "
echo "  docker-clean        Deletes Docker container and all                            "
echo "                      other related files \(WIP\)         <N/A>                   "
echo " ---------------------------------------------------------------------------------"
echo "                                                                                  "
}

function help-debug(){
echo "  debug               Opens a GBD session through JTAG.   <N/A>                   "
echo "                      Useful to step through code                                 "
echo "                      running on hardware. Nexys-A7 must                          "
echo "                      be plugged in before running this                           "
echo "                      target (WIP).                                               "
echo "                                                                                  "
}

function help-options(){
echo "  V                   Verbosity. Disabled by default.     V=1                     "
echo "                      If V=1 is set, all output logs      V=0                     "
echo "                      will be printed in stdout.                                  "
echo "                                                                                  "
echo "  BIT                 Force bitstream generation. By      BIT=1                   "
echo "                      default, if doom_nexys.bit exists,  BIT=0                   "
echo "                      bitstream generation will not be                            "
echo "                      executed. If BIT=1 is set, even if                          "
echo "                      doom_nexys.bit exists, Vivado will                          "
echo "                      be launched to regenerate the                               "
echo "                      bitstream. Useful to reduce build                           "
echo "                      times.                                                      "
echo "                                                                                  "
echo " TIMEOUT              Set Verilator max simulation        TIMEOUT=5000            "
echo "                      timesteps. Useful to reduce         TIMEOUT=1000000         "
echo "                      GTKwave launch times, and to        TIMEOUT=100             "
echo "                      debug long digital protocols        ...                     "
echo "                      \(VGA,RAM R/W, etc...\).                                    "
}

HELP_VAR=$1

help-header

if [[ "$HELP_VAR" == "build" ]]; then
    help-targets-header
    help-build
elif [[ "$HELP_VAR" == "sim" ]]; then
    help-targets-header
    help-sim
elif [[ "$HELP_VAR" == "docker" ]]; then
    help-targets-header
    help-docker
elif [[ "$HELP_VAR" == "debug" ]]; then
    help-targets-header
    help-debug
elif [[ "$HELP_VAR" == "options" ]]; then
    help-options-header
    help-options
else
    help-targets-header
    help-build
    help-sim
    help-docker
    help-debug
    help-options-header
    help-options
fi
