local my_utility = require("my_utility/my_utility")

local menu_elements_caltrop =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "caltrop_base_main_bool")),
    spell_range   = slider_float:new(1.0, 15.0, 2.60, get_hash(my_utility.plugin_label .. "caltrop_spell_range_2")),
    only_elite_or_boss = checkbox:new(true, get_hash(my_utility.plugin_label .. "caltrop_emb_only_elite_or_boss_boolean")),
}

local function menu()
    if menu_elements_caltrop.tree_tab:push("Caltrop")then
        menu_elements_caltrop.main_boolean:render("Enable Spell", "")
        menu_elements_caltrop.spell_range:render("Spell Range", "", 1)
        menu_elements_caltrop.only_elite_or_boss:render("Only Elite or Boss", "")
        menu_elements_caltrop.tree_tab:pop()
    end
end

local spell_id_caltrop = 389667;

local pois_trap = require("spells/poison_trap")

local caltrop_spell_data = spell_data:new(
    3.0,                        -- radius
    1.0,                       -- range
    0.5,                        -- cast_delay
    1.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_caltrop,              -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)

local debug_console = false
local next_time_allowed_cast = 0.0;

local function will_cast(target)
    local menu_boolean = menu_elements_caltrop.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean,
        next_time_allowed_cast,
        spell_id_caltrop
    )
    if not is_logic_allowed then
        return false
    end
    if menu_elements_caltrop.only_elite_or_boss:get() then
        local special_found = false
    
        local enemies = target_selector.get_near_target_list(get_player_position(), 12)
        for _, enemy in pairs(enemies) do
            local is_special = enemy:is_champion() or enemy:is_elite() or enemy:is_boss()
            if is_special then
                special_found = true
                break
            end
        end
    
        if not special_found then
            return false
        end
    end
    return true
end

local function is_valid_logics(entity_list, target_selector_data, target)
    if not will_cast(target) then
        return nil
    end

    local poison_trap_id = 416528;
    if utility.is_spell_ready(poison_trap_id) then
        local pos = pois_trap.is_valid_logics(entity_list, target_selector_data, target)
        if pos then
             return nil
        end
    end

    local spell_range = menu_elements_caltrop.spell_range:get()
    local target_position = target:get_position()
    local player_position = get_player_position()
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) then
        if debug_console then
            console.print("caltrop leaving 2222")
        end
        return nil
    end

    return target_position
end

local function logics(entity_list, target_selector_data, target)
    local cast_position = is_valid_logics(entity_list, target_selector_data, target)
    if not cast_position then
        return false
    end

    if cast_spell.position(spell_id_caltrop, cast_position, caltrop_spell_data.cast_delay) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 6.0;
        console.print("Casted Caltrop");
        return true;
    end

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}