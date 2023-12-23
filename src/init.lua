local charEmpty = ''
local charZero = '0'
local asciiOne = string.byte '1'
local asciiZero = string.byte '0'
local empty = {}

local function sand(string1, string2)
	local length = math.max(#string1, #string2)
	local string3 = {}

	for i = 1, length do
		string3[i] = (string.byte(string1, i) == asciiOne and string.byte(string2, i) == asciiOne) and 1 or 0
	end

	for i = length, 1, -1 do
		if string3[i] ~= 0 then
			break
		end
		string3[i] = nil
	end

	return #string3 == 0 and charZero or table.concat(string3, charEmpty)
end

local function sor(string1, string2)
	local length = math.max(#string1, #string2)
	local string3 = {}

	for i = 1, length do
		string3[i] = (string.byte(string1, i) == asciiOne or string.byte(string2, i) == asciiOne) and 1 or 0
	end

	for i = length, 1, -1 do
		if string3[i] ~= 0 then
			break
		end
		string3[i] = nil
	end

	return #string3 == 0 and charZero or table.concat(string3, charEmpty)
end

local function sxor(string1, string2)
	local length = math.max(#string1, #string2)
	local string3 = {}

	for i in string3 do
	string3[i] = if (string.byte(string1, i) or asciiZero) == (string.byte(string2, i) or asciiZero) then 0 else 1
end

	for i = #string3, 1, -1 do
		if string3[i] ~= 0 then
			break
		end
		string3[i] = nil
	end

	return #string3 == 0 and charZero or table.concat(string3, charEmpty)
end

local function splace(place)
	local String = {}

	for i = 1, place - 1 do
		String[i] = 0
	end

	String[place] = 1

	return #String == 0 and charZero or table.concat(String, charEmpty)
end

local function nextId(last)
	last = last + 1
	local bytes = math.ceil(math.log(last + 1, 256))
	local str
	if bytes <= 1 then
		str = string.char(math.floor(last) % 256)
	elseif bytes == 2 then
		str = string.char(math.floor(last) % 256, math.floor(last * 256 ^ -1) % 256)
	elseif bytes == 3 then
		str = string.char(math.floor(last) % 256, math.floor(last * 256 ^ -1) % 256, math.floor(last * 256 ^ -2) % 256)
	elseif bytes == 4 then
		str = string.char(
			math.floor(last) % 256,
			math.floor(last * 256 ^ -1) % 256,
			math.floor(last * 256 ^ -2) % 256,
			math.floor(last * 256 ^ -3) % 256
		)
	elseif bytes == 5 then
		str = string.char(
			math.floor(last) % 256,
			math.floor(last * 256 ^ -1) % 256,
			math.floor(last * 256 ^ -2) % 256,
			math.floor(last * 256 ^ -3) % 256,
			math.floor(last * 256 ^ -4) % 256
		)
	elseif bytes == 6 then
		str = string.char(
			math.floor(last) % 256,
			math.floor(last * 256 ^ -1) % 256,
			math.floor(last * 256 ^ -2) % 256,
			math.floor(last * 256 ^ -3) % 256,
			math.floor(last * 256 ^ -4) % 256,
			math.floor(last * 256 ^ -5) % 256
		)
	elseif bytes == 7 then
		str = string.char(
			math.floor(last) % 256,
			math.floor(last * 256 ^ -1) % 256,
			math.floor(last * 256 ^ -2) % 256,
			math.floor(last * 256 ^ -3) % 256,
			math.floor(last * 256 ^ -4) % 256,
			math.floor(last * 256 ^ -5) % 256,
			math.floor(last * 256 ^ -6) % 256
		)
	else
		str = string.char(
			math.floor(last) % 256,
			math.floor(last * 256 ^ -1) % 256,
			math.floor(last * 256 ^ -2) % 256,
			math.floor(last * 256 ^ -3) % 256,
			math.floor(last * 256 ^ -4) % 256,
			math.floor(last * 256 ^ -5) % 256,
			math.floor(last * 256 ^ -6) % 256,
			math.floor(last * 256 ^ -7) % 256
		)
	end

	return last, str
end

local function split(str)
	local include, exclude = string.match(str, '([^,]+)!([^,]+)') or str
	return include, exclude
end

--[=[
	@class Stew
]=]
local Stew = {}

local function getCollection(world, signature)
	local found = world._signatureToCollection[signature]
	if found then
		return found
	end

	local include, exclude = split(signature)

	local collection = {}
	world._signatureToCollection[signature] = collection

	local universal = world._signatureToCollection[charZero]

	for entity in pairs(universal) do
		local data = world._entityToData[entity]
		if
			sand(include, data.signature) == include and (not exclude or sand(exclude, data.signature) == charZero)
		then
			collection[entity] = data.components
		end
	end

	return collection
end

local function nop()
	return
end

local tag = {
	add = function(factory, entity)
		return true
	end,

	remove = nop,

	data = nil,
}

local function register(world, entity)
	assert(not world._entityToData[entity], 'Attempting to register entity twice')

	local entityData = {
		signature = charZero,
		components = {},
	}

	world._entityToData[entity] = entityData

	getCollection(world, charZero)[entity] = entityData.components

	world.spawned(entity)
end

local function unregister(world, entity)
	assert(world._entityToData[entity], 'Attempting to unregister entity twice')

	getCollection(world, charZero)[entity] = nil
	world._entityToData[entity] = nil

	world.killed(entity)
end

local function updateCollections(world, entity, entityData)
	local signature = entityData.signature

	for collectionSignature, collection in pairs(world._signatureToCollection) do
		local collectionInclude, collectionExclude = split(collectionSignature)

		if
			sand(collectionInclude, signature) == collectionInclude
			and (collectionExclude == nil or sand(collectionExclude, signature) == charZero)
		then
			if collection[entity] == nil then
				collection[entity] = entityData.components
			end
		elseif collection[entity] ~= nil then
			collection[entity] = nil
		end
	end
end

--[=[
	@within World
	@interface Archetype
	.factory Factory<E, C, D, A..., R...>,
	.create (factory, entity: E, A...) -> C,
	.delete (factory, entity: E, component: C, R...) -> ()
	.signature string,
]=]

--[=[
	@within Stew
	@interface World
	. added (factory: Factory, entity: any, component: any)
	. removed (factory: Factory, entity: any, component: any)
	. spawned (entity: any) -> ()
	. killed (entity: any) -> ()
	. built (archetype: Archetype) -> ()
]=]

Stew._nextWorldId = -1

--[=[
	@within Stew
	@return World

	Creates a new world.

	```lua
	-- Your very own world to toy with
	local myWorld = Stew.world()

	-- If you'd like to listen for certain events, you can define these callbacks:

	-- Called whenever a new factory is built
	function myWorld.built(archetype: Archetype) end

	-- Called whenever a new entity is registered
	function myWorld.spawned(entity) end

	-- Called whenever an entity is unregistered
	function myWorld.killed(entity) end

	-- Called whenever an entity recieves a component
	function myWorld.added(factory, entity, component) end

	-- Called whenever an entity loses a component
	function myWorld.removed(factory, entity, component) end
	```
]=]
function Stew.world()
	--[=[
		@class World

		Worlds are containers for everything in your ECS. They hold all the state and factories you define later. They are very much, an isolated tiny world.

		"Oh what a wonderful world!" - Louis Armstrong
	]=]
	local world = {
		_nextPlace = 1,
		_nextEntityId = -1,
		_factoryToData = {},
		_entityToData = {},
		_signatureToCollection = {
			[charZero] = {},
		},

		built = nop,
		spawned = nop,
		killed = nop,
		added = nop,
		removed = nop,
	}

	Stew._nextWorldId, world._id = nextId(Stew._nextWorldId)

	--[=[
		@within World
		@interface FactoryArgs
		.add (factory: Factory, entity: E, A...) -> C
		.remove (factory: Factory, entity: E, component: C, R...) -> ()?
		.data D?
	]=]

	--[=[
		@within World
		@param factoryArgs FactoryArgs
		@return Factory

		Creates a new factory from an `add` constructor and optional `remove` destructor. An optional `data` field can be defined here and accessed from the factory to store useful metadata like identifiers.

		```lua
		local world = Stew.world()

		local position = world.factory {
			add = function(factory, entity: any, x: number, y: number, z: number)
				return Vector3.new(x, y, z)
			end,
		}

		print(position.data)
		-- nil

		print(position.add('A really cool entity', 5, 7, 9))
		-- Vector3.new(5, 7, 9)

		position.remove('A really cool entity')

		local body = world.factory {
			add = function(factory, entity: Instance, model: Model)
				model.Parent = entity
				return model
			end,
			remove = function(factory, entity: Instance, component: Model)
				component:Destroy()
			end,
			data = 'A temple one might say...',
		}

		print(body.data)
		-- 'A temple one might say...'

		print(body.add(LocalPlayer, TemplateModel))
		-- TemplateModel

		body.remove(LocalPlayer)

		-- If you'd like to listen for interesting events to happen, define these callbacks:

		-- Called when an entity recieves this factory's component
		function body.added(entity: Instance, component: Model) end

		-- Called when an entity loses this factory's component
		function body.removed(entity: Instance, component: Model) end
		```
	]=]
	function world.factory(factoryArgs)
		--[=[
			@class Factory

			Factories are little objects responsible for adding and removing their specific type of component from entities. They are also used to access their type of component from entities and queries. They are well, component factories!
		]=]
		local factory = {
			added = nop,
			removed = nop,
			data = factoryArgs.data,
		}

		local archetype = {
			factory = factory,
			signature = splace(world._nextPlace),
			create = factoryArgs.add,
			delete = factoryArgs.remove or nop,
		}

		--[=[
			@within Factory
			@param entity any
			@param ... any
			@return Component

			Adds the factory's type of component to the entity. If the component already exists, it just returns the old component and does not perform any further changes.

			Anything can be an Entity, if an unregistered object is given a component it is registered as an entity and fires the world `spawned` callback.

			Fires the world and factory `added` callbacks.

			```lua
			local World = require(path.to.world)
			local Move = require(path.to.move.factory)
			local Chase = require(path.to.chase.factory)
			local Model = require(path.to.model.factory)

			local enemy = World.entity()
			Model.add(enemy)
			Move.add(enemy)
			Chase.add(enemy)

			-- continues to below example
			```
		]=]
		function factory.add(entity, ...)
			local entityData = world._entityToData[entity]
			if not entityData then
				register(world, entity)
				entityData = world._entityToData[entity]
			end

			if entityData.components[factory] then
				return entityData.components[factory]
			end

			local component = archetype.create(factory, entity, ...)
			if component == nil then
				return nil
			end

			local signature = sor(entityData.signature, archetype.signature)
			entityData.signature = signature
			entityData.components[factory] = component

			updateCollections(world, entity, entityData)

			factory.added(entity, component)
			world.added(factory, entity, component)

			return component
		end

		--[=[
			@within Factory
			@param entity any
			@param ... any
			@return void?

			Removes the factory's type of component from the entity. If the entity is unregistered, nothing happens.

			Fires the world and factory `removed` callbacks.

			If this is the last component the entity has, it kills the entity and fires the world `killed` callback.

			```lua
			-- continued from above example

			task.wait(5)

			Chase.remove(entity)
			Move.remove(entity)
			```
		]=]
		function factory.remove(entity, ...)
			local entityData = world._entityToData[entity]
			if not entityData then
				return
			end

			local component = entityData.components[factory]
			if not component then
				return
			end

			archetype.delete(factory, entity, component, ...)

			local signature = sxor(entityData.signature, archetype.signature)
			entityData.signature = signature
			entityData.components[factory] = nil

			updateCollections(world, entity, entityData)

			factory.removed(entity, component)
			world.removed(factory, entity, component)

			if not next(entityData.components) then
				unregister(world, entity)
			end

			return nil
		end

		--[=[
			@within Factory
			@param entity any
			@return Component?

			Returns the factory's type of component from the entity if it exists.

			If component is not a table or other referenced type it will not be mutable. Use `World.get` instead if this is a requirement.
			```lua
			local World = require(path.to.World)

			local Fly = World.factory { ... }

			for _, player in Players:GetPlayers() do
				Fly.add(player)
			end

			onPlayerTouched(BlackholeBrick, function(player: Player)
				local fly = Fly.get(player)
				if fly and fly.speed < Constants.LightSpeed then
					World.kill(player)
				end
			end)
			```
		]=]
		function factory.get(entity)
			local entityData = world._entityToData[entity]
			return entityData and entityData.components[factory]
		end

		world._factoryToData[factory] = archetype
		world._nextPlace = world._nextPlace + 1

		world.built(archetype)

		return factory
	end

	--[=[
		@within World
		@return Factory

		Syntax sugar for defining a factory that adds a `true` component. It is used to mark the *existence* of the component, like a tag does.

		```lua
		local world = Stew.world()

		local sad = world.tag()
		local happy = world.tag()
		local sleeping = world.tag()
		local poisoned = world.tag()

		local allHappyPoisonedSleepers = world.query { happy, poisoned, sleeping }
		```
	]=]
	function world.tag()
		return world.factory(tag)
	end

	--[=[
		@within World

		Creates an arbitrary entity and registers it. Keep in mind, in Stew, *anything* can be an Entity (except nil). If you don't have a pre-existing object to use as an entity, this will create a unique identifier you can use.

		Can be sent over remotes and is unique across worlds!

		```lua
		local World = require(path.to.world)
		local Move = require(path.to.move.factory)
		local Chase = require(path.to.chase.factory)
		local Model = require(path.to.model.factory)

		local enemy = World.entity()
		Model.add(enemy)
		Move.add(enemy)
		Chase.add(enemy)

		-- continues to below example
		```
	]=]
	function world.entity()
		local entity
		world._nextEntityId, entity = nextId(world._nextEntityId)
		return world._id .. entity
	end

	--[=[
		@within World
		@param entity any
		@param ... any

		Removes all components from an entity and unregisters it.

		Fires the world `killed` callback.

		```lua
		-- continued from above example

		task.wait(5)

		World.kill(enemy)
		```
	]=]
	function world.kill(entity, ...)
		local entityData = world._entityToData[entity]
		if not entityData then
			return
		end

		for factory in pairs(entityData.components) do
			factory.remove(entity, ...)
		end
	end

	--[=[
		@within World
		@type Components { [Factory]: Component }
	]=]

	--[=[
		@within World
		@tag Do Not Modify
		@param entity any
		@return Components

		Gets all components of an entity in a neat table you can iterate over.

		This is a reference to the internal representation, so mutating this table directly will cause Stew to be out-of-sync.

		```lua
		local World = require(path.to.world)
		local Move = require(path.to.move.factory)
		local Chase = require(path.to.chase.factory)
		local Model = require(path.to.model.factory)

		local enemy = World.entity()

		Model.add(enemy)

		local components = world.get(enemy)

		for factory, component in components do
			print(factory, component)
		end
		-- Model, Model

		Move.add(enemy)

		for factory, component in components do
			print(factory, component)
		end
		-- Model, Model
		-- Move, BodyMover

		Chase.add(enemy)

		for factory, component in components do
			print(factory, component)
		end
		-- Model, Model
		-- Move, BodyMover
		-- Chase, TargetInstance

		print(world.get(entity)[Chase]) -- TargetInstance
		```
	]=]
	function world.get(entity)
		local data = world._entityToData[entity]
		return data and data.components or empty
	end

	--[=[
		@within World
		@tag Do Not Modify
		@param include { Factory }
		@param exclude { Factory }?
		@return { [Entity]: Components }

		Gets a set of all entities that have all included components, and do not have any excluded components. (This is the magic sauce of it all!)

		This is a reference to the internal representation, so mutating this table directly will cause Stew to be out-of-sync.

		```lua
		local World = require(path.to.world)
		local Invincible = require(path.to.invincible.tag)
		local Poisoned = require(path.to.poisoned.factory)
		local Health = require(path.to.health.factory)
		local Color = require(path.to.color.factory)

		local poisonedHealths = world.query({ Poisoned, Health }, { Invincible })

		-- This is a very cool system
		RunService.Heartbeat:Connect(function(deltaTime)
			for entity, components in poisonedHealths do
				local health = components[Health]
				local poison = components[Poison]
				health.current -= deltaTime * poison

				if health.current < 0 then
					World.kill(entity)
				end
			end
		end)

		-- This is another very cool system
		RunService.RenderStepped:Connect(function(deltaTime)
			for entity, components in world.query { Poisoned, Color } do
				local color = components[Color]
				color.hue += deltaTime * (120 - color.hue)
				color.saturation += deltaTime * (1 - color.saturation)
			end
		end)
		```
	]=]
	function world.query(include, exclude)
		local signatureInclude = charZero

		for _, factory in ipairs(include) do
			local data = world._factoryToData[factory]
			if not data then
				error('Passed a non-factory or a different world\'s factory into an include query!', 2)
			end

			signatureInclude = sor(signatureInclude, data.signature)
		end

		if exclude then
			local signatureExclude = charZero

			for _, factory in ipairs(exclude) do
				local data = world._factoryToData[factory]
				if not data then
					error('Passed a non-factory or a different world\'s factory into an exclude query!', 2)
				end

				signatureExclude = sor(signatureExclude, data.signature)
			end

			signatureInclude = signatureInclude .. '!' .. signatureExclude
		end

		return getCollection(world, signatureInclude)
	end

	return world
end

-- do
-- 	local world = Stew.world()

-- 	function world.built(archetype)
-- 		print("BUILT", archetype.signature)
-- 	end

-- 	local Position = world.factory {
-- 		add = function(f, e, t)
-- 			t.x = tonumber(t.x) or t[1] or 0
-- 			t.y = tonumber(t.y) or t[2] or 0
-- 			t.z = tonumber(t.z) or t[3] or 0
-- 			return { x = t.x, y = t.y, z = t.z }
-- 		end,
-- 	}
-- 	local Name = world.factory {
-- 		add = function(f, e, t)
-- 			if type(t) == 'string' then
-- 				return { val = t }
-- 			end
-- 			t.val = t.val or 'NO NAME'
-- 			t.val = tostring(t.val)
-- 			return t
-- 		end,
-- 		data = {
-- 			Name = 'Name',
-- 			UniqueEntities = {},
-- 		},
-- 	}
-- 	local DoorState = world.factory {
-- 		add = function(f, e, t)
-- 			t.proxRadius = t.proxRadius or 5
-- 			t.wantState = 'close'
-- 			t.currentState = 'close'
-- 			t.lastStateChange = os.clock()
-- 			t.cooldown = t.cooldown or 3
-- 			t.redstoneEmitSide = t.redstoneEmitSide or 'right'
-- 			t.redstoneEmitSide = tostring(t.redstoneEmitSide)
-- 			return t
-- 		end,
-- 	}
-- 	local UpdatePosFromRednet = world.tag()
-- 	local Player_Tag = world.tag()
-- 	local UpdatePosFromGPSOnce = world.tag()
-- 	--[[
-- function world.added(f, e, c)
-- 	if type(f.data) == "table" and type(e) == "table" and f.data.Name then
-- 		e[f.data.Name] = c
-- 	end
-- end
-- function world.removed(f, e, c)
-- 	if type(f.data) == "table" and type(e) == "table" and f.data.Name then
-- 		e[f.data.Name] = nil
-- 	end
-- end
-- ]]

-- 	function Name.added(e, c)
-- 		Name.data.UniqueEntities[c.val] = e
-- 	end
-- 	function Name.removed(e, c)
-- 		Name.data.UniqueEntities[c.val] = nil
-- 	end

-- 	local function RegisterPlayer(playerName)
-- 		local ent = world.entity()
-- 		Position.add(ent, { 1, 3, 2 })
-- 		print(
-- 			'PLAYER POSITION REGISTERED',
-- 			Position.get(ent),
-- 			Position.get(ent).x,
-- 			Position.get(ent).y,
-- 			Position.get(ent).z
-- 		)
-- 		UpdatePosFromRednet.add(ent)
-- 		Player_Tag.add(ent)
-- 		Name.add(ent, playerName)
-- 		return ent
-- 	end

-- 	RegisterPlayer 'Unbox101'
-- 	RegisterPlayer 'Drako1245'

-- 	local ent = world.entity()
-- 	Position.add(ent, { 1, 2, 3 })
-- 	print('DOOR POSITION REGISTERED', Position.get(ent), Position.get(ent).x, Position.get(ent).y, Position.get(ent).z)
-- 	Name.add(ent, 'Main Entrance Sliding Door')
-- 	UpdatePosFromGPSOnce.add(ent)
-- 	DoorState.add(ent, { proxRadius = 9, redstoneEmitSide = 'right', cooldown = 0.9 })

-- 	--Update door entity pos from gps ONCE
-- 	for ent, data in pairs(world.query { Position, UpdatePosFromGPSOnce }) do
-- 		local x, y, z = 1, 2, 3
-- 		local pos = data[Position]
-- 		pos.x = x
-- 		pos.y = y
-- 		pos.z = z
-- 		print('Updated pos to gps ', x, y, z)
-- 		--UpdatePosFromGPSOnce.remove(ent)
-- 	end
-- 	while true do
-- 		--Reset door wants
-- 		for ent, data in pairs(world.query { DoorState }) do
-- 			print(world.query { DoorState })
-- 			data[DoorState].wantState = 'close'
-- 		end
-- 		--Set door wants based on nearby players
-- 		for doorEnt, doorComps in pairs(world.query { Position, DoorState }) do
-- 			for playerEnt, playerComps in pairs(world.query { Position, Player_Tag }) do
-- 				local doorPos = doorComps[Position]
-- 				local playerPos = playerComps[Position]
-- 				local doorState = doorComps[DoorState]
-- 				print('\tDOORPOS', doorPos, doorPos.x, doorPos.y, doorPos.z)
-- 				print('\tPLAYERPOS', playerPos, playerPos.x, playerPos.y, playerPos.z)
-- 				if
-- 					(playerPos.x - doorPos.x) ^ 2 + (playerPos.y - doorPos.y) ^ 2 + (playerPos.z - doorPos.z) ^ 2
-- 					< doorState.proxRadius ^ 2
-- 				then
-- 					doorState.wantState = 'open'
-- 					-- print("Distance to door = ", tostring((playerEnt.Position - doorEnt.Position):length()))
-- 				end
-- 			end
-- 		end
-- 		--Update door state if it is not mid cooldown animation
-- 		for doorEnt, doorComps in pairs(world.query { Position, DoorState }) do
-- 			local doorState = doorComps[DoorState]
-- 			if
-- 				os.clock() - doorState.lastStateChange > doorState.cooldown
-- 				and doorState.wantState ~= doorState.currentState
-- 			then
-- 				doorState.lastStateChange = os.clock()
-- 				doorState.currentState = doorState.wantState
-- 				os.sleep(0.1)
-- 			end
-- 		end
-- 		--UpdateEntity from rednet receive
-- 		if math.random() < 0.5 then
-- 			local mData = {
-- 				UniqueId = 'Unbox101',
-- 			}

-- 			if Name.data.UniqueEntities[mData.UniqueId] then
-- 				local Entity = Name.data.UniqueEntities[mData.UniqueId]
-- 				if mData.Position then
-- 					local pos = Position.get(Entity)
-- 					pos.x = mData.Position.x or 0
-- 					pos.y = mData.Position.y or 0
-- 					pos.z = mData.Position.z or 0
-- 				end
-- 			end
-- 		end
-- 	end
-- end

return Stew
