/*      Title:  Find value of a sequence                                    */
/*    Purpose:  To find all uses of finding the value of a sequence         */
/*  -----------------------------------------------------------------

    Copyright (C) 2002 Murray Hermann

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   ------------------------------------------------------------------------ */

{prolint/core/ruleparams.i}

run searchNode            (hTopnode,              /* "Program_root" node                 */
                           "priv-InspectNode":U,  /* name of callback procedure          */
                           "CURRENTVALUE,NEXTVALUE":U).             /* list of statements to search, ?=all */

return.

                                                                                
procedure priv-InspectNode :   
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var lWrite%         as logi initial false           no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sSequenceName%    as char                       no-undo.
def var sSequenceType%  as char                         no-undo.
def var sRecordAttr%    as char                         no-undo.
def var iSibling%       as inte                         no-undo.
def var sSiblingType%   as char                         no-undo.   
def var sAttrType%      as char                         no-undo.
def var sString%        as char                         no-undo.

    
    /* Assign handles and pointers to specific nodes in the Parse Tree */
    assign
        iChild%        = parserGetHandle()
        iSibling%      = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%).
    
    if sChildType% = "" then 
    do:
        parserReleaseHandle(iChild%).
        parserReleaseHandle(iSibling%).
        return.
    end.  
    
                                                                  
    if sNodeType% = "CURRENTVALUE":U OR sNodeType% = "NEXTVALUE":U  then
    do:
        lWrite% = yes.        
        /* The the first sibling of the child node is the ID node of the sequence */
        sChildType% = parserNodeNextSibling(iChild%,iChild%).
        
        if sChildType% = "ID":U then
        do:
            sSequenceName% = parserGetNodeText(iChild%).
            
            /* If the sequence name is invalid then place a warning */
            if index(sSequenceName%, '_seq') <> 0 then
            do:
                
                sNodeType% = "Sequence name".
                run priv-WriteResult(
                    input ipiTheNode%, 
                    input sNodeType%,
                    input sSequenceName%,
                    input "has an invalid ending (_SEQ).").

            end.
        end.
       
    end.
    
    if lWrite% then
        run priv-WriteResult(
            input ipiTheNode%, 
            input sNodeType%,
            input sSequenceName%,
            input "statement used in this program.").
                     
    
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).

end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsSequenceName%    as char         no-undo.
def input param ipsString%          as char         no-undo.

    run PublishResult            (compilationunit,
                                  parserGetNodeFilename(ipiTheNode%),
                                  parserGetNodeLine(ipiTheNode%), 
                                  substitute("&1 &2 &3":T, ipsNodeType%,ipsSequenceName%,ipsString%),
                                  rule_id).
end procedure.


