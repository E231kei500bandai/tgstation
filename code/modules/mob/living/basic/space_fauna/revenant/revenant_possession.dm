/datum/movespeed_modifier/revenant_possession
	multiplicative_slowdown = 1.5

/datum/action/cooldown/spell/list_target/revenant_possession
	name = "Possess Corpse"
	desc = "Temporarily inhabit a dead body, allowing you to shamble around and interact with the world."
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "overload_lights"
	cooldown_time = 45 SECONDS
	max_targets = 1
	range = 5
	
	var/unlock_amount = 100
	var/cast_amount = 60
	var/reveal_duration = 5 SECONDS
	var/stun_duration = 3 SECONDS
	var/possession_duration = 45 SECONDS

/datum/action/cooldown/spell/list_target/revenant_possession/New(Target)
	. = ..()
	AddComponent(/datum/component/revenant_ability, \
		unlock_amount = unlock_amount, \
		cast_amount = cast_amount, \
		reveal_duration = reveal_duration, \
		stun_duration = stun_duration, \
	)

/datum/action/cooldown/spell/list_target/revenant_possession/get_list_targets()
	var/list/targets = list()
	var/mob/living/basic/revenant/caster = owner
	for(var/mob/living/carbon/human/human_target in view(range, caster))
		if(human_target.stat != DEAD)
			continue
		if(human_target.GetComponent(/datum/component/revenant_possession))
			continue
		targets += human_target
	return targets

/datum/action/cooldown/spell/list_target/revenant_possession/cast_on_list_targets(list/targets)
	var/mob/living/basic/revenant/caster = owner
	var/mob/living/carbon/human/target = targets[1]
	
	if(!caster || !target)
		return
	
	target.AddComponent(/datum/component/revenant_possession, caster, possession_duration)
	caster.possessions_used++
	return TRUE

/datum/component/revenant_possession
	var/mob/living/basic/revenant/caster
	var/datum/mind/caster_mind
	var/timer_id

/datum/component/revenant_possession/Initialize(mob/living/basic/revenant/caster, duration)
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
		
	src.caster = caster
	src.caster_mind = caster.mind
	var/mob/living/carbon/human/possessed_body = parent
	
	if(!caster_mind || !possessed_body)
		return COMPONENT_INCOMPATIBLE
		
	// Transfer mind
	caster_mind.transfer_to(possessed_body)
	
	// Setup the possessed body
	possessed_body.add_traits(list(TRAIT_PACIFISM, TRAIT_MUTE, TRAIT_NODEATH, TRAIT_NOHARDCRIT, TRAIT_NOSOFTCRIT, TRAIT_FAKEDEATH, TRAIT_NO_SLIP_ALL), "revenant_possession")
	possessed_body.add_movespeed_modifier(/datum/movespeed_modifier/revenant_possession)
	possessed_body.set_stat(CONSCIOUS)
	possessed_body.blind_eyes(0)
	possessed_body.blur_eyes(0)
	
	to_chat(possessed_body, span_revenboldnotice("You have possessed [possessed_body]! You have [DisplayTimeText(duration)] before you are ejected."))
	
	RegisterSignal(caster, COMSIG_QDELETING, PROC_REF(on_caster_deleted))
	
	timer_id = addtimer(CALLBACK(src, PROC_REF(end_possession)), duration, TIMER_STOPPABLE)
/datum/component/revenant_possession/Destroy()
	if(timer_id)
		deltimer(timer_id)
	end_possession()
	return ..()

/datum/component/revenant_possession/proc/on_caster_deleted()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/possessed_body = parent
	if(possessed_body && caster_mind && caster_mind.current == possessed_body)
		possessed_body.ghostize(FALSE) // Kick them out if revenant body is destroyed
	qdel(src)

/datum/component/revenant_possession/proc/end_possession()
	var/mob/living/carbon/human/possessed_body = parent
	
	if(possessed_body && caster_mind && caster_mind.current == possessed_body)
		if(caster && !QDELETED(caster))
			caster_mind.transfer_to(caster)
			to_chat(caster, span_revennotice("Your possession of [possessed_body] has ended."))
			caster.apply_status_effect(/datum/status_effect/revenant/revealed, 5 SECONDS)
		else
			possessed_body.ghostize(FALSE)
			
	if(possessed_body)
		possessed_body.remove_traits(list(TRAIT_PACIFISM, TRAIT_MUTE, TRAIT_NODEATH, TRAIT_NOHARDCRIT, TRAIT_NOSOFTCRIT, TRAIT_FAKEDEATH, TRAIT_NO_SLIP_ALL), "revenant_possession")
		possessed_body.remove_movespeed_modifier(/datum/movespeed_modifier/revenant_possession)
		possessed_body.set_stat(DEAD)
		
	qdel(src)
