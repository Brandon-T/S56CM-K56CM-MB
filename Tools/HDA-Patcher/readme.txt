Script to patch AppleHDA binary for osx10.7 thru 10.9

I've written a script to auto-patch the AppleHDA binary to support hackintosh codecs under OSX 10.7 thru 10.9.

[b]Background:[/b]
Historically the binary patching of AppleHDA was simple, merely requiring replacement of the best matching codec id found in the driver with the codec id for your hardware.  In more recent releases of AppleHDA, the compiler is better optimizing its code and patching now often requires patching the AppleHDA binary in multiple places.  For some codecs, this has resulted in a patch that is different depending upon which release you're using.  The old strategy of using a perl one-liner to publish&distribute these patches thus became less practical than ever, leading to confusion, seemingly conflicting information and lists of questionable patches for one to try.  This script is meant to replace that.

[b]The solution[/b]
The script is able to dynamically figure out which extra comparisons should be patched to get the matching to work properly.  The script includes an associated codec config database, patch-hda-codecs.pl.   This database contains two tables, first there is the codec_names_to_num table which provides the simple mapping between codec names and their codec id.  Second is codecs_map which maps one's hackintosh codec name to the runtime AppleHDA codec (target codec), again referenced by name.  This second table allows for multiple choices, so for example, the hackintosh realtek alc889 can be patched to either alc 885 or adi 1984.  -c 1 lets you select choice #1 (the default), -c 2 the second choice, and so on.

The script also attempts to auto-detect your system's codec and offers that as a default choice for the codec to patch into AppleHDA (the patch codec id).

Early versions of this script required the patch codec id to be present in the patch-hda-codecs.pl database, but the current version does not.  You can now specify any codec ID you wish and the script will attempt to patch your codec into the ADI 1984 choice (the most common).

Every OSX update that installs a new version of AppleHDA (that is, most of them) requires re-patching your system's AppleHDA.  That is unless you resort to other means such as rolling back your AppleHDA driver (not recommended).

I've included support for the codecs I have, those found in HDA wizard, as well as many more from [url=http://www.insanelymac.com/forum/topic/280468-applehda-patching-in-mountain-lion/]this thread[/url]

