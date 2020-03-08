module Tabletop

using Gtk

include("Character.jl")
export Character
export Dice
export @d_str
export gui

function gui(c = Character[Character("", 0, 0, 0, 0, "")])
    turn_number = 1
    round_number = 1
    win = GtkWindow("Initiative Tracker")

    g = GtkGrid(column_homogeneous=true)

    turn = GtkLabel("Round: $round_number Turn: $turn_number")
    g[1,1] = turn

    next_turn = GtkButton("Next Turn")
    function next_turn_func(w)
        update_character(c[turn_number])
        turn_number += 1
        if turn_number > length(c)
            round_number += 1
            turn_number = 1
        end
        GAccessor.text(turn, "Round: $round_number Turn: $turn_number")
        update_details(c[turn_number])
        println(c)
    end
    signal_connect(next_turn_func, next_turn, "clicked")
    g[1,2] = next_turn

    new_character = GtkButton("New Character")
    function new_char(w)
        push!(c, Character("", 0, 0, 0, 0, ""))
        turn_number = length(c)
        GAccessor.text(turn, "Round: $round_number Turn: $turn_number")
        update_details(c[turn_number])
    end
    signal_connect(new_char, new_character, "clicked")
    g[1,3] = new_character


    name = GtkEntry()
    set_gtk_property!(name, :text, c[turn_number].Name)
    g[2,1] = GtkLabel("Name:")
    g[3,1] = name

    initiative = GtkEntry()
    set_gtk_property!(initiative, :text, c[turn_number].Initiative)
    g[2,2] = GtkLabel("Initiative:")
    g[3,2] = initiative

    hp = GtkEntry()
    set_gtk_property!(hp, :text, c[turn_number].HP)
    hp_text = GtkLabel("HP ($(status(c[turn_number].HP, c[turn_number].Damage))):")
    g[2,3] = hp_text
    g[3,3] = hp

    dmg = GtkEntry()
    set_gtk_property!(dmg, :text, c[turn_number].Damage)
    g[2,4] = GtkLabel("Damage:")
    g[3,4] = dmg

    ac = GtkEntry()
    set_gtk_property!(ac, :text, c[turn_number].AC)
    g[2,5] = GtkLabel("AC:")
    g[3,5] = ac

    details = GtkEntry()
    set_gtk_property!(details, :text, c[turn_number].Details)
    g[2,6] = GtkLabel("Details:")
    g[3,6] = details

    update_char = GtkButton("Update Character")
    function update_character(w)
        update_character(c[turn_number])
        println(c[turn_number])
    end
    signal_connect(update_character, update_char, "clicked")
    g[2:3, 7] = update_char

    push!(win, g)
    showall(win)

    if !isinteractive()
        cond = Condition()
        signal_connect(win, :destroy) do widget
            notify(cond)
        end
        wait(cond)
    end

    function update_character(char::Character)
        char.Name = get_gtk_property(name, :text, String)
        char.Initiative = parse(Int64, get_gtk_property(initiative, :text, String))
        hp_string = get_gtk_property(hp, :text, String)
        char.HP = parse_hp(hp_string)
        char.Damage = parse(Int64, get_gtk_property(dmg, :text, String))
        char.AC = parse(Int64, get_gtk_property(ac, :text, String))
        char.Details = get_gtk_property(details, :text, String)
        GAccessor.text(hp_text, "HP ($(status(char.HP, char.Damage))):")
        generate_character_list()
    end

    function update_details(char::Character)
        set_gtk_property!(name, :text, char.Name)
        set_gtk_property!(initiative, :text, char.Initiative)
        GAccessor.text(hp_text, "HP ($(status(char.HP, char.Damage))):")
        set_gtk_property!(hp, :text, string(char.HP))
        set_gtk_property!(dmg, :text, char.Damage)
        set_gtk_property!(ac, :text, char.AC)
        set_gtk_property!(details, :text, char.Details)
        generate_character_list()
    end

    function generate_character_list()
        x = 1
        y = 4
        ind = sortperm(c, by=x->x.Initiative, rev=true)
        turn_number = ind[turn_number]
        GAccessor.text(turn, "Round: $round_number Turn: $turn_number")
        c = c[ind]
        for char in c
            function temp(w)
                turn_number = y-4
                update_details(c[turn_number])
            end
            try
                btn = g[x,y]
                set_gtk_property!(btn, :label, char.Name)
            catch e
                btn = GtkButton(char.Name)
                id = signal_connect(temp, btn, "clicked")
                g[x,y] = btn
            end
            y += 1
        end
        showall(win)
    end
    generate_character_list()
end

function parse_hp(hp::String)
    if 'd' in hp
        return parse_dice(hp)
    else
        return parse(Int64, hp)
    end
end

end # module
