
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

math.randomseed(CurTime())
self.exploded = false
self.armed = true
self.ticking = true
self.smoking = false
self.flightvector = self.Entity:GetUp() * 100
self.Entity:SetModel( "models/combatmodels/tankshell.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            

self:Think()
 
end   

 function ENT:Think()
	if (self.smoking == false) then
		self.smoking = true
	
		FireTrail = ents.Create("env_fire_trail")
		FireTrail:SetKeyValue("spawnrate","3")
		FireTrail:SetKeyValue("firesprite","sprites/firetrail.spr" )
		FireTrail:SetPos(self.Entity:GetPos())
		FireTrail:SetParent(self.Entity)
		FireTrail:Spawn()
		FireTrail:Activate()
	end 


			local tr = ShieldTrace(self.Entity:GetPos()+ self.Entity:GetUp() * 10,self.flightvector * 3,self.Entity) 
		
	if (tr.Hit) then
		if ( self.exploded == false ) then
			if tr.HitShield then
				self.Entity:SetPos(tr.HitPos)
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
				local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())
					effectdata:SetStart(self.Entity:GetPos())
				util.Effect( "Explosion", effectdata )
					self.exploded = true
					tr.Entity:Hit(self.Entity,tr.HitPos,10,(self.Entity:GetPos()-tr.Entity:GetPos()):Normalize())
					self.Entity:Remove()
					
					return true
			elseif ( self.exploded == false && self.ticking == true ) then
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
				if (tr.Entity:IsWorld() || tr.Entity:IsPlayer() || tr.Entity:IsNPC() || tr.HitSky ) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())
					effectdata:SetStart(self.Entity:GetPos())
					util.Effect( "Explosion", effectdata )
					self.exploded = true
					self.Entity:Remove()
					return true
				else
					local attack = cbt_dealhcghit( tr.Entity, 1000, 7, tr.HitPos , tr.HitPos)
					--if (attack == 0) then
						--brokedshell = ents.Create("prop_physics")
						--brokedshell:SetPos(self.Entity:GetPos())
						--brokedshell:SetAngles(self.Entity:GetAngles())
						--brokedshell:SetKeyValue( "model", "models/combatmodels/tankshell.mdl" )
						--brokedshell:PhysicsInit( SOLID_VPHYSICS )
						--brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
						--brokedshell:SetSolid( SOLID_VPHYSICS )
						--brokedshell:Activate()
						--brokedshell:Spawn()
						--brokedshell:Fire("Kill", "", 20)
						--local phys = brokedshell:GetPhysicsObject()  	
						--if (phys:IsValid()) then  
							--phys:SetVelocity(self.flightvector * 10000)
						--end
					--end

				end

				self.exploded = true
				self.Entity:Remove()
			end
		end
	end

	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(0,0,-1)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end 



function ShieldTrace(pos, dir, filter)
	local tr = StarGate.Trace:New(pos, dir, filter)
	local aim = (dir-pos):GetNormal()
	tr.HitShield = false
	
	if(ValidEntity(tr.Entity)) then 		-- special execption for when hitting avon's shield
		local class = tr.Entity:GetClass()
		if(class == "shield") then 	--This is a  ridiculously complex way of actually finding where the spherical shield is and not the cubic bounding box if anybody knows of a better way PLEASE tell me
			local pos2 = tr.Entity:GetPos()
			local rad = tr.Entity:GetNWInt("size", false)
			local relpos = tr.HitPos-pos2
			local a = aim.x^2+aim.y^2+aim.z^2
			local b = 2*(relpos.x*aim.x+relpos.y*aim.y+relpos.z*aim.z)
			local c = relpos.x^2+relpos.y^2+relpos.z^2-rad^2
			local dist = (-1*b-(b^2-4*a*c)^0.5)/(2*a)	-- Thank god for Brahmagupta				
			if tostring(dist) == "-1.#IND" then 	-- Sometimes the trace will hit the bounding box but end up not actually hitting the round shield and this should mean that dist is a non-real number
				tr.Hit = false
			elseif dist < 0 then -- If the trace starts in the sphere the dist will be negative.
				dist = (-1*b+(b^2-4*a*c)^0.5)/(2*a)
				tr.HitPos = tr.HitPos+aim*dist
				tr.HitNormal = (tr.HitPos-pos2):GetNormal()
				tr.HitShield = true
			else
				tr.HitPos = tr.HitPos+aim*dist
				tr.HitNormal = (tr.HitPos-pos2):GetNormal()
				tr.HitShield = true
			end
		end
	end
    return tr
end 