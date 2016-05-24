if ( SERVER ) then

        AddCSLuaFile( "shared.lua" )
        SWEP.HoldType       = "ar2"
        
end

if ( CLIENT ) then

        SWEP.PrintName  = "Blow Torch"                        
        SWEP.Author     = "Wolly -fixed by LightDemon"
        SWEP.Slot       = 3
        SWEP.SlotPos    = 1
        SWEP.IconLetter = "w"        
end


SWEP.Base     = "weapon_base"


SWEP.Spawnable       = true
SWEP.AdminSpawnable  = true

SWEP.ViewModel    = "models/weapons/v_shotgun.mdl"
SWEP.WorldModel   = "models/weapons/w_shotgun.mdl"

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

function SWEP:Think()
        --if CLIENT then return end
        if not self.Owner then return end
		 local trace=util.GetPlayerTrace(self.Owner)
		 local tr=util.TraceLine(trace)
        if self.Owner:KeyDown(IN_ATTACK) then
		if CLIENT then
         local effectdata = EffectData()
                 effectdata:SetOrigin( self.Owner:GetShootPos())
                 effectdata:SetAngle( self.Owner:GetAimVector():Angle() )
                 effectdata:SetScale( 2 )
         util.Effect( "MuzzleEffect", effectdata )
                
                if self.Owner:GetPos():Distance(tr.HitPos)>300 then return end
         local effectdata = EffectData()
                 effectdata:SetOrigin( tr.HitPos )
                 effectdata:SetNormal( tr.HitNormal*2 )
                 effectdata:SetMagnitude( 1 )
                 effectdata:SetScale( 1 )
                 effectdata:SetRadius( 2 )
         util.Effect( "Sparks", effectdata )
		 end
			if SERVER then
				local attack = cbt_dealdevhit(tr.Entity, 2, 32 )
				if attack == 2 then
					
					local wreck = ents.Create( "wreckedstuff" )
					wreck:SetModel( tr.Entity:GetModel() )
					wreck:SetAngles(  tr.Entity:GetAngles() )
					wreck:SetPos(  tr.Entity:GetPos() )
					wreck:Spawn()
					wreck:Activate()
					wreck.deathtype = 1
					tr.Entity:Remove()
				end
				
			end
        end
		
		if self.Owner:KeyDown(IN_ATTACK2) then
			if CLIENT then
			local effectdata = EffectData()
			effectdata:SetOrigin( self.Owner:GetShootPos())
            effectdata:SetAngle( self.Owner:GetAimVector():Angle() )
            effectdata:SetScale( 2 )
			util.Effect( "MuzzleEffect", effectdata )
                
            if self.Owner:GetPos():Distance(tr.HitPos)>300 then return end
			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetNormal( tr.HitNormal*2 )
			effectdata:SetMagnitude( 1 )
			effectdata:SetScale( 1 )
			effectdata:SetRadius( 2 )
			util.Effect( "Sparks", effectdata )
			end
			if tr.Entity.cbt != nil && SERVER then
				tr.Entity.cbt.health = math.Clamp( tr.Entity.cbt.health + 5 , 10 ,  tr.Entity.cbt.maxhealth)
			end 
				
        end
end


function SWEP:Reload()

end

function SWEP:SecondaryAttack()

end

function SWEP:PrimaryAttack()
        

        --self.Weapon:EmitSound("", 100, 100)
end 