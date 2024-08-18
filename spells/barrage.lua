local my_utility = require("my_utility/my_utility")

local menu_elements_barrage_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "barrage_base_main_bool")),
    use_combo_points    = checkbox:new(false, get_hash(my_utility.plugin_label .. "barrage_use_combo_points")),
    combo_points_slider = slider_int:new(0, 3, 0, get_hash(my_utility.plugin_label .. "barrage__min_combo_points")),
    cast_delay_slider   = slider_float:new(0.0, 1.0, 0.05, get_hash(my_utility.plugin_label .. "barrage_cast_delay")),
    activate_filter     = checkbox:new(true, get_hash(my_utility.plugin_label .. "_activate_filter_base")),
    close_distance      = checkbox:new(false, get_hash(my_utility.plugin_label .. "_close_distance_base")),
    range_slider        = slider_int:new(1, 9, 9, get_hash(my_utility.plugin_label .. "_barrage_range_slider")),
}

local function menu()
    if menu_elements_barrage_base.tree_tab:push("Barrage") then
        menu_elements_barrage_base.main_boolean:render("Enable Spell", "")
        if menu_elements_barrage_base.main_boolean:get() then
            menu_elements_barrage_base.use_combo_points:render("Use Combo Points", "")
            if menu_elements_barrage_base.use_combo_points:get() then
                menu_elements_barrage_base.combo_points_slider:render("Min Combo Points", "")
            end
            menu_elements_barrage_base.cast_delay_slider:render("Cast Delay", "Set the delay between casts (in seconds)", 2)
            menu_elements_barrage_base.activate_filter:render("Activate Distance Check", "Enable distance check")
            if menu_elements_barrage_base.activate_filter:get() then
                menu_elements_barrage_base.close_distance:render("Close Distance to Target", "Move closer if out of range")
                menu_elements_barrage_base.range_slider:render("Spell Range", "Set the range for Barrage")
            end
        end
        menu_elements_barrage_base.tree_tab:pop()
    end
end

local spell_id_barrage = 439762;

local spell_data_barrage = spell_data:new(
    3.0,                        -- radius
    9.0,                        -- range
    1.5,                        -- cast_delay
    3.0,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_barrage,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local next_time_allowed_cast = 0.0;

local function logics(target)
    local menu_boolean = menu_elements_barrage_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_barrage);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();

    if menu_elements_barrage_base.use_combo_points:get() then
        local combo_points = player_local:get_rogue_combo_points()
        local min_combo_points = menu_elements_barrage_base.combo_points_slider:get()
        if combo_points < min_combo_points then
            return false
        end
    end
    
    local player_position = get_player_position();
    local target_position = target:get_position();
    local distance_sqr = target_position:squared_dist_to_ignore_z(player_position)

    local spell_range = menu_elements_barrage_base.range_slider:get()
    local is_filter_enabled = menu_elements_barrage_base.activate_filter:get();  
    if is_filter_enabled then
        if distance_sqr > (spell_range * spell_range) then
            if menu_elements_barrage_base.close_distance:get() then
                pathfinder.request_move(target_position)
                console.print("Moving closer to target for Barrage")
                return true
            else
                console.print("Skip Barrage - Out of range")
                return false
            end
        end
    end

    if cast_spell.target(target, spell_data_barrage, false) then
        local current_time = get_time_since_inject();
        local cast_delay = menu_elements_barrage_base.cast_delay_slider:get()
        next_time_allowed_cast = current_time + cast_delay;
        console.print("Rogue, Casted Barrage");
        return true;
    end;
            
    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}