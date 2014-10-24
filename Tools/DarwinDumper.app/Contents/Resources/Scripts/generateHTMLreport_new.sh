#!/bin/sh

# A script to create an html file from a pre-defined directory of files.
# Copyright (C) 2013-2014 Blackosx <darwindumper@yahoo.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#    
# =======================================================================
#
# This script:
# 1- creates and initialises an html report. Two files are written to and
# then combined at the end. The first file contains the header and the css
# which is appended to as the script runs. The second file is built with the
# Javascript and the html. At the end both files are merged in to one.
#
# 2- scans through a pre-defined set of folders and if locating a set file
# will read the file and place the contents in to the html document. Any
# translations that might be required are also done, for example substituting
# spaces for an html non-breaking space to maintain column spacing.
#
# 3- Calculate table column widths and adjusts accordingly depending on the
# width set by the gMasterFrameWidth global variable. At this point in time,
# the overview section has not been set up to resize. This is to be done.
#
# *************************************************************************************
# The script takes 6 arguments passed to it when called.
# 1 - Path       : Directory of DarwinDumper dumps to read.
# 2 - App Name   : This is printed in the title header of the report
#                  Will almost certainly read 'DarwinDumper'.
# 3 - Version    : This is printed in the title header of the report
#                  This will be the current version of 'DarwinDumper'.
# 4 - TableState : A string of either 'none' or 'block'.
# 5 - CodecID    : A string of the audio codec ID to display in the header.
# 6 - Privacy    : A string to instruct the privacy routine to mask sensitive data.
# *************************************************************************************
#
# Thanks to STLVNUB for the idea of using embedded images.

# ---------------------------------------------------------------------------------------
Initialise()
{   
    local passedDirToRead="$1"
    local passedAppName="$2"
    local passedVersion="$3"
    local passedTableState="$4"
    local passedCodecID="$5"
    local passedPrivacyState="$6" 

    # Global Vars - HTML
    gMasterFrameWidth="1060px" # Change this line to alter the width of the html output.
    gTableState="$passedTableState" # default html Sub section (used in DMI Tables / Bootloader Config sections) table state. Use none for collapsed; block for visible
    gCodecID="$passedCodecID"
    gPrivateState="$passedPrivacyState"
    gDataDir="$7"
    declare -i gTableBoxWidth
    declare -i gTableTextBoxWidth
    gColOne=0; gColTwo=0; gColThree=0; gColFour=0; gColFive=0; gColSix=0; gColSeven=0; gColEight=0
    
    # Base64 strings - Images converted at http://webcodertools.com/imagetobase64converter
    privateStamp="data:image/png;base64,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"
    gLogoDD="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAMAUExURQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///wACAAAAACtiLwACAAAAAAASAAAAAJbCmwECAHu0jwUpB3ukeXWxjQAXAAAAAAAEAGWbdAAIAAAMAG+gdwAEAAAAAFGNZQUvBDV2R6jLqCBbMUqGWQQ9B4S8mQAAAIeykICuhwAoAF6QYws8F2CSZh5OIgc5FAtAGgc9FxFJIRFDHk+NY1VVVWCUaRRPJSFRJQ1AGEiJXkSMY0NvQVqPZEqLYRdRKBteMBJMIzVnOGyXa1eMXi5yRVCQZw1DHVWEUzRzR2SUaE5OTmqUZyoqKlKJXFeOYlSFWVF8ThlZLVmIWXKccRtVKzR4TFFRUSdoOmKWa3aedEt8TRpJICFnOB9ZLyJjNShlNjxrOmeXbEmOZERzRU6FV0l0RypULFN/UR9JIBVVKSRaKG+bbhxiNEN4SzxvPyJVJqioqDB2SSJVLD19VEp4SSJNI1hYWAUyDztlPER+TwYnCwxIHyZcKgIbBh9gMV6LXLi6uUWDWU6KX5+goEyQZ2twbCxgMxdLJEWHXCttQDJgMCpeL0KAV02CUEWLXl+MYSdrPitvQixZLTV8ULCwsausrEl/U4CCgZucnGaQZDhhNmulfzJgNyVYLhdFHk92TDAxMBEqFNDQ0CdRJz11R93e3htBHS9oQRIwFC5lNrW1tkpLSsrKyzt4T3F2cszNzT5zQVuSZjFaMFtcW7y8vNfX2EyFXFKSaTl/VDBqOh9PLUV7SilfO0teTmKQXwIGAoaHhzRuPnl6eRg5GUdGR4uNjJaXlpCSkdPT1EJpQCNdNUCJX16GXcXFxaOkpGhoaDs9O7+/wD6DWCJGJ8jHyFmVayVgMipYNxoyISxJMGFiYSA9I+bl5sHCwkFBQD1pQZmonJGilFZnWHCXa1p/WEdtSD9fQpzCm6Gto2yIcGFuY6+3sIacjHWCeDdsRvDy9ANHFzRTN16BaFN0WwlRIIWQhnmWgMTCxD5TQhYZFcPIx4WofcIYPPkAAADEdFJOUwAgLhYSA0sLAQQnAZm1/MYItQL5O/m1/vnGGmD+hqf7ct364vr8+vr6+u7+/Lz///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////6iCSuzAAAgAElEQVR42u2beVxTZ9r3x5a69G2t49jX1q3LTJ+2M/OQsCQiAQMhIUgCFAiRgIQtmECgshMggECAhsgmW8JWFmUH2WQrguyyyiKIUhcUEH3c61KXdt7rPsEW2zjT+bx9/psfh3OfE05yfe/fdd3XST4f8oc//Ef/0Sv0f35v/VvR1/6vzGntv3Hh2nUb1vyu2rBh3W9FgIs2rNmw7ndF2LDhjbXr1qxZ9xsQ1q6F8Os2rFr94fYd//ef6I//nnZs37rpdZjSun9FsPEP69ZsUFv91p95qZv/9j+q9cknn/zP37/+93Qu2enB+9s3gRlr1679p/HB99X/7Uf/G0T506v17nvvvof0rlLvvax3V0p59vnnf/p8W/pnOzZtUFu3duOr469ds+a1HZ+1vvv5e+f2HwbpHz59WClDfX1D2GPb4d37dxpiD2QGcDI5nLadhocMDQ33Gx42jN25E/5kiI0vZLVz556de859/bc//a32s+1b1Da8kmDjWjW11X+2f+/zbbtP797/1Vdf7YFtzzd7vgGh3Vcvtm+++uobeM3pnX+T1BfX37l76PA3y5crn4J2X33z1Z5vzn3zQnu+2rn/3Neff+31/mtqa15BgOJv/Qz/p6+tDM6d23Xu3HEQjMd37dp1fNc+JOUeG+FBy4WWFvlQT05zWf1TurGZG8jYGH7dDsCGtPdnOTjA5nDA4U+fLP150ysIUPwPP9v8P3stDuw98Auh11g+Uv4aGxtbzJXl6Bz59tsvzkzKy+7kHjDe+3JIFHGlEIWD8eZPLP68Wm3NxrUq1t8ata2h296b3r3/9OndoNPKX+x49/7l3xc6vb9NMpy9+LgVctz6eDKnbL4NpQ0u2g8b6CskyNUetN+DnWHHX+35vBU82LDx1/E3qG36s9W7h77ZuX8nPH//flQ5yoxiZaAcl7Xzm+n5sqFH+jHJQUHJMYd23vMve6r/zU50iVJY8s8t66cDdLhn2yfC/16l9sYv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"
    gLogoYos="data:image/png;base64,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"
    gLogoMav="data:image/png;base64,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"
    gLogoML="data:image/png;base64,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"
    gLogoLion="data:image/png;base64,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"
    gLogoSL="data:image/png;base64,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"
    gLogoLeo="data:image/png;base64,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"

    gCollapseDivId=0
    gPageNavLinks=""
    gBootloadersTextbuildString=""
    gVERS="$passedVersion"
    gtheprog="$passedAppName"
    gMasterDumpFolder="$passedDirToRead"
    gLogIndent="          "
    gHtmlDumpFile="$gMasterDumpFolder"/" DarwinDump.htm"
    gCssDumpFile="$gMasterDumpFolder"/CssDumpFile.htm
    gJsDumpFile="$gMasterDumpFolder"/JsDumpFile.js
}

# ---------------------------------------------------------------------------------------
CheckRoot()
{
    if [ "`whoami`" != "root" ]; then
        echo "Running this requires you to be root."
        sudo "$0"
        exit 0
    fi
}

# ---------------------------------------------------------------------------------------
CheckOsVersion()
{
    local osVer=`uname -r`
    local osVer=${osVer%%.*}
    local rootSystem=""
    
    if [ "$osVer" == "8" ]; then
	    rootSystem="Tiger"
    elif [ "$osVer" == "9" ]; then
	    rootSystem="LEO"
    elif [ "$osVer" == "10" ]; then
	    rootSystem="SL"
    elif [ "$osVer" == "11" ]; then
	    rootSystem="Lion"
    elif [ "$osVer" == "12" ]; then
	    rootSystem="ML"
	elif [ "$osVer" == "13" ]; then
	    rootSystem="Mav"
	elif [ "$osVer" == "14" ]; then
	    rootSystem="Yos" # Speculated
	else 
	    rootSystem="Unknown"
    fi
    echo "$rootSystem"  # This line acts as a return to the caller.
}

#
# =======================================================================================
# WRITE HTML, CSS, JAVASCRIPT & RELATED CODE ROUTINES
# =======================================================================================
#

# ---------------------------------------------------------------------------------------
CloseHtmlFile()
{
    echo "Closing HTML"
    WriteHtmlClearLineToFile
    WriteHtmlFooterToFile
    WriteHtmlCloseBodyDivToFile
    WriteHtmlCloseSectionCollapseExpandDivToFile
}

# ---------------------------------------------------------------------------------------
CloseCssFile()
{
    echo "Closing CSS"
    echo "</style>" >> "$gCssDumpFile"
}

# ---------------------------------------------------------------------------------------
CombineCssJsAndHtmlFiles()
{
    echo "Appending Javascript to CSS file"
    cat "$gJsDumpFile" >> "$gCssDumpFile"
    rm "$gJsDumpFile"
    echo "Appending HTML to Javascript and CSS file"
    cat "$gHtmlDumpFile" >> "$gCssDumpFile"
    rm "$gHtmlDumpFile"
    echo "Renaming CSS file to HTML file"
    mv "$gCssDumpFile" "$gHtmlDumpFile" 
}

