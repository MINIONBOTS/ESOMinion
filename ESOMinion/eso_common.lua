---@ for common features
EsoCommon = {}
-- todo:polish ui rough sinse powder rush me
function EsoCommon.BtreeSettingsUI()
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
--todo : maybe need more like pause passive tree and that
function EsoCommon.StopTaskWithPopUp(str)
    BehaviorManager:Stop()
    Player:StopMovement()
    eso_dialog_manager.IssueNotice(str)
end
