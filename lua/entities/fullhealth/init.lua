AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
self.entlist={}
self.totalhealth = 0
self.curhealth = 0
self.Active = false
self.Entity:SetModel( "models/jaanus/wiretool/wiretool_range.mdl" )	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            
self.Inputs = Wire_CreateInputs(self.Entity, { "Set", "Active" })
self.Outputs = Wire_CreateOutputs( self.Entity, { "Health"} )

local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 

end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "fullhealth" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:Think()
	if self.Active == true then
		for _, v in pairs(self.entlist) do
			if v:GetClass() == "prop_physics" then
				if (v.cbt != nil) then
					self.curhealth = self.curhealth + v.cbt.health
				else
					local h = v:GetPhysicsObject():GetMass() * 4
					local health = math.Clamp( h, 1, 4000 )
					self.curhealth = self.curhealth + health
				end
			end
		end
		
		local percent = (self.curhealth / self.totalhealth)* 100
		
		Wire_TriggerOutput(self.Entity, "Health", percent)
	end
end



function ENT:TriggerInput(iname, value)
	if (iname == "Set") then
		if (value == 1) then
		self:GetHealth()
		end
	end
	
	if (iname == "Active") then
		if (value == 1) then
		self.Active = true
		end
	end
end

function ENT:GetHealth()
self.entlist = duplicator.GetAllConstrainedEntitiesAndConstraints(self.Entity, {},{} ) or {} ents[self.Entity:EntIndex()] = self.Entity
	for _, v in pairs(self.entlist) do
		if v:GetClass() == "prop_physics" then
				local h = v:GetPhysicsObject():GetMass() * 4
				local maxhealth = math.Clamp( h, 1, 4000 )
				self.totalhealth = self.totalhealth + maxhealth
		end
	end			
				
end 