# ---------------------------------------------------------------------------------------
WriteHtmlHeaderToFile()
{
    local passedDirToRead="$1"
    
    echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
<meta name=\"description\" content=\"DarwinDumper Report of OS X System\" />
<meta name=\"author\" content=\"Trauma, JrCs, sonotone, phcoder, STLVNUB, blackosx\" />
<meta name=\"keywords\" content=\"osx, system dump, acpi tables, device properties, disk util, disk partitions, bootloaders, memory map, ioreg, kernel dmesg log, kexts, lspci, rtc, smbios, smc, systemprofiler, video bios\" />
<meta name=\"copyright\" content=\"Copyright 2010-2013 org.darwinx86.app. All rights reserved.\">
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<title>$passedDirToRead</title>" >> "$gCssDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteCssToFile()
{
    echo "<style type=\"text/css\">
body { font-family: Tahoma, Lucida Grande, Lucida Sans Unicode; font-size: 11px; background-color: #666; }
#container { width: 1100px; padding:0; margin:0 auto; background: #FFF; box-shadow: 0px 3px 20px rgba(0, 0, 0, 0.75); }
#overview_container_outer { width: 100%; margin: 0; padding: 0; border: 0; }
#overview_container_inner { width: auto; height: 140px; padding: 20px; }
#overview_topBand { width: 100%; height:190px; background-color:#293840; } /* #1BA4C5; } */
#overview_panel_logo{ width: 148px; float: left; background-repeat: no-repeat; background-position: center center; height: 148px; background-image: url($gLogoDD);}
#overview_panel_title{ width: 55%; float: left; margin: 20px 10px 6px; }
#overview_panel_date{ width: 25%; float: right; margin: 27px 10px 6px; text-align: right; }
#overview_panel_one{ width: 350px; float: left; height: 74px; margin: 10px; border-right-width: 1px; border-right-style: solid; border-right-color: #999; color: #DDD; }
#overview_panel_two{ width: 310px; float: left; height: 74px; margin: 10px 10px 10px 30px; border-right-width: 1px; border-right-style: solid; border-right-color: #999; color: #DDD; overflow:auto; }
#overview_panel_three{ width: 160px; float: right; margin: 10px; height: 64px; margin: 10px 10px 10px 5px; text-align: right; color: #DDD; }
#overview_logo_yos{ width: 32px; float: left; height: 32px; margin: 10px; background-image: url($gLogoYos); }
#overview_logo_mav{ width: 32px; float: left; height: 32px; margin: 10px; background-image: url($gLogoMav); }
#overview_logo_ml{ width: 32px; float: left; height: 32px; margin: 10px; background-image: url($gLogoML); }
#overview_logo_lion{ width: 32px; float: left; height: 32px; margin: 10px; background-image: url($gLogoLion); }
#overview_logo_sl{ width: 32px; float: left; height: 32px; margin: 10px; background-image: url($gLogoSL); }
#overview_logo_leo{ width: 32px; float: left; height: 32px; margin: 10px; background-image: url($gLogoLeo); }
#clear_Line { clear: both; height: 20px; background-color: #FFF; width: auto; } 
#dump_container { width: 1060px; margin:0 auto; }
#note { padding: 8px; background-color: #bad0d4; } /* #5ea33b; } */

td { word-wrap: break-word; }
tr { font-family: Menlo; font-size: 10px; }

#dump_section_inner_table_header2 { background-color: #666; width: auto; height: 26px; border: 1px solid #555; border-bottom-width: 0px; }
#dump_section_inner_table_header2 a:link, #dump_section_inner_table_header2 a:visited { color: #00FFFF;  text-decoration: none; }
#dump_section_inner_table_header2 a:hover { text-decoration: underline; }
#dump_section_inner_table_subheader_info { background-color: #CCC; width: auto; padding: 3px 0px 3px 10px; border-right: 1px solid #666; border-left: 1px solid #666; }
#dump_section_inner_table_content_container { background-color: #EEE; width: auto; padding: 5px 0px 5px 10px; border: 1px solid #7B7B7B; border-top: 0px; }
#dump_section_inner_table_content_container_scroll { background-color: #EEE; width: auto; padding: 5px 0px 5px 10px; border-left:1px solid #7B7B7B; border-right:1px solid #7B7B7B; height: 400px; overflow: auto; }
#footer { background-color: #d3d7d9; width: auto; height: 50px; padding: 10px; text-align: center; }

.text_medium_section_inner_title { font-size: 12px; font-weight: bold; color: #FFF; position: relative; left: 10px; top: 5px; }
.text_small_section_inner_title { font-size: 12px; font-family: Tahoma; font-weight: normal; color: #000; }
.text_small_section_inner_title a:link, .text_small_section_inner_title a:visited { color: #1F76B3; text-decoration: none;  } 
.text_small_section_inner_title a:hover { text-decoration: underline; }
.text_overview_heading { font-size: 20px; font-weight: bold; color: #FFF; }
.text_overview_version { font-size: 12px; line-height: 18px; color: #AAA; }
.text_overview_body { font-size: 12px; line-height: 18px; }

#overview_container_inner a:link, #overview_container_inner a:visited { color: #60bed6; text-decoration: none; }
#overview_container_inner a:hover { text-decoration: underline; }
#footer a:link, #footer a:visited { color: #1f76b3; text-decoration: none; }
#footer a:hover { text-decoration: underline; }

.text_table_heading { font-family: Menlo, Monaco, Courier New; font-size: 10px; font-weight: bold; }
.text_table { font-family: Menlo, Monaco, Courier New; font-size: 10px; }
.text_note { font-family: Tahoma, Geneva, sans-serif; font-size: 12px; text-align: center; color: #444; }
.text_footer { font-family: Tahoma, Geneva, sans-serif; font-size: 10px; line-height:14px; }
.state { display: none; }
a.make_div_clickable { display: block; height: 100%; width: 100%; }
" >> "$gCssDumpFile"

cat "$gDataDir/jquery-ui-1.10.4.custom.min.css" >> "$gCssDumpFile"

echo "
/* Overrides for jqueryUI theme */

.ui-accordion .ui-accordion-header {
  margin-top: 0;
  border-bottom: none;
}

.ui-accordion .ui-accordion-content {
    padding: 0; /* remove default padding to increase overall space */
}

.ui-tabs {
    padding: 0; /* remove default padding to increase overall space */
    border: none;
}

.ui-tabs .ui-tabs-nav .ui-tabs-anchor { /* Style the tabs */
    font-size: 11px;
    padding: 4px 8px 4px 8px;
}

.ui-tabs .ui-tabs-panel {
    padding: 0; /* remove default padding to increase overall space */
}

ul.ui-tabs-nav li.ui-state-default {
    border: none; /* Remove border around tabs */
}

.ui-tabs-anchor:focus { /* Target the focus of the currently selected tab */
    outline-width: 0px; /* Safari's user agent stylesheet add's a border - here we remove that border */
}

.ui-icon-triangle-1-s, .ui-icon-triangle-1-e {
    display: none; /* As we're not using the image file, then hide arrows at left of section headings */
}

h3 {
    padding-left: 10px !important; /* close the space left for the arrow images that we're not using */
}" >> "$gCssDumpFile"

}

# ---------------------------------------------------------------------------------------
WriteDiskPartitionCssToFile()
{
    echo "/* disk partition view items */

/* Top bar to hold disk name, size, partition table etc. */
#diskView_inner_table_subheader_info { background-color: #444; width: auto; padding: 3px 0px 3px 10px; border: 1px solid #666; border-top: 0px; border-bottom: 0px; }
.text_small_section_inner_title_White { font-size: 12px; font-weight: normal; color: #FFF; line-height: 18px; font-family: Tahoma; }

/* Main grey box for the Disk page */
#diskView_dd_frame { width: $gMasterFrameWidth; background-color: #555; margin: 0 auto 0 auto; padding: 0px 0px 5px 0px; overflow:hidden; height:1%; }

/* Left side box to hold the partition table */
#diskViewTable { width: 620px; min-height:676px; height: 98%; background-color: #3a3a3a; padding: 0px 0px 5px 0px; border: 1px solid #222; float:left; }

/* table */
.t             { display: table; border-spacing: 0px; width: 620px; }

/* table row */
.tr            { display: table-row; font-family: Menlo; font-size: 10px; color: #FFF; }

/* table cells - GPT */
.gpt_tc_Start_lba  { width: 60px;  display:table-cell; padding: 5px 10px 0px 0px; vertical-align: top;    text-align: right; }
.gpt_tc_Active     { width: 5px;   display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; }
.gpt_tc_Mbr_Pe     { width: 114px; display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; text-align: center; }
.gpt_tc_Type       { width: 220px; display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; text-align: center; }
.gpt_tc_Loader     { width: 100px;  display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; text-align: center; }

/* table cells - MBR */
.mbr_tc_Start_lba  { width: 60px;  display:table-cell; padding: 5px 10px 0px 0px; vertical-align: top;    text-align: right; }
.mbr_tc_Active     { width: 5px;   display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; }
.mbr_tc_Type       { width: 314px; display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; text-align: center; }
.mbr_tc_Loader     { width: 80px;  display:table-cell; padding: 0px  0px 0px 0px; vertical-align: middle; text-align: center; }

/* fill for Header Bar */
#headerBar                             { background-color: #272727; height:26px; color: #FFF; }

/* fills for partition types */
/* Note: I've made all FAT partition types the same colour as Windows Basic Data (see http://en.wikipedia.org/wiki/Basic_data_partition) */
#fillMBR                               { background-color: #68802f; border-top-color: #8d9f62; border-bottom-color: #45551f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillMBR:hover                         { background-color: #90a457; border-top-color: #afbd8b; border-bottom-color: #6f7f43; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillEBR                               { background-color: #68802f; border-top-color: #8d9f62; border-bottom-color: #45551f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillEBR:hover                         { background-color: #90a457; border-top-color: #afbd8b; border-bottom-color: #6f7f43; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillPrimaryGPTHeader                  { background-color: #6e6440; border-top-color: #918a6e; border-bottom-color: #49432b; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillPrimaryGPTHeader:hover            { background-color: #958c6a; border-top-color: #b2ac95; border-bottom-color: #736d52; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillPrimaryGPTHeaderTop               { background-color: #6e6440; border-top-color: #918a6e; border-bottom-color: #6e6440; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillPrimaryGPTHeaderMid               { background-color: #6e6440; border-top-color: #6e6440; border-bottom-color: #6e6440; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; line-height: 6px; }
#fillPrimaryGPTHeaderBot               { background-color: #6e6440; border-top-color: #6e6440; border-bottom-color: #49432b; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillPrimaryGPTTable                   { background-color: #5b4f25; border-top-color: #837a5a; border-bottom-color: #5b4f25; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillPrimaryGPTTable:hover             { background-color: #84794b; border-top-color: #a79f83; border-bottom-color: #675e3a; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillBackupGPTHeader                   { background-color: #6e6440; border-top-color: #918a6e; border-bottom-color: #49432b; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillBackupGPTHeader:hover             { background-color: #958c6a; border-top-color: #b2ac95; border-bottom-color: #736d52; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillBackupGPTTable                    { background-color: #5b4f25; border-top-color: #837a5a; border-bottom-color: #5b4f25; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillBackupGPTTable:hover              { background-color: #84794b; border-top-color: #a79f83; border-bottom-color: #675e3a; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillEFISystemPartition                { background-color: #9f905c; border-top-color: #b6ab84; border-bottom-color: #6a603d; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillEFISystemPartition:hover          { background-color: #bdb185; border-top-color: #cec6a8; border-bottom-color: #928967; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT12                             { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT12:hover                       { background-color: #8087bc; border-top-color: #a4a8ce; border-bottom-color: #626991; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT16                             { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT16:hover                       { background-color: #8087bc; border-top-color: #a4a8ce; border-bottom-color: #626991; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT16LBA                          { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT16LBA:hover                    { background-color: #8087bc; border-top-color: #a4a8ce; border-bottom-color: #626991; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT32                             { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT32:hover                       { background-color: #8087bc; border-top-color: #a4a8ce; border-bottom-color: #626991; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT32LBA                          { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFAT32LBA:hover                    { background-color: #8087bc; border-top-color: #a4a8ce; border-bottom-color: #626991; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNTFS                              { background-color: #198abf; border-top-color: #51a6cf; border-bottom-color: #115c7f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNTFS:hover                        { background-color: #3aacd4; border-top-color: #7bc2df; border-bottom-color: #2c85a4; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillMicrosoftReservedPartition        { background-color: #8f8f8f; border-top-color: #c9c9c9; border-bottom-color: #5f5f5f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillMicrosoftReservedPartition:hover  { background-color: #81a5ab; border-top-color: #a5bec1; border-bottom-color: #648084; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillWindowsBasicData                  { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillWindowsBasicData:hover            { background-color: #8087bc; border-top-color: #a4a8ce; border-bottom-color: #626991; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillWindowsRecoveryEnvironment        { background-color: #299889; border-top-color: #5db1a6; border-bottom-color: #1b655b; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillWindowsRecoveryEnvironment:hover  { background-color: #3dcec0; border-top-color: #8be1d9; border-bottom-color: #289688; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillHFS                               { background-color: #a92ea9; border-top-color: #be61be; border-bottom-color: #711f71; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillHFS:hover                         { background-color: #c456c4; border-top-color: #d38ad3; border-bottom-color: #984398; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillOSXBoot                           { background-color: #a13b66; border-top-color: #b86b8b; border-bottom-color: #6b2744; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillOSXBoot:hover                     { background-color: #be648e; border-top-color: #cf93ad; border-bottom-color: #934d6e; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillCoreStorage                       { background-color: #8649a0; border-top-color: #a375b7; border-bottom-color: #59316b; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillCoreStorage:hover                 { background-color: #a973be; border-top-color: #c09bce; border-bottom-color: #825993; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillAppleRAID                         { background-color: #d363d3; border-top-color: #de89de; border-bottom-color: #8d428d; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillAppleRAID:hover                   { background-color: #e28ce2; border-top-color: #e9ace9; border-bottom-color: #af6caf; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillLinux                             { background-color: #bb841a; border-top-color: #cca252; border-bottom-color: #7d5811; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillLinux:hover                       { background-color: #d1a83c; border-top-color: #ddbf7c; border-bottom-color: #a2812c; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillLinuxSwap                         { background-color: #af5e22; border-top-color: #c28558; border-bottom-color: #753f17; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillLinuxSwap:hover                   { background-color: #c98747; border-top-color: #d6a881; border-bottom-color: #9b6937; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFreeBSD                           { background-color: #410e54; border-top-color: #6f497e; border-bottom-color: #2b0938; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillFreeBSD:hover                     { background-color: #6b257e; border-top-color: #9673a3; border-bottom-color: #521961; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillOpenBSD                           { background-color: #2f0e54; border-top-color: #62497e; border-bottom-color: #1f0938; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillOpenBSD:hover                     { background-color: #57257e; border-top-color: #8b73a3; border-bottom-color: #431961; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNetBSD                            { background-color: #540e43; border-top-color: #7e4971; border-bottom-color: #38092d; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNetBSD:hover                      { background-color: #7e256d; border-top-color: #a37398; border-bottom-color: #611954; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillSyncError                         { background-color: #d11212; border-top-color: #dc4c4c; border-bottom-color: #8b0c0c; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillSpace                             { background-color: #565656; border-top-color: #424242; border-bottom-color: #565656; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; line-height: 6px; }
#fillBlank                             { background-color: #3a3a3a; border-top-color: #3a3a3a; border-bottom-color: #3a3a3a; border-left-color: #3a3a3a; border-right-color: #3a3a3a; border-width: 2px; border-style: solid; line-height: 6px; }

/* fills for partition types (as abaove) without hover */
#fillNoHoverMBR                        { background-color: #68802f; border-top-color: #8d9f62; border-bottom-color: #45551f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverEBR                        { background-color: #68802f; border-top-color: #8d9f62; border-bottom-color: #45551f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverFAT12                      { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverFAT16                      { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverFAT16LBA                   { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverFAT32                      { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverFAT32LBA                   { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverNTFS                       { background-color: #198abf; border-top-color: #51a6cf; border-bottom-color: #115c7f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverMicrosoftReservedPartition { background-color: #8f8f8f; border-top-color: #c9c9c9; border-bottom-color: #5f5f5f; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverWindowsBasicData           { background-color: #565e9e; border-top-color: #7f85b6; border-bottom-color: #393f69; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverHFS                        { background-color: #a92ea9; border-top-color: #be61be; border-bottom-color: #711f71; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverOSXBoot                    { background-color: #a13b66; border-top-color: #b86b8b; border-bottom-color: #6b2744; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverCoreStorage                { background-color: #8649a0; border-top-color: #a375b7; border-bottom-color: #59316b; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverAppleRAID                  { background-color: #d363d3; border-top-color: #de89de; border-bottom-color: #8d428d; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverLinux                      { background-color: #bb841a; border-top-color: #cca252; border-bottom-color: #7d5811; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverLinuxSwap                  { background-color: #af5e22; border-top-color: #c28558; border-bottom-color: #753f17; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverSyncError                  { background-color: #d11212; border-top-color: #dc4c4c; border-bottom-color: #8b0c0c; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; padding: 2px 0 2px 0; }
#fillNoHoverSpace                      { background-color: #565656; border-top-color: #424242; border-bottom-color: #565656; border-left-color: #333; border-right-color: #333; border-width: 2px; border-style: solid; line-height: 6px; }
#fillNoHoverBlank                      { background-color: #3a3a3a; border-top-color: #3a3a3a; border-bottom-color: #3a3a3a; border-left-color: #3a3a3a; border-right-color: #3a3a3a; border-width: 2px; border-style: solid; line-height: 6px; }
#fillNoHoverxx                         { background-color: #222222; border-top-color: #222222; border-bottom-color: #222222; border-left-color: #3a3a3a; border-right-color: #3a3a3a; border-width: 2px; border-style: solid; line-height: 6px; }

/* fills for loader and active partition */
#loader                                { background-color: #86c205; border-top-color: #add655; border-bottom-color: #598103; border-top-width: 2px; border-top-style: solid; border-bottom-width: 2px; border-bottom-style: solid; padding: 2px 0 2px 0; font-size: 8px; color: #000; }
/* #loader:hover                          { background-color: #a9d60e; border-top-color: #c7e47f; border-bottom-color: #82a509; border-top-width: 2px; border-top-style: solid; border-bottom-width: 2px; border-bottom-style: solid; padding: 2px 0 2px 0; font-size: 8px; color: #000; } */
#activePart                            { background-color: #edea0d; border-top-color: #f3f15b; border-bottom-color: #9e9c09; border-top-width: 2px; border-top-style: solid; border-bottom-width: 2px; border-bottom-style: solid; padding: 2px 0 2px 0; }

/* Right Side */
#diskInfoHexTableBox { height: 438px; width: 420px; background-color: #3a3a3a; margin-top: 0px; padding: 0px 5px 5px 5px; border: 1px solid #222; float:right; font-family: Menlo; font-size: 10px; color: #FFF; overflow-y:auto;}
#diskInfoDetailsBox  { width: 420px; background-color: #3a3a3a; margin-top: 5px; padding: 0px 5px 5px 5px; border: 1px solid #222; float:right; font-family: Menlo; font-size: 10px; color: #FFF; overflow-y:auto; }

/* Right Side Header Text */
.rsText_Body      { font-size: 12px; color: #FFF; line-height: 5px; }
.rsText_BodyBold  { font-size: 12px; font-weight: bold; color: #FC3; line-height: 10px; }
.rsText_HexTable  { font-size: 12px; color: #FFF; line-height: 12px; }

/* end disk partition view items */
" >> "$gCssDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteIECssToFile()
{
    echo "<!--[if IE]>
<style type=\"text/css\">
  #nav ul { margin-left:0px;}
  .text_table { font-family: \"Courier New\", Courier, monospace; font-size: 11px; }
  .text_large_section_outer_title { font-family:Arial; font-size:14px; font-weight:bold; }
  .text_medium_section_inner_title { font-family:Arial; }
  .text_small_section_inner_title_White { font-family:Arial; }
  #diskInfoHexTableBox { font-family: \"Courier New\", Courier, monospace; font-size: 10px; }
  #diskInfoDetailsBox  { font-family: \"Courier New\", Courier, monospace; font-size: 11px; }
  .rsText_Body      { font-size: 14px; line-height: 10px; }
  .rsText_BodyBold  { font-size: 14px; line-height: 10px; padding-top: 8px; }
  .rsText_HexTable  { font-size: 14px; line-height: 12px; }
</style>
<![endif]-->" >> "$gCssDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteJavaScriptToFile()
{
    # Add jQuery min from file
    echo "
<script type=\"text/javascript\">" >> "$gJsDumpFile"
    cat "$gDataDir/jquery-1.11.1.min.js" >> "$gJsDumpFile"
    echo "
</script>" >> "$gJsDumpFile"
    
    # Add jQueryUI min from file
    echo "
<script>" >> "$gJsDumpFile"
    cat "$gDataDir/jquery-ui-1.10.4.custom.min.js" >> "$gJsDumpFile"
    echo "
</script>" >> "$gJsDumpFile"

    echo "

<script type=\"text/javascript\">
\$(function() {
  \$( \"#accordion\" ).accordion({
      heightStyle: \"content\",
      active: false,
      collapsible: true,
      animate: {
        duration: 150
    }
  });
});
function navShowHeaderBar(divID, state)
{
    var table = document.getElementById(divID);
    table.style.display = 'block';
}
function headerBarToggleShowHide(divID, state)
{
    var table = document.getElementById(divID);
    table.style.display = table.style.display == 'none' ? 'block' : 'none';
}
</script>" >> "$gJsDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteJavaScriptJqueryUITabToFile()
{
    local passedTabName="$1"
    echo "<script type=\"text/javascript\">
\$(function() {
  \$( \"#tabs_$passedTabName\" ).tabs();
});
</script>
" >> "$gJsDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlClearLineToFile()
{
    echo "<div id=\"clear_Line\"></div>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlFooterToFile()
{
    echo "<div id=footer> <span class=\"text_footer\"><a href=\"https://bitbucket.org/blackosx/darwindumper\" target=\"_blank\">DarwinDumper</a> is licensed under <a href=\"http://opensource.org/licenses/GPL-3.0\" target=\"_blank\">GPL v3</a>. The individual programs used to collect and decode some of the data each come under <a href=\"http://bit.ly/1ksKSGY\" target=\"_blank\">their own respective licences</a>.<br />The DarwinDumper scripts and tools are enclosed in a <a href=\"http://sveinbjorn.org/platypus/\" target=\"_blank\">Platypus</a> application wrapper and uses <a href=\"https://bitbucket.org/blackosx/macgap\" target=\"_blank\">macgap</a> for it's user interface for gathering user input.</span></div>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
CalculateTableWidths()
{
    local passedOutputType="$1"
    
    # This uses the gMasterFrameWidth set at the head of this file.
    local gContainerWidth=${gMasterFrameWidth%px*}
    gTableBoxWidth=$((gContainerWidth-20))
    gTableTextBoxWidth=$((gTableBoxWidth-6))

    # Calculate percentage widths of table columns, then add 100.
    if [ "$passedOutputType" == "DiskDump" ]; then
        # Original design pixel widths were 53, 66, 142, 181, 58, 146, 90, 204
        # New design pixel widths are 35, 60, 165, 162, 47, 130, 186, 161
        # To fit UEFI revisions, let's try widths of 30, 57, 160, 157, 45, 125, 180, 180
        # Latest squeeze to fit better, let's try widths of 7, 56, 139, 163, 50, 120, 214, 205
        local gColOnePcToUse=$(bc <<< 'scale=3; 7 / '$gTableTextBoxWidth' * 100 + 100')
        local gCoTwoPcToUse=$(bc <<< 'scale=3; 56 / '$gTableTextBoxWidth' * 100 + 100')
        local gColThreePcToUse=$(bc <<< 'scale=3; 139 / '$gTableTextBoxWidth' * 100 + 100')
        local gColFourPcToUse=$(bc <<< 'scale=3; 163 / '$gTableTextBoxWidth' * 100 + 100')
        local gColFivePcToUse=$(bc <<< 'scale=3; 50 / '$gTableTextBoxWidth' * 100 + 100')
        local gColSixPcToUse=$(bc <<< 'scale=3; 120 / '$gTableTextBoxWidth' * 100 + 100')
        local gColSevenPcToUse=$(bc <<< 'scale=3; 214 / '$gTableTextBoxWidth' * 100 + 100')
        local gColEightPcToUse=$(bc <<< 'scale=3; 205 / '$gTableTextBoxWidth' * 100 + 100')
    fi
    
    if [ "$passedOutputType" == "KextDump" ]; then
        # Original design pixel widths were 34, 34, 108, 68, 68, 341, 89, 170
        local gColOnePcToUse=$(bc <<< 'scale=3; 32 / '$gTableTextBoxWidth' * 100 + 100')
        local gCoTwoPcToUse=$(bc <<< 'scale=3; 32 / '$gTableTextBoxWidth' * 100 + 100')
        local gColThreePcToUse=$(bc <<< 'scale=3; 108 / '$gTableTextBoxWidth' * 100 + 100')
        local gColFourPcToUse=$(bc <<< 'scale=3; 66 / '$gTableTextBoxWidth' * 100 + 100')
        local gColFivePcToUse=$(bc <<< 'scale=3; 66 / '$gTableTextBoxWidth' * 100 + 100')
        local gColSixPcToUse=$(bc <<< 'scale=3; 349 / '$gTableTextBoxWidth' * 100 + 100')
        local gColSevenPcToUse=$(bc <<< 'scale=3; 89 / '$gTableTextBoxWidth' * 100 + 100')
        local gColEightPcToUse=$(bc <<< 'scale=3; 170 / '$gTableTextBoxWidth' * 100 + 100')
    fi

    # Calculate pixel width to use based on percentage of total width.
    gColOne=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColOnePcToUse' - '$gTableTextBoxWidth' ')
    gColTwo=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gCoTwoPcToUse' - '$gTableTextBoxWidth' ')
    gColThree=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColThreePcToUse' - '$gTableTextBoxWidth' ')
    gColFour=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColFourPcToUse' - '$gTableTextBoxWidth' ')
    gColFive=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColFivePcToUse' - '$gTableTextBoxWidth' ')
    gColSix=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColSixPcToUse' - '$gTableTextBoxWidth' ')
    gColSeven=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColSevenPcToUse' - '$gTableTextBoxWidth' ')
    gColEight=$(bc <<< 'scale=3; '$gTableTextBoxWidth' / 100 * '$gColEightPcToUse' - '$gTableTextBoxWidth' ')
}

# ---------------------------------------------------------------------------------------
WriteHtmlCloseHeadToFile()
{
    echo "</head>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlOpenBodyOpenDivToFile()
{
    if [ -d "$gDumpFolderIoreg/IORegViewer/Resources/dataFiles" ]; then
        echo "<body bgcolor=\"#666\">
<div id=\"container\">" >> "$gHtmlDumpFile"
    else
        echo "<body bgcolor=\"#666\">
<div id=\"container\">" >> "$gHtmlDumpFile"
    fi
}

# ---------------------------------------------------------------------------------------
WriteHtmlCloseBodyDivToFile()
{
    echo "</div> <!-- End container -->
</body>
</html>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlSectionAnchorToFile()
{
    local passedAnchor="$1"
    
    echo "<a name=\"$passedAnchor\"></a>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlSectionHeadingToFile()
{
    local passedSectionHeading="$1"
    
    echo "<span class=\"text_large_section_outer_title\">$passedSectionHeading</span>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteOuterH3()
{
    local passeOuterHeading="$1" # Used for the table title.
    echo "<h3>$passeOuterHeading</h3>
<div>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteEndingH3()
{
    echo "</div> <!-- End h3 -->" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlCloseSectionOuterDivToFile()
{    
    echo "</div> <!-- End sectionname -->" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlCloseSectionCollapseExpandDivToFile()
{    
    echo "</div> <!-- End Outer Section Collapse/Expand div-->" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
# The dark grey header bar under the main (coloured) section bar - Non Collapsable
WriteHtmlTableHeaderToFile()
{
    local passedTableHeading="$1"
    
    echo "<div id=\"dump_section_inner_table_header2\">
  <span class=\"text_medium_section_inner_title\">$passedTableHeading</span>
</div>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
ReadDirCreateTabsAddFileData()
{
    local passedDirToRead="$1"
    local tabname="$2"
    local files=()
    local filesExtensionRemoved=()
    local count=0
    local tmp
    local infoString=""
    
    WriteJavaScriptJqueryUITabToFile "$tabname"

    # Check if Directory is not empty.
    if [ "$(ls -A "${passedDirToRead}")" ]; then
    
        # Build list of file names
        for file in "$passedDirToRead"/*
        do
            # Check for, and exclude, files we don't want to include in the report (for example, .rom)
            local lastFour=$( echo -n "$file" | tail -c 5 )
            if [ ! "$lastFour" == ".rom" ]; then
                files+=("${file##*/}")
                tmp="${files[$count]%.txt*}"
                tmp="${tmp%.dsl*}"
                filesExtensionRemoved+=("$tmp")
                ((count++))
            fi
        done

        if [ $count -gt 0 ]; then
            # Write tabs to file
            echo "<div id=\"tabs_${tabname}\">
  <ul>" >> "$gHtmlDumpFile"
            for (( n=0; n<$count; n++ ))
            do
                echo "    <li><a href=\"#tabs_${tabname}-$((n+1))\">${filesExtensionRemoved[$n]}</a></li>" >> "$gHtmlDumpFile"
            done
            echo  "</ul>" >> "$gHtmlDumpFile"
                    
            # Write html to file
            for (( n=0; n<$count; n++ ))
            do

                # Match details for printing about the tool/dump.
                # Include all tables names from iasl -ht and also other sources.
                case "$tabname" in
                    "acpitableinfo") case ${filesExtensionRemoved[$n]} in
                                         AAFT) infoString="ASRock OEM AAFT Table" ;;
                                         APIC) infoString="Multiple APIC Description Table" ;;
                                         APIC*) infoString="Multiple APIC Description Table" ;;
                                         ASF!) infoString="Alert Standard Format Table" ;;
                                         BERT) infoString="Boot Error Record Table" ;;
                                         BGRT) infoString="Boot Graphics Resource Table" ;;
                                         BOOT) infoString="Simple Boot Flag Table" ;;
                                         CPEP) infoString="Corrected Platform Error Polling Table" ;;
                                         CSRT) infoString="Core System Resources Table" ;;
                                         DBG2) infoString="Debug Port Table 2" ;;
                                         DBGP) infoString="Debug Port Table" ;;
                                         DMAR) infoString="DMA Remapping Table" ;;
                                         DSDT) infoString="Differentiated System Description Table" ;;
                                         ECDT) infoString="Embedded Controller Boot Table" ;;
                                         EINJ) infoString="Error Injection Table" ;;
                                         ERST) infoString="Error Record Serialization Table" ;;
                                         ETDT) infoString="Event Timer Description Table (Obsolete)" ;;
                                         FACP) infoString="Fixed ACPI Description Table" ;;
                                         FACS) infoString="Firmware ACPI Control Structure" ;;
                                         FADT) infoString="Fixed ACPI Description Table" ;;
                                         FPDT) infoString="Firmware Performance Data Table" ;;
                                         GTDT) infoString="Generic Timer Description Table" ;;
                                         HEST) infoString="Hardware Error Source Table" ;;
                                         HPET) infoString="High Precision Event Timer Table" ;;
                                         IBFT) infoString="iSCSI Boot Firmware Table" ;;
                                         IVRS) infoString="I/O Virtualization Reporting Structure" ;;
                                         MADT) infoString="Multiple APIC Description Table" ;;
                                         MCFG) infoString="PCI Express memory mapped configuration space base address Description Table" ;;
                                         MCHI) infoString="Management Controller Host Interface Table" ;;
                                         MPST) infoString="Memory Power State Table" ;;
                                         MSCT) infoString="Maximum System Characteristics Table" ;;
                                         MSDM) infoString="Microsoft Data Management Table" ;;
                                         MTMR) infoString="MID Timer Table" ;;
                                         OEM*) infoString="OEM Specific Information Tables" ;;
                                         PCCT) infoString="Platform Communications Channel Table" ;;
                                         PMTT) infoString="Platform Memory Topology Table" ;;
                                         PSDT) infoString="Persistent System Description Table" ;;
                                         RASF) infoString="ACPI RAS Feature Table" ;;
                                         RSDP) infoString="Root System Description Pointer" ;;
                                         RSDT) infoString="Root System Description Table" ;;
                                         S3PT) infoString="S3 Performance Table" ;;
                                         SBST) infoString="Smart Battery Specification Table" ;;
                                         SLIC) infoString="Microsoft Software Licensing Table Specification" ;;
                                         SLIT) infoString="System Locality Distance Information Table" ;;
                                         SPCR) infoString="Serial Port Console Redirection Table" ;;
                                         SPMI) infoString=" Server Platform Management Interface Table" ;;
                                         SRAT) infoString="System Resource Affinity Table" ;;
                                         SSDT) infoString="Secondary System Description Table" ;;
                                         SSDT*) infoString="Secondary System Description Table" ;;
                                         TCPA) infoString="Trusted Computing Platform Alliance Capabilities Table" ;;
                                         TPM2) infoString="Trusted Platform Module 2 Table" ;;
                                         UEFI) infoString="UEFI ACPI Data Table" ;;
                                         VRTC) infoString="Virtual Real-Time Clock Table" ;;
                                         WAET) infoString="Windows ACPI Eemulated Devices Table" ;;
                                         WDAT) infoString="Watchdog Action Table" ;;
                                         WDDT) infoString="Watchdog Description Table" ;;
                                         WDRT) infoString="Watchdog Resource Table" ;;
                                         WPBT) infoString="Windows Platform Binary Table" ;;
                                         XSDT) infoString="Extended System Description" ;;
                                         *) infoString="Unknown table description."
                                     esac ;;
                    "biosVideo")  infoString="Decoded using <a href=\"http://bit.ly/15YTV9f\" target=\"_blank\">Andy Vandijck's</a> updated version of <a href=\"http://bit.ly/hTxytX\" target=\"_blank\">dong's</a> radeon_bios_decode tool" ;;
                    "lspciinfo")  if [ "${filesExtensionRemoved[$n]}" == "lspci (nnvv)" ]; then
                                      infoString="Numbers & names view. Dumped using pciutils v3.2.0 by Martin Mares. <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2480\" target=\"_blank\">OS X port by THe KiNG.</a> This version compiled by xsmile."
                                  elif [ "${filesExtensionRemoved[$n]}" == "lspci detailed (nnvvbxxxx)" ]; then
                                      infoString="Bus centric view - Extended hex dump. Dumped using pciutils v3.2.0 by Martin Mares. <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2480\" target=\"_blank\">OS X port by THe KiNG.</a> This version compiled by xsmile."
                                  elif [ "${filesExtensionRemoved[$n]}" == "lspci tree (nnvvt)" ]; then
                                      infoString="Tree view. Dumped using pciutils v3.2.0 by Martin Mares. <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2480\" target=\"_blank\">OS X port by THe KiNG.</a> This version compiled by xsmile."
                                  elif [ "${filesExtensionRemoved[$n]}" == "lspci map (M)" ]; then
                                      infoString="Map view. Dumped using pciutils v3.2.0 by Martin Mares. <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2480\" target=\"_blank\">OS X port by THe KiNG.</a> This version compiled by xsmile."
                                  fi ;;
                    "kernellogs") if [ ${filesExtensionRemoved[$n]} == "AppleSystemLog" ]; then
                                      infoString="Dumped from the log file in /var/log/asl/ created last time this system was booted."
                                  elif [ ${filesExtensionRemoved[$n]} == "dmesg" ]; then
                                      infoString="Dumped using /sbin/dmesg"
                                  fi ;;
                    "kernelinfo") if [ ${filesExtensionRemoved[$n]} == "kernel_version" ]; then
                                      infoString="Dumped using uname -v"
                                  elif [ ${filesExtensionRemoved[$n]} == "sysctl_cpu" ]; then
                                      infoString="Dumped using /usr/sbin/sysctl -a | grep cpu"
                                  elif [ ${filesExtensionRemoved[$n]} == "sysctl_hw" ]; then
                                      infoString="Dumped using /usr/sbin/sysctl -a | grep hw"
                                  elif [ ${filesExtensionRemoved[$n]} == "sysctl_machdep_xcpm" ]; then
                                      infoString="Dumped using /usr/sbin/sysctl -a machdep.xcpm (Thanks Pike)."
                                  fi ;;
                     "nvraminfo") if [ ${filesExtensionRemoved[$n]} == "nvram.plist" ]; then
                                      infoString="Dumped using nvram -x -p"
                                  elif [ ${filesExtensionRemoved[$n]} == "nvram_hexdump" ]; then
                                      infoString="Dumped with nvram -hp using an <a href=\"https://bitbucket.org/blackosx/nvram\" target=\"_blank\">amended version of Apple's nvram tool.</a>"
                                  elif [ ${filesExtensionRemoved[$n]} == "uefi_firmware_vars" ]; then
                                      infoString="Dumped with nvram -ha using an <a href=\"https://bitbucket.org/blackosx/nvram\" target=\"_blank\">amended version of Apple's nvram tool.</a>"
                                  fi ;;
                          "smc") infoString="Dumped using SMC_util2 (Former Apple System Management Control (SMC) tool 0.01) by usr-sse2." ;;
                              *)  infoString="${filesExtensionRemoved[$n]}" ;;
                esac

                echo "<div id=\"tabs_${tabname}-$((n+1))\">" >> "$gHtmlDumpFile"
                ReadFileAndWriteSubSectionToHtml "$passedDirToRead/${files[$n]}"\
                                                 "$infoString"\
                                                 "<a href=\"$finalDestination/${files[$n]}\" target=\"_blank\">View File ${files[$n]}</a>"\
                                                 "${filesExtensionRemoved[$n]}"\
                                                 ""\
                                                 ""
                echo "</div> <!-- End tabs_${tabname}-$((n+1)) -->" >> "$gHtmlDumpFile"
            done
            echo "</div> <!-- Close tabs_${tabname} -->" >> "$gHtmlDumpFile"
        fi
    fi
}    

