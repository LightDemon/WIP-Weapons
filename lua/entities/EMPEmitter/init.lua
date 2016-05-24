AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
--This File is a rework based off AlgorithmX2's EMP field for the Wire Field Generator. 
function ENT:Initialize()   



self.Entity:SetModel( "models/combatmodels/tankshell.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            
 
 local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
	self.List ={}
	self.Done = false
	self.EndDone = false
	self.EndTime = CurTime() + 10
end   


 function ENT:Think()
	if not self.Done then
		self.List = ents.FindInSphere( self.Entity:GetPos(), 200 )
		self.Done = true
	end
	
	self.Entity:NextThink( CurTime() + .6 )
	
		for _, v in pairs(self.List) do
			if v and v:IsValid() then
				local effectdata = EffectData() 
				effectdata:SetStart( v:GetPos() )
				effectdata:SetOrigin( v:GetPos() )
				effectdata:SetScale( 10 )
				effectdata:SetMagnitude( 10 )
				effectdata:SetEntity(v)
				util.Effect( "TeslaHitBoxes", effectdata ) --YAY lighning
			end
		end
			if CurTime() < self.EndTime then
				gcx_EmpRun(self.List)
			end
			
			if CurTime() > self.EndTime then
				gcx_EmpEnd(self.List)
				self:Fire("Kill", "", 4)
			end		
return true
end
 