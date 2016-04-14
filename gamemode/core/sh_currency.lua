--[[
	Filename: sh_currency.lua
	Description: Raindrop has support for multiple currencies, there is a single 'primary' curreny and then secondary currencies.
--]]

rain.curreny = {}
rain.currenybuffer = {}

--[[
	Name: Setup Master
	Category: Currency
	Desc: Sets up the master currency which is basically the primary currency used by the script
--]]

function rain.curreny.setupmaster(sPrintName, sPrintDesc, fnResolveCurrencyName)
	rain.currency.master = {}
	rain.currency.Master.PrintName = sPrintName
	rain.currency.Master.PrintDesc = sPrintDesc
	rain.currency.Master.ResolveCurrencyName = fnResolveCurrencyName
end

--[[
	Name: Add
	Category: Currency
	Desc: Adds a currency, currency added via this function is considered a secondary currency.
--]]

function rain.curreny.add(sCurrenyName, sPrintName, sPrintDesc, fnResolveCurrencyName, nVal)
	rain.currencybuffer[sCurrencyName] = {PrintName = sPrintName, PrintDesc = sPrintDesc, ResolveCurrency = fnResolveCurrencyName, Val = nVal}
end

function rain.curreny.enabled()
	if rain.cfg.currency and rain.cfg.currency.enabled then
		return false
	end

	if rain.curreny.master then
		return true
	end

	return false
end

local rainclient = FindMetaTable("Player")

function rainclient:CanAfford(nPrice)

end

function rainclient:CanAffordByCurrency()

end

local rainchar = rain.character.getmeta()

function rainchar:SetCurrencyAmount(nAmount, sCurrency)
	local sCurrency = sCurrency or nil

	if !sCurrency then
		sCurrency = "Master"
	end

	local currencies = self:GetAdminOnlyData("currency", {})

	currencies[sCurrency] = nAmount or 0

	self:SetAdminOnlyData("currency", currencies)
end

function rainchar:GetCurrencyAmount(sCurrency)
	local currencies = self:GetAdminOnlyData("currency", {})
	
	if !sCurrency then
		sCurrency = "Master"
	end

	if currencies[sCurrency] then
		return currencies[sCurrency]
	else 
		return 0
	end
end

function rainchar:AddCurrency(nAmount, sCurrency)
	local currencies = self:GetAdminOnlyData("currency", {})
	if !sCurrency then
		sCurrency = "Master"
	end

	if currencies[sCurrency] then
		currencies[sCurrency] = currencies[sCurrency] + nAmount
	else
		currencies[sCurrency] = nAmount
	end

	self:SetAdminOnlyData("currency", currencies)
end

function rainchar:RemoveCurrency(nAmount, sCurrency)
	local currencies = self:GetAdminOnlyData("currency", {})

	if !sCurrency then
		sCurrency = "Master"
	end

	if currencies[sCurrency] then
		currencies[sCurrency] = math.Clamp((currencies[sCurrency] - nAmount), 0, math.inf)
	end

	self:SetAdminOnlyData("currency", currencies)
end