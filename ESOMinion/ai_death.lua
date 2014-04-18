-- Handles Death and respawn
-----------
c_dead = inheritsFrom( ml_cause )
e_dead = inheritsFrom( ml_effect )
c_dead.lastHealth = nil
c_dead.deadTmr = 0
function c_dead:evaluate()
	if ( Player.dead ) then
		return true
	end
	c_dead.deadTmr = 0
	return false
end
function e_dead:execute()
	ml_log("e_dead ")
	ml_global_information.Wait( 2000 ) 
	e("Release()")
	
end
