/*
 * MPS-converter - Convert setups made for MPS
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright © the AVsitter Contributors (http://avsitter.github.io)
 * AVsitter™ is a trademark. For trademark use policy see:
 * https://avsitter.github.io/TRADEMARK.mediawiki
 *
 * Please consider supporting continued development of AVsitter and
 * receive automatic updates and other benefits! All details and user
 * instructions can be found at http://avsitter.github.io
 */

// At the moment, this script is too primitive. It only converts pose
// names and positions/rotations, not any other features. It generates
// SYNC only and one sitter at a time (per prim). If the setup requires
// POSE lines, they need to be changed manually.
//
// ********************************************************************
//
// Usage: Drop this script into each of the prims that have MPS sitters
// and copy the resulting chat to an AVpos notecard. Note it needs to
// be used in the prim that has a [zED]~MPS~Settings notecard of the
// build; it doesn't work to take the notecard out of the object,
// because it needs to read position/rotation data from the prim that
// it was setup for.
//
// You need to add manually the SITTER line and edit all SYNC that need
// to be POSE instead. The menus also need to be redone. Other features
// need to be replicated manually.

string NcName = "[zED]~MPS~Settings";
key NcQuery;
integer NcLine;

default
{
    state_entry()
    {
        llOwnerSay("-------------Beginning dump");
        llSleep(2);
        NcQuery = llGetNotecardLine(NcName, NcLine = 0);
    }

    dataserver(key id, string data)
    {
        if (NcQuery != id) return;
        if (data == EOF)
        {
            llSleep(2);
            llOwnerSay("-------------End of dump");
            llRemoveInventory(llGetScriptName());
            return;
        }
        NcQuery = llGetNotecardLine(NcName, ++NcLine);
        list parse = llParseStringKeepNulls(data, [" # "], []);

        if (llGetListLength(parse) > 1 && llSubStringIndex(llList2String(parse, 0), "CPU|") != -1)
        {
            parse = llParseStringKeepNulls(llList2String(parse, 1), [" ; "], []);
            vector pos = (vector)llList2String(parse, 2);
            rotation rot = (rotation)llList2String(parse, 3);
            vector childpos = llGetLocalPos();
            rotation childrot = llGetLocalRot();
            pos = (pos + <0,0,.4> + <0,0,-.05>*rot) * childrot + childpos;
            rot = rot * childrot;
            list new = llParseString2List(llList2String(parse, 1), [" | "], []);
            llOwnerSay("◆SYNC " + llList2String(parse, 0) + "|" +  llList2String(new, 0));
            llOwnerSay("◆{" + llList2String(parse, 0) + "}" + (string)pos + (string)(llRot2Euler(rot)*RAD_TO_DEG));
        }
    }
}
