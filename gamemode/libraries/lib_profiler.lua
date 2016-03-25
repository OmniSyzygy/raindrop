--[[
	Lua Profiler (1.0 dev)

	Alexander Grist-Hucker
	http://www.revotech.org
--]]

local pcall = pcall;
local unpack = unpack;
local tostring = tostring;
local pairs = pairs;
local table = table; 
local math = math;
local SysTime = SysTime;
local AddCSLuaFile = AddCSLuaFile;

if (SERVER) then
	AddCSLuaFile();
end;

if (!ConVarExists("profiler_enabled")) then
	CreateConVar("profiler_enabled", "1", FCVAR_NONE);
end;

local ProfilerEnabled = 1;
local ProfilerStored = {};
local ProfilerData = {};
local ProfilerTime = 0;

profiler = {};

function profiler.Call(name, uniqueID, func, ...)
	if (GetConVarNumber("profiler_enabled") == 1) then
		if (!ProfilerStored[name]) then
			ProfilerStored[name] = {};
		end;

		if (!ProfilerStored[name][uniqueID]) then
			ProfilerStored[name][uniqueID] = {
				times = {}, min = 0, max = 0, avg = 0 
			};
		end;

		local startTime = SysTime();
			local result = {pcall(func, ...)};
		table.insert(ProfilerStored[name][uniqueID].times, SysTime() - startTime);

		if (#ProfilerStored[name][uniqueID].times >= 5) then
			table.remove(ProfilerStored[name][uniqueID].times);
		end;

		return unpack(result);
	end;

	local result = {pcall(func, ...)};

	return unpack(result);
end;

function profiler.GetResults()
	local data = table.Copy(ProfilerData);
	local usage = {};

	for k, v in pairs(data) do
		local stored = {};

		for k2, v2 in pairs(v.stored) do
			local value = math.Round((((v2 or 0) / v.time) * 100) * 100.0) / 100.0;

			stored[#stored + 1] = {key = tostring(k2), value = value, time = tostring(v2)};
		end;

		table.sort(stored, function(a, b)
			return a.value > b.value;
		end);

		local value = math.Round((((v.time or 0) / ProfilerTime) * 100) * 100.0) / 100.0;

		usage[#usage + 1] = {key = tostring(k), value = value, time = tostring(v.time), stored = stored};
	end;

	if (table.Count(usage) == 0) then
		MsgC(Color(255, 0, 0), "No Profiler Data!\n");
	end;

	table.sort(usage, function(a, b)
		return a.value > b.value;
	end);

	return usage;
end;

function profiler.GetStored()
	return ProfilerStored;
end;

function profiler.GetTime()
	return ProfilerTime;
end;

function profiler.GetData()
	return ProfilerData;
end;

timer.Create("Profiler", 1, 0, function()
	if (GetConVarNumber("profiler_enabled") == 1) then
		ProfilerTime = 0;
		ProfilerData = {};

		for k, v in pairs(ProfilerStored) do
			for k2, v2 in pairs(v) do
				ProfilerStored[k][k2].min = math.min(unpack(ProfilerStored[k][k2].times));
				ProfilerStored[k][k2].max = math.max(unpack(ProfilerStored[k][k2].times));

				for i = 1, #ProfilerStored[k][k2].times, 1 do
					ProfilerStored[k][k2].avg = ProfilerStored[k][k2].avg + ProfilerStored[k][k2].times[i];
				end;

				ProfilerStored[k][k2].avg = ProfilerStored[k][k2].avg / #ProfilerStored[k][k2].times;

				ProfilerTime = ProfilerTime + (ProfilerStored[k][k2].avg or 0);

				ProfilerData[k] = ProfilerData[k] or {};
				ProfilerData[k].time = (ProfilerData[k].time or 0) + (ProfilerStored[k][k2].avg or 0);
				ProfilerData[k].stored = ProfilerData[k].stored or {};
				ProfilerData[k].stored[k2] = ProfilerStored[k][k2].avg;
			end;
		end;

		ProfilerStored = {};
	end;
end);

concommand.Add("Profiler", function(player, command, arguments)
	if (IsValid(player) and !player:IsSuperAdmin()) then
		return;
	end;

	if (GetConVarNumber("profiler_enabled") != 1) then
		MsgC(Color(255, 0, 0), "Profiler is not enabled! Use \"profiler_enabled 1\" to enabled it.");
		return;
	end;

	local usage = profiler.GetResults();

	print("######## Profiler ########");

	for k, v in pairs(usage) do
		local color = math.Round(math.Clamp(v.value * 2.55, 0, 255), 0);

		print(v.key..": "..v.value.."% => ("..v.time.."ms)");
		--MsgC(Color(color, 255 - color, 0, 255), v.key..": "..v.value.."% => ("..v.time.."ms)\n");

		local i = 0;
		for k2, v2 in pairs(v.stored) do
			if (i >= 5) then
				break;
			end;

			if (v2.key and v2.value) then
				local color = math.Round(math.Clamp(v2.value * 2.55, 0, 255), 0);

				print("    "..v2.key..": "..v2.value.."% => ("..v2.time.."ms)");
				--MsgC(Color(color, 255 - color, 0, 255), "    "..v2.key..": "..v2.value.."% => ("..v2.time.."ms)\n");

				i = i + 1;
			end;
		end;
	end;

	print("Total: "..ProfilerTime.."ms");
end);