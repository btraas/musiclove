cmake_minimum_required(VERSION 3.13)  # CMake version check
project(musiclove)               # Create project "simple_example"
set(CMAKE_CXX_STANDARD 14)            # Enable c++14 standard

# Add main.cpp file of project root directory as source file
set(SOURCE_FILES Main.xm preftools.xm MusicLove.h common.m)

# Add executable target with source files listed in SOURCE_FILES variable
add_executable(musiclove ${SOURCE_FILES})