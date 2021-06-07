local lib_action = {}
lib_action.dictionaries = {}
lib_action.ModuleFunctions = GetPrivateModuleFunctions()
lib_action.testingPath = GetStartupPath()..[[\LuaMods\ESOLib\data\]]
lib_action.API = {}
if not ESOLib then
	_G["ESOLib"] = {}
end

function lib_action.StripFileExtension(filename)
	return string.gsub(filename,"%..+$","")
end
function lib_action.LoadData()	
	if (not ValidTable(lib_action.ModuleFunctions)) then
		lib_action.LoadTestingData("skill_data.lua")
	else
		lib_action.LoadPrivateData("skill_data.lua")
	end
end
lib_action.API.LoadData = lib_action.LoadData

function lib_action.LoadTestingData(filename)
d("attempting to load data for ["..tostring(filename).."]")
    if (filename ~= "" and FileExists(lib_action.testingPath..filename)) then
        local profileData,e = persistence.load(lib_action.testingPath..filename)
		if (ValidTable(profileData)) then
			local entryName = lib_action.StripFileExtension(filename)
			if (entryName ~= "") then
				if (lib_action[entryName] == nil) then
					lib_action[entryName] = profileData
					lib_action.dictionaries[entryName] = true
					d("["..tostring(entryName).."] was loaded")
				end
			end
		else
			d("Could not load profile data:"..tostring(e))
		end
    end
end
function lib_action.LoadPrivateData(filename)
	if (lib_action.ModuleFunctions and lib_action.ModuleFunctions.ReadModuleFile) then
		local fileInfo = { p = "data" , m = "ESOLib" , f = filename }
		local fileString = lib_action.ModuleFunctions.ReadModuleFile(fileInfo)
		if (fileString) then
			local entryName = lib_action.StripFileExtension(filename)
			local fileFunction, errorMessage = loadstring(fileString)
			if (fileFunction) then
				lib_action[entryName] = fileFunction()
				lib_action.dictionaries[entryName] = true
			end
		end
	end
end

lib_action.LoadData()

function lib_action.UnloadData()
	if (table.valid(lib_action.dictionaries)) then
		for dictionary,_ in pairs(lib_action.dictionaries) do
			lib_action[dictionary] = nil
			lib_action.dictionaries[dictionary] = false
		end
	end
end
lib_action.API.UnloadData = lib_action.UnloadData

function lib_action.GetSkillData(id)
	local skillLib = lib_action["skill_data"]
	if (table.valid(skillLib)) then
		if skillLib[id] then
			return skillLib[id]
		end
	end
	return nil
end
lib_action.API.GetSkillData = lib_action.GetSkillData

ESOLib.Action = setmetatable({}, {__index = lib_action.API, __newindex = function() end, __metatable = false})
