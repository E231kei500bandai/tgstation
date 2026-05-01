/datum/antagonist/revenant
	name = "\improper Revenant"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HORRORS

/datum/antagonist/revenant/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/revenant/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/revenant/get_preview_icon()
	return finish_preview_icon(uni_icon('icons/mob/simple/mob.dmi', "revenant_idle"))

/datum/antagonist/revenant/forge_objectives()
	var/datum/objective/revenant/objective = new
	objective.owner = owner
	objectives += objective
	
	var/list/chaos_objs = list(
		/datum/objective/revenant_tether,
		/datum/objective/revenant_malfunction,
		/datum/objective/revenant_possession
	)
	var/num_chaos = rand(1, 2)
	for(var/i in 1 to num_chaos)
		if(!chaos_objs.len)
			break
		var/obj_type = pick_n_take(chaos_objs)
		var/datum/objective/new_objective = new obj_type()
		new_objective.owner = owner
		objectives += new_objective

	var/datum/objective/revenant_fluff/objective2 = new
	objective2.owner = owner
	objectives += objective2
