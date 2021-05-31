pmemoize = {}
pmemoize.loadedfunctions = {}

function InitializeMemoize()
	if (not memoize) then
		memoize = {}
	end
	if (not memoize.entities) then
		memoize.entities = {}
	end
	return true
end

function GetMemoized(key)
	if (memoize[key] == "nil") then
		return nil
	else
		if (memoize[key]) then
			return memoize[key]
		end
	end
	return nil
end

function SetMemoized(key,variant)
	InitializeMemoize()
	memoize[key] = variant
end

function AddMemoizedEntity(id,entity)
	memoize.entities[id] = entity
end

function MGetGameCameraInteractableActionInfo()
	local memString = "GetGameCameraInteractableActionInfo"
	local memoized = GetMemoized(memString)
	if (memoized) then
		return memoized
	else
		local using = e("GetGameCameraInteractableActionInfo()")
		SetMemoized(memString,using)
		return using
	end
end
function MUsingAutoFace()
	local memString = "MUsingAutoFace"
	local memoized = GetMemoized(memString)
	if (memoized) then
		return memoized
	else
		local using = UsingAutoFace()
		SetMemoized(memString,using)
		return using
	end
end
function MGetGameState()
	local memoized = memoize.gamestate
	if (table.valid(memoized)) then
		return memoized
	else
		memoize.gamestate = GetGameState()
		return memoize.gamestate
	end
end

function MGetEntity(entityid)
	entityid = tonumber(entityid) or 0
	
	local memString = "MGetEntity;"..tostring(entityid)
	local memoized = GetMemoized(memString)
	if (memoized) then
		return memoized
	else
		local entity = EntityList:Get(entityid)
		SetMemoized(memString,entity)
		return entity
	end
end

function MIsMoving()
	local memString = "MIsMoving"
	local memoized = GetMemoized(memString)
	if (memoized) then
		return memoized
	else
		local ret = Player:IsMoving()
		SetMemoized(memString,ret)
		return ret
	end
end

function MGetTarget()
	local memString = "MGetTarget"
	local memoized = GetMemoized(memString)
	if (memoized) then
		return memoized
	else
		local target = Player:GetTarget()
		SetMemoized(memString,target)
		return target
	end
end

function MEntityList(elstring)
	elstring = elstring or ""
	local memString = "MEntityList;"..tostring(elstring)
	local memoized = GetMemoized(memString)
	if (memoized) then
		return memoized
	else
		InitializeMemoize()
		local el = EntityList(elstring)
		if (table.valid(el)) then
			SetMemoized(memString,el)
			return el
		end
	end
end
			
-- Functions below pertain to permanent memoize, never-changing data.
function GetPermaMemoized(key)
	return pmemoize[key]
end

function SetPermaMemoized(key,variant)
	pmemoize[key] = variant
end

function PDistance3D(x1,y1,z1,x2,y2,z2)
	x1 = round(x1, 1)
	y1 = round(y1, 1)
	z1 = round(z1, 1)
	x2 = round(x2, 1)
	y2 = round(y2, 1)
	z2 = round(z2, 1)
	
	return Distance3D(x1,y1,z1,x2,y2,z2)
end