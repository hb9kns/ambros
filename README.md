# AMBroS

## Introduction

*AMBroS = Autonomous Morse code Broadcasting System*

Is Morse-Code on the way to die? It migh be, if not used anymore...
To increase the amount of Morse code transmissions available to
listeners, broadcast stations are needed that process interesting
texts and transmit them for human ears: Morse-Code Broadcasting!

Although the running costs of a transmitting station (excluding mortgages
and appreciation of equipment) consist only of the comparatively small
expenses for electricity needed to actually transmit and control the
transmitter, creation and assembling of transmission texts are quite
expensive tasks, if done manually. Therefore, it is important to make this
a process as automatic as possible, and AMBroS is meant to fill this gap.

AMBROS shall be a completely autonomous system, collecting textual data
from different sources (online or offline), filtering them according
to predefined rules, assembling the resulting texts into a contiuous
transmission schedule, and broadcasting them via an attached transmitter
system.

On the hardware side, only a low-cost computer and a suitable transmitter
are needed. Depending on the chosen transmitter type, additional software
drivers may be needed, to complement the core of AMBroS.

## Roadmap

Initially, a demonstrator system shall be created, which is an assemblage
of various scripts (shell, sed, awk, etc) capable of running at least
a low-traffic AMBroS. This initial demonstrator may simulate the Morse
code transmission, not yet relying on a real transmission system.

Once the demonstrator is running, its components may be gradually replaced
by faster interpreted scripts or even compiled programs, while keeping the
interfaces of the various components unmodified if possible. In addition,
a demonstrator controlling a real transmitter shall be tested, be it on
commonly available (free) frequencies, amateur radio, or any other radio
service.

---

## Information for Developers

### Git Repository Structure

#### Scratch

In `Scratch/`, contributors may create personal files with names
starting with their user/account name, to store notes and other
personal and project related information.
Please do not tamper with other people's files!

#### examples

`examples/` contains sample or test configuration files

#### src

`src/` contains scripts or (in a later stage) sources for compilation

##### morse

`src/morse/` contains scripts or sources concerning Morse code generation


---

_2014-July, Yargo Bonetti_ ( `HB9KNS` )
