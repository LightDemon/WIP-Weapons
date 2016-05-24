AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
self.Entity:SetModel( "models/combatmodels/tankshell.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            

 local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
self.Arm = false;
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "EMPMine" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

 function ENT:Think()
	for _, v in pairs(ents.FindInSphere( self.Entity:GetPos(), 200 )) do
		if v.Outputs == nil then 
			else
			self.Arm = true;
			end

		if self.Arm then
			for _, v in pairs(ents.FindInSphere( self.Entity:GetPos(), 200 )) do
				local effectdata = EffectData() 
				effectdata:SetStart( v:GetPos() )
				effectdata:SetOrigin( v:GetPos() )
				effectdata:SetScale( 10 )
				effectdata:SetMagnitude( 10 )
				effectdata:SetEntity(v)
				util.Effect( "TeslaHitBoxes", effectdata ) --YAY lighning
			end
				self:EMP()
				self:Fire("Kill", "", 3)	
				self.Entity:NextThink( CurTime() + .6 )	
		end
	end		
return true
end
 
 function ENT:EMP() --Ape Shit Crazy
	for _, v in pairs(ents.FindInSphere( self.Entity:GetPos(), 200 )) do
		if v.Outputs == nil then
			
		else
			v.Think = function(self2) --thanks _killburn
				if self2.Outputs == nil then return false end
					for key,output in pairs(self2.Outputs) do
						if type(output)=="table" and output.Name then
						Wire_TriggerOutput(self2.Entity,output.Name,2000*math.random()-1000)
						end
					end
				self2.Entity:NextThink(CurTime()+1)
				return true	
				end
		end
	end
end 
