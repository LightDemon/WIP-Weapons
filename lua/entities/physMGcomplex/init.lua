
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

util.PrecacheSound("arty/mg42.wav")


function ENT:Initialize()   

	
	self.Entity:SetModel( "models/props_combine/combine_mine01.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "X", "Y", "Z", "Fire"} )
	self.XCo = 0
	self.YCo = 0
	self.ZCo = 0
	self.Target = Vector(0,0,0)
	self.Firelaser = false
	self.reloadtime = CurTime()
	
	self.Turret = ents.Create("prop_physics")
	self.Turret:SetModel("models/weapons/w_rocket_launcher.mdl")
	self.Turret:SetPos(self.Entity:GetPos() + self.Entity:GetUp() * 10)
	self.Turret:SetAngles(self.Entity:GetAngles())
	self.Turret:Spawn()
	self.Turret:GetPhysicsObject():EnableGravity(false)
	self.Turret:SetParent(self.Entity)
	self.Turret:SetNotSolid(true)
	self.Turret:Activate()
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "physMGcomplex" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:FireCannon()
	local inacc = Vector(math.Rand(-0.002,0.002), math.Rand(-0.002,0.002), math.Rand(-0.002,0.002))
	local ent = ents.Create( "mgturretbullet" )
		ent:SetPos( self.Turret.Entity:GetPos() + self.Turret.Entity:GetForward() * 50 + self.Turret.Entity:GetUp() *5 + self.Turret.Entity:GetRight() *1.5)
		ent:SetAngles( (self.Turret.Entity:GetForward() + inacc):Angle() + Angle(90))
		
		ent:Spawn()
		ent:Activate()
		--ent:SetVelocity( ent:GetUp() * 18500 )
		self.reloadtime = CurTime() + .1
		self.Entity:EmitSound( "arty/mg42.wav", 500, 100 )	


end



function ENT:Think()
	
	
	self.Target = Vector(self.XCo,self.YCo,self.ZCo)
	targloc = self.Entity:WorldToLocal(self.Target)
	local targetangle = (targloc - Vector(0,0,0)):Normalize():Angle()
	local turretangle = self.Turret.Entity:GetAngles()
	local turpos = self.Entity:GetPos()	
	local targpos = Vector(targloc.x,targloc.y,turpos.z)
	local Dist = (turpos:Distance(targloc))
	local Elev = (targloc.z) 
	local Grav = 600
	local Velo = 18500
	local stepA = (2 * Elev * Velo^2)	--(Velo^4 + Grav * (Grav * Dist^2 + (2 * Elev * Velo^2)))
	local stepB = (Grav * Dist^2)    	--stepA^0.5
	local stepC = (Velo^4 + Grav)		--((Velo^2 + stepB)/Grav * Dist)
	local stepD = ((stepA + stepB) * stepC)
	local stepE = stepD^0.5
	local stepF = (Velo^2 - stepE)
	local stepG = (Grav * Dist)
	local stepH = (stepF / stepG)
	local angtt = math.tan(stepH)
	local correction = math.deg(angtt)
	
	
	local message = "X: " .. targloc.x .. "\n" .. "Y: " .. targloc.y .. "\n" .. "Z: " .. targloc.z .. "\n" .. "Correction: " .. correction .. "\n" .. "TUR-X: " .. turpos.x .. "\n" .. "TUR-Y: " .. turpos.y .. "\n" .. "TUR-Z: " .. turpos.z .. "\n" .. "angtt: " .. angtt .. "\n" .. "Dist: " .. Dist .. "\n"
	player.GetByID( 1 ):PrintMessage( HUD_PRINTCENTER, message )

		-- targetangle.p +
	turretangle.p = math.ApproachAngle(turretangle.p, correction,2.25)
	turretangle.y = math.ApproachAngle(turretangle.y,targetangle.y,2.25)
	turretangle.r = math.ApproachAngle(turretangle.r,self.Entity:GetAngles().r,2.25)
		self.Turret.Entity:SetAngles(turretangle)
	
	
	if self.Firelaser and self.reloadtime < CurTime() then
		self:FireCannon()
	end
	
	self.Entity:NextThink(CurTime())
	return true
end

function ENT:TriggerInput(k, v)
	if (k == "X") then
		self.XCo = v
	
	elseif (k== "Y") then
		self.YCo = v
	
	elseif (k == "Z") then
		self.ZCo = v
	
	elseif (k == "Fire") then
		if v == 1 then
			self.Firelaser = true
		else
			self.Firelaser = false
		end
		
	end
end
 
 
