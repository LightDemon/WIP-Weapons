
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "sound/MadMoe/klingon_beam_a.wav" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   
	self.infire = false
	self.Entity:SetModel( "models/props_lab/lab_flourescentlight002b.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
	self.ID = math.random(1000);
	self.Inputs = Wire_CreateInputs( self.Entity, { "Charge", "Arm", "Fire", "X", "Y", "Z"} )
	self.Outputs = Wire_CreateOutputs(self.Entity, { "Charge Amount", "Armed" })
	self.ShoopTarget = SpawnShoopTarget(self.Entity, self.distance, self.ID)
	self.ShoopEnt = SpawnShoop(self.Entity, self.BeamTarget, self.ID)
	self.ShoopEnt2 = SpawnShoop2(self.Entity, self.BeamTarget, self.ID)
	self.ShoopEnt3 = SpawnShoop3(self.Entity, self.BeamTarget, self.ID)
	self.ShoopEnt4 = SpawnShoop4(self.Entity, self.BeamTarget, self.ID)
	self.ShoopEnt5 = SpawnShoop5(self.Entity, self.BeamTarget, self.ID)
	self.ShoopEnt:Fire("turnoff","",0)
	self.ShoopEnt2:Fire("turnoff","",0)
	self.ShoopEnt3:Fire("turnoff","",0)
	self.ShoopEnt4:Fire("turnoff","",0)
	self.ShoopEnt5:Fire("turnoff","",0)
	
	self.canFire = false
	self.Chargin = 0 
	self.MaxChargin = 1000
	self.Chargerate = 2.5
	
	self.fireSound = "MadMoe/klingon_beam_a.wav"
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "shoopershoop" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()

if FIELDS == nil and COMBATDAMAGEENGINE == nil then return end

	if(self.inCharge && self.Holding && self.Chargin <= self.MaxChargin) then
			self.Chargin = self.Chargin + (self.Chargerate * 0.5)
			self.canFire = true
			Wire_TriggerOutput(self.Entity, "Charge Amount", self.Chargin)
			Wire_TriggerOutput(self.Entity, "Holding", 1)
		if(!self.Holding && self.inCharge && self.Chargin <= self.MaxChargin) then
			self.Chargin = self.Chargin + self.Chargerate
			self.canFire = false
			Wire_TriggerOutput(self.Entity, "Charge Amount", self.Chargin)
			Wire_TriggerOutput(self.Entity, "Holding", 0)
		end		
	elseif(!self.inCharge && self.Holding && self.Chargin > 0) then
			self.Chargin = self.Chargin - 0.1
			self.canFire = true
			Wire_TriggerOutput(self.Entity, "Charge Amount", self.Chargin)
			Wire_TriggerOutput(self.Entity, "Holding", 1)
		if(self.Holding && !self.inCharge && self.Chargin <= 0) then
			self.Chargin = 0
			self.canFire = false
			Wire_TriggerOutput(self.Entity, "Charge Amount", self.Chargin)
			Wire_TriggerOutput(self.Entity, "Holding", 0)
		end
			
	end
		
	Wire_TriggerOutput(self.Entity, "Charge Amount", self.Chargin)	
		
		
		
		
	self.Target = Vector(self.XCo, self.YCo, self.ZCo)
	self.ShoopTarget:SetPos(self.Target)
	self.Location = self.Entity:GetPos()
	if(self.canFire && self.Chargin > 0) then
	if (self.inFire && self.Chargin > 0) then
			local targetVec = (self.Target - self.Entity:GetPos()):GetNormal()
			local angle = math.acos(self.Entity:GetForward():DotProduct(targetVec))
			
     
			if(math.Rad2Deg(angle) < 20) then
			
				local trace = {}
				trace.start = self.Entity:GetPos() + (self.Entity:GetForward() * 5)
				trace.endpos = self.Target 
				trace.filter = self.Entity 
				local tr = util.TraceLine( trace )
				if tr.Hit then
					if (tr.Entity:IsWorld() || tr.Entity:IsPlayer() || tr.Entity:IsNPC() || tr.HitSky) then
			
					else
					cbt_dealnrghit(tr.Entity, self.Chargin, 8, tr.HitPos, tr.HitPos)
					
					end
				end
				
				self.Entity:EmitSound( self.fireSound, 500, 100 )
				self.ShoopEnt:Fire("turnon","",0)
				self.ShoopEnt2:Fire("turnon","",0)
				self.ShoopEnt3:Fire("turnon","",0)
				self.ShoopEnt4:Fire("turnon","",0)
				self.ShoopEnt5:Fire("turnon","",0)
				self.Chargin = self.Chargin - 20
			elseif (math.Rad2Deg(angle) < 40 or !self.inFire or self.Chargin <= 0) then
				self.ShoopEnt:Fire("turnoff","",0)
				self.ShoopEnt2:Fire("turnoff","",0)
				self.ShoopEnt3:Fire("turnoff","",0)
				self.ShoopEnt4:Fire("turnoff","",0)
				self.ShoopEnt5:Fire("turnoff","",0)
			else
				self.ShoopEnt:Fire("turnoff","",0)
				self.ShoopEnt2:Fire("turnoff","",0)
				self.ShoopEnt3:Fire("turnoff","",0)
				self.ShoopEnt4:Fire("turnoff","",0)
				self.ShoopEnt5:Fire("turnoff","",0)
			end
		
	elseif (!self.inFire or self.Chargin <= 0) then 
		self.ShoopEnt:Fire("turnoff","",0)
		self.ShoopEnt2:Fire("turnoff","",0)
		self.ShoopEnt3:Fire("turnoff","",0)
		self.ShoopEnt4:Fire("turnoff","",0)
		self.ShoopEnt5:Fire("turnoff","",0)
	end
	
		
end
self.Entity:NextThink(CurTime())
		
		
end


 function ENT:TriggerInput(k, v)
 
	if(k == "Charge") then
		if((v or 0) >= 1) then
			self.inCharge = true
		else
			self.inCharge = false
		end
	end
		
	if(k == "Hold") then
		if((v or 0) >= 1) then
			self.Holding = true
		else
			self.Holding = false
		end
	end
		
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
 
 function SpawnShoopTarget( ent, length, id )
  local  BeamTarget = ents.Create("info_target")
    BeamTarget:SetKeyValue("targetname", "LAZOR_"..id)
	BeamTarget:SetPos(ent:GetPos() + ent:GetForward() * 2000)
	BeamTarget:SetAngles(ent:GetAngles())
    BeamTarget:Spawn()

	return BeamTarget
end

function SpawnShoop( ent, target, id )
  
  local  Beam = ents.Create("env_laser")
	Beam:SetPos(ent:GetPos() + (ent:GetForward() * 5) )
	Beam:SetAngles(ent:GetAngles())
    Beam:SetKeyValue("renderamt", "255")
    Beam:SetKeyValue("rendercolor", "255 255 255")
	Beam:SetKeyValue("renderfx", 14)
    Beam:SetKeyValue("texture", "materials/effects/phaser9.vmt")
    Beam:SetKeyValue("TextureScroll", 70)
    Beam:SetKeyValue("damage", 100)
	Beam:SetKeyValue("NoiseAmplitude", 0)
    Beam:SetKeyValue("width", 20 )
    Beam:SetKeyValue("dissolvetype", 0)
    Beam:SetKeyValue("LaserTarget", "LAZOR_"..id)
    Beam:Spawn()
	Beam:SetParent(ent)
	
	return Beam
end 
function SpawnShoop2( ent, target, id )
  
  local  Beam2 = ents.Create("env_laser")
	Beam2:SetPos(ent:GetPos() + ((ent:GetForward() * 5) + (ent:GetRight() * 10) + (ent:GetUp() * 10)))
	Beam2:SetAngles(ent:GetAngles())
    Beam2:SetKeyValue("renderamt", "255")
    Beam2:SetKeyValue("rendercolor", "255 255 255")
	Beam2:SetKeyValue("renderfx", 14)
    Beam2:SetKeyValue("texture", "materials/effects/phaser9.vmt")
    Beam2:SetKeyValue("TextureScroll", 70)
    Beam2:SetKeyValue("damage", 100)
	Beam2:SetKeyValue("NoiseAmplitude", 0)
    Beam2:SetKeyValue("width", 20 )
    Beam2:SetKeyValue("dissolvetype", 0)
    Beam2:SetKeyValue("LaserTarget", "LAZOR_"..id)
    Beam2:Spawn()
	Beam2:SetParent(ent)
	
	return Beam2
end 
function SpawnShoop3( ent, target, id )
  
  local  Beam3 = ents.Create("env_laser")
	Beam3:SetPos(ent:GetPos() + ((ent:GetForward() * 5) + (ent:GetRight() * -10) + (ent:GetUp() * 10)))
	Beam3:SetAngles(ent:GetAngles())
    Beam3:SetKeyValue("renderamt", "255")
    Beam3:SetKeyValue("rendercolor", "255 255 255")
	Beam3:SetKeyValue("renderfx", 14)
    Beam3:SetKeyValue("texture", "materials/effects/phaser9.vmt")
    Beam3:SetKeyValue("TextureScroll", 70)
    Beam3:SetKeyValue("damage", 100)
	Beam3:SetKeyValue("NoiseAmplitude", 0)
    Beam3:SetKeyValue("width", 20 )
    Beam3:SetKeyValue("dissolvetype", 0)
    Beam3:SetKeyValue("LaserTarget", "LAZOR_"..id)
    Beam3:Spawn()
	Beam3:SetParent(ent)
	
	return Beam3
end 
function SpawnShoop4( ent, target, id )
  
  local  Beam4 = ents.Create("env_laser")
	Beam4:SetPos(ent:GetPos() + ((ent:GetForward() * 5) + (ent:GetRight() * 10) + (ent:GetUp() * -10)))
	Beam4:SetAngles(ent:GetAngles())
    Beam4:SetKeyValue("renderamt", "255")
    Beam4:SetKeyValue("rendercolor", "255 255 255")
	Beam4:SetKeyValue("renderfx", 14)
    Beam4:SetKeyValue("texture", "materials/effects/phaser9.vmt")
    Beam4:SetKeyValue("TextureScroll", 70)
    Beam4:SetKeyValue("damage", 100)
	Beam4:SetKeyValue("NoiseAmplitude", 0)
    Beam4:SetKeyValue("width", 20 )
    Beam4:SetKeyValue("dissolvetype", 0)
    Beam4:SetKeyValue("LaserTarget", "LAZOR_"..id)
    Beam4:Spawn()
	Beam4:SetParent(ent)
	
	return Beam4
end 
function SpawnShoop5( ent, target, id )
  
  local  Beam5 = ents.Create("env_laser")
	Beam5:SetPos(ent:GetPos() + ((ent:GetForward() * 5) + (ent:GetRight() * -10) + (ent:GetUp() * -10)))
	Beam5:SetAngles(ent:GetAngles())
    Beam5:SetKeyValue("renderamt", "255")
    Beam5:SetKeyValue("rendercolor", "255 255 255")
	Beam5:SetKeyValue("renderfx", 14)
    Beam5:SetKeyValue("texture", "materials/effects/phaser9.vmt")
    Beam5:SetKeyValue("TextureScroll", 70)
    Beam5:SetKeyValue("damage", 100)
	Beam5:SetKeyValue("NoiseAmplitude", 0)
    Beam5:SetKeyValue("width", 20 )
    Beam5:SetKeyValue("dissolvetype", 0)
    Beam5:SetKeyValue("LaserTarget", "LAZOR_"..id)
    Beam5:Spawn()
	Beam5:SetParent(ent)
	
	return Beam5
end 