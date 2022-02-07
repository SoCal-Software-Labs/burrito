# Burrito Examples

This directory contains a few sample applications that demonstrate the capabilities of Burrito!

## basic_cli
----

A simple application that prints a random number and the arguments passed to it to standard out.


## only_one
----

A simple CLI application that demonstrates Zig plugins, it will not allow more than 1 copy of the application to run at a time.
It utilizes a pre-defined UDP port to listen on in place of a lockfile.