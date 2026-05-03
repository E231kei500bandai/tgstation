/datum/action/cooldown/spell/list_target/revenant_tether
	name = "Tether"
	desc = "Tether to a living mortal. They will be immune to your area of effect abilities, and you will harvest essence when others die near them. If they die, the tether breaks."
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"
	cooldown_time = 15 SECONDS
	max_targets = 1
	range = 7
	
	var/unlock_amount = 50
	var/cast_amount = 40
	var/reveal_duration = 5 SECONDS
	var/stun_duration = 2 SECONDS

/datum/action/cooldown/spell/list_target/revenant_tether/New(Target)
	. = ..()
	AddComponent(/datum/component/revenant_ability, \
		unlock_amount = unlock_amount, \
		cast_amount = cast_amount, \
		reveal_duration = reveal_duration, \
		stun_duration = stun_duration, \
	)

/datum/action/cooldown/spell/list_target/revenant_tether/get_list_targets()
	var/list/targets = list()
	var/mob/living/basic/revenant/caster = owner
	for(var/mob/living/living_mob in view(range, caster))
		if(living_mob == caster || living_mob.stat == DEAD)
			continue
		if(living_mob.has_status_effect(/datum/status_effect/revenant_tether))
			continue
		targets += living_mob
	return targets

/datum/action/cooldown/spell/list_target/revenant_tether/cast_on_list_targets(list/targets)
	var/mob/living/basic/revenant/caster = owner
	var/mob/living/target = targets[1]
	
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
	var/datum/beam/tether_beam

/datum/status_effect/revenant_tether/on_apply()
	if(isnull(args[1]))
		return FALSE
	tetherer = args[1]
	if(QDELETED(tetherer))
		return FALSE
	
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(on_any_death))
	
	tether_beam = tetherer.Beam(owner, icon_state = "drain_life", time = duration)
	return TRUE

/datum/status_effect/revenant_tether/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH)
	if(!QDELETED(tether_beam))
		qdel(tether_beam)

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
