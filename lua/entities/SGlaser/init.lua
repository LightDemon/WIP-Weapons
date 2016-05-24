
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   

	util.PrecacheSound( "Lasers/Medium/Laser.wav" ) 
	
	self.ammos = 6
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.shelltype = 42
	self.infire = false
	self.distance = 6000
	self.Entity:SetModel( "models/combatmodels/tank_gun.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(100,40,255,255)

	self.val1 = 0
	self.val2 = 0
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	phys:SetMass( 3 ) 
	end 
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Discharge" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "SGlaser" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:discharge()

	if (self.ammos > 0) then
	
		local pos = self.Entity:GetPos()
		
	
		local tr = ShieldTrace(self.Entity:GetPos() + self.Entity:GetUp() * 50, self.Entity:GetUp() * self.distance, self.Entity)
		
		if (tr.Hit && tr.Entity:IsValid()) then
			
			if tr.HitShield then
				tr.Entity:Hit(self.Entity,tr.HitPos,20,(self.Entity:GetPos()-tr.Entity:GetPos()):Normalize())
			
			elseif ( !tr.Entity:IsWorld() || !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() || !tr.Entity:IsVehicle() || !tr.HitShield) then
				gcombat.nrghit( tr.Entity, 52, 7, tr.HitPos, tr.HitPos)

			end
		end
	
		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 200, 50)
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
			util.Effect( "MediumLaserBeam", effectdata )
			self.Entity:EmitSound( "Lasers/Medium/Laser.wav", 500, 100 )
		
		
		self.reloadtime = CurTime() + 2.6
		
		

	
	end

end

function ENT:Think()
	if (self.reloadtime > CurTime()) then
		self.armed = false
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if (self.armed == true) then
		
			if (self.shelltype == 1) then
				self:discharge()
				
			end
		
	elseif (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
		if (self.infire == true) then self.armed = true end
	end

end

function ENT:TriggerInput(iname, value)

	if (iname == "Discharge") then
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
		self.shelltype = 1
		self.Entity:NextThink( CurTime() )
		return true
	end
		
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
