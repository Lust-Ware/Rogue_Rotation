local my_utility = require("my_utility/my_utility")

local menu_elements_flurry_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "flurry_main_bool_base")),
    use_combo_points    = checkbox:new(false, get_hash(my_utility.plugin_label .. "flurry_use_combo_points")),
    combo_points_slider = slider_int:new(0, 3, 0, get_hash(my_utility.plugin_label .. "flurry_min_combo_points")),
}

local function menu()
    
    if menu_elements_flurry_base.tree_tab:push("Flurry")then
        menu_elements_flurry_base.main_boolean:render("Enable Spell", "")
        menu_elements_flurry_base.use_combo_points:render("Use Combo Points", "")
        if menu_elements_flurry_base.use_combo_points:get() then
            menu_elements_flurry_base.combo_points_slider:render("Min Combo Points", "")
        end
 
        menu_elements_flurry_base.tree_tab:pop()
    end
end

local spell_id_flurry = 358339;

local spell_data_puncture = spell_data:new(
    2.0,                        -- radius
    0.3,                        -- range
    0.4,                        -- cast_delay
    0.4,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_flurry,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_flurry_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_flurry);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    if menu_elements_flurry_base.use_combo_points:get() then
        local combo_points = player_local:get_rogue_combo_points()
        local min_combo_points = menu_elements_flurry_base.combo_points_slider:get()
        if combo_points < min_combo_points then
            return false
        end
    end

    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.target(target, spell_data_puncture, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;

        console.print("Rouge, Casted Flurry");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}