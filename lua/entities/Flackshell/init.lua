AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
self.inFlight = true
self.TimeCheck = CurTime() + .2
self.Death = CurTime() + 3
self.Entity:SetModel( "models/combatmodels/tankshell_40mm.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            
 self.flightvector = self.Entity:GetUp() * 100
end   


 function ENT:Think()
	local entlist = ents.FindInSphere( self.Entity:GetPos(), 100 )
		
	if self.inFlight then			
		self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
		self.flightvector = self.flightvector + Vector(0,0,-.1)
		self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
		if self.Death < CurTime() then
		self:Boom()
		end
	end	
	if self.TimeCheck < CurTime() and table.getn(entlist) > 0 then
		self.inFlight = false
		self:Boom()
		return false
	end
	self.Entity:NextThink( CurTime() )
return true
end
 
 function ENT:Boom() 
	cbt_hcgexplode(self.Entity:GetPos(), 200, 200 ,9)
	local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())
					effectdata:SetStart(self.Entity:GetPos())
					util.Effect( "Explosion", effectdata )
					self.exploded = true
	self.Entity:Remove()
end 