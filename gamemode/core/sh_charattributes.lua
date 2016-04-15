--[[
	sh_attributes.lua
--]]

rain.attributes = {}
rain.attributebuffer = {}

function rain.attributes.add(sAttributeName)
	table.insert(rain.attributebuffer, sAttributeName)
end

function rain.attributes.playerspawn(pClient)
	local char = pClient:GetCharacter()
	if char then
		char:SetupAttributes()
	end
end

function rain.attributes.defaultattributes()
	local defaultattributes = {}

	for _, attribute in pairs(rain.attributebuffer) do
		defaultattributes[attribute] = 50
	end

	return defaultattributes
end

local rainclient = FindMetaTable("Player")

function rainclient:GetAttributes()
	local char = self:GetCharacter()

	if char then
		return char:GetAttributes()
	end

	return rain.attributes.defaultattributes()
end

function rainclient:GetAttribute(sAttributeName)
	local char = self:GetCharacter()

	if char then
		local attributes = char:GetAttributes()

		return attributes[sAttributeName]
	end 
end

local rainchar = rain.character.getmeta()

function rainchar:SetupAttributes()
	local attributes = self:GetAdminOnlyData("attributes", false)
	if !attributes then
		self:SetAdminOnlyData("attributes", rain.attributes.defaultattributes())
	end
end

function rainchar:GetAttributes()
	return self:GetAdminOnlyData("attributes", rain.attributes.defaultattributes())
end

function rainchar:SetAttribute(sAttributeName, nAmount)
	local attributes = self:GetAdminOnlyData("attributes", rain.attributes.defaultattributes())

	attributes[sAttributeName] = nAmount

	self:SetAdminOnlyData("attributes", attributes)
end

function rainchar:GetAttribute(sAttributeName)
	local attributes = self:GetAdminOnlyData("attributes", rain.attributes.defaultattributes())
	local attributemodifiers = self:GetAdminOnlyData("attributemodifiers", {})

	if attributemodifiers[sAttributeName] and attributemodifiers[sAttributeName].ExpireTime > CurTime() then
		return attributes[sAttributeName] + attributemodifiers[sAttributeName]
	else
		return attributes[sAttributeName]
	end

	return attributes[sAttributeName]
end

function rainchar:UpdateAttribute(sAttributeName, nAttributeDelta)
	local attributes = self:GetAdminOnlyData("attributes", rain.attributes.defaultattributes())

	attributes[sAttributeName] = math.Clamp(attributes[sAttributeName] + nAttributeDelta, 0, 100)
end

function rainchar:DebuffAttribute(sAttributeName, nDebuffAmount)
	local attributemodifiers = self:GetAdminOnlyData("attributemodifiers", {})

	attributemodifiers[sAttributeName] = -(math.abs(nDebuffAmount))

	self:SetAdminOnlyData("attributemodifiers", attributemodifiers)
end

function rainchar:BuffAttribute(sAttributeName, nBuffAmount)
	local attributemodifiers = self:GetAdminOnlyData("attributemodifiers", {})

	attributemodifiers[sAttributeName] = math.abs(nBuffAmount)

	self:SetAdminOnlyData("attributemodifiers", attributemodifiers)
end

rain.attributes.add("TestAttribute1")
rain.attributes.add("TestAttribute2")
rain.attributes.add("TestAttribute3")