PLAYER_NAME = _TARGET:getName()

local hasStartedQuest = _TARGET:getState():has("KeyItem", "MysteriousMachinations_Started")

local WHAT_R_U_DOING = option "What are you doing?"
local WHO_R_U        = option "Who are you?"
local QUEST
do
	if hasStartedQuest then
		QUEST        = option "What's next?"
	else
		QUEST        = option "Can I help?"
	end
end
local NOPE_IM_GOOD   = option "Nope, I'm good!"

local result
repeat
	result = select {
		WHAT_R_U_DOING,
		WHO_R_U,
		QUEST,
		NOPE_IM_GOOD
	}

	if result == WHAT_R_U_DOING then
		speaker "_TARGET"
		message "What are you doing? This place is scary and impressive!"

		speaker "Hex"
		message {
			"Bwahahahaha! I detected a massive energy pulse frozen in time a thousand years ago.",
			"But time travel is messy! So I'm trying to bypass the whole 'paradox' thing by using my expertise with Antilogika."
		}

		local WHAT_IS_ANTILOGIKA = option "Woah! What's Antilogika?"
		local OKAY_COOL_CRAZY      = option "Okay, cool, you crazy lady!"

		result = select {
			WHAT_IS_ANTILOGIKA,
			OKAY_COOL_CRAZY
		}

		if result == WHAT_IS_ANTILOGIKA then
			speaker "_TARGET"
			message "Woah! What is Antilogika? Sounds dangerous!"

			speaker "Hex"
			message {
				"Why, Antilogika is the the reality-warping, logic-defying powers of the Old Ones themselves!",
				"By using Antilogika, you cut out those silly obstacles known as plot-holes by rewriting reality to your whim.",
				"The limit is your imagination! Or lack thereof."
			}

			speaker "_TARGET"
			message "That doesn't make any sense!"

			speaker "Hex"
			message {
				"It's not supposed to!",
				"You gotta let sense go, %person{${PLAYER_NAME}}, when you experiment with Antilogika!"
			}
		elseif result == OKAY_COOL_CRAZY then
			speaker "_TARGET"
			message "Okay, cool, you crazy lady!"

			speaker "Hex"
			message "Bwahahahaha! What makes YOU think I'm crazy?"

			speaker "Emily"
			message "Bleep bloop bleep."

			PRONOUN = Utility.Text.getPronoun(_TARGET, Utility.Text.PRONOUN_SUBJECT)

			speaker "Hex"
			message "Exactly! ${PRONOUN} crazy, that's all, %person{Emily}!"

			speaker "_TARGET"
			message "I'm right here, %person{Hex}!"

			speaker "Hex"
			message "Oh, I forgot. How rude of me. %person{Emily}, speak %hint{Squeakish}, puh-LEASE!"

			speaker "Emily"
			message {
				"Bleep bloop bleep.",
				"",
				"...Apologies for speaking %hint{Beepish}. I told %person{Hex} she is the most sane person in the Realm while you are a bonafide loon.",
				"Your reputation exceeds the incorrectly understood casuality of the universe and time itself."
			}

			speaker "_TARGET"
			message "Wooooow."
		end
	elseif result == WHO_R_U then
		speaker "_TARGET"
		message "I'm %person{${PLAYER_NAME}}, as you might know. Who are you?"

		speaker "Hex"
		message {
			"Bwahahahaha! I'm Hex, the Techromancer! A lady of the most devious of sciences!",
			"%person{Emily}, introduce yourself, too!"
		}

		speaker "Emily"
		message {
			"I am %person{Emily}. Emily stands for %hint{Emergent Intelligence Life Ynit}.",
			"My %hint{core processing unit} exists outside of the time-space continuum."
		}

		local WAIT_WHAT        = option "How does that work?"
		local OK_SURE_WHATEVER = option "Okay, sure, whatever."

		result = select {
			WAIT_WHAT,
			OK_SURE_WHATEVER
		}

		if result == WAIT_WHAT then
			speaker "_TARGET"
			message "How does that work?"

			speaker "Hex"
			message {
				"Don't you remember? Antilogika defies logic! Thus the name!",
				"Emily is my finest creation, and such an UH-MAZING example of what Antilogika can do!"
			}
		elseif result == OK_SURE_WHATEVER then
			speaker "_TARGET"
			message {
				"Okay, sure, sure, whatever. I'd rather hit my head on a space bar."
			}

			speaker "Hex"
			message "What's that?"

			speaker "Emily"
			message "It's a fourth-wall immersion-breaking reference to pressing the space bar on the player's keyboard to skip dialog."

			speaker "Hex"
			message "Oh, the fourth-wall. Who cares. TUH-ME FOR SCIENCE!"
		end
	elseif result == QUEST then
		defer "Resources/Game/Maps/Rumbridge_HexLabs_Floor1/Dialog/HexMysteriousMachinationsInProgress_en-US.lua"
	end
until result == NOPE_IM_GOOD

speaker "_TARGET"
message "Nope! I'm good as a goober!"
