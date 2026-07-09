# Copyright (c) 2012 ARM Limited
# All rights reserved.
#
# The license below extends only to copyright in the software and shall
# not be construed as granting a license to any other intellectual
# property including but not limited to intellectual property relating
# to a hardware implementation of the functionality of the software
# licensed hereunder.  You may use the software subject to the license
# terms below provided that you ensure that this notice is replicated
# unmodified and in its entirety in all distributions of the software,
# modified or unmodified, in source code or in binary form.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from m5.objects.BaseISA import BaseISA
from m5.params import *


class X86ISA(BaseISA):
    type = "X86ISA"
    cxx_class = "gem5::X86ISA::ISA"
    cxx_header = "arch/x86/isa.hh"

    # Upstream gem5 defaults this to "HygonGenuine": "M5 Simulator" is not a
    # genuine CPUID vendor and newer GLIBC rejects it. (Upstream first tried
    # "GenuineAMD", https://gem5-review.googlesource.com/c/public/gem5/+/64831,
    # then settled on "HygonGenuine" over a kernel boot issue, GEM5-1300.)
    #
    # MCSquare needs "M5 Simulator" back. The artifact's disk image boots via
    # /sbin/gem5init, which decides whether it is running under gem5 by string-
    # comparing /proc/cpuinfo's vendor_id against exactly "M5 Simulator". On any
    # other value it prints "Not in gem5. Not loading script" and exits without
    # running the script delivered by --script; the guest then idles forever and
    # never executes an m5 pseudo-instruction, so `m5 exit` never fires and the
    # KVM->O3 switch never happens. ("HygonGenuine" also makes Linux take the
    # AMD PMU path and fail on MSR 0xc0010007.) The guest is Ubuntu 20.04
    # (glibc 2.31), which predates the strict CPUID check, so this is safe.
    vendor_string = Param.String(
        "M5 Simulator", "Vendor string for CPUID instruction"
    )
    name_string = Param.String(
        "Fake gem5 x86_64 CPU", "Processor name for CPUID instruction"
    )

    # For the functions that return numerical values we use a vector of ints.
    # The order of the values is: EAX, EBX, EDX, ECX.
    #
    # If the CPU function can take an index, the index value is used as an
    # offset into the vector and four numerical values are added for each
    # possible index value. For example, if the function accepts 3 index
    # values, there are 12 total ints in the vector param. In addition, the
    # last values for functions which take an index must be all zeros. All
    # zeros indicates to the KVM cpu / OS that there are no more index values
    # to iterate over.
    #
    # A good resource for these values can be found here:
    #     https://sandpile.org/x86/cpuid.htm
    # 0000_0001h
    FamilyModelStepping = VectorParam.UInt32(
        [0x00020F51, 0x00000805, 0xEFDBFBFF, 0x00000209],
        "type/family/model/stepping and feature flags",
    )
    # 0000_0004h
    CacheParams = VectorParam.UInt32(
        [0x00000000, 0x00000000, 0x00000000, 0x00000000],
        "cache configuration descriptors",
    )
    # 0000_0007h
    ExtendedFeatures = VectorParam.UInt32(
        [0x00000000, 0x01800000, 0x00000000, 0x00000000], "feature flags"
    )
    # 0000_000Dh - This uses ECX index, so the last entry must be all zeros
    ExtendedState = VectorParam.UInt32(
        [
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
        ],
        "extended state enumeration",
    )
    # 8000_0001h
    FamilyModelSteppingBrandFeatures = VectorParam.UInt32(
        [0x00020F51, 0x00000405, 0xEBD3FBFF, 0x00020001],
        "family/model/stepping and features flags",
    )
    # 8000_0005h
    L1CacheAndTLB = VectorParam.UInt32(
        [0xFF08FF08, 0xFF20FF20, 0x40020140, 0x40020140],
        "L1 cache and L1 TLB configuration descriptors",
    )
    # 8000_0006h
    L2L3CacheAndL2TLB = VectorParam.UInt32(
        [0x00000000, 0x42004200, 0x00000000, 0x04008140],
        "L2/L3 cache and L2 TLB configuration descriptors",
    )
    # 8000_0007h
    APMInfo = VectorParam.UInt32(
        [0x80000018, 0x68747541, 0x69746E65, 0x444D4163],
        "processor feedback capabilities",
    )
    # 8000_0008h
    LongModeAddressSize = VectorParam.UInt32(
        [0x00003030, 0x00000000, 0x00000000, 0x00000000],
        "miscellaneous information",
    )
