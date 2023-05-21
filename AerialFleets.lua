--[[

     █████  ███████ ██████  ██  █████  ██          ███████ ██      ███████ ███████ ████████ ███████ 
    ██   ██ ██      ██   ██ ██ ██   ██ ██          ██      ██      ██      ██         ██    ██      
    ███████ █████   ██████  ██ ███████ ██          █████   ██      █████   █████      ██    ███████ 
    ██   ██ ██      ██   ██ ██ ██   ██ ██          ██      ██      ██      ██         ██         ██ 
    ██   ██ ███████ ██   ██ ██ ██   ██ ███████     ██      ███████ ███████ ███████    ██    ███████ 
                                                 
    Features:
    - Compatible All Stand Versions if deprecated versions too.
    - Complete script.

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html

    Owner: Stealthy.#8293
]]--

    ---========================================----
    ---       Basic Parts for Air Fleet
    ---      The part of most important
    ----========================================----

        util.keep_running()
        util.require_natives(1681379138)
        local int_max = 2147483647
        local SCRIPT_VERSION = "1.93LN"
        local STAND_VERSION = menu.get_version().version
        local AerialFleetMSG = "Aerial Fleets v"..SCRIPT_VERSION

        local aalib = require("aalib")
        FleetSongs = aalib.play_sound
        local SND_ASYNC<const> = 0x0001
        local SND_FILENAME<const> = 0x00020000

        AerialFleetsNotify = function(str) if ToggleNotify then if NotifMode == 2 then util.show_corner_help(AerialFleetMSG.."~s~~n~"..str) else util.toast(AerialFleetMSG.."\n\n"..str) end end end
        AWACSNotify = function(str) if ToggleNotify then if NotifMode == 2 then util.show_corner_help("AWACS Detection System".."~s~~n~"..str ) else util.toast("AWACS Detection System".."\n\n"..str) end end end
        AvailableSession =  function() return util.is_session_started() and not util.is_session_transition_active() end

        local script_resources = filesystem.resources_dir() .. "AerialFleets" -- Redirects to %appdata%\Stand\Lua Scripts\resources\AerialFleets
        if not filesystem.is_dir(script_resources) then
            filesystem.mkdirs(script_resources)
        end

        local songs = script_resources .. "/Songs" -- Redirects to %appdata%\Stand\Lua Scripts\resources\AerialFleets\Songs
        if not filesystem.is_dir(songs) then
            filesystem.mkdirs(songs)
        end

    ---========================================----
    ---         Functions for Air Fleet
    ---         The part of essentials
    ----========================================----

        local function request_model_load(hash)
            request_time = os.time()
            if not STREAMING.IS_MODEL_VALID(hash) then
                return
            end
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if os.time() - request_time >= 10 then
                    break
                end
                util.yield()
            end
        end

        local function escort_attack(pedUser, hash, surfaceVehicle)
            local limitSpeed = 3200.0
            local speedVehicle = 1300.0
            if not players.is_in_interior(pedUser) then
                local vehicleHash = util.joaat(hash)
                local playerPed = PLAYER.PLAYER_PED_ID()
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pedUser)
                local altitude = surfaceVehicle and 450 or 150
                request_model_load(vehicleHash)
                local playerPos = players.get_position(playerPed)
                playerPos.z = playerPos.z + altitude
                local offsetX = math.random(-55, 55)
                local offsetY = math.random(surfaceVehicle and -125 or -100, surfaceVehicle and 10 or -5)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, offsetX, offsetY, playerPos.z)
                local vehicle = entities.create_vehicle(vehicleHash, coords, ENTITY.GET_ENTITY_HEADING(playerPed))
                if not STREAMING.HAS_MODEL_LOADED(vehicle) then
                    request_model_load(vehicle)
                end
                for i = 0, 49 do
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    if vehicleHash == util.joaat("rogue") or
                       vehicleHash == util.joaat("pyro") or
                       vehicleHash == util.joaat("nokota") or
                       vehicleHash == util.joaat("strikeforce") or
                       vehicleHash == util.joaat("molotok") or
                       vehicleHash == util.joaat("hunter") or
                       vehicleHash == util.joaat("starling") or
                       vehicleHash == util.joaat("akula") then
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                end
                VEHICLE.CONTROL_LANDING_GEAR(vehicle, 3)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, speedVehicle)
                VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, speedVehicle)
                VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle, false)
                VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle, false)
                VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, limitSpeed)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
                VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(vehicle, 0.0)
                VEHICLE.SET_VEHICLE_FORCE_AFTERBURNER(vehicle, true)
                VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, 1)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                coords = ENTITY.GET_ENTITY_COORDS(playerPed, false)
                coords.x = coords['x']
                coords.y = coords['y']
                coords.z = coords['z']
                local hash_models = {
                    util.joaat("s_m_y_blackops_01"),
                    util.joaat("s_m_m_marine_01"),
                    util.joaat("s_m_m_pilot_02"),
                    util.joaat("s_m_y_pilot_01"),
                    util.joaat("s_m_m_marine_02"),
                    util.joaat("s_m_m_prisguard_01"),
                    util.joaat("mp_g_m_pros_01"),
                    util.joaat("mp_m_avongoon"),
                    util.joaat("mp_m_boatstaff_01"),
                    util.joaat("mp_m_bogdangoon"),
                    util.joaat("mp_m_claude_01"),
                    util.joaat("mp_m_cocaine_01"),
                    util.joaat("mp_m_counterfeit_01"),
                    util.joaat("mp_m_exarmy_01"),
                    util.joaat("mp_m_fibsec_01")
                }
                local hash_model = hash_models[math.random(#hash_models)]
                request_model_load(hash_model)
                local attacker = entities.create_ped(28, hash_model, coords, math.random(0, 270))
                PED.SET_PED_AS_COP(attacker, true)
                PED.SET_DRIVER_AGGRESSIVENESS(attacker, 1.0)
                PED.SET_PED_CONFIG_FLAG(attacker, 281, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 2, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 33, false)
                PED.SET_PED_HEARING_RANGE(attacker, 99999)
                PED.SET_PED_RANDOM_COMPONENT_VARIATION(attacker, 0)
                PED.SET_PED_SHOOT_RATE(attacker, 5)
                PED.SET_PED_ACCURACY(attacker, 100.0)
                PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                PED.SET_PED_COMBAT_ABILITY(attacker, 2, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, false)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attacker, true)
                ENTITY.SET_ENTITY_INVINCIBLE(attacker, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                PED.CREATE_PED_INSIDE_VEHICLE(attacker, vehicle, 28, hash_model, -1, true)
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attacker, true, true)
                local playerEnemy = players.get_position(pedUser)
                playerEnemy.z = playerEnemy.z + altitude
                if VEHICLE.IS_THIS_MODEL_A_HELI(vehicleHash) then
                    TASK.TASK_HELI_CHASE(attacker, ped, playerEnemy.x, playerEnemy.y, playerEnemy.z)
                    local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                    if PED.IS_PED_IN_VEHICLE(ped, playerVehicle, false) then
                        TASK.TASK_HELI_MISSION(attacker, vehicle, playerVehicle, ped, playerEnemy.x, playerEnemy.y, playerEnemy.z, 6, 300, 100.0, 0, -1, 0.0, 0.0, true)
                    else
                        TASK.TASK_HELI_MISSION(attacker, vehicle, 0, ped, playerEnemy.x, playerEnemy.y, playerEnemy.z, 6, 300, 100.0, 0, -1, 0.0, 0.0, true)
                    end
                    VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehicle)
                    VEHICLE.SET_HELI_BLADES_SPEED(vehicle, 1.0)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                    VEHICLE.SET_VEHICLE_FORCE_AFTERBURNER(vehicle, true)
                else
                    TASK.TASK_VEHICLE_MISSION_PED_TARGET(attacker, vehicle, ped, 6, 500.0, 786988, 0.0, 0.0, true)
                    TASK.TASK_PLANE_CHASE(attacker, ped, playerEnemy.x, playerEnemy.y, playerEnemy.z)
                    local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                    if PED.IS_PED_IN_VEHICLE(ped, playerVehicle, false) then
                        TASK.TASK_PLANE_MISSION(attacker, vehicle, playerVehicle, ped, playerEnemy.x, playerEnemy.y, playerEnemy.z, 6, 100.0, -1.0, 0, 100, 0.0, 0.0, true)
                    else
                        TASK.TASK_PLANE_MISSION(attacker, vehicle, 0, ped, playerEnemy.x, playerEnemy.y, playerEnemy.z, 6, 100.0, -1.0, 0, 100, 0.0, 0.0, true)
                    end
                    VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                    VEHICLE.SET_VEHICLE_FORCE_AFTERBURNER(vehicle, true)
                end
                TASK.TASK_VEHICLE_CHASE(attacker, ped)
                TASK.SET_DRIVE_TASK_DRIVING_STYLE(attacker, 2883621)
                PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(attacker, 1)
            end
        end

        local function display_onscreen_keyboard()
            MISC.DISPLAY_ONSCREEN_KEYBOARD(1, "FMMC_KEY_TIP8", "", "", "", "", "", 100)
            while MISC.UPDATE_ONSCREEN_KEYBOARD() == 0 do
                util.yield_once()
            end
        
            if MISC.UPDATE_ONSCREEN_KEYBOARD() == 1 then
                local text = MISC.GET_ONSCREEN_KEYBOARD_RESULT()
                return text
            end
        end

        local function harass_vehicle(pedUser, vehicleHash, aerialCar)
            if aerialCar then
                if not players.is_in_interior(pedUser) then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pedUser)
                    local hash = util.joaat(vehicleHash)
                    request_model_load(hash)
                    local altitude = 150
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, altitude)
                    local vehicle = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(ped))
                    if not STREAMING.HAS_MODEL_LOADED(vehicle) then
                        request_model_load(vehicle)
                    end
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                    VEHICLE.CONTROL_LANDING_GEAR(vehicle, 3)
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 320.0)
                    VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, 1000.0)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
                    VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(PlaneToggleGod))
                    coords = ENTITY.GET_ENTITY_COORDS(ped, false)
                    coords.x = coords['x']
                    coords.y = coords['y']
                    coords.z = coords['z']
                    local hash_model = util.joaat("s_m_y_pilot_01")
                    request_model_load(hash_model)
                    local attacker = entities.create_ped(28, hash_model, coords, math.random(0, 270))
                    PED.SET_PED_AS_COP(attacker, true)
                    PED.CREATE_PED_INSIDE_VEHICLE(attacker, vehicle, 28, hash_model, -1, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 281, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 2, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 33, false)
                    PED.SET_PED_HEARING_RANGE(attacker, 99999)
                    PED.SET_PED_RANDOM_COMPONENT_VARIATION(attacker, 0)
                    PED.SET_PED_SHOOT_RATE(attacker, 5)
                    VEHICLE.CONTROL_LANDING_GEAR(vehicle, 3)
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 100.0)
                    VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, 1000.0)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
                    VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
                    PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attacker, true, true)
                    TASK.TASK_VEHICLE_MISSION_PED_TARGET(attacker, vehicle, ped, 6, 500.0, 786988, 0.0, 0.0, true)
                    PED.SET_PED_ACCURACY(attacker, 100.0)
                    PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                    PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                    PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(attacker, 1)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(attacker, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                    local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                    PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                end
            end
        end

        local function ResetRendering()
            menu.trigger_commands("locktime off")
            menu.trigger_commands("clouds normal")
            if AvailableSession() then
                menu.trigger_commands("syncclock")
            end
        end

        local randomMsgs = {
            "Smell like Vietnam but we are crazy",
            "hmm we want freedom and oil",
            "war is not ready but we are ready",
            "Good Morning Vietnam",
            "Ready to fight for freedom?",
        }

        local function join_path(parent, child)
            local sub = parent:sub(-1)
            if sub == "/" or sub == "\\" then
                return parent .. child
            else
                return parent .. "/" .. child
            end
        end

    ---========================================----
    ---        Exclusion Aerial Fleets
    ---         The part of exclude
    ----========================================----

        EToggleSelf = true
        EToggleFriend = true
        EToggleStrangers = true
        EToggleCrew = true
        EToggleOrg = true
        
        local function toggleSelfCallback(toggle)
            EToggleSelf = not toggle
        end
        
        local function toggleFriendCallback(toggle)
            EToggleFriend = not toggle
        end

        local function toggleStrangersCallback(toggle)
            EToggleStrangers = not toggle
        end

        local function toggleCrewCallback(toggle)
            EToggleCrew = not toggle
        end

        local function toggleOrgCallback(toggle)
            EToggleOrg = not toggle
        end

        local TaskForceDesc = "The \"Task Force\" consists of flooding the session with aircraft for which the host acts as an escort and lets the aircraft appear and act autonomously as a killer AI and neither the host will be able to do anything and will not take control of the entities."

    ----========================================----
    ---              Update Parts
    ---     The part of update. Auto or manual
    ----========================================----

        -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
        local status, auto_updater = pcall(require, "auto-updater")
        if not status then
            local auto_update_complete = nil AerialFleetsNotify("Installing auto-updater...", TOAST_ALL)
            async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
                function(result, headers, status_code)
                    local function parse_auto_update_result(result, headers, status_code)
                        local error_prefix = "Error downloading auto-updater: "
                        if status_code ~= 200 then AerialFleetsNotify(error_prefix..status_code, TOAST_ALL) return false end
                        if not result or result == "" then AerialFleetsNotify(error_prefix.."Found empty file.", TOAST_ALL) return false end
                        filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                        local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                        if file == nil then AerialFleetsNotify(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                        file:write(result) file:close() AerialFleetsNotify("Successfully installed auto-updater lib", TOAST_ALL) return true
                    end
                    auto_update_complete = parse_auto_update_result(result, headers, status_code)
                end, function() AerialFleetsNotify("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
            async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
            if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
            auto_updater = require("auto-updater")
        end
        if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

        local default_check_interval = 604800
        local auto_update_config = {
            source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/AerialFleets.lua",
            script_relpath=SCRIPT_RELPATH,
            switch_to_branch=selected_branch,
            verify_file_begins_with="--",
            check_interval=86400,
            silent_updates=true,
            dependencies={
                {
                    name="Logo",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/AerialFleets.png",
                    script_relpath="resources/AerialFleets/AerialFleets.png",
                    check_interval=default_check_interval,
                },
                {
                    name="DisplayLogo",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/DisplayLogo.txt",
                    script_relpath="resources/AerialFleets/DisplayLogo.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="DisplayMessages",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/DisplayMessages.txt",
                    script_relpath="resources/AerialFleets/DisplayLogo.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="aalib",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/lib/aalib.dll",
                    script_relpath="lib/aalib.dll",
                    check_interval=default_check_interval,
                },
                {
                    name="California Dreamin",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/Songs/CaliforniaDreamin.wav",
                    script_relpath="resources/AerialFleets/Songs/CaliforniaDreamin.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="Paint It Black",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/Songs/PaintItBlack.wav",
                    script_relpath="resources/AerialFleets/Songs/PaintItBlack.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="Fortunate Son",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/Songs/FortunateSon.wav",
                    script_relpath="resources/AerialFleets/Songs/FortunateSon.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="Paranoid",
                    source_url="https://raw.githubusercontent.com/StealthyAD/AerialFleets/main/resources/AerialFleets/Songs/Paranoid.wav",
                    script_relpath="resources/AerialFleets/Songs/Paranoid.wav",
                    check_interval=default_check_interval,
                },
            }
        }

        auto_updater.run_auto_update(auto_update_config)

    ---========================================----
    ---        Roots for Aerial Fleets
    ---         The part of essentials
    ----========================================----

        local AerialFleets = menu.my_root()
        AerialFleets:divider(AerialFleetMSG)
        local ExcludeParts = AerialFleets:list("Exclusions", {"afexclusions"})
        local Detections = AerialFleets:list("Detections", {"afdetections"}, "Detect any ways and remove them by consequence.")
        local TaskForce = AerialFleets:list("Task Force", {"aftaskforce"})
        local PlaneParts = AerialFleets:list("US Air Force", {"afusaf"})
        local WeatherParts = AerialFleets:list("World & Weather", {"afworld"})
        local Settings = AerialFleets:list("Settings", {"afsettings"})

    ---========================================----
    ---        Exclude Roots for parts
    ---         The part of essentials
    ----========================================----

        ExcludeParts:toggle("Exclude Self", {"afself"}, "Exclude Self for using these features.", toggleSelfCallback)
        ExcludeParts:toggle("Exclude Friends", {"affriend"}, "Exclude Friends for using these features.", toggleFriendCallback)
        ExcludeParts:toggle("Exclude Strangers", {"afstrangers"}, "Exclude Strangers for using these features.", toggleStrangersCallback)
        ExcludeParts:toggle("Exclude Crew Members", {"afcrews"}, "Exclude Crew Members for using these features.", toggleCrewCallback)
        ExcludeParts:toggle("Exclude Organization Members", {"aforg"}, "Exclude Organization Members for using these features.", toggleOrgCallback)

    ---========================================----
    ---    Continue part for Aerial Fleets
    ----========================================----

        PlaneParts:divider("Advanced Aerial Defense")
        delayAirForce = PlaneParts:slider("Delay Time", {"afdelayaf"}, "Recommended to not spam if you are in public session to avoid saturation of vehicle.\nRecommended: 3 seconds.\nApplies also for helicopters & Planes", 2, int_max, 3, 1, function()end)
        PlaneCount = PlaneParts:slider("Number of Generation of Planes", {"afplanes"}, "For purposes: limit atleast 5 planes if you are in Public session with 30 players.".."\n\nFor recommendation:".."\n".."\n- Lazer: 3 or 5 more.", 1, 10, 1, 1, function()end)
        PlaneToggleGod = PlaneParts:toggle_loop("Toggle Godmode Air Force", {}, "Toggle (Enable/Disable) Godmode Planes while using \"Send Air Force\".",  function()end)
        
        PlaneParts:divider("Aerial Defense (US Air Force)")
        local planeModels = {
            ["Lazer"] = "lazer",
            ["V-65 Molotok"] = "molotok",
            ["Western Rogue"] = "rogue",
            ["Pyro"] = "pyro",
            ["P-45 Nokota"] = "nokota",
        }

        local vehicleModelsToDelete = {
            util.joaat("lazer"),
            util.joaat("hydra"),
            util.joaat("strikeforce"),
            util.joaat("molotok"),
            util.joaat("rogue"),
            util.joaat("pyro"),
            util.joaat("nokota"),
            util.joaat("buzzard"),
            util.joaat("savage"),
            util.joaat("valkyrie"),
            util.joaat("hunter"),
            util.joaat("akula"),
            util.joaat("annihilator"),
            util.joaat("annihilator2"),
            util.joaat("cargobob"),
            util.joaat("starling"),
            util.joaat("mogul"),
            util.joaat("seabreeze"),
        }

        local modelToDelete = {
            util.joaat("s_m_y_marine_01"),
            util.joaat("s_m_y_marine_03"),
            util.joaat("s_m_y_pilot_01"),
            util.joaat("s_m_y_blackops_01"),
            util.joaat("s_m_m_marine_01"),
            util.joaat("s_m_m_pilot_02"),
            util.joaat("s_m_m_marine_02"),
            util.joaat("s_m_m_prisguard_01"),
            util.joaat("mp_g_m_pros_01"),
            util.joaat("mp_m_avongoon"),
            util.joaat("mp_m_boatstaff_01"),
            util.joaat("mp_m_bogdangoon"),
            util.joaat("mp_m_claude_01"),
            util.joaat("mp_m_cocaine_01"),
            util.joaat("mp_m_counterfeit_01"),
            util.joaat("mp_m_exarmy_01"),
            util.joaat("mp_m_fibsec_01")
        }
        
        local planeModelNames = {}
        for name, _ in pairs(planeModels) do
            table.insert(planeModelNames, name)
        end

        table.sort(planeModelNames, function(a, b) return a[1] < b[1] end)
        
        local selectedPlaneModel = "Lazer"
        local planesHash = planeModels[selectedPlaneModel]
        
        PlaneParts:list_select("Types of Planes", {"afplanes"}, "The entities that will add while sending air force planes.", planeModelNames, 1, function(index)
            selectedPlaneModel = planeModelNames[index]
            planesHash = planeModels[selectedPlaneModel]
        end)

        PlaneParts:action("Send Air Force", {"afusafsp"}, "Sending America to war and intervene more planes.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features.", function()
            local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            local delay = menu.get_value(delayAirForce) * 1000
            for _, pid in pairs(playerList) do
                if AvailableSession() and not players.is_in_interior(pid) then
                    for _ = 1, menu.get_value(PlaneCount) do
                        harass_vehicle(pid, planesHash, true)
                        util.yield(delay)
                    end
                end
            end
        end)

        PlaneParts:action("Cleanup Air Force", {}, "Includes jets & helicopters.", function()
            local ct = 0
            local vehicles = entities.get_all_vehicles_as_handles()
            for k, veh in pairs(vehicles) do
                local model = ENTITY.GET_ENTITY_MODEL(veh)
                if table.contains(vehicleModelsToDelete, model) then
                    entities.delete_by_handle(veh)
                    ct = ct + 1
                end
            end
            local et = 0
            local monkeys = entities.get_all_peds_as_handles()
            for k, entity in pairs(monkeys) do
                local model = ENTITY.GET_ENTITY_MODEL(entity)
                if table.contains(modelToDelete, model) then
                    entities.delete_by_handle(entity)
                    et = et + 1
                end
            end
        end)

    ---========================================----
    ---    Task Force Aerial Superiority
    ----========================================----

        local specialMsg = "US Air Force has sent a friend request."
        TaskForce:divider("Parameters for Task Force")
        TaskForce:action("What is Task Force", {}, "Read how does work Task Force in a single summary to understand.\nUndetectable by modders, take the opportunity to invade the session with aggressive means.", function()
            AerialFleetsNotify(TaskForceDesc)
        end)
        local PresetSpawningTF = TaskForce:list("Preset Spawner")
        local CustomVehicleTF = TaskForce:list("Custom Parts")
        CustomVehicleAdvanced = CustomVehicleTF:toggle_loop("Custom Vehicle", {}, "", function()end)
        ShowMessages = CustomVehicleTF:toggle_loop("Show Messages", {}, "", function()end)
        EnableMusics = CustomVehicleTF:toggle_loop("Toggle Musics", {}, "", function()end)

        local Songs = {
            ["California Dreamin"] = "CaliforniaDreamin",
            ["Fortunate Son"] = "FortunateSon",
            ["Paint It Black"] = "PaintItBlack",
            ["Paranoid"] = "Paranoid",
        }
        
        local musicName = {}
        for name, _ in pairs(Songs) do
            table.insert(musicName, name)
        end

        table.sort(musicName, function(a, b) return a[1] < b[1] end)
        
        local selectedMusic = "California Dreamin"
        local songsName = Songs[selectedMusic]
        CustomVehicleTF:list_select("Music List", {}, "", musicName, 1, function(index)
            selectedMusic = musicName[index]
            songsName = Songs[selectedMusic]
        end)

        CustomVehicleTF:text_input("Send Message", {"aftaskforcemsg"}, "America has sent a friend request.", function(typeText)
            if typeText ~= "" then
                specialMsg = typeText
            else
                specialMsg = "US Air Force has sent a friend request."
            end
        end, specialMsg)

        local delaySpawning = 1
        CustomVehicleTF:text_input("Delay Time", {"aftimertf"}, "Do not abuse for spawning vehicle, do not go to lower for preventing for crash, mass entities.\n\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 0 then
                    delaySpawning = delay
                else
                    AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 0.")
                    delaySpawning = 1
                end
            else
                delaySpawning = 1
            end
        end, delaySpawning)

        local delayCountdown = 2
        CustomVehicleTF:text_input("Delay Countdown", {"aftimercountdown"}, "Countdown for messages.\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 1 then
                    delayCountdown = delay
                else
                    AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 1.")
                    delayCountdown = 2
                end
            else
                delayCountdown = 2
            end
        end, delayCountdown)

        CustomVehicleTF:divider("Sending Planes")
        -- Send Air Force (Task Force) - Surface
        CustomVehicleTF:action("Send Air Force (Task Force) - Custom Surface", {""}, "Sending America to war and intervene more custom planes (Real Undetectable).\nWARNING: The action is irreversible in the session bcz godmode permanent.\n\nSome peds can fall and attach you.", function()
            if menu.get_value(CustomVehicleAdvanced) ~= true then AerialFleetsNotify("I'm sorry, enable \"Custom Vehicle\" to use more advantages.") return end
            local player = PLAYER.PLAYER_PED_ID()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then AerialFleetsNotify("Sit down in a vehicle.") return end
            local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(playerVehicle)
            if vehicleClass ~= 19 then AerialFleetsNotify("To operate the action, you need to be in a military vehicle.") return end
            local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            local textInput = display_onscreen_keyboard()
            if textInput == "" or textInput == nil then return end
            local modelHash = util.joaat(textInput)
            if not (STREAMING.IS_MODEL_VALID(modelHash) and STREAMING.IS_MODEL_A_VEHICLE(modelHash)) then
                AerialFleetsNotify("I'm sorry, we cannot send the plane named: " .. textInput)
                return
            end
            local vehicleClass = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(modelHash)
            if vehicleClass ~= 15 and vehicleClass ~= 16 then
                AerialFleetsNotify("Invalid vehicle model: " .. textInput .. ". Only aerial vehicles planes or helicopters are allowed.")
                return
            end
            if menu.get_value(ShowMessages) == true then
                for i = delayCountdown, 1, -1 do
                    AerialFleetsNotify("Ready in "..i.." seconds.")
                    util.yield(1000)
                end
                chat.send_message(specialMsg, false, true, true)
            end
            if menu.get_value(EnableMusics) == true then
                FleetSongs(join_path(songs, songsName .. ".wav"), SND_FILENAME | SND_ASYNC)
                local randomMSG = randomMsgs[math.random(#randomMsgs)]
                AerialFleetsNotify(randomMSG)
            end
            for _, pid in pairs(playerList) do
                if AvailableSession() and not players.is_in_interior(pid) then
                    escort_attack(pid, textInput, true)
                    util.yield(delaySpawning * 1000)
                end
            end
        end)

        -- Send Air Force (Task Force) Custom
        CustomVehicleTF:action("Send Air Force (Task Force) - Custom Aerial", {""}, "Sending America to war and intervene more custom planes (Real Undetectable).\nWARNING: The action is irreversible in the session bcz godmode permanent.\n\nSome peds can fall and attach you.", function()
            if menu.get_value(CustomVehicleAdvanced) ~= true then AerialFleetsNotify("I'm sorry, enable \"Custom Vehicle\" to use more advantages.") return end
            local player = PLAYER.PLAYER_PED_ID()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then AerialFleetsNotify("Sit down in a vehicle.") return end
            if not (PED.IS_PED_IN_ANY_PLANE(player) or PED.IS_PED_IN_ANY_HELI(player)) then
                AerialFleetsNotify("To operate the action, you need to be in a plane to operate planes.")
                return
            end
            local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            local textInput = display_onscreen_keyboard()
            if textInput == "" or textInput == nil then return end
            local modelHash = util.joaat(textInput)
            if not (STREAMING.IS_MODEL_VALID(modelHash) and STREAMING.IS_MODEL_A_VEHICLE(modelHash)) then
                AerialFleetsNotify("I'm sorry, we cannot send the plane named: " .. textInput)
                return
            end
            local vehicleClass = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(modelHash)
            if vehicleClass ~= 15 and vehicleClass ~= 16 then
                AerialFleetsNotify("Invalid vehicle model: " .. textInput .. ". Only aerial vehicles planes are allowed.")
                return
            end
            if menu.get_value(ShowMessages) == true then
                for i = delayCountdown, 1, -1 do
                    AerialFleetsNotify("Ready in "..i.." seconds.")
                    util.yield(1000)
                end
                chat.send_message(specialMsg, false, true, true)
            end
            if menu.get_value(EnableMusics) == true then
                FleetSongs(join_path(songs, songsName .. ".wav"), SND_FILENAME | SND_ASYNC)
                local randomMSG = randomMsgs[math.random(#randomMsgs)]
                AerialFleetsNotify(randomMSG)
            end
            for _, pid in pairs(playerList) do
                if AvailableSession() and not players.is_in_interior(pid) then
                    escort_attack(pid, textInput, false)
                    util.yield(delaySpawning * 1000)
                end
            end
        end)

    ----========================================----
    ---           Task Force (Advanced)
    ---            Target part player
    ----========================================----

        TaskForce:divider("Target Players (Sending Planes)")
        local modelVehicle = "lazer"
        TaskForce:text_input("Model Vehicle", {"afmodelveh"}, "Choose specific model existing on GTAV or existing DLC Customs Aerial Vehicles. Recommended to use combat fighters planes", function(txtModel)
            if txtModel ~= "" then
                local modelHash = util.joaat(txtModel)
                if STREAMING.IS_MODEL_A_VEHICLE(modelHash) then
                    local vehicleClass = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(modelHash)
                    if vehicleClass == 15 or vehicleClass == 16 then
                        modelVehicle = txtModel
                    else
                        AerialFleetsNotify("Invalid vehicle model: " .. txtModel .. ". Only aerial vehicles (planes and helicopters) are allowed.")
                        modelVehicle = "lazer"
                    end
                else
                    AerialFleetsNotify("Invalid vehicle model: " .. txtModel)
                    modelVehicle = "lazer"
                end
            else
                modelVehicle = "lazer"
            end
        end, tostring(modelVehicle))

        ToggleRandom = TaskForce:toggle_loop("Random Player", {}, "Choose randomly players in the session and target automatically.", function()end)
        ToggleSurfaceTASK = TaskForce:toggle_loop("Toggle Surface Task Force", {}, "Send the air force to ground control.\n- It is more efficient to be on the ground to make surgical strikes with such perfect accuracy.\n- In the air, you will be very efficient and in groups unlike on the ground where the planes will hit different areas.", function()end)
        TaskForce:action("Target Player", {"aftarget"}, "We need more communication and more precise for informations.\nTarget player is the priority objective for your choice if the player is in the session.", function()
            local isSurfaceTask = menu.get_value(ToggleSurfaceTASK) == true
            local isRandomToggle = menu.get_value(ToggleRandom) == true
            local player = PLAYER.PLAYER_PED_ID()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then AerialFleetsNotify("To operate the action, you need to be in a vehicle.") return end
            local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(playerVehicle)
            if isSurfaceTask then if vehicleClass ~= 19 then AerialFleetsNotify("To operate the action, you need to be in a military vehicle.") return end
            else
                if not (PED.IS_PED_IN_ANY_PLANE(player) or PED.IS_PED_IN_ANY_HELI(player)) then
                    AerialFleetsNotify("To operate the action, you need to be in a plane or helicopter.")
                    return
                end
            end
            local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            if #playerList == 0 then AerialFleetsNotify("No players are currently in the session.") return end
            if isRandomToggle then
                local randomIndex = math.random(#playerList)
                local playerId = playerList[randomIndex]
                local playerName = players.get_name(playerId)
                if not AvailableSession() then
                    AerialFleetsNotify("Unable to target player due to session availability.")
                    return
                end
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerId)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                    if vehicleClass == 15 or vehicleClass == 16 then
                        menu.trigger_commands("vehkick"..players.get_name(playerId))
                        TASK.TASK_LEAVE_VEHICLE(playerId, vehicle, math.random(0, 1))
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                        TASK.TASK_LEAVE_ANY_VEHICLE(playerPed, 0, 0)
                    end
                end
                if not players.is_in_interior(playerId) then
                    escort_attack(playerId, modelVehicle, isSurfaceTask)
                    AerialFleetsNotify("Confirmed target player: "..playerName..".".."\nReady to target, roger that. Thanks for the information.")
                else
                    AerialFleetsNotify("I'm sorry, you cannot target "..playerName.." while staying on the base. But I have an idea to force. Let's US Army do something.")
                    for i = 1, 5 do
                        menu.trigger_commands("interiorkick"..playerName)
                    end
                end
            else
                local textInput = display_onscreen_keyboard()
                if textInput == nil or textInput == "" then
                    return
                end
                local isUserFound = false
                for _, pid in ipairs(playerList) do
                    local playerName = players.get_name(pid)
                    if playerName == textInput then
                        isUserFound = true
                        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                        local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                        if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                            if vehicleClass == 15 or vehicleClass == 16 then
                                menu.trigger_commands("vehkick"..players.get_name(pid))
                                TASK.TASK_LEAVE_VEHICLE(pid, vehicle, math.random(0, 1))
                                VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                                VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                                TASK.TASK_LEAVE_ANY_VEHICLE(playerPed, 0, 0)
                            end
                        end
                        if not players.is_in_interior(pid) then
                            AerialFleetsNotify("Confirmed target player: "..textInput..".".."\nReady to target, roger that. Thanks for the information.")
                            escort_attack(pid, modelVehicle, isSurfaceTask)
                            break
                        else
                            AerialFleetsNotify("I'm sorry, you cannot target "..textInput.." while staying on the base. But I have an idea to force. Let's US Army do something.")
                            for i = 1, 5 do
                                menu.trigger_commands("interiorkick"..textInput)
                            end
                        end
                    end
                end
                if not isUserFound then
                    AerialFleetsNotify("Error STATUS: The US Air Force cannot recognize the user named "..textInput)
                end
            end
        end)

    ----========================================----
    ---          Task Force (Presets)
    ---         Sending presets vehicle
    ----========================================----

        PresetSpawningTF:divider("Parameters for Presets Vehicles")
        local DLCs = PresetSpawningTF:list("DLCs Customs")
        local delaySpawningPresets = 1
        PresetSpawningTF:text_input("Delay Time", {"aftimertfpresets"}, "Do not abuse for spawning vehicle, do not go to lower for preventing for crash, mass entities.\n\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 0 then
                    delaySpawningPresets = delay
                else
                    AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 0.")
                    delaySpawningPresets = 1
                end
            else
                delaySpawningPresets = 1
            end
        end, delaySpawningPresets)

        local tableSpawners = {
            ["Lazer"] = "lazer",
            ["Molotok"] = "molotok",
            ["Rogue"] = "rogue",
            ["Pyro"] = "pyro",
            ["Nokota"] = "nokota",
            ["Starling"] = "starling",
            ["Seabreeze"] = "seabreeze",
            ["Strikeforce"] = "strikeforce",
        }

        local tempSpawners = {}
        for spawnerName, spawnerModel in pairs(tableSpawners) do
            table.insert(tempSpawners, {spawnerName, spawnerModel})
        end

        table.sort(tempSpawners, function(a, b)
            return a[1] < b[1]
        end)

        local msgPresets = "US Air Force has sent a friend request."
        PresetSpawningTF:text_input("Send Message", {"aftaskforcemsgpr"}, "America has sent a friend request.", function(typeText)
            if typeText ~= "" then
                msgPresets = typeText
            else
                msgPresets = "US Air Force has sent a friend request."
            end
        end, msgPresets)

        local delayCountdownTF = 3
        PresetSpawningTF:text_input("Delay Countdown", {"aftimerprcount"}, "Countdown for notification.\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 2 then
                    delayCountdownTF = delay
                else
                    AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 1.")
                    delayCountdownTF = 3
                end
            else
                delayCountdownTF = 3
            end
        end, delayCountdownTF)

        ShowingMSGS = PresetSpawningTF:toggle_loop("Show Messages", {}, "", function()end)

        local SongsPT = {
            ["California Dreamin"] = "CaliforniaDreamin",
            ["Fortunate Son"] = "FortunateSon",
            ["Paint It Black"] = "PaintItBlack",
            ["Paranoid"] = "Paranoid",
        }
        
        local musicNamePRT = {}
        for name, _ in pairs(SongsPT) do
            table.insert(musicNamePRT, name)
        end

        table.sort(musicNamePRT, function(a, b) return a[1] < b[1] end)
        
        local selectedMusicPT = "California Dreamin"
        local songsNamePT = SongsPT[selectedMusicPT]
        PresetSpawningTF:list_select("Music List", {}, "", musicNamePRT, 1, function(index)
            selectedMusicPT = musicNamePRT[index]
            songsNamePT = SongsPT[selectedMusicPT]
        end)

        EnableMusicsTF = PresetSpawningTF:toggle_loop("Toggle Musics", {}, "", function()end)
        CustomPresets = PresetSpawningTF:toggle_loop("Toggle Preset Vehicle", {}, "", function()end)
        ToggleSurfaceTF = PresetSpawningTF:toggle_loop("Toggle Surface Task Force", {}, "Send the air force to ground control.\n- It is more efficient to be on the ground to make surgical strikes with such perfect accuracy.\n- In the air, you will be very efficient and in groups unlike on the ground where the planes will hit different areas.", function()end)
        PresetSpawningTF:divider("Presets Vehicles")
        for _, spawner in ipairs(tempSpawners) do
            local spawnerName = spawner[1]
            local spawnerModel = spawner[2]
            PresetSpawningTF:action("Spawn " .. spawnerName, {"aftask"..spawnerModel}, "", function()
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                local isSurfaceTF = menu.get_value(ToggleSurfaceTF) == true
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(playerVehicle)
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                local showingMsgs = menu.get_value(ShowingMSGS) == true
                if menu.get_value(CustomPresets) == true then
                    if isSurfaceTF then
                        if vehicleClass ~= 19 then
                            AerialFleetsNotify("To operate the action, you need to be in a military vehicle.")
                            return
                        end
                    elseif not PED.IS_PED_IN_ANY_PLANE(player) then
                        AerialFleetsNotify("To operate the action, you need to be in a plane.")
                        return
                    end
                else
                    AerialFleetsNotify("Please enable \"Toggle Preset Vehicle\" to work for "..spawnerName)
                    return
                end
                if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    AerialFleetsNotify("Please sit down in a vehicle.")
                    return
                end
                if showingMsgs then
                    local countdown = isSurfaceTF and delayCountdownTF or delayCountdownTF
                    for i = countdown, 1, -1 do
                        AerialFleetsNotify("Ready in "..i.." seconds.")
                        util.yield(1000)
                    end
                    chat.send_message(msgPresets, false, true, true)
                end                            
                if menu.get_value(EnableMusicsTF) == true then
                    FleetSongs(join_path(songs, songsNamePT .. ".wav"), SND_FILENAME | SND_ASYNC)
                    local randomMSG = randomMsgs[math.random(#randomMsgs)]
                    AerialFleetsNotify(randomMSG)
                end
                for _, pid in pairs(playerList) do
                    if AvailableSession() then
                        if not players.is_in_interior(pid) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            escort_attack(pid, spawnerModel, isSurfaceTF)
                            util.yield(delaySpawningPresets * 1000)
                        end
                    end
                end
            end)
        end

        PresetSpawningTF:divider("Helicopters")

        local heliTables = {
            ["FH-1 Hunter"] = "hunter",
            ["Savage"] = "savage",
            ["Buzzard Attack Chopper"] = "buzzard",
            ["RF-1 Akula"] = "akula"
        }
        
        local heliSpawner = {}
        for heliTypeSpawn, spawnerModelH in pairs(heliTables) do
            table.insert(heliSpawner, {heliTypeSpawn, spawnerModelH})
        end
        
        table.sort(heliSpawner, function(a, b)
            return a[1] < b[1]
        end)
        
        for _, spawner in ipairs(heliSpawner) do
            local spawnerName = spawner[1]
            local spawnerModel = spawner[2]
            PresetSpawningTF:action("Spawn " .. spawnerName, {"aftask" .. spawnerModel}, "", function()
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                local isSurfaceTF = menu.get_value(ToggleSurfaceTF) == true
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(playerVehicle)
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                local showingMsgs = menu.get_value(ShowingMSGS) == true
                if menu.get_value(CustomPresets) == true then
                    if isSurfaceTF then
                        if vehicleClass ~= 19 then
                            AerialFleetsNotify("To operate the action, you need to be in a military vehicle.")
                            return
                        end
                    elseif not PED.IS_PED_IN_ANY_PLANE(player) then
                        AerialFleetsNotify("To operate the action, you need to be in a plane.")
                        return
                    end
                else
                    AerialFleetsNotify("Please enable \"Toggle Preset Vehicle\" to work for " .. spawnerName)
                    return
                end
                if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    AerialFleetsNotify("Please sit down in a vehicle.")
                    return
                end
                if showingMsgs then
                    local countdown = isSurfaceTF and delayCountdownTF or delayCountdownTF
                    for i = countdown, 1, -1 do
                        AerialFleetsNotify("Ready in " .. i .. " seconds.")
                        util.yield(1000)
                    end
                    chat.send_message(msgPresets, false, true, true)
                end
                if menu.get_value(EnableMusicsTF) == true then
                    FleetSongs(join_path(songs, songsNamePT .. ".wav"), SND_FILENAME | SND_ASYNC)
                    local randomMSG = randomMsgs[math.random(#randomMsgs)]
                    AerialFleetsNotify(randomMSG)
                end
                for _, pid in pairs(playerList) do
                    if AvailableSession() then
                        if not players.is_in_interior(pid) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            escort_attack(pid, spawnerModel, isSurfaceTF)
                            util.yield(delaySpawningPresets * 1000)
                        end
                    end
                end
            end)
        end

    ----========================================----
    ---        Task Force (DLCs Presets)
    ---         Sending presets vehicle
    ----========================================----

        DLCs:divider("Parameters")
        if menu.get_edition() >= 2 then
            EnableDLCS = DLCs:toggle_loop("Custom Vehicles", {}, "", function()end)
        end
        ShowingMSGDLC = DLCs:toggle_loop("Show Messages", {}, "", function()end)
        local DLCSongs = {
            ["California Dreamin"] = "CaliforniaDreamin",
            ["Fortunate Son"] = "FortunateSon",
            ["Paint It Black"] = "PaintItBlack",
            ["Paranoid"] = "Paranoid",
        }
        
        local DLCNameMusics = {}
        for name, _ in pairs(DLCSongs) do
            table.insert(DLCNameMusics, name)
        end

        table.sort(DLCNameMusics, function(a, b) return a[1] < b[1] end)
        
        local selectedMusicDLCS = "California Dreamin"
        local DLCSongsName = DLCSongs[selectedMusicDLCS]
        DLCs:list_select("Music List", {}, "", DLCNameMusics, 1, function(index)
            selectedMusicPT = DLCNameMusics[index]
            DLCSongsName = DLCSongs[selectedMusicDLCS]
        end)
        EnableMusicsDLC = DLCs:toggle_loop("Toggle Musics", {}, "", function()end)
        local delaySpawningDLC = 1
        DLCs:text_input("Delay Time", {"aftimertfdlc"}, "Do not abuse for spawning vehicle, do not go to lower for preventing for crash, mass entities.\n\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 0 then
                    delaySpawningDLC = delay
                else
                    AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 0.")
                    delaySpawningDLC = 1
                end
            else
                delaySpawningDLC = 1
            end
        end, delaySpawningDLC)

        DLCs:hyperlink("Download Required files", "https://bit.ly/3OmUGGF", "Do not use presets vehicles while not downloading required files.\nTo know how to drag: Stand/Custom DLCs and load.")
        local dlcMsgs = "US Air Force has sent a friend request."
        DLCs:text_input("Send Message", {"aftaskforcemsgdlc"}, "America has sent a friend request.", function(typeText)
            if typeText ~= "" then
                dlcMsgs = typeText
            else
                dlcMsgs = "US Air Force has sent a friend request."
            end
        end, dlcMsgs)

        local delayCountdownDLC = 2
        DLCs:text_input("Delay Countdown", {"aftimerprcountdlc"}, "Countdown for notification.\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 1 then
                    delayCountdownDLC = delay
                else
                    AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 1.")
                    delayCountdownDLC = 2
                end
            else
                delayCountdownDLC = 2
            end
        end, delayCountdownDLC)

        DLCs:divider("Preset DLCs Vehicles")
        local tableSpawnersDLC = {
            ["Boeing F-15C Eagle"] = "f15c2",
            ["Boeing F-15 Silent Eagle"] = "f15s",
            ["Lockheed Martin F-16C Fighting Falcon"] = "f16c",
            ["Lockheed Martin F-22A Raptor"] = "f22a",
            ["Lockheed Martin F-35C Lightning II"] = "f35c",
        }

        local tempSpawnersDLC = {}
        for dlcSpawners, spawnerModel in pairs(tableSpawnersDLC) do
            table.insert(tempSpawnersDLC, {dlcSpawners, spawnerModel})
        end

        table.sort(tempSpawnersDLC, function(a, b)
            return a[1] < b[1]
        end)

        for _, spawner in ipairs(tempSpawnersDLC) do
            local spawnerName = spawner[1]
            local spawnerModel = spawner[2]
            DLCs:action(spawnerName, {"afdlc"..spawnerModel}, "", function()
                if menu.get_value(EnableDLCS) ~= true then
                    AerialFleetsNotify("I'm sorry, please enable \"Custom Vehicles\" to make work DLCs Customs.")
                    return
                end
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                local isSurfaceDLC = not PED.IS_PED_IN_ANY_PLANE(player)
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                local modelHash = util.joaat(spawnerModel)
                local showingMsgs = menu.get_value(ShowingMSGDLC) == true
                if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    AerialFleetsNotify("Sit down in a vehicle.")
                    return
                end
                if isSurfaceDLC then
                    AerialFleetsNotify("To operate the action, you need to be in a plane to operate planes.")
                    return
                end
                if not STREAMING.IS_MODEL_VALID(modelHash) then
                    AerialFleetsNotify("Make sure you need to load the model: "..spawnerName)
                    return
                end
                if not STREAMING.IS_MODEL_A_VEHICLE(modelHash) then
                    AerialFleetsNotify("I'm sorry, we cannot send the plane named: "..spawnerName)
                    return
                end
                if showingMsgs then
                    for i = delayCountdownDLC, 1, -1 do
                        AerialFleetsNotify("Ready in "..i.." seconds.")
                        util.yield(1000)
                    end
                    chat.send_message(dlcMsgs, false, true, true) 
                end
                if menu.get_value(EnableMusicsDLC) == true then
                    FleetSongs(join_path(songs, DLCSongsName .. ".wav"), SND_FILENAME | SND_ASYNC)
                    local randomMSG = randomMsgs[math.random(#randomMsgs)]
                    AerialFleetsNotify(randomMSG)
                end
                AerialFleetsNotify("Confirmed target. The US Air Force is coming soon. Sending tons of "..spawnerName..".".."\nReady to target, roger that. Thanks for the information.")
                for _, pid in pairs(playerList) do
                    if AvailableSession() and not players.is_in_interior(pid) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        escort_attack(pid, spawnerModel, false)
                        util.yield(delaySpawningDLC * 1000)
                    end
                end
            end)
        end

    ----========================================----
    ---             Detection Vehicles
    ---         Let them put on the ground
    ----========================================----

        Detections:divider("Detection Parts")
        Detections:action("Plane System Detection", {"afplanedetection"}, "Detect any players while using planes  who might be a suspect.", function()
            local players_detected = 0
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_IN_ANY_PLANE(playerPed) then
                    players_detected = players_detected + 1
                end
            end
            if players_detected > 0 then
                local message = tostring(players_detected) .. " player"
                if players_detected > 1 then
                    message = message .. "s"
                end
                message = message .. " has been detected using planes.\nRadar Status: Ready."
                AWACSNotify(message)
            else
                AWACSNotify("No one is using a plane.\nTrying to verify.\nPlease wait for complete detection.")
            end
        end)

        Detections:action("Helicopter System Detection", {"afhelidetection"}, "Detect any players while using choppers who might be a suspect.", function()
            local players_detected = 0
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_IN_ANY_HELI(playerPed) then
                    players_detected = players_detected + 1
                end
            end
            if players_detected > 0 then
                local message = tostring(players_detected) .. " player"
                if players_detected > 1 then
                    message = message .. "s"
                end
                message = message .. " has been detected using helicopters.\nRadar Status: Ready."
                AWACSNotify(message)
            else
                AWACSNotify("No one is using a helicopter.\nTrying to verify. \nPlease wait for complete detection.")
            end
        end)

        Detections:divider("Removal Parts")
        Detections:toggle_loop("Remove All Planes", {}, "Let me do with the US Air Force to put them on the ground, all will be put on the ground well slept.\n\nWarning: you can be might karma.", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                    if vehicleClass == 16 then
                        menu.trigger_commands("vehkick"..players.get_name(pid))
                        TASK.TASK_LEAVE_VEHICLE(pid, vehicle, math.random(0, 1))
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                        TASK.TASK_LEAVE_ANY_VEHICLE(playerPed, 0, 0)
                        TASK.TASK_EVERYONE_LEAVE_VEHICLE(vehicle)
                    end
                end
            end
        end)

        Detections:toggle_loop("Remove All Helicopters", {}, "Let me do with the US Air Force to put them on the ground, all will be put on the ground well slept.\n\nWarning: you can be might karma.", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                    if vehicleClass == 15 then
                        menu.trigger_commands("vehkick"..players.get_name(pid))
                        TASK.TASK_LEAVE_VEHICLE(pid, vehicle, math.random(0, 1))
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                        TASK.TASK_LEAVE_ANY_VEHICLE(playerPed, 0, 0)
                        TASK.TASK_EVERYONE_LEAVE_VEHICLE(vehicle)
                    end
                end
            end
        end)

        Detections:toggle_loop("Remove All Vehicles", {}, "Let me do with the US Army and the America to put them on the ground, all will be put on the ground well slept.\n\nWarning: you can be might karma.\nDangerous part and more aggressive.", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                    for class = 0, 21 do
                        if vehicleClass == class then
                            menu.trigger_commands("vehkick"..players.get_name(pid))
                            TASK.TASK_LEAVE_VEHICLE(playerPed, vehicle, math.random(0, 1))
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                            TASK.TASK_LEAVE_ANY_VEHICLE(playerPed, 0, 0)
                            TASK.TASK_EVERYONE_LEAVE_VEHICLE(vehicle)
                        end
                    end
                end
            end
        end)

        Detections:toggle_loop("Lock All Vehicles", {}, "Let me do with the US Army and the America to lock them and never exit.\n\nDangerous part and more aggressive.", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                    for class = 0, 21 do
                        if vehicleClass == class then
                            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                        end
                    end
                end
            end
        end, function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then
                    for class = 0, 21 do
                        if vehicleClass == class then
                            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 0)
                        end
                    end
                end
            end
        end)

    ----========================================----
    ---               Weather Parts
    ---         Better visuals to launch
    ----========================================----

        WeatherParts:toggle_loop("Better Visuals", {"afvisuals"}, "*works locally*", function()
            MISC.UNLOAD_ALL_CLOUD_HATS()
            menu.trigger_commands("weather extrasunny")
        end, function()
            menu.trigger_commands("weather normal")
            menu.trigger_commands("clouds normal")
        end)

        WeatherParts:action("Remove Clouds", {}, "", function() MISC.UNLOAD_ALL_CLOUD_HATS()end)

        clear_day = WeatherParts:toggle("Clear Day", {}, "", function(on)
            util.yield()
            if on then
                if menu.get_value(clear_night) then
                    menu.set_value(clear_night, false)
                end
                menu.trigger_commands("locktime on")
                menu.trigger_commands("timesmoothing off")
                menu.trigger_commands("time "..math.random(10, 15))
                menu.trigger_commands("clouds horizon")
            elseif not menu.get_value(clear_night) then
                ResetRendering()
                menu.trigger_commands("clouds normal")
            end
        end)

        clear_night = WeatherParts:toggle("Clear Night", {}, "", function(on)
            util.yield()
            if on then
                if menu.get_value(clear_day) then
                    menu.set_value(clear_day, false)
                end
                menu.trigger_commands("locktime on")
                menu.trigger_commands("timesmoothing off")
                menu.trigger_commands("time " .. math.random(1, 3))
                menu.trigger_commands("clouds horizon")
            elseif not menu.get_value(clear_day) then
                ResetRendering()
                menu.trigger_commands("clouds normal")
            end
        end)

    ---========================================----
    ---      Settings Parts of Aerial Fleets
    ---      The part to set up aerial fleets
    ----========================================----

        Settings:readonly("Stand Version", STAND_VERSION)
        Settings:readonly("Script Version", SCRIPT_VERSION)

        NotifMode = "Stand"
        Settings:list_select("Notify Mode", {}, "", {"Stand", "Help Message"}, 1, function(selected_mode)
            NotifMode = selected_mode
        end)

        ToggleNotify = true
        Settings:toggle("Toggle Notify", {}, "", function(toggled)
            util.yield()
            ToggleNotify = toggled
        end, true)

        local MenuSettings = Settings:list("Lua Settings")
        Settings:divider("Github & Updates")
        Settings:hyperlink("GitHub Page", "https://github.com/StealthyAD/AerialFleets", "Visit the page to know about Aerial Fleets v"..SCRIPT_VERSION)
        Settings:action("Check for Updates", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        auto_update_config.check_interval = 0
            if auto_updater.run_auto_update(auto_update_config) then
                AerialFleetsNotify("No updates found.")
            end
        end)
        
        Settings:action("Clean Reinstall", {}, "Force an update to the latest version, regardless of current version.", function()
            auto_update_config.clean_reinstall = true
            auto_updater.run_auto_update(auto_update_config)
        end)

    ---========================================----
    ---      Settings Parts of Aerial Fleets
    ---      (part Lua Settings, image, etc)
    ----========================================----

        MenuSettings:toggle("Toggle Transition Logo while starting", {}, "Toggle (Enable/Disable) image while starting Lua Script AerialFleets.", function(templateBool)
            local fp = io.open(script_resources .. '/DisplayLogo.txt', 'w')
            fp:write(not templateBool and 'True' or 'False')
            fp:close()
        end, io.open(script_resources .. '/DisplayLogo.txt', 'r'):read('*all') == 'True')

        MenuSettings:toggle("Toggle Message while starting", {}, "Toggle (Enable/Disable) message while starting Lua Script AerialFleets.", function(templateBool)
            local filepath = io.open(script_resources .. '/DisplayMessages.txt', 'w')
            filepath:write(not templateBool and 'True' or 'False')
            filepath:close()
        end, io.open(script_resources .. '/DisplayMessages.txt', 'r'):read('*all') == 'True')

    ---========================================----
    ---      Players Parts (Aerial Fleets)
    ---========================================----

        players.on_join(function(pid)
            local AerialFleetsR = menu.player_root(pid)
            AerialFleetsR:divider(AerialFleetMSG)
            local AerialName = players.get_name(pid)

            AerialSpec = {}
            toggleSpec = AerialFleetsR:toggle("Spectate", {"aerialspec"}, "", function(on)
                if on then
                    if pid == players.user() then
                        AerialFleetsNotify("You cannot spectate yourself.")
                        menu.set_value(toggleSpec, false)
                    end
                    if #AerialSpec ~= 0 then
                        menu.trigger_commands("interspec"..AerialSpec[1].." off")
                    end
                    table.insert(AerialSpec, AerialName)
                    if AerialName == players.get_name(players.user()) then
                        return
                    else
                        AerialFleetsNotify("You are currently spectating "..AerialName)
                    end
                    menu.trigger_commands("spectate"..AerialName.." on")
                else
                    if players.exists(pid) then
                        if AerialName == players.get_name(players.user()) then
                            return
                        else
                            AerialFleetsNotify("You are stopping spectating "..AerialName)
                        end
                        menu.trigger_commands("spectate"..AerialName.." off")
                    end
                    table.remove(AerialSpec, 1)
                end
            end)

            AerialFleetsR:action_slider("Kick Tools", {}, "Different types of Kick users:\n- AIO (All-in-One) - Faster kick\n- Blast\n- Boop\n- Array", {
                "AIO (All-in-One)",
                "Blast",
                "Boop",
                "Array"
            }, function(kickType)
                if kickType == 1 then
                    local cmd = {"breakup", "kick", "confusionkick", "aids", "orgasmkick","nonhostkick", "pickupkick"}
                    for _, command in pairs(cmd) do
                        menu.trigger_commands(command..AerialName)
                    end
                    AerialFleetsNotify(AerialName.." has been forced breakup.")
                elseif kickType == 2 then
                    menu.trigger_commands("historyblock " .. AerialName)
                    menu.trigger_commands("breakup" .. AerialName)
                elseif kickType == 3 then
                    menu.trigger_commands("breakup" .. AerialName)
                    menu.trigger_commands("givesh" .. AerialName)
                    util.trigger_script_event(1 << pid, {697566862, pid, 0x4, -1, 1, 1, 1}) --697566862 Give Collectible
                    util.trigger_script_event(1 << pid, {1268038438, pid, memory.script_global(2657589 + 1 + (pid * 466) + 321 + 8)}) 
                    util.trigger_script_event(1 << pid, {915462795, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE))})
                    util.trigger_script_event(1 << pid, {697566862, pid, 0x4, -1, 1, 1, 1})
                    util.trigger_script_event(1 << pid, {1268038438, pid, memory.script_global(2657589 + 1 + (pid * 466) + 321 + 8)})
                    util.trigger_script_event(1 << pid, {915462795, players.user(), memory.read_int(memory.script_global(1894573 + 1 + (pid * 608) + 510))})
                else
                    local int_min = -2147483647
                    local int_max = 2147483647
                    for i = 1, 15 do
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1, math.random(int_min, int_max), math.random(int_min, int_max), 
                        math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
                        math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1})
                    end
                    menu.trigger_commands("givesh" .. AerialName)
                    util.yield()
                    for i = 1, 15 do
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1, pid, math.random(int_min, int_max)})
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1})
                    end
                end
            end)

            local PartsPlayer = AerialFleetsR:list("Aerial Force")
            local TaskForceP = AerialFleetsR:list("Task Force", {}, TaskForceDesc)
            
        ---========================================----
        ---      Players Parts (Aerial Fleets)
        ---        Sending in the sky planes
        ---========================================----

            PartsPlayer:divider("Aerial Defense (US Air Force)")
            PlaneCountP = PartsPlayer:slider("Number of Generation of Planes", {"afplanes"}, "For purposes: limit atleast 5 planes if you are in Public session with 30 players.".."\n\nFor recommendation:".."\n".."- Lazer: 3 or 5 more.", 1, 25, 1, 1, function()end)
            local delaySpawningPlayer = 1
            PartsPlayer:text_input("Delay Time", {"aftimerp"}, "Do not abuse for spawning vehicle, do not go to lower for preventing for crash, mass entities.\n\nMeasured in seconds.", function(typeText)
                if typeText ~= "" then
                    local delay = tonumber(typeText)
                    if delay and delay > 0 then
                        delaySpawningPlayer = delay
                    else
                        AerialFleetsNotify("Invalid delay value. Please enter a positive number greater than 0.")
                        delaySpawningPlayer = 1
                    end
                else
                    delaySpawningPlayer = 1
                end
            end, delaySpawningPlayer)

            local planeModelsP = {
                ["Lazer"] = "lazer",
                ["V-65 Molotok"] = "molotok",
                ["Western Rogue"] = "rogue",
                ["Pyro"] = "pyro",
                ["P-45 Nokota"] = "nokota",
            }
            
            local planeModelNames = {}
            for name, _ in pairs(planeModelsP) do
                table.insert(planeModelNames, name)
            end
    
            table.sort(planeModelNames, function(a, b) return a[1] < b[1] end)
            
            local selectedPlaneModel = "Lazer"
            local planesHashP = planeModelsP[selectedPlaneModel]
            PartsPlayer:list_select("Types of Planes", {}, "The entities that will add while sending air force planes.", planeModelNames, 1, function(index)
                selectedPlaneModel = planeModelNames[index]
                planesHashP = planeModelsP[selectedPlaneModel]
            end)
    
            PartsPlayer:action("Send Air Force", {"afusaft"}, "Sending America to war and intervene more planes.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features.", function()
                if AvailableSession() then
                    for _ = 1, menu.get_value(PlaneCountP) do
                        harass_vehicle(pid, planesHashP, true)
                        util.yield(delaySpawningPlayer * 1000)
                    end
                end
            end)

        ---========================================----
        ---        Players Parts (Task Force)
        ---          Escort jet and fire
        ---========================================----

            local modelVehicleP = "lazer"
            TaskForceP:text_input("Model Vehicle", {"aerialveh"}, "Choose specific model existing on GTAV. Recommended to use combat fighters planes", function(txtModel)
                if txtModel ~= "" then
                    local modelHash = util.joaat(txtModel)
                    if STREAMING.IS_MODEL_A_VEHICLE(modelHash) then
                        local vehicleClass = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(modelHash)
                        if vehicleClass == 15 or vehicleClass == 16 then
                            modelVehicleP = txtModel
                        else
                            AerialFleetsNotify("Invalid vehicle model: " .. txtModel .. ". Only aerial vehicles (planes and helicopters) are allowed.")
                            modelVehicleP = "lazer"
                        end
                    else
                        AerialFleetsNotify("Invalid vehicle model: " .. txtModel)
                        modelVehicleP = "lazer"
                    end
                else
                    modelVehicleP = "lazer"
                end
            end, tostring(modelVehicleP))

            TaskForceP:action("Target Player (Task Force)", {"aerialtf"}, "", function()
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if not PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then AerialFleetsNotify("Sit down in a vehicle.") return end
                if not (PED.IS_PED_IN_ANY_HELI(player) or PED.IS_PED_IN_ANY_PLANE(player)) then AerialFleetsNotify("To operate the action, you need to be in a plane/helis to operate vehicles.") return end
                if pid == players.user() then AerialFleetsNotify("You cannot target yourself.") return end
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local vehicleClass = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                if not PED.IS_PED_IN_VEHICLE(playerPed, vehicle, false) then return end
                if vehicleClass == 15 or vehicleClass == 16 then
                    menu.trigger_commands("vehkick"..players.get_name(pid))
                    TASK.TASK_LEAVE_VEHICLE(pid, vehicle, math.random(0, 1))
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerPed, 4)
                    TASK.TASK_LEAVE_ANY_VEHICLE(playerPed, 0, 0)
                end
                util.yield(1000)
                if not players.is_in_interior(pid) then
                    AerialFleetsNotify("Confirmed target player: "..AerialName..".".."\nReady to target, roger that. Thanks for the information.")
                    escort_attack(pid, modelVehicleP, false)
                else
                    AerialFleetsNotify("I'm sorry, you cannot target "..AerialName.." while sitting on the base. But I have an idea to force. Let's US Army do something.")
                    for i = 1, 5 do
                        menu.trigger_commands("interiorkick"..AerialName)
                    end
                end
            end)
        end)

        players.dispatch_on_join()
        players.on_leave(function()end)

    ----========================================----
    ---            End Part of Script
    ---       The part of useful lua script
    ----========================================----

        util.on_stop(function()
            FleetSongs(join_path(script_resources, "stops.wav"), SND_FILENAME | SND_ASYNC)
        end)

        if SCRIPT_MANUAL_START and not SCRIPT_SILENT_START then
            local InterLogo = directx.create_texture(script_resources .. "/AerialFleets.png")

            local transitionStarting = script_resources .. "/DisplayLogo.txt"
            local msgStarting = script_resources .. "/DisplayMessages.txt"
            -- Check if the file exists and read its content (True or False) -- Transition Image
            local filepath = io.open(transitionStarting, 'r')
            local transitionLogoStarted = filepath and (filepath:read('*all') == 'True')
            filepath:close()

            -- Check if the file exists and read its content (True or False) -- Toggle Message
            local filepathMsg = io.open(msgStarting, 'r')
            local msgStarted = filepathMsg and (filepathMsg:read('*all') == 'True')
            filepathMsg:close()

            if msgStarted ~= false then 
                AerialFleetsNotify("Welcome "..SOCIALCLUB.SC_ACCOUNT_INFO_GET_NICKNAME().." to Aerial Fleets.\nCompatible with Stand v"..STAND_VERSION..".")
            end

            local alpha = 0
            local alpha_incr = 0.005
            if transitionLogoStarted ~= false then
                logo_alpha_thread = util.create_thread(function()
                    while true do
                        alpha = alpha + alpha_incr
                        if alpha > 1 then
                            alpha = 1
                        elseif alpha < 0 then 
                            alpha = 0
                            util.stop_thread()
                        end
                        util.yield()
                    end
                end)
                
                logo_thread = util.create_thread(function()
                    local start_time = os.clock()
                    while true do
                        directx.draw_texture(InterLogo, 0.08, 0.08, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, alpha)
                        local time_passed = os.clock() - start_time
                        if time_passed > 3 then
                            alpha_incr = -0.01
                        end
                        if alpha == 0 then
                            util.stop_thread()
                        end
                        util.yield()
                    end
                end)
            end
        end

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
