---@ for common features
EsoCommon = {}
-- todo:polish ui rough sinse powder rush me
-- This should instead be written in the actual Btree that is loaded, not by code ...
function EsoCommon.DrawBTreeMainMenu()
    GUI:Text("")
    GUI:Text("UI rough. please polish. (powder rushes me so). ")
    GUI:Text("BehaviorManager.SettingsUI inside eso_common.lua")
    GUI:Text("")
    if GUI:Button("Close Btree Settings") then
        BehaviorManager.settings_open = false
    end
    Settings.Global.show_btree_editor = GUI:Checkbox("show btree editor ## btreeminion", Settings.Global.show_btree_editor)
    Settings.Global.show_btree_manager = GUI:Checkbox("show btree manager ## btreeminion", Settings.Global.show_btree_manager)
end
if (BTSettings) then -- setting this func to be drawn by ALL active Btrees as main menu... (that's not how it should work btw..)
    BTSettings.SetDrawMainMenuFunction ( EsoCommon.DrawBTreeMainMenu )
end

--todo : maybe need more like pause passive tree and that
function EsoCommon.StopTaskWithPopUp(str)
    BehaviorManager:Stop()
    Player:StopMovement()
    eso_dialog_manager.IssueNotice(str)
end
