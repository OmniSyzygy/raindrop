AddCSLuaFile()

if (CLIENT) then
	SWEP.PrintName = "Hands"
	SWEP.Category = "Raindrop"
	SWEP.Slot = 0
	SWEP.SlotPos = 1

	SWEP.BobScale = 2
	SWEP.SwayScale = 2

	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "jooni"
SWEP.Instructions = "These are for hand stuff."
SWEP.Purpose = "Knocking on doors"
SWEP.Drop = false

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false

SWEP.UseHands = false

SWEP.HoldType = "fist"

SWEP.ViewModel = Model("models/weapons/c_arms_cstrike.mdl")
SWEP.WorldModel = ""

if (rain.dev) then
	SWEP.Spawnable = true
	SWEP.AdminOnly = true
else
	SWEP.Spawnable = false
	SWEP.AdminOnly = false
end

SWEP.Raised = false

function SWEP:Deploy()
	self.Raised = false
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()

end

function SWEP:DrawWorldModel()
	return
end

function SWEP:PreDrawViewModel(ViewModel, Weapon, pClient)
	ViewModel:SetNoDraw(!self.Raised)
end