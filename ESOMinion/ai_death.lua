-- Handles Death and respawn
-----------
c_dead = inheritsFrom( ml_cause )
e_dead = inheritsFrom( ml_effect )
e_dead.lastseenalive = 0
e_dead.wait = 5000

function c_dead:evaluate()
	if ( ml_global_information.Player_Dead == true) then
		return true
	end
	e_dead.lastseenalive = ml_global_information.Now
	return false
end

function e_dead:execute()
	ml_log("e_dead")
	if ml_global_information.Now - e_dead.lastseenalive > e_dead.wait then
		ml_global_information.ResetBot()
		e("Release()")		
	end
end