[b]What this thread is not:[/b]
A complete solution for getting your AppleHDA audio working.
In addition to patching your AppleHDA binary, you need to also configure xml for your codec.  (A pathmap and pin configuration as it's referred to in the drivers).  See [url=http://www.projectosx.com/forum/index.php?showtopic=465]http://www.projectosx.com/forum/index.php?showtopic=465[/url]
Thirdly, you need a method to inject into your ioregistry the layout-id used by your pathmap and/or also some flags for working HDMI audio.  These edits can be done quite concisely via DSDT.  Alternatively you may also inject them into your ioregistry thru other means such as a kext.  Again see the above thread.

[b]Usage:[/b]
Run this script from a terminal window, supplying the codec name or the hexadecimal codec id of the codec found on your hackintosh.  If your codec is in the database (patch-hda-codecs.pl) the script will patch things for you automatically.  Alternatively you can click on the patch-hda shell script from the finder.  

Command line switches
[list]
[*]-y Makes the script use the auto-detected codec without running the script interactively.
[*]-c <choice number> For codecs with multiple known working choices for the runtime AppleHDA codec (target codec) to use, this option selects the choice.  -c 1 lets you select choice #1 (the default), -c 2 the second choice, and so on.
[*]-s <directory> to specify an alternative to /System/Library/Extensions
[*]-r <volume root> to specify an alternate disk volume to use as the root for everything (particularly useful when you have multiple installs of OSX and you want to patch OSX on one of those other volumes.

Also, for both of the above the script determines the OS release based upon the AppleHDA kext version. If for some reason the script gets this wrong, there's also
[*]-o <os version number> to override the auto-detected OS version (10.7/10.8/10.9)
[*]-t to run the script in test-only mode, where AppleHDA is not actually patched. 
[/list]
[b]Implementation details:[/b]

The script accomplishes patching of the codec comparisons by zeroing out the codec ids found as operands to the applicable comparison instructions.  This is easier to do in a script than other patch methods such as jumping over unwanted comparisons.  The solution in this script is easier to implement as the script can avoid parsing AppleHDA's match routine's instructions to work successfully.  (see ati-personality.pl for an example of that more complicated kind of processing).

[b]How to help[/b]
Please DO contribute updates to this script, especially the patch-hda-codecs.pl list, to support new hardware.  I do not have a lab of hardware to test against; I rely upon users to fill in the blanks as to what does/doesn't work.  I do not have time to test codecs for hardware I do not have; I barely had time to write this post.  Feel free to post revised versions of patch-hda-codecs.pl here.

Please DON'T post to this thread to beg for a solution for your codec.  It takes quite a bit of tinkering to make a working pathmap&pinconfig for a new codec.  And there are better threads for such discussion such as:  [url=http://www.insanelymac.com/forum/topic/280468-applehda-patching-in-mountain-lion/]http://www.insanelymac.com/forum/topic/280468-applehda-patching-in-mountain-lion/[/url]

Please DON'T PM me for tech support either, I likely don't even have time to answer.

This script resembles the concept of [url=http://www.insanelymac.com/forum/index.php?showtopic=266531]HDA wizard[/url] but instead of being GUI focused, it focuses on getting the AppleHDA binary patching done automatic&right across osx releases.

Examples, under 10.7:
[code]
% ./patch-hda.pl 111d7675
Patching AppleHDA codec 11d41984 with 111d7675
1 codec range comparison(s) to patch
Patching range comparison 11d41983
AppleHDA patched successfully.[/code]
under 10.8:
[code]
% ./patch-hda.pl 111d7675
Patching AppleHDA codec 11d41984 with 111d7675
No codec range comparisons require patching
AppleHDA patched successfully.
% ./patch-hda.pl 10ec0889
Patching AppleHDA codec 10ec0885 with 10ec0889
No codec range comparisons require patching
AppleHDA patched successfully.
% ./patch-hda.pl 'Realtek ALC889' -c 2
Patching AppleHDA codec 11d41984 with 10ec0889
No codec range comparisons require patching
AppleHDA patched successfully.
% ./patch-hda.pl 0x10ec0801
OSX version 10.8 detected
Couldn't find a codec map to apply for '0x10ec0801'.
Would you like to try using ADI 1984 (the default) (Y/N)? y
Patching AppleHDA codec 11d41984 with 10ec0801
2 codec range comparison(s) to patch
Patching range comparison 10ec0884
Patching range comparison 10ec0885
AppleHDA patched successfully.
% ./patch-hda.pl
OSX version 10.9 detected
Enter codec-id or codec-name for AppleHDA patch.  Eg. 111d7675 or IDT 7675
Press enter for default, or ? for help 
? ?
Usage: patch-hda.pl <codec-id>|<codec-name>
Command line switches:
  -y            Use the auto-detected codec without running the script
                interactively.
  -c <choice>   For codecs with multiple known working choices for the
                runtime AppleHDA codec (target codec) to use,
                this option selects the choice.
                -c 1 lets you select choice #1 (the default),
                -c 2 the second choice, and so on.
  -s <directory>        kext directory to use instead of
                        /System/Library/Extensions
  -r <volume root>      specify an alternate disk volume to use
                        as the root for everything
  -o <os vers number>   override auto-detected OS version (10.7/10.8/10.9)
  -t            run the script in test-only mode,
                where AppleHDA is not actually patched.
Examples:       patch-hda.pl 111d7675
                patch-hda.pl 'IDT 7675'
                patch-hda.pl -c 2 'Realtek ALC892'
		patch-hda.pl -y
Supported codecs:
Target          Target          Patch
Codec ID        Name            Codec Name
-------------------------------------------
10ec0662        Realtek ALC662  ALC 885
111d7603        IDT 7603        ADI 1984
10ec0272        Realtek ALC272  ADI 1984
111d76e0        IDT 76e0        ADI 1984B
10ec0889        Realtek ALC889  Choice 1: ALC 885
                                Choice 2: ADI 1984
111d7675        IDT 7675        ADI 1984
10ec0892        Realtek ALC892  Choice 1: ALC 885
                                Choice 2: ADI 1984B
10ec0883        Realtek ALC883  ALC 885
10ec0270        Realtek ALC270  ADI 1984
11060441        VIA VT2021      ADI 1984
10ec0887        Realtek ALC887  ADI 1984B
11d4989b        ADI AD2000B     ADI 1984B
111d76d1        IDT 76d1        ADI 1984
10ec0269        Realtek ALC269  ADI 1984
10ec0888        Realtek ALC888  ALC 885
10ec0882        Realtek ALC882  ALC 885
111d7605        IDT 7605        ADI 1984B
?[/code]
For interactive use:
[code]% ./patch-hda.pl
OSX version 10.9 detected
Default target codec: 10ec0892 detected.
Enter codec-id or codec-name for AppleHDA patch.  Eg. 111d7675 or IDT 7675
Press enter for default, or ? for help (Default: 10ec0892)
? <enter>
There are 2 choices for target codec
Choose codec number to patch to (1 thru 2) (default 1)
Choice 1: ALC 885
Choice 2: ADI 1984B
? 2
Patching AppleHDA codec 11d4198b with 10ec0892
1 codec range comparison(s) to patch
Patching range comparison 11d41984
This script requires superuser access to update AppleHDA
Password:
/System/Library/Extensions/AppleHDA.kext/Contents/MacOS/AppleHDA patched successfully.
%
[/code]
The new command line argument -y allows you to pick up the auto-detected codec without running the script interactively.  So the non-interactive equivlanet of the above:[code]sudo ./patch-hda.pl -y -c 2[/code]

Note: For some codecs, there are multiple choices for the target codec to patch to.  (See alc889 and alc892 above).  For these codecs, use the command line argument -c to specify which choice you wish to use (or leave the argument off and get choice #1).

B.C.
bcc24x7@gmail.com
