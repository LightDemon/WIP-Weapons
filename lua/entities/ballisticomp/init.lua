AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
self.Entity:SetModel( "models/jaanus/wiretool/wiretool_range.mdl" )	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            
self.Inputs = Wire_CreateInputs(self.Entity, { "Distance to Target", "Projectile Velocity" })
self.Outputs = Wire_CreateOutputs( self.Entity, { "Angle" } )

self.DTT = 0
self.PROJVEL = 0

local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 

end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "ballisticomp" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:TriggerInput(iname, value)
	if (iname == "Distance to Target") then
		if (value > 0) then
		self.DTT = value
		else
		self.DTT = 0
		end
	end
	
	if (iname == "Projectile Velocity") then
		if (value > 0) then
		self.PROJVEL = value
		else
		self.PROJVEL = 0
		end
	end
end


function ENT:Think()
	local dist = self.DTT
	local vel = self.PROJVEL
	local result = (-400 * dist)/(vel^2)	
	local angtt = math.asin(result)
	local correction = math.deg(angtt)
	Wire_TriggerOutput(self.Entity, "Angle", correction)
	self.Entity:NextThink( CurTime() )
end