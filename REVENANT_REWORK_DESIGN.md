# Revenant Rework Design Document: Chaos Parasite Support Antagonist

## 1. Introduction and Core Problem
The Revenant in its previous iteration suffered from a flawed core gameplay loop that was simultaneously overly punishing, heavily reliant on meta-knowledge, and unengaging for both the player and the crew.

As noted by community feedback (e.g., moocowswag), playing a Revenant optimally required an exhaustive understanding of the codebase:
- **Math-Heavy Risk Assessment:** Because Essence serves as both the Revenant's resource and its health bar, casting any ability meant betting your life. Players had to mentally calculate reveal durations, click cooldowns, and the specific weapon force of everyone in the room to determine if an action was survivable.
- **Hidden Mechanics:** Cryptic interactions, such as unarmed punches dealing significantly more damage to simple mobs (~15 damage), created frustrating "gotcha" moments where a Revenant could be unexpectedly killed in seconds by an unarmed assistant.
- **Unengaging Abilities:** The math-heavy risk assessment often culminated in abilities that felt underwhelming or passive. The core loop revolved around waiting for someone to die, popping in to slowly click-drain them, and occasionally breaking a light or opening a door. It lacked dynamic interaction.

**The Goal:** Transform the Revenant from a hyper-vulnerable, math-dependent scavenger into a proactive "Chaos Parasite"—a true support antagonist that thrives on amplifying existing threats and manipulating the battlefield without directly exposing itself to instant death every time it wants to interact.

## 2. Core Principles of the Rework

### A. Divorce Income from Extreme Vulnerability (Soul Leech)
**Old:** The only way to get meaningful Essence was to manually harvest a corpse, locking the Revenant in place and fully revealing them for a long duration, making them highly vulnerable.
**New:** The introduction of the **Soul Leech** passive. When any mob dies within 7 tiles of the Revenant, they passively absorb a portion of their essence. 
*   **Result:** The Revenant is encouraged to spectate and follow active combat zones, anomalies, or other antagonists. They are rewarded for positioning themselves near danger without being forced to physically manifest in the crossfire just to survive. Manual harvesting still exists as a bonus for secured kills, but is no longer the sole lifeline.

### B. Mechanical Symbiosis with Other Antagonists (Tether)
**Old:** The fluff objective stated "assist existing threats," but the Revenant had no mechanical way to actually do this besides coincidentally attacking the same people.
**New:** The **Tether** ability. The Revenant can link themselves to a living mortal.
*   **Result:** A tethered target becomes immune to the Revenant's AoE abilities (Overload Lights, Malfunction, Blight, Haunted Objects). This allows the Revenant to actively support a Traitor, Wizard, or even a robust crewmember by blinding, shocking, and blighting their enemies while leaving the tethered "partner" completely unharmed. Furthermore, if the tethered target dies, the Revenant receives a massive Essence payout.

### C. Shifting from "Time-to-Kill Math" to Strategic Disruption
**Old:** Abilities like Blight and Malfunction cost health to cast and had marginal, easily ignorable impacts (e.g., minor toxin damage or a brief EMP).
**New:** Abilities are now designed to drastically swing the momentum of a fight without requiring the Revenant to stand in the open.
*   **Blight Rework:** Instead of dealing negligible toxin damage, Blight now inflicts a scaling damage vulnerability (up to +75% damage taken). This turns the Revenant into a powerful debuffer, enabling other threats to quickly dispatch crewmembers.
*   **Defile Radio Jamming:** Defile now spawns a spectral jammer, temporarily cutting off radio communications in the area. This isolates victims and prevents them from calling Security, perfectly complementing a Traitor's ambush.
*   **Revenant Mark:** Corpses can be booby-trapped. When a crewmember attempts to examine or revive the body, it bursts, blinding and confusing them while feeding the Revenant. This creates paranoia around fallen crew and disrupts the medical pipeline.

### D. Meaningful World Interaction (Possess Corpse & Haunt Buff)
**Old:** The Revenant felt disconnected from the physical world, functioning more as an annoying poltergeist.
**New:** Giving the Revenant direct, albeit temporary, physical agency.
*   **Possess Corpse:** The Revenant can temporarily inhabit a dead body. While possessed, the body shambles around as a pacifist zombie. This allows the Revenant to physically interact with the world—pressing buttons, moving items, dragging bodies, or simply terrifying the crew—before the body collapses back into a corpse.
*   **Haunt Object Buff:** Haunted items now last significantly longer (5-10 minutes), creating lasting hazard zones rather than brief 60-second nuisances.

### E. Objective Overhaul
**Old:** A singular, boring goal: "Accumulate 350-600 essence."
**New:** A multi-objective system. The primary goal is to consume a set number of *unique* souls (encouraging moving around the station rather than farming one spot). Secondary objectives require the use of the new toolkit (e.g., "Tether to mortals 3 times," "Possess a corpse," "Cause machine chaos").

## 3. Conclusion
This rework directly addresses the cognitive overload of playing a Revenant. By providing passive income and abilities that synergize with allies (Tether) and debuff enemies (Blight vulnerability, Defile comms blackout), the Revenant no longer has to constantly calculate their own "time-to-kill" to justify casting a spell. They can fulfill their intended role: an elusive, malevolent spirit that turns a bad situation for the crew into an absolute nightmare.