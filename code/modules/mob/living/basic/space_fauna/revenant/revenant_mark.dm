/datum/action/cooldown/spell/list_target/revenant_mark
	name = "Revenant Mark"
	desc = "Plant a spectral trap on a corpse. When examined, it will blind and confuse nearby mortals, feeding you essence."
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_haunt"
	cooldown_time = 10 SECONDS
	target_radius = 7
	
	var/unlock_amount = 40
	var/cast_amount = 20
	var/reveal_duration = 3 SECONDS
	var/stun_duration = 1 SECONDS

/datum/action/cooldown/spell/list_target/revenant_mark/New(Target)
	. = ..()
	AddComponent(/datum/component/revenant_ability, \
		unlock_amount = unlock_amount, \
		cast_amount = cast_amount, \
		reveal_duration = reveal_duration, \
		stun_duration = stun_duration, \
	)

/datum/action/cooldown/spell/list_target/revenant_mark/get_list_targets(atom/center, target_radius = 7)
	var/list/targets = list()
	var/mob/living/basic/revenant/caster = owner
	for(var/mob/living/living_mob in view(target_radius, center))
		if(living_mob == caster || living_mob.stat != DEAD)
			continue
		if(living_mob.GetComponent(/datum/component/revenant_mark))
			continue
		targets += living_mob
	return targets

/datum/action/cooldown/spell/list_target/revenant_mark/cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
		
	var/mob/living/basic/revenant/caster = owner
	var/mob/living/target = cast_on
	
	if(!caster || !target)
		return
	
	target.AddComponent(/datum/component/revenant_mark, caster)
	to_chat(caster, span_revennotice("You place a spectral trap on [target]."))
	return TRUE

/datum/component/revenant_mark
	var/mob/living/basic/revenant/caster

/datum/component/revenant_mark/Initialize(mob/living/basic/revenant/caster)
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	src.caster = caster
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/revenant_mark/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(isobserver(user) || isrevenant(user))
		examine_list += span_revenwarning("This body has a spectral trap placed on it!")
		return
		
	if(!user || !user.client || !isliving(user))
		return
		
	var/mob/living/marked_mob = parent
	marked_mob.visible_message(span_warning("A burst of violet energy erupts from [marked_mob]!"), span_revenwarning("Violet energy erupts!"))
	playsound(marked_mob, 'sound/effects/screech.ogg', 50, TRUE)
	
	for(var/mob/living/victim in view(3, marked_mob))
		if(isrevenant(victim))
			continue
		victim.adjust_blindness(2 SECONDS)
		victim.adjust_confusion(3 SECONDS)
		
	if(!QDELETED(caster))
		to_chat(caster, span_revennotice("Your mark on [marked_mob] has been triggered!"))
		caster.change_essence_amount(15, FALSE, "mark triggered")
		
	qdel(src)