# ---------------------------------------------------------------------------------------
# The dark grey header bar under the main (coloured) section bar - Collapsable
WriteHtmlTableHeaderWithCollapseToFile()
{
    local passedTableHeading="$1"
    local passedCollapseDivId="$2"
    local passedState="$3"
    local whichArrow=$(SelectArrow)
    
    if [ "$passedCollapseDivId" == "" ]; then
        passedCollapseDivId=collapseID_$gCollapseDivId
    fi
    
    # Remove any exclamation marks from collapseID.
    if [[ "$passedCollapseDivId" == *!* ]]; then
        passedCollapseDivId=$( echo "$passedCollapseDivId" | sed 's/\!//g' )
    fi
    
    echo "<div id=\"dump_section_inner_table_header2\"> 
<a class="make_div_clickable" style=\"cursor:pointer;\" onClick=\"javascript:headerBarToggleShowHide('$passedCollapseDivId', this)\"> <span class=\"text_medium_section_inner_title\"> $passedTableHeading</span></a></td></tr></table>
</div> <!-- End dump_section_inner_table_header2 -->
<div id=\"$passedCollapseDivId\" style=\"display:${passedState};\">" >> "$gHtmlDumpFile"

    echo "#$passedCollapseDivId { display: $passedState; }" >> "$gCssDumpFile"
    ((gCollapseDivId++))
}

