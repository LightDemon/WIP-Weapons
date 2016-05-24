
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   
	self.infire = false
	self.Entity:SetModel( "models/combatmodels/tank_gun.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "X", "Y", "Z"} )
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "phaser" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
if FIELDS == nil and COMBATDAMAGEENGINE == nil then return end
	self.Target = Vector(self.XCo, self.YCo, self.ZCo)
	local normal = (self.Target - self:GetPos())
	if self.inFire then
		if normal:DotProduct(self.Entity:GetForward()) > 0.2 then 
			local trace = {}
			trace.start = self.Entity:GetPos() + self.Entity:GetUp() * 50
			trace.endpos = self.Target 
			trace.filter = self.Entity 
			local tr = util.TraceLine( trace ) 
			local effectdata = EffectData()
			effectdata:SetOrigin(self.Target)
			effectdata:SetStart(self.Entity:GetPos() + self.Entity:GetUp() * 50)
			util.Effect( "ISLargeLaserBeam", effectdata )

		end
	end
end


 function ENT:TriggerInput(k, v)
	if(k=="Fire") then
		if((v or 0) >= 1) then
			self.inFire = true
		else
			self.inFire = false
		end
	
	elseif (k == "X") then
		self.XCo = v
	
	elseif (k== "Y") then
		self.YCo = v
	
	elseif (k == "Z") then
		self.ZCo = v
	end
end
 
 
