/datum/action/cooldown/spell/list_target/revenant/revenant_tether
	name = "Tether"
	desc = "Tether to a living mortal. They will be immune to your area of effect abilities, and you will harvest essence when others die near them. If they die, the tether breaks. Right-click this ability to see your current tethered targets."
	button_icon_state = "r_transmit"
	cooldown_time = 15 SECONDS
	target_radius = 7
	
	unlock_amount = 50
	cast_amount = 40
	reveal_duration = 5 SECONDS
	stun_duration = 2 SECONDS

/datum/action/cooldown/spell/list_target/revenant/revenant_tether/Trigger(mob/clicker, trigger_flags)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		var/mob/living/basic/revenant/caster = owner
		if(!istype(caster))
			return TRUE
			
		var/list/tethered_mobs = list()
		for(var/mob/living/living_mob in GLOB.mob_living_list)
			var/datum/status_effect/revenant_tether/tether = living_mob.has_status_effect(/datum/status_effect/revenant_tether)
			if(tether && tether.tetherer == caster)
				tethered_mobs += living_mob
				
		if(!length(tethered_mobs))
			to_chat(caster, span_revenwarning("You currently have no tethered targets."))
			return TRUE
			
		var/msg = span_revennotice("<b>Currently Tethered Targets:</b><br>")
		for(var/mob/living/tethered_mob in tethered_mobs)
			var/area/mob_area = get_area(tethered_mob)
			msg += "[tethered_mob.name] ([mob_area ? mob_area.name : "Unknown Location"])<br>"
		to_chat(caster, msg)
		return TRUE
		
	return ..()

/datum/action/cooldown/spell/list_target/revenant/revenant_tether/get_list_targets(atom/center, target_radius = 7)
	var/list/targets = list()
	var/mob/living/basic/revenant/caster = owner
	for(var/mob/living/living_mob in view(target_radius, center))
		if(living_mob == caster || living_mob.stat == DEAD)
			continue
		if(living_mob.has_status_effect(/datum/status_effect/revenant_tether))
			continue
		targets += living_mob
	return targets

/datum/action/cooldown/spell/list_target/revenant/revenant_tether/cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
		
	var/mob/living/basic/revenant/caster = owner
	var/mob/living/target = cast_on
	
	if(!caster || !target)
		return
	
	target.apply_status_effect(/datum/status_effect/revenant_tether, caster)
	caster.tethers_used++
	to_chat(caster, span_revennotice("You tether yourself to [target]."))
	return TRUE

/datum/status_effect/revenant_tether
	id = "revenant_tether"
	duration = 3 MINUTES
	tick_interval = 5 SECONDS
	alert_type = null
	var/mob/living/basic/revenant/tetherer

/datum/status_effect/revenant_tether/on_creation(mob/living/new_owner, mob/living/basic/revenant/tetherer)
	if(isnull(tetherer))
		return FALSE
	src.tetherer = tetherer
	if(QDELETED(tetherer))
		return FALSE
	return ..()

/datum/status_effect/revenant_tether/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(on_any_death))
	return TRUE

/datum/status_effect/revenant_tether/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH)

/datum/status_effect/revenant_tether/tick(action_time)
	if(QDELETED(tetherer) || tetherer.dormant || QDELETED(owner))
		qdel(src)
		return

/datum/status_effect/revenant_tether/proc/on_target_death(datum/source, gibbed)
	SIGNAL_HANDLER
	if(!QDELETED(tetherer))
		to_chat(tetherer, span_revenwarning("Your tethered victim [owner] has perished! The link has been severed."))
	qdel(src)

/datum/status_effect/revenant_tether/proc/on_any_death(datum/source, mob/living/victim, gibbed)
	SIGNAL_HANDLER
	if(QDELETED(tetherer) || tetherer.dormant || QDELETED(owner) || victim == owner || victim == tetherer)
		return

	if(get_dist(owner, victim) > 7)
		return

	if(LAZYFIND(tetherer.drained_mobs, REF(victim)))
		return

	var/essence_gained = 0

	if(victim.client || victim.ckey)
		essence_gained += rand(10, 15)
	else
		essence_gained += rand(2, 5)

	if(essence_gained > 0)
		to_chat(tetherer, span_revennotice("You siphon essence from the death of [victim] near your tethered partner."))
		tetherer.change_essence_amount(essence_gained, FALSE, "tether proximity death of [victim]")
		tetherer.souls_consumed++