# ---------------------------------------------------------------------------------------
# The light grey sub header bar under the dark grey header bar.
WriteHtmlTableSubHeaderToFile()
{
    local passedType="$1"
    local passedDevice="$2"
    local passedSize="$3"
    local passedContent="$4"
    local passedMbrBootCode="$5"
    local finalDestination="$6"
    
    if [ "$passedType" == "Disk" ]; then
        if [ "$passedMbrBootCode" == "" ] || [ "$passedMbrBootCode" == " " ]; then
            passedMbrBootCode=""
        else
            passedMbrBootCode="| MBR boot code detected: $passedMbrBootCode"
        fi
        echo "<div id=\"dump_section_inner_table_subheader_info\">
<table><tr><td class=\"text_small_section_inner_title\">$passedDevice | $passedSize | $passedContent $passedMbrBootCode | <a href=\"$finalDestination\" target=\"_blank\">View Disk Sectors</a></td></tr></table>
</div>" >> "$gHtmlDumpFile"
    else
        echo "<div id=\"dump_section_inner_table_subheader_info\">
<table><tr class=\"text_small_section_inner_title\"><td>$passedDevice</td></tr></table>
</div>" >> "$gHtmlDumpFile"
    fi
}

# ---------------------------------------------------------------------------------------
# The very light grey main section content panel, under the light grey sub header bar.
WriteHtmlTableTextHeadingToFile()
{   
    local tableType="$1"
    # These tables have text headings
    if [ "$tableType" == "diskutil" ]; then
        echo "<div id=\"dump_section_inner_table_content_container\">
<table style=\"table-layout: fixed; width: 100%\" width=\"$gTableBoxWidth\" border=\"0\">
  <tr class=\"text_table_heading\"><td width=\"$gColOne\"></td><td width=\"$gColTwo\">DEVICE</td><td width=\"$gColThree\">TYPE</td><td width=\"$gColFour\">NAME</td><td width=\"$gColFive\">SIZE</td><td width=\"$gColSix\">PBR (Stage1)</td><td width=\"$gColSeven\">BootFile (Stage 2)</td><td width=\"$gColEight\">UEFI BootFile</td></tr>" >> "$gHtmlDumpFile"
    elif [ "$tableType" == "NonAppleKexts" ]; then
        echo "<div id=\"dump_section_inner_table_content_container\">
<table style=\"table-layout: fixed; width: 100%\" width=\"$gTableBoxWidth\" border=\"0\">
  <tr class=\"text_table_heading\"><td width=\"$gColOne\">IDX</td><td width=\"$gColTwo\">REFS</td><td width=\"$gColThree\">ADDRESS</td><td width=\"$gColFour\">SIZE</td><td width=\"$gColFive\">WIRED</td><td width=\"$gColSix\">NAME</td><td width=\"$gColSeven\">VERSION</td><td width=\"$gColEight\">LINKED AGAINST</td></tr>" >> "$gHtmlDumpFile"
    elif [ "$tableType" == "AppleKexts" ]; then
        echo "<div id=\"dump_section_inner_table_content_container_scroll\">
<table style=\"table-layout: fixed; width: 100%\" width=\"$gTableBoxWidth\" border=\"0\">
  <tr class=\"text_table_heading\"><td width=\"$gColOne\">IDX</td><td width=\"$gColTwo\">REFS</td><td width=\"$gColThree\">ADDRESS</td><td width=\"$gColFour\">SIZE</td><td width=\"$gColFive\">WIRED</td><td width=\"$gColSix\">NAME</td><td width=\"$gColSeven\">VERSION</td><td width=\"$gColEight\">LINKED AGAINST</td></tr>" >> "$gHtmlDumpFile"
    
    # Don't print a text table header for the others.
    # These tables don't use scrollable boxes
    elif [ "$tableType" == "dmitables" ] || [ "$tableType" == "rcLocal" ]; then
        echo "<div id=\"dump_section_inner_table_content_container\">
<table style=\"table-layout: fixed; width: 100%\" width=\"$gTableBoxWidth\" border=\"0\">" >> "$gHtmlDumpFile"

    # These tables use scrollable boxes
    else 
        echo "<div id=\"dump_section_inner_table_content_container_scroll\">
<table style=\"table-layout: fixed; width: 100%\" width=\"$gTableBoxWidth\" border=\"0\">" >> "$gHtmlDumpFile"
    fi
}

# ---------------------------------------------------------------------------------------
# The masthead of the page.
WriteHtmlOverviewToFile()
{
    local passedAppName="$1"
    local passedVersion="$2"
    local passedTimeStamp="$3"
    local passedSystemVersion="$4"
    local passedOsVersion="$5"
    local passedMacModel="$6"
    local passedCpu="$7"
    local passedGraphics="$8"
    local passedMemory="$9"
    local passedCodecID="${10}"
    
    local buildFile=""
    local osVersion=""
    local osLogo=""

    case "${passedSystemVersion}" in
        "LEO")  osVersion="Leopard" 
                osLogo="overview_logo_leo" ;;
        "SL")   osVersion="Snow Leopard"
                osLogo="overview_logo_sl" ;;
        "Lion") osVersion="Lion"
                osLogo="overview_logo_lion" ;;
        "ML")   osVersion="Mountain Lion"
                osLogo="overview_logo_ml" ;;
        "Mav")   osVersion="Mavericks"
                osLogo="overview_logo_mav" ;;
        "Yos")   osVersion="Yosemite" # Speculated
                osLogo="overview_logo_yos" ;; # To Do - Add new logo
        "Unknown")   osVersion="Unknown";;
    esac
     
    buildFile="<div id=\"overview_container_outer\">
  <div id=\"overview_topBand\">
    <div id=\"overview_container_inner\">
      <div id=\"overview_panel_logo\"><div id=\"ddlogo\"></div></div>"
      
    if [ "$gPrivateState" == "Private" ]; then
        buildFile="$buildFile
      <div id=\"overview_panel_title\" class=\"text_overview_heading\">$passedAppName Report&nbsp;<img alt=\"\" width=\"52\" height=\"22\" align=\"top\" src=\"${privateStamp}\"/><span class=\"text_overview_body\">&nbsp;&nbsp;Version: ${passedVersion}</span></div>"
    else
       buildFile="$buildFile
      <div id=\"overview_panel_title\" class=\"text_overview_heading\">$passedAppName Report<span class=\"text_overview_version\">&nbsp;&nbsp;Version: ${passedVersion}</span></div>"
    fi

    buildFile="$buildFile
      <div id=\"overview_panel_date\" class=\"text_overview_version\">${passedTimeStamp}</div>
      <div id=\"overview_panel_one\" class=\"text_overview_body\">Mac Model: <a href=\"http://www.everymac.com/ultimate-mac-lookup/?search_keywords=${passedMacModel}\" target=\"_blank\">${passedMacModel}</a><br />CPU: ${passedCpu}<br />Memory: ${passedMemory}</div>
      <div id=\"overview_panel_two\" class=\"text_overview_body\">Video: ${passedGraphics}<br />Audio: ${passedCodecID}</div>
      <div id=\"overview_panel_three\"><div id=\"${osLogo}\"></div><span class=\"text_overview_body\">Operating System<br /><strong>${osVersion}</strong><br />$passedOsVersion</span></div>
    </div> <!-- End overview_container_inner -->
  </div> <!-- End overview_topBand -->
</div> <!-- End overview_container_outer -->"
    echo "${buildFile}" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteHtmlTableTextToFile()
{
    local passedFieldOne="$1"
    local passedFieldTwo="$2"
    local passedFieldThree="$3"
    local passedFieldFour="$4"
    local passedFieldFive="$5"
    local passedFieldSix="$6"
    local passedFieldSeven="$7"
    local passedFieldEight="$8"
    
    if [ "$passedFieldOne" = "" ]; then
        passedActive="&nbsp;"
    fi
    if [ "$passedFieldTwo" = "" ]; then
        passedDevice="&nbsp;"
    fi
    if [ "$passedFieldThree" = "" ]; then
        passedType="&nbsp;"
    fi
    if [ "$passedFieldFour" = "" ]; then
        passedName="&nbsp;"
    fi
    if [ "$passedFieldFive" = "" ]; then
        passedSize="&nbsp;"
    fi
    if [ "$passedFieldSix" = "" ]; then
        passedPbr="&nbsp;"
    fi
    if [ "$passedFieldSeven" = "" ]; then
        passedBoot="&nbsp;"
    fi
    if [ "$passedFieldEight" = "" ]; then
        passedLoader="&nbsp;"
    fi
    
    case "$#" in
        1) echo "<tr><td>$passedFieldOne</td></tr>" >> "$gHtmlDumpFile" ;;
        2) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td></tr>" >> "$gHtmlDumpFile" ;;
        3) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td><td>$passedFieldThree</td></tr>" >> "$gHtmlDumpFile" ;;
        4) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td><td>$passedFieldThree</td><td>$passedFieldFour</td></tr>" >> "$gHtmlDumpFile" ;;
        5) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td><td>$passedFieldThree</td><td>$passedFieldFour</td><td>$passedFieldFive</td</tr>" >> "$gHtmlDumpFile" ;;
        6) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td><td>$passedFieldThree</td><td>$passedFieldFour</td><td>$passedFieldFive</td><td>$passedFieldSix</td></tr>" >> "$gHtmlDumpFile" ;;
        7) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td><td>$passedFieldThree</td><td>$passedFieldFour</td><td>$passedFieldFive</td><td>$passedFieldSix</td><td>$passedFieldSeven</td></tr>" >> "$gHtmlDumpFile" ;;
        8) echo "<tr><td>$passedFieldOne</td><td>$passedFieldTwo</td><td>$passedFieldThree</td><td>$passedFieldFour</td><td>$passedFieldFive</td><td>$passedFieldSix</td><td>$passedFieldSeven</td><td>$passedFieldEight</td></tr>" >> "$gHtmlDumpFile" ;;
    esac
}

