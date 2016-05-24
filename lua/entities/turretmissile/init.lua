AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')
local FlightSound = Sound( "PhysicsCannister.ThrusterLoop" )
local blastRadius = 400
function ENT:Initialize()
	self.Entity:SetModel('models/aamissile.mdl')

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_NONE )

	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:EnableGravity( false )
		phys:Wake()
	end
	
	self.Entity:EmitSound( FlightSound )
	self.Entity:SetGravity( 0 )
	self.SpawnTime = CurTime()
	self.DeathTime = CurTime() + 10
	
	local ent = self.Entity
 RockTrail = ents.Create("env_rockettrail")
				RockTrail:SetPos( self.Entity:GetPos() )
				RockTrail:SetParent(ent)
				RockTrail:SetAngles( self.Entity:GetAngles() + Angle(-90,0,0)  )
				RockTrail:Spawn()
				RockTrail:Activate()       
	
end

function ENT:PhysicsCollide( data, physobj )
	self:Explode()
end

function ENT:SetAngles( Ang )
	self.Entity:SetAngles(Ang)
end

function ENT:PhysicsUpdate( physobj )
	--local Ang = self.Entity:GetUp() * 20
	--local force = Ang * 1000

	physobj:SetVelocity(self.Entity:GetUp()*6200)
end

function ENT:flak()
	
	if(!self.Exploded) then
		for i=1,5 do
			local sopme	= (self.Entity:GetPos() + Vector(math.random(-600, 600), math.random(-600, 600), math.random(-600, 600)))
			local effectdatab = EffectData()
						effectdatab:SetOrigin(sopme)		
						effectdatab:SetStart(self.Entity:GetPos())
						util.Effect( "aamsplode", effectdatab )
						gcombat.hcgexplode( sopme, 300, 500, 7 )
						util.BlastDamage(self.Entity, self.Entity, sopme, blastRadius, 200)
			
		end
	end
end

function ENT:Explode()
	if ( self.Exploded ) then return end
	
	
	
	local attack = gcombat.hcgexplode( self.Entity:GetPos(), 300, 500, 7)
				if (attack == 0) then
					brokedshell = ents.Create("prop_physics")
					brokedshell:SetPos(self.Entity:GetPos())
					brokedshell:SetAngles(self.Entity:GetAngles())
					brokedshell:SetKeyValue( "model", "models/aamissile.mdl" )
					brokedshell:PhysicsInit( SOLID_VPHYSICS )
					brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
					brokedshell:SetSolid( SOLID_VPHYSICS )
					brokedshell:Activate()
					brokedshell:Spawn()
					brokedshell:Fire("Kill", "", 20)
				elseif (attack != 0) then
					self:flak()
					util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), blastRadius, 200)
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())		
					effectdata:SetStart(self.Entity:GetPos())
					util.Effect( "aamsplode", effectdata )
				end
	
 	--util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), blastRadius, 50 )

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
	util.Effect( "Explosion", effectdata, true, true )
self.Exploded = true
end



local seekRadius = 1000

function AngToVec( ang )
	return Vector(ang.pitch%360,ang.yaw%360,ang.roll%360)
end

local seekable = {
gmod_thruster = true,
prop_vehicle_airboat = true,
prop_vehicle_jeep = true,
gmod_hoverball = true,
malawar_repulsor = true,
prop_physics = true
}

function ENT:CheckSeeking()
	local seekStart = self.Entity:GetPos() + (self.Entity:GetUp())
	local seekVec = self.Entity:GetUp()
	local seekDist = 8000
	local seaKAng = 30
	local targets = FindinCone2( seekStart, seekVec, seekDist, seaKAng )
	for i, e in pairs(targets) do
		cls = e:GetClass()
		if seekable[cls] then
		--if cls == 'gmod_thruster' or cls == 'prop_vehicle_airboat' or cls == 'prop_vehicle_jeep' then
			local Ang = e:GetPos() - self.Entity:GetPos()
			local dist = Ang:Length()
			if dist < (20) then
				self:Explode()				
				return
			end
			
			local phys = self.Entity:GetPhysicsObject()
			local oldVel = phys:GetVelocity()
			Ang = Ang:Angle()
			Ang.pitch = Ang.pitch + 90
			self.Entity:GetPhysicsObject():SetAngle(Ang)
			phys:SetVelocity((oldVel) * 1)
			return
		end
	end
end

function ENT:Think()
	if self.Solid == nil and CurTime() > (self.SpawnTime + 0.4) then
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Solid = true
	end
	
	if CurTime() > self.SpawnTime + 1 then
		self:CheckSeeking()
	end
	
	
	if CurTime() > self.DeathTime then
		self.Entity:Remove()
	end
	if self.Exploded then
		self.Entity:Remove()
	end
end

function ENT:OnRemove()
	self.Entity:StopSound( FlightSound )
end
