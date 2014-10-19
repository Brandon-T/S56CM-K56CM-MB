/*
 * Intel ACPI Component Architecture
 * AML Disassembler version 20120420-32 [May 17 2012]
 * Copyright (c) 2000 - 2012 Intel Corporation
 * 
 * Disassembly of /Extra/wtf/SSDT-3.aml, Sat Oct 11 01:07:19 2014
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000091C (2332)
 *     Revision         0x01
 *     Checksum         0xEE
 *     OEM ID           "CfgTDP"
 *     OEM Table ID     "CfgTDP_"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20091112 (537465106)
 */

DefinitionBlock ("/Extra/wtf/SSDT-3.aml", "SSDT", 1, "CfgTDP", "CfgTDP_", 0x00001000)
{
    External (CPL2, MethodObj)    // 0 Arguments
    External (CPL1, MethodObj)    // 0 Arguments
    External (CPL0, MethodObj)    // 0 Arguments
    External (CPNU, MethodObj)    // 2 Arguments
    External (CLCK)
    External (CTNL, IntObj)
    External (\_PR_.CBMI, IntObj)
    External (\_PR_.CTC2, IntObj)
    External (\_PR_.TAR2)
    External (\_PR_.CTC1, IntObj)
    External (\_PR_.TAR1)
    External (\_PR_.CTC0, IntObj)
    External (\_PR_.TAR0)
    External (\_PR_.PL12)
    External (\_PR_.PL11)
    External (\_PR_.PL10)
    External (\_PR_.CLVL, IntObj)
    External (\_SB_.IETM, DeviceObj)
    External (\_SB_.PCI0.B0D4, DeviceObj)
    External (\_SB_.PCI0.LPCB.EC0_, DeviceObj)

    Scope (\_SB.IETM)
    {
        Name (CTSP, Package (0x01)
        {
            Buffer (0x10)
            {
                /* 0000 */   0x0A, 0x97, 0x45, 0xE1, 0xC1, 0xE4, 0x73, 0x4D,
                /* 0008 */   0x90, 0x0E, 0xC9, 0xC5, 0xA6, 0x9D, 0xD0, 0x67
            }
        })
    }

    Scope (\_SB.PCI0.B0D4)
    {
        Method (TDPL, 0, Serialized)
        {
            Name (_T_0, Zero)
            Name (AAAA, Zero)
            Name (BBBB, Zero)
            Name (CCCC, Zero)
            Name (PPUU, Zero)
            Name (TMP1, Package (0x01)
            {
                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }
            })
            Name (TMP2, Package (0x02)
            {
                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }, 

                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }
            })
            Name (TMP3, Package (0x03)
            {
                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }, 

                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }, 

                Package (0x05)
                {
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000, 
                    0x80000000
                }
            })
            Store (CTNL, Local0)
            If (LOr (LEqual (Local0, One), LEqual (Local0, 0x02)))
            {
                Store (\_PR.CLVL, Local0)
            }
            Else
            {
                Return (Zero)
            }

            If (LEqual (CLCK, One))
            {
                Store (One, Local0)
            }

            Store (CPNU (\_PR.PL10, One), AAAA)
            Store (CPNU (\_PR.PL11, One), BBBB)
            Store (CPNU (\_PR.PL12, One), CCCC)
            If (LEqual (Local0, 0x03))
            {
                If (LGreaterEqual (AAAA, BBBB))
                {
                    If (LGreater (AAAA, CCCC))
                    {
                        If (LGreater (BBBB, CCCC))
                        {
                            Store (Zero, Local3)
                            Store (Zero, LEV0)
                            Store (One, Local4)
                            Store (One, LEV1)
                            Store (0x02, Local5)
                            Store (0x02, LEV2)
                        }
                        Else
                        {
                            Store (Zero, Local3)
                            Store (Zero, LEV0)
                            Store (One, Local5)
                            Store (0x02, LEV1)
                            Store (0x02, Local4)
                        }

                        Store (One, LEV2)
                    }
                    Else
                    {
                        Store (Zero, Local5)
                        Store (0x02, LEV0)
                        Store (One, Local3)
                        Store (Zero, LEV1)
                        Store (0x02, Local4)
                        Store (One, LEV2)
                    }
                }
                Else
                {
                    If (LGreater (BBBB, CCCC))
                    {
                        If (LGreater (AAAA, CCCC))
                        {
                            Store (Zero, Local4)
                            Store (One, LEV0)
                            Store (One, Local3)
                            Store (Zero, LEV1)
                            Store (0x02, Local5)
                            Store (0x02, LEV2)
                        }
                        Else
                        {
                            Store (Zero, Local4)
                            Store (One, LEV0)
                            Store (One, Local5)
                            Store (0x02, LEV1)
                            Store (0x02, Local3)
                            Store (Zero, LEV2)
                        }
                    }
                    Else
                    {
                        Store (Zero, Local5)
                        Store (0x02, LEV0)
                        Store (One, Local4)
                        Store (One, LEV1)
                        Store (0x02, Local3)
                        Store (Zero, LEV2)
                    }
                }

                Store (Add (\_PR.TAR0, One), Local1)
                Multiply (Local1, 0x64, Local2)
                Store (AAAA, Index (DerefOf (Index (TMP3, Local3)), Zero))
                Store (Local2, Index (DerefOf (Index (TMP3, Local3)), One))
                Store (\_PR.CTC0, Index (DerefOf (Index (TMP3, Local3)), 0x02))
                Store (Local1, Index (DerefOf (Index (TMP3, Local3)), 0x03))
                Store (Zero, Index (DerefOf (Index (TMP3, Local3)), 0x04))
                Store (Add (\_PR.TAR1, One), Local1)
                Multiply (Local1, 0x64, Local2)
                Store (BBBB, Index (DerefOf (Index (TMP3, Local4)), Zero))
                Store (Local2, Index (DerefOf (Index (TMP3, Local4)), One))
                Store (\_PR.CTC1, Index (DerefOf (Index (TMP3, Local4)), 0x02))
                Store (Local1, Index (DerefOf (Index (TMP3, Local4)), 0x03))
                Store (Zero, Index (DerefOf (Index (TMP3, Local4)), 0x04))
                Store (Add (\_PR.TAR2, One), Local1)
                Multiply (Local1, 0x64, Local2)
                Store (CCCC, Index (DerefOf (Index (TMP3, Local5)), Zero))
                Store (Local2, Index (DerefOf (Index (TMP3, Local5)), One))
                Store (\_PR.CTC2, Index (DerefOf (Index (TMP3, Local5)), 0x02))
                Store (Local1, Index (DerefOf (Index (TMP3, Local5)), 0x03))
                Store (Zero, Index (DerefOf (Index (TMP3, Local5)), 0x04))
                Return (TMP3)
            }

            If (LEqual (Local0, 0x02))
            {
                If (LGreaterEqual (AAAA, BBBB))
                {
                    Store (Zero, Local3)
                    Store (One, Local4)
                    Store (Zero, LEV0)
                    Store (One, LEV1)
                    Store (Zero, LEV2)
                }
                Else
                {
                    Store (Zero, Local4)
                    Store (One, Local3)
                    Store (One, LEV0)
                    Store (Zero, LEV1)
                    Store (Zero, LEV2)
                }

                Store (Add (\_PR.TAR0, One), Local1)
                Multiply (Local1, 0x64, Local2)
                Store (AAAA, Index (DerefOf (Index (TMP2, Local3)), Zero))
                Store (Local2, Index (DerefOf (Index (TMP2, Local3)), One))
                Store (\_PR.CTC0, Index (DerefOf (Index (TMP2, Local3)), 0x02))
                Store (Local1, Index (DerefOf (Index (TMP2, Local3)), 0x03))
                Store (Zero, Index (DerefOf (Index (TMP2, Local3)), 0x04))
                Store (Add (\_PR.TAR1, One), Local1)
                Multiply (Local1, 0x64, Local2)
                Store (BBBB, Index (DerefOf (Index (TMP2, Local4)), Zero))
                Store (Local2, Index (DerefOf (Index (TMP2, Local4)), One))
                Store (\_PR.CTC1, Index (DerefOf (Index (TMP2, Local4)), 0x02))
                Store (Local1, Index (DerefOf (Index (TMP2, Local4)), 0x03))
                Store (Zero, Index (DerefOf (Index (TMP2, Local4)), 0x04))
                Return (TMP2)
            }

            If (LEqual (Local0, One))
            {
                While (One)
                {
                    Store (\_PR.CBMI, _T_0)
                    If (LEqual (_T_0, Zero))
                    {
                        Store (Add (\_PR.TAR0, One), Local1)
                        Multiply (Local1, 0x64, Local2)
                        Store (AAAA, Index (DerefOf (Index (TMP1, Zero)), Zero))
                        Store (Local2, Index (DerefOf (Index (TMP1, Zero)), One))
                        Store (\_PR.CTC0, Index (DerefOf (Index (TMP1, Zero)), 0x02))
                        Store (Local1, Index (DerefOf (Index (TMP1, Zero)), 0x03))
                        Store (Zero, Index (DerefOf (Index (TMP1, Zero)), 0x04))
                        Store (Zero, LEV0)
                        Store (Zero, LEV1)
                        Store (Zero, LEV2)
                    }
                    Else
                    {
                        If (LEqual (_T_0, One))
                        {
                            Store (Add (\_PR.TAR1, One), Local1)
                            Multiply (Local1, 0x64, Local2)
                            Store (BBBB, Index (DerefOf (Index (TMP1, Zero)), Zero))
                            Store (Local2, Index (DerefOf (Index (TMP1, Zero)), One))
                            Store (\_PR.CTC1, Index (DerefOf (Index (TMP1, Zero)), 0x02))
                            Store (Local1, Index (DerefOf (Index (TMP1, Zero)), 0x03))
                            Store (Zero, Index (DerefOf (Index (TMP1, Zero)), 0x04))
                            Store (One, LEV0)
                            Store (One, LEV1)
                            Store (One, LEV2)
                        }
                        Else
                        {
                            If (LEqual (_T_0, 0x02))
                            {
                                Store (Add (\_PR.TAR2, One), Local1)
                                Multiply (Local1, 0x64, Local2)
                                Store (CCCC, Index (DerefOf (Index (TMP1, Zero)), Zero))
                                Store (Local2, Index (DerefOf (Index (TMP1, Zero)), One))
                                Store (\_PR.CTC2, Index (DerefOf (Index (TMP1, Zero)), 0x02))
                                Store (Local1, Index (DerefOf (Index (TMP1, Zero)), 0x03))
                                Store (Zero, Index (DerefOf (Index (TMP1, Zero)), 0x04))
                                Store (0x02, LEV0)
                                Store (0x02, LEV1)
                                Store (0x02, LEV2)
                            }
                        }
                    }

                    Break
                }

                Return (TMP1)
            }

            Return (Zero)
        }

        Name (MAXT, Zero)
        Method (TDPC, 0, NotSerialized)
        {
            Return (MAXT)
        }

        Name (LEV0, Zero)
        Name (LEV1, Zero)
        Name (LEV2, Zero)
        Method (STDP, 1, Serialized)
        {
            Name (_T_1, Zero)
            Name (_T_0, Zero)
            If (LGreaterEqual (Arg0, \_PR.CLVL))
            {
                Return (Zero)
            }

            While (One)
            {
                Store (Arg0, _T_0)
                If (LEqual (_T_0, Zero))
                {
                    Store (LEV0, Local0)
                }
                Else
                {
                    If (LEqual (_T_0, One))
                    {
                        Store (LEV1, Local0)
                    }
                    Else
                    {
                        If (LEqual (_T_0, 0x02))
                        {
                            Store (LEV2, Local0)
                        }
                    }
                }

                Break
            }

            While (One)
            {
                Store (Local0, _T_1)
                If (LEqual (_T_1, Zero))
                {
                    CPL0 ()
                }
                Else
                {
                    If (LEqual (_T_1, One))
                    {
                        CPL1 ()
                    }
                    Else
                    {
                        If (LEqual (_T_1, 0x02))
                        {
                            CPL2 ()
                        }
                    }
                }

                Break
            }

            Notify (\_SB.PCI0.B0D4, 0x83)
        }
    }

    Scope (\_SB.PCI0.LPCB.EC0)
    {
        Method (_Q7F, 0, NotSerialized)
        {
            Increment (\_SB.PCI0.B0D4.MAXT)
            If (LGreaterEqual (\_SB.PCI0.B0D4.MAXT, 0x03))
            {
                Store (Zero, \_SB.PCI0.B0D4.MAXT)
            }

            Notify (\_SB.PCI0.B0D4, 0x84)
        }

        Method (_QB7, 0, NotSerialized)
        {
            Store (Zero, \_SB.PCI0.B0D4.MAXT)
            Notify (\_SB.PCI0.B0D4, 0x84)
        }

        Method (_QB8, 0, Serialized)
        {
            Name (_T_0, Zero)
            While (One)
            {
                Store (\_PR.CLVL, _T_0)
                If (LEqual (_T_0, 0x03))
                {
                    Store (One, \_SB.PCI0.B0D4.MAXT)
                }
                Else
                {
                    If (LEqual (_T_0, 0x02))
                    {
                        Store (Zero, \_SB.PCI0.B0D4.MAXT)
                    }
                    Else
                    {
                        If (LEqual (_T_0, One))
                        {
                            Store (Zero, \_SB.PCI0.B0D4.MAXT)
                        }
                    }
                }

                Break
            }

            Notify (\_SB.PCI0.B0D4, 0x84)
        }

        Method (_QB9, 0, Serialized)
        {
            Name (_T_0, Zero)
            While (One)
            {
                Store (\_PR.CLVL, _T_0)
                If (LEqual (_T_0, 0x03))
                {
                    Store (0x02, \_SB.PCI0.B0D4.MAXT)
                }
                Else
                {
                    If (LEqual (_T_0, 0x02))
                    {
                        Store (One, \_SB.PCI0.B0D4.MAXT)
                    }
                    Else
                    {
                        If (LEqual (_T_0, One))
                        {
                            Store (Zero, \_SB.PCI0.B0D4.MAXT)
                        }
                    }
                }

                Break
            }

            Notify (\_SB.PCI0.B0D4, 0x84)
        }
    }
}

         Notify (\_PR.CPU0, 0x80)
                            Notify (\_PR.CPU1, 0x80)
                        }
                        Else
                        {
                            Notify (\_PR.CPU0, 0x80)
                        }
                    }
                }

                Break
            }
        }

        Method (_TMP, 0, NotSerialized)
        {
            Return (0x0BB8)
        }

        Method (_DTI, 1, NotSerialized)
        {
            Store (Arg0, LSTM)
            Notify (B0D4, 0x91)
        }

        Method (_NTT, 0, NotSerialized)
        {
            Return (0x0ADE)
        }

        Method (_PSS, 0, NotSerialized)
        {
            If (CondRefOf (\_PR.CPU0._PSS))
            {
                Return (\_PR.CPU0._PSS)
            }
            Else
            {
                Return (Package (0x01)
                {
                    Zero
                })
            }
        }

        Method (_TSS, 0, NotSerialized)
        {
            If (CondRefOf (\_PR.CPU0._TSS))
            {
                Return (\_PR.CPU0._TSS)
            }
            Else
            {
                Return (Package (0x01)
                {
                    Zero
                })
            }
        }

        Method (_TPC, 0, NotSerialized)
        {
            If (CondRefOf (\_PR.CPU0._TPC))
            {
                Return (\_PR.CPU0._TPC)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (_PTC, 0, NotSerialized)
        {
            If (CondRefOf (\_PR.CPU0._PTC))
            {
                Return (\_PR.CPU0._PTC)
            }
            Else
            {
                Return (Package (0x01)
                {
                    Zero
                })
            }
        }

        Method (_TSD, 0, NotSerialized)
        {
            If (CondRefOf (\_PR.CPU0._TSD))
            {
                Return (\_PR.CPU0._TSD)
            }
            Else
            {
                Return (Package (0x01)
                {
                    Zero
                })
            }
        }

        Method (_TDL, 0, NotSerialized)
        {
            Name (LFMI, Zero)
            If (CondRefOf (\_PR.CPU0._TSS))
            {
                Store (SizeOf (\_PR.CPU0._TSS), LFMI)
                Decrement (LFMI)
                Return (LFMI)
            }
            Else
            {
                Return (Zero)
            }
        }

        Method (_PDL, 0, NotSerialized)
        {
            Name (LFMI, Zero)
            If (CondRefOf (\_PR.CPU0._PSS))
            {
                Store (SizeOf (\_PR.CPU0._PSS), LFMI)
                Decrement (LFMI)
                Return (LFMI)
            }
            Else
            {
                Return (Zero)
            }
        }
    }
}