# ---------------------------------------------------------------------------------------
WriteHtmlTableTextEndingToFile()
{
    echo "</table>
</div> <!-- End table_container ( also closes End table_container_scroll ) -->" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
InsertInternalSeparatorHTMLToFile()
{
    local passedTitle="$1"
    
    echo "" >> "$gHtmlDumpFile"
    echo "<!-- ====================================================================================================================================================== -->" >> "$gHtmlDumpFile"
    echo "<!--                                                     SECTION FOR: $passedTitle                                        -->" >> "$gHtmlDumpFile"
    echo "<!-- ====================================================================================================================================================== -->" >> "$gHtmlDumpFile"
    echo "" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
SelectArrow()
{
    local whichArrow=""
    if [ "$gTableState" == "block" ]; then
        whichArrow="${gArrowClosed}"
    else
        whichArrow="${gArrowOpen}"
    fi
    echo "$whichArrow" # This line acts as a return to the caller.
}    
    
# ---------------------------------------------------------------------------------------
SetHtmlNonBreakingSpace()
{
    local passedFile="$1"
    
    LANG=C expand "$passedFile" > "$passedFile_spaces.txt" # Convert tabs to spaces
    LANG=C sed -i.bak 's/ /\&nbsp\;/g' "$passedFile_spaces.txt" # Convert spaces to html non-breaking space &nbsp
    
    echo "$passedFile_spaces.txt" # This line acts as a return to the caller.
}

# ---------------------------------------------------------------------------------------
FixHtmlLessThanGreaterThan()
{
    local passedFile="$1"
    
    LANG=C sed -i.bak 's/</\&lt\;/g' "$passedFile" # Convert < to &lt
    LANG=C sed -i.bak 's/>/\&gt\;/g' "$passedFile" # Convert > to &gt

    echo "$passedFile" # This line acts as a return to the caller.
}

# ---------------------------------------------------------------------------------------
RemoveHtmlNonBreakingSpaceFiles()
{
    local passedFile="$1"
    
    rm "$passedFile_spaces.txt"
    rm "$passedFile_spaces.txt.bak"
}

# ---------------------------------------------------------------------------------------
ReadFileAndWriteCompleteSectionToHtml()
{
    local passedFile="$1"
    local passedSectionHeading="$2"
    local passedTableHeading="$3"
    local passedSubHeader="$4"
    local passedTextHeading="$5"
    local passedAnchor="$6"
    local passedWarning="$7"
    local passedColllapseDivId="$8"
    local lineRead
    
    WriteOuterH3 "$passedSectionHeading"
    WriteHtmlTableHeaderToFile "$passedTableHeading"
    WriteHtmlTableSubHeaderToFile "" "$passedSubHeader"
    WriteHtmlTableTextHeadingToFile "$passedTextHeading"
    
    local fixedFile=$(SetHtmlNonBreakingSpace "$passedFile")
    local fixedFile=$(FixHtmlLessThanGreaterThan "$fixedFile")
    
    while read -r lineRead
    do
        WriteHtmlTableTextToFile "$lineRead"
    done < "$fixedFile"
    
    WriteHtmlTableTextEndingToFile   
    WriteEndingH3
}

# ---------------------------------------------------------------------------------------
ReadFileAndWriteSubSectionToHtml()
{
    local passedFile="$1"
    local passedTableHeading="$2"   # Dark gray bar under main section heading.
    local passedSubHeader="$3"      # Contents of light gray bar under dark gray bar.
    local passedTextHeading="$4"    # Certain tables, for example Kexts, had special headings. These can be set from here.
    local passedCollapseID="$5"     # ID Value for collapse or empty string.
    local passedState="$6"          # String of either 'none' or 'block' (only used if passedCollapseID is not empty).
    local lineRead

    if [ "$passedState" == "" ]; then
        passedState="$gTableState"
    fi
    
    if [ "$passedCollapseID" == "" ]; then
        WriteHtmlTableHeaderToFile "$passedTableHeading"
    else
        WriteHtmlTableHeaderWithCollapseToFile "$passedTableHeading" "$passedCollapseID" "$passedState"
    fi

    if [ ! "$passedTextHeading" == "dmitables" ]; then
        WriteHtmlTableSubHeaderToFile "" "$passedSubHeader"
    fi
    WriteHtmlTableTextHeadingToFile "$passedTextHeading"
    
    local fixedFile=$(SetHtmlNonBreakingSpace "$passedFile")
    local fixedFile=$(FixHtmlLessThanGreaterThan "$fixedFile")

    while read -r lineRead
    do
        WriteHtmlTableTextToFile "$lineRead"
    done < "$fixedFile"

    WriteHtmlTableTextEndingToFile    
}

# ---------------------------------------------------------------------------------------
CreateAndInitialiseHtmlFile()
{
    echo "Creating HTML report..." >> "${gLogFile}"
    echo "Creating HTML report"
    WriteHtmlHeaderToFile "$gtheprog"
    WriteCssToFile
    WriteJavaScriptToFile
    WriteHtmlCloseHeadToFile
    WriteHtmlOpenBodyOpenDivToFile
    DumpSystemOverview
    WriteNote
    WriteHtmlClearLineToFile
    WriteDumpContainerOpen
}

#
# =======================================================================================
# READ DUMP FILES & CALL HTML WRITE ROUTINES 
# =======================================================================================
#

# ---------------------------------------------------------------------------------------
DumpSystemOverview()
{
    local systemVersion=$(CheckOsVersion)
    
    oIFS="$IFS"; IFS=$'\r\n'
    tmp=()
    tmp=( $( /usr/sbin/system_profiler SPDisplaysDataType | grep "Chipset Model:" ))
    # Read tmp array for video and compile in to am html string for the report overview.                
    if [ ${#tmp[@]} -gt 0 ]; then
        macGraphics="${tmp[0]##*: }"   
        for (( c=1; c<${#tmp[@]}; c++ ))
        do
            macGraphics="${macGraphics}<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"$( printf '%s\n\r' "${tmp[$c]##*: }" )
        done
    else
        macGraphics="${tmp[@]}"  
    fi
    IFS="$oIFS"
 
    local macModel=$( /usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier:" )
    macModel="${macModel##*: }"
    local macOsVer=$( /usr/sbin/system_profiler SPSoftwareDataType | grep "System Version" )
    macOsVer="${macOsVer##*X }"
    local macMemory=$( /usr/sbin/system_profiler SPHardwareDataType | grep "Memory:" )
    macMemory="${macMemory##*: }"
    
    # Get memory type and speed.
    local memType=$( /usr/sbin/system_profiler SPMemoryDataType | grep Type | grep -v 'Empty' | tail -n1 )
    memType="${memType##*: }"
    local memSpeed=$( /usr/sbin/system_profiler SPMemoryDataType | grep Speed | grep -v 'Empty' | tail -n1 )
    memSpeed="${memSpeed##*: }"
    
    if [ "${systemVersion}" == "LEO" ] || [ "${systemVersion}" == "Tiger" ]; then
        if [ -f "$gDumpFolderSysProf/System-Profiler.txt" ]; then
            macCpu=$( fgrep "Processor Name:" "$gDumpFolderSysProf/System-Profiler.txt" )
        else
            macCpu=$( sysctl -a | grep "cpu.brand_string" )
        fi
    else
        macCpu=$( sysctl -a | grep "cpu.brand_string" )
    fi
    local macCpu="${macCpu##*: }"
    local timeStamp=$( date +"%A %d %B %Y" )

    # There's only space for 4 lines in the report header for audio and graphics
    # Sometimes the AudioCodec can report more than one line.
    # For Example:
    # Cirrus Logic CS4206
    # ATI R6xx HDMI
    #
    # So, in the case of multiple devices remove the line breaks and add a slash to separate them.
    #gCodecID=$( echo "$gCodecID" | tr "\n" "/"  | sed 's/.$//' )
    #macGraphics=$( echo "$macGraphics" | tr "\n" "/"  | sed 's/.$//' )

    WriteHtmlSectionAnchorToFile "aTop"
    WriteHtmlOverviewToFile "$gtheprog" "$gVERS" "$timeStamp" "$systemVersion" "$macOsVer" "$macModel" "$macCpu" "$macGraphics" "${macMemory} ${memSpeed} ${memType}" "$gCodecID"
}

# ---------------------------------------------------------------------------------------
WriteNote()
{
    echo "<div id=\"note\" class=\"text_note\">Note: A complete dump contains more information than shown in this .htm report. If submitting a report for help then please supply the containing directory, not just this file.</div>" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteAccordionOpen()
{
    echo "<div id=\"accordion\">" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteAccordionClose()
{
    echo "</div> <!-- Close Accordion -->" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteDumpContainerOpen()
{
    echo "<div id=\"dump_container\">" >> "$gHtmlDumpFile"
}

# ---------------------------------------------------------------------------------------
WriteDumpContainerClose()
{
    echo "</div> <!-- Close dump_container -->" >> "$gHtmlDumpFile"
}


# ---------------------------------------------------------------------------------------
DumpHtmlAcpiTables()
{
    local finalDestination=""
    local checkFileExistence=`find "$gDumpFolderAcpiDsl" -type f -name *.dsl -print 2>/dev/null`
    if [ ! "$checkFileExistence" == "" ]; then
        local finalDestination="${gDumpFolderAcpi##*/}/${gDumpFolderAcpiDsl##*/}"
        echo "${gLogIndent}adding ACPI tables" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "ACPI Tables"
        WriteOuterH3 "ACPI Tables"
        ReadDirCreateTabsAddFileData "$gDumpFolderAcpiDsl" "acpitableinfo"
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlAudio()
{
    local finalDestination="${gDumpFolderAudio##*/}"
    if [ -f "$gDumpFolderAudio/VoodooHDAGetdump.txt" ]; then
        echo "${gLogIndent}adding VoodooHDAGetdump.txt" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Audio Voodoo Dump"
        local checkLog=$( grep "if AppleHDA is disabled." "${gLogFile}" )
        if [ ! "$checkLog" == "" ]; then
            local message="&nbsp;&nbsp;Note: VoodooHDA's getdump may produce more info if AppleHDA is disabled."
        fi
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderAudio/VoodooHDAGetdump.txt" "Audio" "Dumped using <a href=\"http://www.projectosx.com/forum/index.php?showtopic=355\" target=\"_blank\">VoodooHDA's getdump tool</a>$message" "<a href=\"$finalDestination/VoodooHDAGetdump.txt\" target=\"_blank\">View VoodooHDAGetdump.txt File</a>" "Audio" "aAudio" "" "collapseID_Audio"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlBiosSystem()
{
    local finalDestination="${gDumpFolderBios##*/}/${gDumpFolderBiosSystem##*/}"
    if [ -f "$gDumpFolderBiosSystem/flashrom_log.txt" ]; then
        echo "${gLogIndent}adding BIOS flashrom_log.txt" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "BIOS System Dump"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderBiosSystem/flashrom_log.txt" "BIOS - System: Flashrom Log" "Dumped using Flashrom Darwin Port, v0.9.7 r1786. <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2485\" target=\"_blank\">OS X port by THe KiNG.</a>." "<a href=\"$finalDestination/flashrom_log.txt\" target=\"_blank\">View flashrom_log.txt File</a>" "BiosSystem" "aBiosSystem" "" "collapseID_BiosSystem"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlBiosVideo()
{
    local finalDestination="${gDumpFolderBios##*/}/${gDumpFolderBiosVideo##*/}"
    local checkFileExistence=`find "$gDumpFolderBiosVideo" -type f -name "*.txt" 2>/dev/null`
    if [ ! "$checkFileExistence" == "" ]; then
    
        echo "${gLogIndent}adding BIOS Video decoded text file" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "BIOS Video Dump"
        WriteOuterH3 "BIOS Video"
        ReadDirCreateTabsAddFileData "$gDumpFolderBiosVideo" "biosVideo"
    	WriteEndingH3
    fi   
}

# ---------------------------------------------------------------------------------------
DumpHtmlCpuInfo()
{
    local finalDestination="${gDumpFolderCPU##*/}"
    if [ -f "$gDumpFolderCPU/cpuinfo.txt" ]; then
        echo "${gLogIndent}adding CPU Information" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "CPU Information"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderCPU/cpuinfo.txt" "CPU Information" "Dumped using x86info v1.31pre. Written to succeed CPUID by Phil Karn (KA9Q). Compiled by Slice" "<a href=\"$finalDestination/cpuinfo.txt\" target=\"_blank\">View cpuinfo.txt File</a>" "CpuInfo" "aCpuInfo" "" "collapseID_CpuInfo"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlDeviceProperties()
{
    local finalDestination="${gDumpFolderDevProps##*/}"
    if [ -f "$gDumpFolderDevProps/device-properties.plist" ]; then
        echo "${gLogIndent}adding device properties" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Device Properties"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderDevProps/device-properties.plist" "Device Properties" "Dumped using gfxutil v0.71b by McMatrix from 2007" "<a href=\"$finalDestination/device-properties.plist\" target=\"_blank\">View device-properties.plist File</a>" "DeviceProperties" "aDeviceProps" "" "collapseID_DevProps"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlBootLoaderAndDiskSectors()
{
    local finalDestination=""
    local fileToRead="$gDDTmpFolder"/diskutilLoaderInfo.txt # Created in the gatherDiskUtilLoaderinfo.sh script

    if [ -f "$fileToRead" ]; then
        echo "${gLogIndent}adding diskutil & loader info" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Bootloaders & Disk Sectors"
        CalculateTableWidths "DiskDump"
        local tabname="Bootloaders"
        local diskCount=1
        WriteJavaScriptJqueryUITabToFile "$tabname"
        WriteOuterH3 "Bootloaders & Disk Sectors"
        
        # Build list of disks for tab names
        local disks=()
        disks+=( $( cat "$fileToRead" | grep "WD:" | tr -d 'WD:' ))
   
        # Write tabs to file
        local numDisks="${#disks[@]}"
        if [ $numDisks -gt 0 ]; then
            # Write tabs to file
            echo "<div id=\"tabs_${tabname}\">
  <ul>" >> "$gHtmlDumpFile"
            for (( n=0; n<$numDisks; n++ ))
            do
                echo "    <li><a href=\"#tabs_${tabname}-$((n+1))\">${disks[$n]}</a></li>" >> "$gHtmlDumpFile"
            done
            echo  "</ul>" >> "$gHtmlDumpFile"
        fi
    
        while read -r lineRead
        do
            if [ "${lineRead:0:1}" == "=" ]; then
                WriteHtmlTableTextEndingToFile
                #echo "</div> <!-- End div section for device id & set state -->" >> "$gHtmlDumpFile"
                echo "</div> <!-- End tabs_${tabname}-$diskCount -->" >> "$gHtmlDumpFile"
                ((diskCount++))
            else
                codeRead="${lineRead%%:*}"
                detailsRead="${lineRead#*:}"
                if [ "$detailsRead" == "" ]; then
                    detailsRead=" "
                fi 
        
                case "$codeRead" in
                    "WD") diskIdentifier="${detailsRead}"
                          #WriteHtmlTableHeaderWithCollapseToFile "${diskIdentifier}" ;;
                          echo "<div id=\"tabs_${tabname}-$diskCount\">" >> "$gHtmlDumpFile"
                          ;;
                    "DN") diskName="${detailsRead}" ;;
                    "DS") diskSize="${detailsRead}" ;;
                    "DT") diskType="${detailsRead}" ;;
                    "S0") stageZero="${detailsRead}"
                          diskNameWithoutBlockSize="${diskName%% (*}"
                          finalDestination="${gDumpFolderDisks##*/}/${gDumpFolderDiskBootSectors##*/}/${diskIdentifier##*/}-${diskNameWithoutBlockSize}-${diskSize}.txt"
                          WriteHtmlTableSubHeaderToFile "Disk" "${diskName}" "${diskSize}" "${diskType}" "$stageZero" "$finalDestination"
                          WriteHtmlTableTextHeadingToFile "diskutil" ;;
                    "VA") volumeActive="${detailsRead}" ;;
                    "VD") volumeDevice="${detailsRead}" ;;
                    "VT") volumeType="${detailsRead}" ;;
                    "VN") volumeName="${detailsRead}" ;;
                    "VS") volumeSize="${detailsRead}" ;;
                    "S1") stageOne="${detailsRead}"
                          WriteHtmlTableTextToFile "$volumeActive" "${volumeDevice}" "${volumeType}" "${volumeName}" "${volumeSize}" "${stageOne}" "" "" ;;
                    "BF") bootFile="${detailsRead}" ;;
                    "S2") if [ "${detailsRead}" == "" ] || [[ "${detailsRead}" =~ ^\ +$ ]] ;then # if blank or only whitespace
                              stageTwo=""
                          else
                              stageTwo="(${detailsRead})"
                          fi
                          WriteHtmlTableTextToFile "" "" "" "" "" "" "<b>${bootFile}</b>${stageTwo}" ;;
                    "UF") uefiFile="${detailsRead}" ;;
                    "U2") if [ "${detailsRead}" == "" ] || [[ "${detailsRead}" =~ ^\ +$ ]] ;then # if blank or only whitespace
                              uefiFileVersion=""
                          else
                              uefiFileVersion="(${detailsRead})"
                          fi
                          WriteHtmlTableTextToFile "" "" "" "" "" "" "" "<b>${uefiFile}</b>${uefiFileVersion}";;
                esac 
            fi
        done < "$fileToRead"
                
        echo "</div> <!-- Close tabs_${tabname} -->" >> "$gHtmlDumpFile"
        WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlDiskUUIDs()
{
    local finalDestination="${gDumpFolderDisks##*/}"
    if [ -f "$gDumpFolderDisks/UIDs.txt" ]; then
        echo "${gLogIndent}adding disk & volume UIDs" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Disk & Volume UIDs"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderDisks/UIDs.txt" "Disk & Volume UIDs" "UUID's grabbed from diskutil info. Unique partition GUID's dumped from IOreg." "<a href=\"$finalDestination/UIDs.txt\" target=\"_blank\">View UIDs.txt File</a>" "UIDs" "aUIDs" "" "collapseID_UIDs"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlDisks()
{    
    #------------------------
    AppendTableData()
    {
        local passedLine="$1"
        diskTableData="$diskTableData"$(printf "$passedLine\r")
    }
    
    #------------------------
    AppendHexDetailsData()
    {
        local passedLine="$1"
        hexDetailsData="$hexDetailsData"$(printf "$passedLine\r")
    }
    
    #------------------------
    AppendCssInitBlocks()
    {
        local passedCount=$1
        if [ $passedCount -eq 0 ]; then
            cssInitBlock="$cssInitBlock"$(printf "#diskPartitionCollapseID_${diskToRead}_$passedCount { display: block; }\r")
        else
            cssInitBlock="$cssInitBlock"$(printf "#diskPartitionCollapseID_${diskToRead}_$passedCount { display: none; }\r")
        fi
    }
    
    #------------------------
    AppendJsBlock()
    {
        local passedCount=$1
        jsBlock="$jsBlock"$(printf "    diskPartitionCollapseID_${diskToRead}_${passedCount}.style.display = 'none';\r")
    }
            
    local finalDestination="${gDumpFolderDisks##*/}"
    
    # Name of the folder in "$gDumpFolderDisks" that contains the partition table dumps
    gDumpFolderName="${gDumpFolderDiskPartitionInfo}/Partition bdisk Scan"

    if [ -d "$gDumpFolderName" ]; then
        echo "${gLogIndent}adding partition table info" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Disk Partition Tables"
        local tabname="DiskPartInfo"
        local diskTabCount=1
        WriteJavaScriptJqueryUITabToFile "$tabname"
        WriteOuterH3 "Disk Partition Tables"
        
        # Build list of disks and write tabs to file
        local disks=()
        local count=0
        for file in "$gDDTmpFolder"/html_build_file_disk*
        do
            local tmp="${file##*_}"
            disks+=("${tmp%.txt}")
            ((count++))
        done   
        if [ $count -gt 0 ]; then
            echo "<div id=\"tabs_${tabname}\">
  <ul>" >> "$gHtmlDumpFile"
            for (( n=0; n<$count; n++ ))
            do
                echo "    <li><a href=\"#tabs_${tabname}-$((n+1))\">${disks[$n]}</a></li>" >> "$gHtmlDumpFile"
            done
            echo  "</ul>" >> "$gHtmlDumpFile"
        fi

        local cdir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        cd "$cdir"; cd ..; cd ..
        local resourcesDir="$( pwd )"/Resources
        local dataDir="$resourcesDir"/Data

        # Add specific css for the disk partitions
        WriteDiskPartitionCssToFile

        for file in "$gDDTmpFolder"/html_build_file_disk*.txt
        do
            local fileFound="${file##*/}"
            fileToProcess="$gDDTmpFolder"/"$fileFound"
            diskToRead="${fileFound##*_}"
            diskToRead="${diskToRead%.*}"
            gDumpFolderHex="${gDumpFolderName}/${diskToRead}/hex"
            gDumpFolderDecoded="${gDumpFolderName}/${diskToRead}/decoded"
            
            #htmlFile="${gDumpFolderDisks}/Partition_${diskToRead}.html"
                    
            diskTableData=""
            hexDetailsData=""
            jsBlock=""
            diskInfoToInsert=""

            #local fileToRead="$gTmpHtmlParseFile"
    
            # Set Javascript Function Name
            jsFuncName="ShowHideDiskPartitionHexDetails_${diskToRead}"
    
            if [ -f "$fileToProcess" ]; then

                InsertInternalSeparatorHTMLToFile "Disk Partition Table: ${diskToRead}"
  
                diskInfoToInsert=""
                diskInfoToInsert2=""
                unset cssInitBlocks
                local collapseCount=0
                local foundGPT=0
                local tmpTableType="gpt"

                while read -r lineRead
                do
                        codeRead="${lineRead%%@*}"
                        detailsRead="${lineRead#*@}"

                        if [ "$detailsRead" == "" ]; then
                            detailsRead=" "
                        fi 

                        case "$codeRead" in

                            "Title")       # lines beginning with Title are joined together to print in the subheader title bar

                                           diskInfoToInsert="${diskInfoToInsert}${detailsRead}&nbsp;&nbsp;|&nbsp;&nbsp;"
                                           ;;
                                           
                            "Title2")      # lines beginning with Title2 are joined together to print the 2nd line of the subheader title bar

                                           diskInfoToInsert2="${diskInfoToInsert2}${detailsRead}&nbsp;&nbsp;|&nbsp;&nbsp;"

                                           # Make a note if HTML table type is MBR or GPT.
                                           # We can use this to decide which table to produce (ie. number of columns)
                                           if [ "${detailsRead}" == "MBR Partition Table" ]; then
                                               tmpTableType="mbr"
                                           fi
                                           ;;

                            "TableHgt")    # lines beginning with TableHgt indicate the height in pixels that this table row will be.
                                           # Finding this line also indicates the beginning of a partition description.

                                           ((collapseCount++))
                                           AppendTableData "        <div class=\"t\">"
                                           AppendTableData "            <div class=\"tr\" style=\"height:${detailsRead}px;\">"
                                           ;;

                            "TableLba")    # lines beginning with TableLba indicate the starting LBA of this entry.

                                           # Add the html code for the starting LBA table column and include the LBA number.
                                           AppendTableData "                <div class=\"${tmpTableType}_tc_Start_lba\">${detailsRead}</div>"

                                           # Remember the startingLBA for later.
                                           local tmpLba=${detailsRead}
                                           ;;

                            "TableAct")    # lines beginning with TableAct indicate if this entry is active.

                                           if [ "$detailsRead" == "" ] || [ "$detailsRead" == " " ]; then

                                               # If the data is blank, then add the html code for a blank active table column.
                                               AppendTableData "                <div class=\"${tmpTableType}_tc_Active\">&nbsp;</div>"
                                           else
                                               # If the data is not blank, then add the html code for an active table column with ID set to active.
                                               AppendTableData "                <div class=\"${tmpTableType}_tc_Active\" id=\"activePart\">&nbsp;</div>" 
                                           fi
                                           ;;

                            "TablePeTyp")  # lines beginning with TablePeTyp indicate a partition entry type.
                                           # Data for this can be either a boot record type: MBR or EBR
                                           # or a GUID partition type. For example, Primary GPT Header / EFI System Partition / HFS

                                           # For now, remember this for using later.
                                           tmpPeType="$detailsRead" ;;

                            "TablePeVal")  # lines beginning with TablePeVal indicate a partition entry value.
                                           # Data for this will be a hex byte, though it may be blank.

                                           # Check to see if the data is blank.
                                           if [ "$detailsRead" == "" ] || [ "$detailsRead" == " " ]; then
                                           
                                               # Have we already added html code for a GPT entry to the MBR Partition Map table column?
                                               #if [ $foundGPT -eq 0 ]; then
                                        
                                                   # first occurrence of EE will have already had html code added (Top). So we add html code for the Mid section
                                                   #AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillPrimaryGPTHeaderMid\">${detailsRead}</div>"
                                               #else
                                        
                                                   # If reading LBA 0 and we have a GPT disk, add html code for an MBR fill to the MBR Partition Map table column.
                                                   if [ "$tmpLba" == "0" ]; then
                                                       if [ "$tmpTableType" == "gpt" ]; then
                                                           AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillNoHoverMBR\">&nbsp;</div>"
                                                       fi
                                                   else
                                                       # We are not reading LBA 0. So if this is a GPT disk then add html code for a blank fill in the MBR Partition Map table column.
                                                       if [ "$tmpTableType" == "gpt" ]; then
                                                           AppendTableData "                <div class=\"${tmpTableType}_tc_Mbr_Pe\" id=\"fillBlank\">&nbsp;</div>"
                                                       fi
                                                   fi
                                              # fi
                                           else # The data is not blank

                                               # Is the hex byte ee for a GPT partition?
                                               if [ "$detailsRead" == "ee" ]; then
                                               
                                                   # Is this the first time we've read hex byte ee ?
                                                   if [ $foundGPT -eq 0 ]; then
                                                   
                                                       # remember we've found hex byte ee
                                                       foundGPT=1

                                                       # First time EE will be printed - So add html code for the Top section of the MBR Partition Map table column.
                                                       AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillPrimaryGPTHeaderTop\">EFI Protective (ee)</div>"
                                                   else
                                                       #AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillPrimaryGPTHeaderMid\">${detailsRead}</div>"
                                                       AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillPrimaryGPTHeaderMid\">&nbsp;</div>"
                                                   fi
                                                   
                                               else # the hex byte is not a GPT partition ID of ee

                                                   # Have we already discovered a GPT and currently reading a GPT ?
                                                   if [ $foundGPT -eq 1 ]; then

                                                       # We are reading a hybrid table.
                                                       # Data for a hybrid will have been passed as: Name (id)  For example, HFS+ (af)

                                                       # Take the first item before a space followed by an opening parenthesis
                                                       local tmp=$( echo "${detailsRead% (*}" | tr -d '()' )

                                                       # Remove all non-alphanumeric chars (for example HFS+ to HFS)
                                                       tmp=$( echo "$tmp" | sed 's/[^a-zA-Z0-9]//g' )

                                                       # add html code for the partition entry in to the MBR Partition Map table column.
                                                       # Check first for code (xx) that represents an unprotected area of MBR for a GPT/MBR hybrid.
                                                       if [ "$detailsRead" == "xx" ]; then
                                                           AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillNoHover${tmp}\">&nbsp;</div>"
                                                       else
                                                           AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillNoHover${tmp}\">${detailsRead}</div>"
                                                       fi
                                                       
                                                   else # A partition type of EFI Protective (ee) is not currently open (being written to the MBR Partition Map table column) for this disk.

                                                       # Check the partition table this disk is using.
                                                       if [ "$tmpTableType" == "gpt" ]; then

                                                           # add html code for the partition entry type in to the MBR Partition Map table column.
                                                           AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fill${tmpPeType}\">${detailsRead}</div>"
                                                       fi
                                                   fi
                                               fi
                                           fi
                                           ;;

                            "TableTyp")    # lines beginning with TableTyp indicate the GUID partition type. For example: Primary GPT Header / EFI System Partition / HFS

                                           tmpType="$detailsRead" 
                                           ;;

                            "TableNme")    # lines beginning with TableNme indicate the GUID partition name.

                                           # Check if the name needs printing in the html table, then remember the name for later.
                                           if [ "$tmpType" == "Space" ]; then 
                                               if [ ! "$detailsRead" == "Unused" ]; then
                                                   local tmpName="&nbsp;"
                                               else
                                                   local tmpName="$detailsRead"
                                               fi

                                           else # Not Space

                                               # Remember name for later.
                                               local tmpName="$detailsRead"

                                               # As this entry is not a space, use the LBA as the collapse_show ID.
                                               cssInitBlocks+=("${tmpLba}")
                                               AppendCssInitBlocks "${tmpLba}"
                                               AppendJsBlock "${tmpLba}"
                                           fi
                                           ;;

                            "TableSze")    # lines beginning with TableSze indicate the size of the partition as human readable. For example 160.0 GB

                                           # Check if the type is a Space and if so, is it a large unused space (>=1GB) worth displaying
                                           if [ "$tmpType" == "Space" ]; then
                                               if [ "$tmpName" == "Unused" ]; then

                                                   # add html code for a table cell with a space ID and include the name Unused and the Size.
                                                   AppendTableData "                <div class=\"${tmpTableType}_tc_Type\" id=\"fillSpace\">${tmpName} ${detailsRead}</div>"
                                               else
                                                   # add html code for a blank table cell with a space ID.
                                                   AppendTableData "                <div class=\"${tmpTableType}_tc_Type\" id=\"fillSpace\">&nbsp;</div>"
                                               fi

                                           else # Not a Space

                                               if [ "$detailsRead" == "" ] || [ "$detailsRead" == " " ]; then
                                               
                                                   # add html code for a clickable partition type without a size label. For example, Primary GPT Header
                                                   AppendTableData "                <div class=\"${tmpTableType}_tc_Type\" id=\"fill${tmpType}\" style=\"cursor:pointer;\" onClick=\"javascript:${jsFuncName}('diskPartitionCollapseID_${diskToRead}_${tmpLba}', this)\">${tmpName}</div>"
                                               else
                                                   # add html code for a clickable partition type with a size label. For example, Macintosh HD (160.0GB)
                                                   AppendTableData "                <div class=\"${tmpTableType}_tc_Type\" id=\"fill${tmpType}\" style=\"cursor:pointer;\" onClick=\"javascript:${jsFuncName}('diskPartitionCollapseID_${diskToRead}_${tmpLba}', this)\">${tmpName} ${detailsRead}</div>"
                                               fi
                                           fi
                                           ;;

                            "TableLdr")    # lines beginning with TableLdr indicate identified boot code in the partition sector.
                                           # Finding this line also indicates the end of a partition description on the parse file.

                                           if [ "$detailsRead" == "" ] || [ "$detailsRead" == " " ]; then
                                           
                                               # add html code to include a space in the Loader table column as no data was found.
                                               AppendTableData "                <div class=\"${tmpTableType}_tc_Loader\">&nbsp;</div>"
                                           else
                                               # add html code to include the loader title in the Loader table column.
                                               AppendTableData "                <div class=\"${tmpTableType}_tc_Loader\" id=\"loader\">${detailsRead}</div>"
                                           fi
                                           
                                           # add html code to complete the div table section.
                                           AppendTableData "            </div>"
                                           AppendTableData "        </div>"
                                           ;;
                                           
                            "SyncErrorLba")    # lines beginning with SyncErrorLba indicate a hybrid GPT has an MBR partition entry out of sync.
                                               # Finding this line shows we have to create an extra table row.

                                               AppendTableData "        <div class=\"t\">"
                                               AppendTableData "            <div class=\"tr\" style=\"height:10px;\">"
                                               AppendTableData "                <div class=\"${tmpTableType}_tc_Start_lba\">${detailsRead}</div>"
                                               ;;

                            "SyncErrorAct")    # lines beginning with SyncErrorAct indicate the active partition

                                               if [ "$detailsRead" == "" ] || [ "$detailsRead" == " " ]; then

                                                   # If the data is blank, then add the html code for a blank active table column.
                                                   AppendTableData "                <div class=\"${tmpTableType}_tc_Active\">&nbsp;</div>"
                                               else
                                                   # If the data is not blank, then add the html code for an active table column with ID set to active.
                                                   AppendTableData "                <div class=\"${tmpTableType}_tc_Active\" id=\"activePart\">&nbsp;</div>" 
                                               fi
                                               ;;

                            "SyncErrorTyp")    # lines beginning with SyncErrorTyp indicate the partition type
                            
                                               # add html code for the partition entry type.
                                               AppendTableData "                <div class=\"gpt_tc_Mbr_Pe\" id=\"fillSyncError\">${detailsRead}</div>"
                                               ;;
                                               
                            "SyncErrorSze")    # lines beginning with SyncErrorSze indicate the partition size
                            
                                               # add html code for the partition entry size
                                               AppendTableData "                <div class=\"gpt_tc_Type\" id=\"fillSyncError\">Sync Error (${detailsRead})</div>"
                                               
                                               # add html code for a blank field in the loader column
                                               AppendTableData "                <div class=\"${tmpTableType}_tc_Loader\">&nbsp;</div>"
                                               
                                               # add html code to complete the div table section.
                                               AppendTableData "            </div>"
                                               AppendTableData "        </div>"
                                               ;;
                                               
                        esac
                done < "$fileToProcess"
                
                # Remove the ending pipe from diskInfoToInsert and diskInfoToInsert2.
                diskInfoToInsert="${diskInfoToInsert%|*}"
                diskInfoToInsert2="${diskInfoToInsert2%|*}"

                # Build Hex and Details HTML for inserting in to HTML template.
                for (( c=0; c<${#cssInitBlocks[@]}; c++ ))
                do
        
                    AppendHexDetailsData "        <div id=\"diskPartitionCollapseID_${diskToRead}_${cssInitBlocks[$c]}\">"
                    AppendHexDetailsData "            <div id=\"diskInfoHexTableBox\" class=\"rsText_HexTable\">"
                    AppendHexDetailsData "                <p class=\"rsText_BodyBold\">LBA ${cssInitBlocks[$c]}</p>"

                    # Include the hex which would have been saved to file earlier.
                    # Read only the first 64 lines of the hex file (which should equate to 1024 bytes)
                    if [ -f "${gDumpFolderHex}/LBA${cssInitBlocks[$c]}_Hex.txt" ]; then
                        fileToInclude=$( head -n 64 < "${gDumpFolderHex}/LBA${cssInitBlocks[$c]}_Hex.txt" )
                        while read -r line; do

                            # Escape any ampersands.
                            # Repeat any percentage characters otherwise printf complains.
                            # Escape any forward slashes.
                            # Convert any spaces to html non breaking space $nbsp;.
                            line=$( echo "$line" | sed 's/&/\\&/g;s/%/%%/g;s/\//\\/g;s/ /\&nbsp\;/g' )
                            AppendHexDetailsData "${line}</br>"
                        done <<< "$fileToInclude"
                    else
                        AppendHexDetailsData "</br>"
                    fi

                    AppendHexDetailsData "            </div>"
                    AppendHexDetailsData "            <div id=\"diskInfoDetailsBox\" class=\"rsText_HexTable\">"
                    AppendHexDetailsData "                <p class=\"rsText_BodyBold\">Details</p>"
            
                    # Include the decoded hex details which would have been saved to file earlier.
                    # Read only the first 128 lines of the hex file (which should equate to 2048 bytes)
                    if [ -f "${gDumpFolderDecoded}/LBA${cssInitBlocks[$c]}_Details.txt" ]; then
                        fileToInclude=$( head -n 128 < "${gDumpFolderDecoded}/LBA${cssInitBlocks[$c]}_Details.txt" )
                        while read -r line; do
                            AppendHexDetailsData "${line}</br>"
                        done <<< "$fileToInclude"            
                    else
                        AppendHexDetailsData "</br>"
                    fi
            
                    AppendHexDetailsData "            </div>"
                    AppendHexDetailsData "        </div>"
                done

                #-----------------------------
                # Write all details to file.
                #-----------------------------

                # Insert the javascript block
                echo "<script type=\"text/javascript\">
function ${jsFuncName}(divID, state)
{
    var table = document.getElementById(divID);
${jsBlock}
    table.style.display = 'block';
}
</script>" >> "$gHtmlDumpFile"

                #WriteHtmlTableHeaderWithCollapseToFile "/dev/${diskToRead}"
                echo "<div id=\"tabs_${tabname}-${diskTabCount}\">" >> "$gHtmlDumpFile"

                #-----------------------------
                # Write sub title bar header.
                #-----------------------------

                # Insert the header data    
                 echo "    <div id=\"diskView_inner_table_subheader_info\">
                <table width=\"\" border=\"0\"><tr><td width=\"\" class=\"text_small_section_inner_title_White\">${diskInfoToInsert}<br>${diskInfoToInsert2}</td></tr></table>
            </div> <!-- End dump_section_inner_table_subheader_info -->" >> "$gHtmlDumpFile"

                #-----------------------------
                # Write table header.
                #-----------------------------

                # TABLE HEADER BAR - Part 1
                echo "    <div id=\"diskView_dd_frame\">    

        <!----------------------------------------  LEFT SIDE DISK TABLE ---------------------------------------->

        <div id=\"diskViewTable\">
    
            <!-- Header Bar -->
 
            <div class=\"t\">
                <div class=\"tr\" id=\"headerBar\">" >> "$gHtmlDumpFile"
                
                # TABLE HEADER BAR - Part 2 - Different contents for different partition type.
                if [ "$tmpTableType" == "gpt" ]; then
                    # Insert the partition table data
                    echo "
                    <div class=\"gpt_tc_Start_lba\" style=\"padding: 0px 10px 0px 0px; vertical-align: middle;\">Start LBA</div>
                    <div class=\"gpt_tc_Active\">A</div>
                    <div class=\"gpt_tc_Mbr_Pe\">MBR Partition Map</div>
                    <div class=\"gpt_tc_Type\">GPT Partition Map</div>
                    <div class=\"gpt_tc_Loader\">Loader</div>" >> "$gHtmlDumpFile"
                else
                    # Insert the partition table data
                    echo "
                    <div class=\"mbr_tc_Start_lba\" style=\"padding: 0px 10px 0px 0px; vertical-align: middle;\">Start LBA</div>
                    <div class=\"mbr_tc_Active\">A</div>
                    <div class=\"mbr_tc_Type\">MBR Partition Map</div>
                    <div class=\"mbr_tc_Loader\">Loader</div>" >> "$gHtmlDumpFile"
                fi
                
                # TABLE HEADER BAR - Part 3
                echo "                </div>
            </div>
 
            <!-- Partition Table -->
            
${diskTableData}
    </div> <!-- End diskViewTable -->
" >> "$gHtmlDumpFile"
                

       
       
       
                # Insert the hex and details data
                echo "    <!----------------------------------------  RIGHT SIDE DETAILS ---------------------------------------->
    
${hexDetailsData}

    </div><!-- End diskView_dd_frame -->" >> "$gHtmlDumpFile"
  
               echo "</div> <!-- End tabs_${tabname}-${diskTabCount} -->" >> "$gHtmlDumpFile"
               ((diskTabCount++))

                # Remove the temporary parse file
                if [ -f "$fileToProcess" ]; then
                    rm "$fileToProcess"
                fi
            fi

        done # End of for loop.
        
        # Write the css collapse init block
        echo "#$cssInitBlock" >> "$gCssDumpFile"
    	
        echo "</div> <!-- End div section for device id & set state -->" >> "$gHtmlDumpFile"
        
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlBootloaderConfigs()
{
    # Note - the config files are dumped by the diskutil and loader routine.
   
    local plistFiles=()
    local plistName=""
    local finalDestination="${gDumpFolderBootLoader##*/}/${gDumpFolderBootLoaderConfigs##*/}"
    local fileLocation=""
    local fileType=""
    local oIFS="$IFS"
    local tabname="BootloaderConfigs"
    local count=0
    local lastEntry=""
    
    # ---------------------------------------------------------------------------------------
    getConfigType()
    {
        local passedTextLine="$1"
        local fileType=""
        
        if [ ! "$passedTextLine" == "" ]; then
            case "${passedTextLine##*/}" in
                "org.chameleon.Boot.plist") fileType="<span style=\"color:#99CC33\">Chameleon</span>" ;;
                "SMBIOS.plist") fileType="<span style=\"color:#99CC33\">Chameleon</span>" ;;
                "com.apple.Boot.plist") fileType="<span style=\"color:#DDDDDD\">Apple</span>" ;;
                "config.plist") fileType="<span style=\"color:#FFFF66\">Clover</span>" ;;
                "CurrentCloverBootedConfig.plist") fileType="<span style=\"color:#FFFF66\">Clover</span>" ;;
                "settings.plist") fileType="<span style=\"color:#66FFFF\">XPC</span>" ;;
                "Defaults.plist") fileType="<span style=\"color:#fb6f6f\">Ozmosis</span>" ;;
            esac
            echo "$fileType" # This line acts as a return to the caller.
        fi
    }

    if [ -d "$gDumpFolderBootLoaderConfigs" ]; then
        echo "${gLogIndent}adding Bootloader config files" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Bootloader Config .plist files"
        WriteJavaScriptJqueryUITabToFile "$tabname"
        WriteOuterH3 "$tabname"
        IFS=$'\n'
        
        # Build list of files
        plistFiles=( $(find "$gDumpFolderBootLoaderConfigs" -type f -name "*.plist") )
        for (( c=0; c<${#plistFiles[@]}; c++ ))
        do
            stripVolumeA="${plistFiles[$c]##*Configuration Files/}"
            stripVolumeB="${stripVolumeA%-*}"
            fileDeviceID+=("$stripVolumeB")
            ((count++))
        done
        
        # Build tabs
        if [ $count -gt 0 ]; then
            echo "<div id=\"tabs_${tabname}\">
  <ul>" >> "$gHtmlDumpFile"
            local tabCount=1
            for (( n=0; n<$count; n++ ))
            do
                if [ ! "${fileDeviceID[$n]}" == "$lastEntry" ]; then
                    echo "    <li><a href=\"#tabs_${tabname}-${tabCount}\">${fileDeviceID[$n]}</a></li>" >> "$gHtmlDumpFile"
                    lastEntry="${fileDeviceID[$n]}"
                    ((tabCount++))
                fi
            done
            echo  "</ul>" >> "$gHtmlDumpFile"
        fi

        tabCount=1
        echo "<div id=\"tabs_${tabname}-${tabCount}\">" >> "$gHtmlDumpFile"
        lastEntry="${fileDeviceID[0]}"
        
        for (( p=0; p<${#plistFiles[@]}; p++ ))
        do
            if [ -f "${plistFiles[$p]}" ]; then

                if [ ! "${fileDeviceID[$p]}" == "$lastEntry" ]; then
                    echo "</div> <!-- End tabs_${tabname}-${tabCount} -->" >> "$gHtmlDumpFile"
                    ((tabCount++))
                    echo "<div id=\"tabs_${tabname}-${tabCount}\">" >> "$gHtmlDumpFile"
                fi

                fileLocation="${plistFiles[$p]##*$gDumpFolderBootLoaderConfigs/}"
                fileType=$(getConfigType "${plistFiles[$p]}")
                ReadFileAndWriteSubSectionToHtml "${plistFiles[$p]}"\
                                                 "/$fileLocation : $fileType"\
                                                 "<a href=\"$finalDestination/$fileLocation\" target=\"_blank\">View ${plistFiles[$p]##*/}</a>"\
                                                 ""\
                                                 "collapseID_BootLoaderConfigs$p"\
                                                 "none"
                echo "</div> <!-- End div section for device id & set state -->" >> "$gHtmlDumpFile"
                
                lastEntry="${fileDeviceID[$p]}"
            fi
        done
        IFS="$oIFS"
        
        echo "</div> <!-- End tabs_${tabname}-${tabCount} -->" >> "$gHtmlDumpFile"
        echo "</div> <!-- Close tabs_${tabname} -->" >> "$gHtmlDumpFile"
        WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlFirmwareLog()
{
    local fileName=()
    local finalDestination="${gDumpFolderBootLog##*/}"
    
    local checkFileExistence=`find "$gDumpFolderBootLog" -type f -name *_BootLog.txt -print 2>/dev/null`
    if [ ! "$checkFileExistence" == "" ]; then
        echo "${gLogIndent}adding firmware log" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Firmware Log"
        for file in "$gDumpFolderBootLog"/*_BootLog.txt
        do
            fileName+=("${file##*/}")
            if [[ "${fileName}" =~ "BootLog.txt" ]]; then
                ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderBootLog/${fileName}" "Firmware Log" "Dumped using the <a href=\"http://sourceforge.net/p/cloverefiboot/code/1905/tree/CloverPackage/utils/bdmesg/bdmesg.c\" target=\"_blank\">bdmesg tool</a>. Created by Kabyl, modified by JrCs from an idea by STLVNUB" "<a href=\"$finalDestination/${fileName}\" target=\"_blank\">View ${fileName} File</a>" "FirmwareLog" "aFirmwareLog" "" "collapseID_FirmLog"
                break
            fi
        done
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlFirmwareMemoryMap()
{
    local finalDestination="${gDumpFolderMemory##*/}"
    if [ -f "$gDumpFolderMemory/FirmwareMemoryMap.txt" ]; then
        echo "${gLogIndent}adding firmware memory map" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Firmware Memory Map"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderMemory/FirmwareMemoryMap.txt" "Firmware Memory Map" "Script: FirmwareMemoryMap (formerly showbootermemorymap) by Amit Singh. Revised by bcc9, then by dmazar." "<a href=\"$finalDestination/FirmwareMemoryMap.txt\" target=\"_blank\">View FirmwareMemoryMap.txt File</a>" "FirmwareMemoryMap" "aFirmwareMemoryMap" "" "CollapseID_FirmMemMap"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlIoreg()
{
    local finalDestination="${gDumpFolderIoreg##*/}"
    if [ -d "$gDumpFolderIoreg/IORegViewer/Resources/dataFiles" ]; then
        echo "${gLogIndent}adding IORegistry Viewer" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "I/O Kit Registry"
        WriteOuterH3 "I/O Kit Registry"
        WriteHtmlTableHeaderToFile "This is best viewed in a separate browser window/tab. <a href=\"$finalDestination/IORegViewer/IORegFileViewer.html\" target=\"_blank\">Click here to load it.</a>"
        WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlKernelLogs()
{
    local finalDestination="${gDumpFolderKernelLogs##*/}"
    if [ -d "$gDumpFolderKernelLogs" ]; then
        echo "${gLogIndent}adding kernel logs" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Kernel Logs"
        WriteOuterH3 "Kernel Logs (Apple System Log / dmesg)"
        ReadDirCreateTabsAddFileData "$gDumpFolderKernelLogs" "kernellogs"
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlKernelInfo()
{
    local finalDestination="${gDumpFolderKernelInfo##*/}"
    if [ -d "$gDumpFolderKernelInfo" ]; then
        echo "${gLogIndent}adding kernel info" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Kernel Info"
    	WriteOuterH3 "Kernel Info"
    	ReadDirCreateTabsAddFileData "$gDumpFolderKernelInfo" "kernelinfo"
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlKextLists()
{
    local finalDestination="${gDumpFolderKexts##*/}"
    
    # Only run if the text files exist
    if [ -f "$gDumpFolderKexts/NonAppleKexts.txt" ] || [ -f "$gDumpFolderKexts/AppleKexts.txt" ]; then
        echo "${gLogIndent}adding kext dumps" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "Kext Dumps"

        # For ref: Kextstat returns 8 output fields. Index, Refs, Address, Size, Wired, Name, Version, Linked Against   
        declare -a ksIndex
        declare -a ksRefs
        declare -a ksAddress
        declare -a ksSize
        declare -a ksWired
        declare -a ksName
        declare -a ksVer
        declare -a ksLinked

        # ---------------------------------------------------------------------------------------
        WriteHtml()
        {
            local passedAnchor="$1"
            local passedHeading="$2"
            local passedCount="$3"
            local passedSubHeader="$4"
            local passedTableTextHeading="$5"
        
            CalculateTableWidths "KextDump"
            WriteHtmlTableHeaderToFile "Dumped using: $passedSubHeader"
            WriteHtmlTableSubHeaderToFile "" "$passedHeading : $passedCount"
            WriteHtmlTableTextHeadingToFile "$passedTableTextHeading"
        }
    
        # ---------------------------------------------------------------------------------------
        readKextInfoInToStrings()
        {
            local fileToRead="$1"
            local kextCount=0
            ksIndex=(); ksRefs=(); ksAddress=(); ksSize=(); ksWired=(); ksName=(); ksVer=(); ksLinked=()
            firstLinked=0
            if [ -f "$fileToRead" ]; then
                oIFS="$IFS"; IFS=$'\n' 
                inFile=( `cat "$fileToRead"` )
                for (( n=0; n<${#inFile[@]}; n++ ))
                do
                    (( kextCount++ ))
                    ksIndex+=(`echo "${inFile[$n]}" | awk '{print $1}'`)
                    ksRefs+=(`echo "${inFile[$n]}" | awk '{print $2}'`)
                    ksAddress+=(`echo "${inFile[$n]}" | awk '{print $3}'`)
                    ksSize+=(`echo "${inFile[$n]}" | awk '{print $4}'`)
                    ksWired+=(`echo "${inFile[$n]}" | awk '{print $5}'`)
                    ksName+=(`echo "${inFile[$n]}" | awk '{print $6}'`)
                    ksVer+=(`echo "${inFile[$n]}" | awk '{print $7}'`)
                    ksLinked+=(`echo "${inFile[$n]}" | awk 'BEGIN { FS = "<" } ; {print $2}'`)
                    if [[ "${inFile[$n]}" =~ "<" ]] && [ $firstLinked -eq 0 ]; then
                        firstLinked=$kextCount
                    fi
                done
                IFS="$oIFS"
            fi
        }
    
        local tabname="Kexts"
        WriteJavaScriptJqueryUITabToFile "$tabname"
        WriteOuterH3 "$tabname"
        local count=0
        
        # Build list of file names and write tabs
        for file in "$gDumpFolderKexts"/*
        do
            files+=("${file##*/}")
            filesExtensionRemoved+=("${files[$count]%.txt*}")
            ((count++))
        done
        if [ $count -gt 0 ]; then
            echo "<div id=\"tabs_${tabname}\">
  <ul>" >> "$gHtmlDumpFile"
            for (( n=0; n<$count; n++ ))
            do
                echo "    <li><a href=\"#tabs_${tabname}-$((n+1))\">${filesExtensionRemoved[$n]}</a></li>" >> "$gHtmlDumpFile"
            done
            echo  "</ul>" >> "$gHtmlDumpFile"
        fi
        
        echo "<div id=\"tabs_${tabname}-1\">" >> "$gHtmlDumpFile"
        readKextInfoInToStrings "$gDumpFolderKexts/AppleKexts.txt"
        local totalCount=${#ksIndex[@]}
        # Note: some kexts at beginning of list aren't linked. 
        (( firstLinked-- )) # adjust for zero based array.
        WriteHtml "aAppleKexts" "Apple Kexts" "$totalCount" "kextstat -l | egrep \"com.apple\"" "AppleKexts"
        for (( n=0; n<$firstLinked; n++ )) # print first lines which are not linked
        do
            WriteHtmlTableTextToFile "${ksIndex[$n]}" "${ksRefs[$n]}" "${ksAddress[$n]}" "${ksSize[$n]}" "${ksWired[$n]}" "${ksName[$n]}" "${ksVer[$n]}"
        done
        for (( n=$firstLinked; n<$totalCount; n++ )) # print remaining lines which are linked
        do
            WriteHtmlTableTextToFile "${ksIndex[$n]}" "${ksRefs[$n]}" "${ksAddress[$n]}" "${ksSize[$n]}" "${ksWired[$n]}" "${ksName[$n]}" "${ksVer[$n]}" "<${ksLinked[$n-$firstLinked]}"
        done
        
        WriteHtmlTableTextEndingToFile
        echo "</div> <!-- End tabs_${tabname}-1 -->" >> "$gHtmlDumpFile"
        
        
        echo "<div id=\"tabs_${tabname}-2\">" >> "$gHtmlDumpFile"
        readKextInfoInToStrings "$gDumpFolderKexts/NonAppleKexts.txt"
        local totalCount=${#ksIndex[@]}
        WriteHtml "aNonAppleKexts" "Non Apple Kexts" "$totalCount" "kextstat -l | egrep -v \"com.apple\"" "NonAppleKexts"
        for (( n=0; n<$totalCount; n++ ))
        do
            WriteHtmlTableTextToFile "${ksIndex[$n]}" "${ksRefs[$n]}" "${ksAddress[$n]}" "${ksSize[$n]}" "${ksWired[$n]}" "${ksName[$n]}" "${ksVer[$n]}" "<${ksLinked[$n]}"
        done
        WriteHtmlTableTextEndingToFile
        echo "</div> <!-- End tabs_${tabname}-2 -->" >> "$gHtmlDumpFile"
        echo "</div> <!-- Close tabs_${tabname} -->" >> "$gHtmlDumpFile"
        WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlLspci()
{
    local finalDestination="${gDumpFolderLspci##*/}"
    
    if [ -d "$gDumpFolderLspci" ]; then
        echo "${gLogIndent}adding LSPCI dumps" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "LSPCI"
        WriteOuterH3 "LSPCI"
        ReadDirCreateTabsAddFileData "$gDumpFolderLspci" "lspciinfo"
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlOpenCL()
{
    local finalDestination="${gDumpFolderOpenCl##*/}"
    if [ -f "$gDumpFolderOpenCl/openCLinfo.txt" ]; then
        echo "${gLogIndent}adding OpenCL dump" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "OpenCL"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderOpenCl/openCLinfo.txt" "OpenCL" "Dumped using opencl by cmf from 2009" "<a href=\"$finalDestination/openCLinfo.txt\" target=\"_blank\">View openCLinfo.txt File</a>" "OpenCL" "aOpenCL" "" "collapseID_OpenCL"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlRtc()
{
    local finalDestination="${gDumpFolderRtc##*/}"
    if [ -f "$gDumpFolderRtc/RTCDump${rtclength}.txt" ]; then
        echo "${gLogIndent}adding RTC dump" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "RTC"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderRtc/RTCDump${rtclength}.txt" "RTC" "Dumped using cmosDumperForOsx by rafirafi, revised extensively by STLVNUB" "<a href=\"$finalDestination/RTCDump${rtclength}.txt\" target=\"_blank\">View RTCDump${rtclength}.txt File</a>" "RTC" "aRTC" "" "collapseID_RTC"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlDmiTables()
{
    local warningMessage=()
    local checkMessage=""
    local finalDestination="${gDumpFolderDmi##*/}"
    local tabName="dmi"
    local outfileTableDir="${gDDTmpFolder}/dmi_split_files/"
    local outfileTableName="dmi_table_type_"
    local currentType=""
    local currentHandle=""
    local infoString=""
    declare -a tableType
    declare -a tableTypeSorted
    declare -a findFiles

    #warningMessage[0]="Wrong DMI structures"
    #warningMessage[1]="DMI table is broken"

    if [ -f "$gDumpFolderDmi/SMBIOS.txt" ]; then
        echo "${gLogIndent}adding DMI dump" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "DMI Tables"
        WriteOuterH3 "DMI Tables"
    	WriteJavaScriptJqueryUITabToFile "$tabName"
        
        oIFS="$IFS"; IFS=$'\n'
        
        echo "<div id=\"tabs_$tabName\">
  <ul>" >> "$gHtmlDumpFile"
  
        if [ ! -d "$outfileTableDir" ]; then
            mkdir "$outfileTableDir"
        fi
        
        # Split SMBIOS.txt file in to individual handle files.
        while read -r lineRead
        do
            if [[ "$lineRead" == *"DMI type"* ]]; then
                currentType="${lineRead##*type }";
                currentType="${currentType%,*}"

                # Is number already in array?
                match=0
                for type in "${tableType[@]}"
                do
                    if [[ $type = "$currentType" ]]; then
                        match=1
                        break
                    fi
                done
                if [[ $match = 0 ]]; then
                    tableType+=($currentType)  
                fi
                currentHandle="${lineRead%%,*}";
                currentHandle="${currentHandle##* }"
            else
                echo "$lineRead" >> "${outfileTableDir}${outfileTableName}${currentType}_${currentHandle}".txt  
            fi
        done < "$gDumpFolderDmi/SMBIOS.txt"
     
        # Sort type array
        tableTypeSorted=($(sort -g <<<"${tableType[*]}"))
        
        # Print tab entries to main html file.
        for ((s=0; s<${#tableTypeSorted[@]}; s++))
        do       
            echo "    <li><a href=\"#tabs_$tabName-$s\">${tableTypeSorted[$s]}</a></li>" >> "$gHtmlDumpFile"
        done
        
        echo "</ul>" >> "$gHtmlDumpFile"
        
        # Insert each table under it's subsequent tab
        for ((s=0; s<${#tableTypeSorted[@]}; s++))
        do       
            echo "<div id=\"tabs_$tabName-$s\">" >> "$gHtmlDumpFile"
            findFiles=( $(find "$outfileTableDir" -type f -name "${outfileTableName}${tableTypeSorted[$s]}_0x*.txt") )
            for (( x=0; x<${#findFiles[@]}; x++ ))
            do
                handle=$( echo "${findFiles[$x]##*_}" | tr -d '.txt' )
           
                # Add a description for the table type
                case "${tableTypeSorted[$s]}" in
                    0) infoString="DMI Type 0: BIOS" ;;
                    1) infoString="DMI Type 1: System" ;;
                    2) infoString="DMI Type 2: Base Board" ;;
                    3) infoString="DMI Type 3: Chassis" ;;
                    4) infoString="DMI Type 4: Processor" ;;
                    5) infoString="DMI Type 5: Memory Controller" ;;
                    6) infoString="DMI Type 6: Memory Module" ;;
                    7) infoString="DMI Type 7: Cache" ;;
                    8) infoString="DMI Type 8: Port Connector" ;;
                    9) infoString="DMI Type 9: System Slots" ;;
                    10) infoString="DMI Type 10: On Board Devices" ;;
                    11) infoString="DMI Type 11: OEM Strings" ;;
                    12) infoString="DMI Type 12: System Configuration Options" ;;
                    13) infoString="DMI Type 13: BIOS Language" ;;
                    14) infoString="DMI Type 14: Group Associations" ;;
                    15) infoString="DMI Type 15: System Event Log" ;;
                    16) infoString="DMI Type 16: Physical Memory Array" ;;
                    17) infoString="DMI Type 17: Memory Device" ;;
                    18) infoString="DMI Type 18: 32-bit Memory Error" ;;
                    19) infoString="DMI Type 19: Memory Array Mapped Address" ;;
                    20) infoString="DMI Type 20: Memory Device Mapped Address" ;;
                    21) infoString="DMI Type 21: Built-in Pointing Device" ;;
                    22) infoString="DMI Type 22: Portable Battery" ;;
                    23) infoString="DMI Type 23: System Reset" ;;
                    24) infoString="DMI Type 24: Hardware Security" ;;
                    25) infoString="DMI Type 25: System Power Controls" ;;
                    26) infoString="DMI Type 26: Voltage Probe" ;;
                    27) infoString="DMI Type 27: Cooling Device" ;;
                    28) infoString="DMI Type 28: Temperature Probe" ;;
                    29) infoString="DMI Type 29: Electrical Current Probe" ;;
                    30) infoString="DMI Type 30: Out-of-band Remote Access" ;;
                    31) infoString="DMI Type 31: Boot Integrity Services" ;;
                    32) infoString="DMI Type 32: System Boot" ;;
                    33) infoString="DMI Type 33: 64-bit Memory Error" ;;
                    34) infoString="DMI Type 34: Management Device" ;;
                    35) infoString="DMI Type 35: Management Device Component" ;;
                    36) infoString="DMI Type 36: Management Device Threshold Data" ;;
                    37) infoString="DMI Type 37: Memory Channel" ;;
                    38) infoString="DMI Type 38: IPMI Device" ;;
                    39) infoString="DMI Type 39: Power Supply" ;;
                    40) infoString="DMI Type 40: Additional Information" ;;
                    41) infoString="DMI Type 41: Onboard Device" ;;
                    42) infoString="DMI Type 42: Management Controller Host Interface" ;;
    4[3-9]|1[0-2][0-5]) infoString="DMI Type ${tableTypeSorted[$s]}: Unknown Table Type" ;;
                    126) infoString="DMI Type 126: Disabled Entry" ;;
                    127) infoString="DMI Type 127: End of Table Marker" ;;
                    128) infoString="DMI Type 128: OEM Table - Apple FirmwareVolume" ;;
                    130) infoString="DMI Type 130: OEM Table - Apple Memory SPD" ;;
                    131) infoString="DMI Type 131: OEM Table - Apple Processor Type" ;;
                    132) infoString="DMI Type 132: OEM Table - Apple Processor Interconnect Speed" ;;   
                    133) infoString="DMI Type 133: OEM Table - Apple - Unknown Table Type" ;;                
                      *) infoString="DMI Type ${tableTypeSorted[$s]}: OEM Table - Unknown Table Type" ;;
                esac
            
                # To have the sub tables collapsed by default, use these two lines.
                ReadFileAndWriteSubSectionToHtml "${findFiles[$x]}"\
                                                 "${infoString}&nbsp;&nbsp;&nbsp;&nbsp;<span style=\"color:#CCC\">Handle:$handle</span>"\
                                                 "<a href=\"$finalDestination/$fileLocation\" target=\"_blank\">View ${plistFiles[$p]##*/}</a>"\
                                                 "dmitables"\
                                                 "collapseID_DMITables_${s}_${x}"\
                                                 "block"
                # To have the sub tables open/un-collapsed for the dmi tables, use this instead of the code above.
                #ReadFileAndWriteSubSectionToHtml "${findFiles[$x]}" "${infoString}&nbsp;&nbsp;&nbsp;&nbsp;<span style=\"color:#CCC\">Handle:$handle</span>" "<a href=\"$finalDestination/$fileLocation\"target=\"_blank\">View SMBIOS.txt File</a>" "dmitables" "" "" "none"
                echo "</div> <!-- End div section for device id & set state -->" >> "$gHtmlDumpFile"
            done
            echo "</div> <!-- End tabs_$tabName-$s -->" >> "$gHtmlDumpFile"
        done
        
        echo "</div> <!-- Close tabs_rcscripts -->" >> "$gHtmlDumpFile"
    	WriteEndingH3
        
        # Clean up
        if [ -d "$outfileTableDir" ]; then
            rm "$outfileTableDir"/*
            rmdir "$outfileTableDir"
        fi

        # Check for a couple of warnings
        #for (( n=0; n<${#warningMessage[@]}; n++ ))
        #do
        #    checkMessage=`fgrep "${warningMessage[$n]}" "$gDumpFolderDmi/SMBIOS.txt"`
        #    if [ ! "$checkMessage" == "" ]; then
        #        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderDmi/SMBIOS.txt" "SMBIOS" "Dumped using smbios-reader & <a href=\"http://www.nongnu.org/dmidecode/\">dmidecode</a> v2.12. dmidecode <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2208\">compiled for OS X</a> by Slice." "<a href=\"$finalDestination/SMBIOS.txt\" target=\"_blank\">View SMBIOS.txt File</a>" "SMBIOS" "aSMBIOS" "Warning: $checkMessage" "collapseID_SMBIOS"
        #        break
        #    fi
        #done
        
        #if [ "$checkMessage" == "" ]; then
        #    ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderDmi/SMBIOS.txt" "SMBIOS" "Dumped using smbios-reader & <a href=\"http://www.nongnu.org/dmidecode/\">dmidecode</a> v2.12. dmidecode <a href=\"http://www.projectosx.com/forum/index.php?showtopic=2208\">compiled for OS X</a> by Slice." "<a href=\"$finalDestination/SMBIOS.txt\" target=\"_blank\">View SMBIOS.txt File</a>" "SMBIOS" "aSMBIOS" "" "collapseID_SMBIOS"
        #fi
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlSmcKeys()
{
    local finalDestination="${gDumpFolderSmc##*/}"
    if [ -d "$gDumpFolderSmc" ]; then
        echo "${gLogIndent}adding SMC dumps" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "SMC"
        WriteOuterH3 "SMC"
        ReadDirCreateTabsAddFileData "$gDumpFolderSmc" "smc"
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlSytemProfiler()
{
    local finalDestination="${gDumpFolderSysProf##*/}"
    if [ -f "$gDumpFolderSysProf/System-Profiler.txt" ]; then
        echo "${gLogIndent}adding System Profiler dump" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "System Profiler"
        ReadFileAndWriteCompleteSectionToHtml "$gDumpFolderSysProf/System-Profiler.txt" "System Profiler" "Dumped using /usr/sbin/system_profiler -detailLevel mini" "<a href=\"$finalDestination/System-Profiler.txt\" target=\"_blank\">View System-Profiler.txt File</a>" "SystemProfiler" "aSystemProfiler" "" "collapseID_SysProf"
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlRcScripts()
{
    local finalDestination="${gDumpFolderRcScripts##*/}"
    declare -a readScriptFiles

    # ---------------------------------------------------------------------------------------
    BuildTabs()
    {
        if [ ${#readScriptFiles[@]} -gt 0 ]; then
        
            echo "<div id=\"tabs_rcscripts\">
  <ul>" >> "$gHtmlDumpFile"

            for (( x=0; x<${#readScriptFiles[@]}; x++ ))
            do
                if [ -f "${readScriptFiles[$x]}" ]; then
                    fileLocation="${readScriptFiles[$x]##*$gDumpFolderRcScripts/}"
                    echo "
    <li><a href=\"#tabs_rcscripts-(($x+1))\">/etc/${fileLocation}</a></li>" >> "$gHtmlDumpFile"
                fi
            done
            echo "</ul>" >> "$gHtmlDumpFile"
        fi
    }
    
    # ---------------------------------------------------------------------------------------
    AddScriptsDumps()
    {
        if [ ${#readScriptFiles[@]} -gt 0 ]; then
            echo "${gLogIndent}adding RC Startup and Shutdown scripts" >> "${gLogFile}"
            finalDestination="RC Scripts"
            for (( x=0; x<${#readScriptFiles[@]}; x++ ))
            do
                if [ -f "${readScriptFiles[$x]}" ]; then
                    fileLocation="${readScriptFiles[$x]##*$gDumpFolderRcScripts/}"
                    echo "<div id=\"tabs_rcscripts-(($x+1))\">" >> "$gHtmlDumpFile"
                    ReadFileAndWriteSubSectionToHtml "${readScriptFiles[$x]}"\
                                                     "Found from searching /etc/rc*"\
                                                     "<a href=\"$finalDestination/$fileLocation\">View ${readScriptFiles[$x]##*/} file</a>"\
                                                     "RCScripts"\
                                                     ""\
                                                     "none"
                    echo "</div> <!-- Endtabs_rcscripts-(($x+1)) -->" >> "$gHtmlDumpFile"
                fi
            done
        fi
    }
    
    if [ -d "$gDumpFolderRcScripts" ]; then
        InsertInternalSeparatorHTMLToFile "RC Startup and Shutdown scripts"
        WriteOuterH3 "RC Startup and Shutdown scripts"
    	WriteJavaScriptJqueryUITabToFile "rcscripts"
    	
    	local oIFS="$IFS"
        IFS=$'\n'
        readScriptFiles=( $(find "$gDumpFolderRcScripts" -type f -not -path '*svn*') )
    	IFS="$oIFS"
    	
    	BuildTabs
        AddScriptsDumps
        
        echo "</div> <!-- Close tabs_rcscripts -->" >> "$gHtmlDumpFile"
    	WriteEndingH3
    fi
}

# ---------------------------------------------------------------------------------------
DumpHtmlNvram()
{
    local finalDestination="${gDumpFolderNvram##*/}"
    if [ -d "$gDumpFolderNvram" ]; then
        echo "${gLogIndent}adding nvram info" >> "${gLogFile}"
        InsertInternalSeparatorHTMLToFile "NVRAM"
    	WriteOuterH3 "NVRAM"
    	ReadDirCreateTabsAddFileData "$gDumpFolderNvram" "nvraminfo"
    	WriteEndingH3
    fi
}


# ---------------------------------------------------------------------------------------
DumpHtmlEdid()
{
    local finalDestination="${gDumpFolderEdid##*/}"
    local tabname="edid"
    local edidFileName=""
    local edidFileNameExtensionRemoved=""

    if [ -d "$gDumpFolderEdid" ]; then
    
        # Build list of files
        local edidFiles=( $(find "$gDumpFolderEdid" -type f -name "EDI*.txt") )

        if [ ${#edidFiles[@]} -gt 1 ]; then
            InsertInternalSeparatorHTMLToFile "EDID"
            WriteOuterH3 "EDID"
            WriteJavaScriptJqueryUITabToFile "$tabname"

            # Build tabs
            echo "<div id=\"tabs_${tabname}\">
  <ul>" >> "$gHtmlDumpFile"
            for (( n=0; n<${#edidFiles[@]}; n++ ))
            do
                echo "    <li><a href=\"#tabs_${tabname}-${n}\">${edidFiles[$n]##*/}</a></li>" >> "$gHtmlDumpFile"
            done
            echo  "</ul>" >> "$gHtmlDumpFile"

            # Read file and add contents in to each tab
            for (( n=0; n<${#edidFiles[@]}; n++ ))
            do
                edidFileName="${edidFiles[$n]##*/}"
                echo "${gLogIndent}adding $edidFileName" >> "${gLogFile}"
                edidFileNameExtensionRemoved="${edidFileName%.txt*}"
                echo "<div id=\"tabs_${tabname}-${n}\">" >> "$gHtmlDumpFile"
                ReadFileAndWriteSubSectionToHtml "${gDumpFolderEdid}/${edidFileName}"\
                                                  "${edidFileNameExtensionRemoved}"\
                                                  "Dumped IODisplayEDID from ioreg and decoded using <a href=\"http://cgit.freedesktop.org/xorg/app/edid-decode/\" target=\"_blank\">edid-decode</a> by Adam Jackson. <a href=\"$finalDestination/${edidFileName}\" target=\"_blank\">View ${edidFileName} File</a>"\
                                                  "${edidFileName}"\
                                                  ""\
                                                  ""
                echo "</div> <!-- End tabs_${tabname}-${n} -->" >> "$gHtmlDumpFile"
            done
            echo "</div> <!-- Close tabs_edid -->" >> "$gHtmlDumpFile"
        	WriteEndingH3

        else
            # Only one file to read
            if [ -f "$gDumpFolderEdid/EDID.txt" ]; then
                echo "${gLogIndent}adding EDID.txt" >> "${gLogFile}"
                InsertInternalSeparatorHTMLToFile "EDID"
                ReadFileAndWriteCompleteSectionToHtml "${gDumpFolderEdid}/EDID.txt" "EDID" "Dumped IODisplayEDID from ioreg and decoded using <a href=\"http://cgit.freedesktop.org/xorg/app/edid-decode/\">edid-decode</a> by Adam Jackson. Updated by Andy Vandijck." "<a href=\"$finalDestination/EDID.txt\" target=\"_blank\">View EDID.txt File</a>" "EDID" "aEDID" "" "collapseID_EDID" "block"
            fi
        fi
    fi
}

#
# =======================================================================================
# MAIN
# =======================================================================================
#


#CheckRoot
Initialise "$1" "$2" "$3" "$4" "$5" "$6" "$7"
CreateAndInitialiseHtmlFile
WriteAccordionOpen
DumpHtmlAcpiTables
DumpHtmlAudio
DumpHtmlBiosSystem
DumpHtmlBiosVideo
DumpHtmlBootLoaderAndDiskSectors
DumpHtmlBootloaderConfigs
DumpHtmlCpuInfo
DumpHtmlDeviceProperties
DumpHtmlDisks
DumpHtmlDiskUUIDs
DumpHtmlDmiTables
DumpHtmlEdid
DumpHtmlFirmwareLog
DumpHtmlFirmwareMemoryMap
DumpHtmlIoreg
DumpHtmlKernelLogs
DumpHtmlKernelInfo
DumpHtmlKextLists
DumpHtmlLspci
DumpHtmlNvram
DumpHtmlOpenCL
DumpHtmlRcScripts
DumpHtmlRtc
DumpHtmlSmcKeys
DumpHtmlSytemProfiler
WriteAccordionClose
WriteDumpContainerClose
CloseCssFile
CloseHtmlFile
WriteIECssToFile
CombineCssJsAndHtmlFiles