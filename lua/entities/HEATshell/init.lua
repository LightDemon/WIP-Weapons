
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



function ENT:Initialize()   

math.randomseed(CurTime())
self.exploded = false
self.armed = true
self.ticking = true
self.smoking = false
self.flightvector = self.Entity:GetUp() * 400
self.Entity:SetModel( "models/combatmodels/tankshell.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            

self.PhysObj = self.Entity:GetPhysicsObject()
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end

self.Decay = CurTime() + 5
 self.PhysObj:SetVelocity( self.Entity:GetUp() * 18500 )
end   

function ENT:PhysicsUpdate( physobj )
	
	if self.Exploded or CurTime() > self.Decay then
		self.Entity:Remove()
	end	
end

function ENT:Think()
	
end
 
 function ENT:Touch( victim )
	if(victim:IsValid() || victim:IsWorld())then
		if(!self.Exploded) then
		
		gcombat.hcgexplode( self.Entity:GetPos(), 25, 250, 7)
		
			local shellpos = self.Entity:GetPos()
			local fragdir = self.Entity:GetUp()
			local fragdist = 200
			local fragang = 10
			local attack = gcx.fragcone( shellpos, fragdir, fragdist, fragang, 250, 7)
						if (attack == 0) then
						brokedshell = ents.Create("prop_physics")
						brokedshell:SetPos(self.Entity:GetPos())
						brokedshell:SetAngles(self.Entity:GetAngles())
						brokedshell:SetKeyValue( "model", "models/combatmodels/tankshell_120mm.mdl" )
						brokedshell:PhysicsInit( SOLID_VPHYSICS )
						brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
						brokedshell:SetSolid( SOLID_VPHYSICS )
						brokedshell:Activate()
						brokedshell:Spawn()
						brokedshell:Fire("Kill", "", 1)
						local phys = brokedshell:GetPhysicsObject()  	
						if (phys:IsValid()) then  
						phys:SetVelocity(self.flightvector * 6000)
						end
						elseif (attack != 0) then
						util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 600, 450)
						local effectdata = EffectData()
						effectdata:SetOrigin(self.Entity:GetPos())
						effectdata:SetStart(self.Entity:GetPos())
						util.Effect( "HEATsplode", effectdata )
				end
			end
			self.Exploded = true
		end
end

 --gcx.fragcone( position, direction, distance, angle, damage, pierce)
 
 function ENT:PhysicsCollide( data, physobj )
 --[[if(!self.Exploded) then
		
		gcombat.hcgexplode( self.Entity:GetPos(), 25, 250, 7)
		
			local shellpos = self.Entity:GetPos()
			local fragdir = self.Entity:GetUp()
			local fragdist = 200
			local fragang = 10
			local attack = gcx.fragcone( shellpos, fragdir, fragdist, fragang, 250, 7)
						if (attack == 0) then
						brokedshell = ents.Create("prop_physics")
						brokedshell:SetPos(self.Entity:GetPos())
						brokedshell:SetAngles(self.Entity:GetAngles())
						brokedshell:SetKeyValue( "model", "models/combatmodels/tankshell_120mm.mdl" )
						brokedshell:PhysicsInit( SOLID_VPHYSICS )
						brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
						brokedshell:SetSolid( SOLID_VPHYSICS )
						brokedshell:Activate()
						brokedshell:Spawn()
						brokedshell:Fire("Kill", "", 1)
						local phys = brokedshell:GetPhysicsObject()  	
						if (phys:IsValid()) then  
						phys:SetVelocity(self.flightvector * 6000)
						end
						elseif (attack != 0) then
						util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 600, 450)
						local effectdata = EffectData()
						effectdata:SetOrigin(self.Entity:GetPos())
						effectdata:SetStart(self.Entity:GetPos())
						util.Effect( "HEATsplode", effectdata )
				end
			end
			self.Exploded = true]]
end

