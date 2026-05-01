/datum/action/cooldown/spell/list_target/revenant_tether
	name = "Tether"
	desc = "Tether to a living mortal. Their death will unleash a violent spectral shockwave, and they will be immune to your area of effect abilities."
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
	
tether_beam = tetherer.Beam(owner, icon_state = "drain_life", time = duration)
	return TRUE

/datum/status_effect/revenant_tether/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH))
	if(!QDELETED(tether_beam))
		qdel(tether_beam)

/datum/status_effect/revenant_tether/tick(action_time)
	if(QDELETED(tetherer) || tetherer.dormant || QDELETED(owner))
		qdel(src)
		return
		
	if(get_dist(tetherer, owner) > 15)
		to_chat(tetherer, span_revenwarning("Your tether to [owner] snaps from distance."))
		qdel(src)
		return

/datum/status_effect/revenant_tether/proc/on_target_death(datum/source, gibbed)
	SIGNAL_HANDLER
	if(!QDELETED(tetherer))
		to_chat(tetherer, span_revenboldnotice("Your tethered victim [owner] has perished, unleashing a violent spectral shockwave!"))
		tetherer.apply_status_effect(/datum/status_effect/revenant/revealed, 10 SECONDS)
		
	var/turf/death_turf = get_turf(owner)
	if(death_turf)
		playsound(death_turf, 'sound/effects/screech.ogg', 100, TRUE)
		new /obj/effect/temp_visual/revenant(death_turf)
		empulse(death_turf, 2, 4)
		
		for(var/mob/living/victim in view(4, death_turf))
			if(victim == owner || isrevenant(victim))
				continue
			to_chat(victim, span_revenwarning("A terrifying wail echoes in your mind as violet energy erupts from [owner]!"))
			victim.blind_eyes(2)
			victim.add_confusion(5)
			victim.adjust_stamina_loss(40)
			
		for(var/obj/machinery/light/light in view(4, death_turf))
			light.flicker(rand(5, 10))
			if(prob(50))
				light.break_light_tube()
				
	qdel(src)
