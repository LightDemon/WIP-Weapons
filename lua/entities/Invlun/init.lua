AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
self.entlist={}
self.Fired = false
self.Go = false
self.Entity:SetModel( "models//props_wasteland/panel_leverBase001a.mdl" )	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            
self.Inputs = Wire_CreateInputs(self.Entity, { "Fire" })

local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 

end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "boost" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:Think()
	if self.Go == true && self.Fired == false then
	self.entlist = duplicator.GetAllConstrainedEntitiesAndConstraints(self.Entity, {},{} ) or {} ents[self.Entity:EntIndex()] = self.Entity
	for _, v in pairs(self.entlist) do
	if v:GetClass() == "boost" && v != self.Entity then
		local effectdata = EffectData()
				effectdata:SetOrigin(self.Entity:GetPos())
				effectdata:SetStart(self.Entity:GetPos())
				util.Effect( "Explosion", effectdata )
				self.Entity:Remove()
		cbt_nrgexplode( self.Entity:GetPos(), 500, 2000, 20)
	return end
	end
		self:Repair()
		     local effectdata = EffectData()
				effectdata:SetOrigin( self.Entity:GetPos())
				effectdata:SetNormal( self.Entity:GetPos():GetNormal() )
				effectdata:SetMagnitude( 15 )
				effectdata:SetScale( 150 )
				effectdata:SetRadius( 50 )
				util.Effect( "ThumperDust", effectdata )
		self.Fired = true
	
	end
end

function ENT:Repair()
if self.Fired == true then return end
	for _, v in pairs(self.entlist) do
		if v.cbt == nil then
		
		else
			v.cbt.health = math.Clamp(v.cbt.health + 600 , 10 , v.cbt.maxhealth)
		end
	end
	self.Fired = true
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		if (value == 1) then
		self.Go = true
		end
	end
end
