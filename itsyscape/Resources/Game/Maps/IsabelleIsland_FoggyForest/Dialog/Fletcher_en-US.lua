speaker "Fletcher"

TARGET_NAME = _TARGET:getName()
message "Yo yo yo!"

do
	local INFO = option "Can you tell me about this place?"
	local DO   = option "What do you do?"
	local QUIT = option "Nevermind."

	local result
	while result ~= QUIT do
		result = select {
			INFO,
			DO,
			QUIT
		}

		if result == INFO then
			message {
				"Gotcha! You're in the Foggy Forest.",
				"Lots of undead creeps roam this area."
			}

			message {
				"But I'm prepared, ha ha ha!",
				"Those wood nymphs sure don't like bows! Poke!"
			}

		elseif result == DO then
			message {
				"I'm a self-sufficient archer, so I gotta make my own arrows and bows.",
				"With a knife, you can make little work logs to make arrow shafts and bows like me."
			}

			message {
				"Gotta smith arrowheads and get some feathers if you want to make arrows.",
				"Bows need bowstring, which is spun from flax. Luckily there's wild flax here."
			}

			message {
				"With some skill, you can make a longbow like mine.",
				"It goes a lot further than a regular bow!"
			}
		else
			message "Later, yo."
		end
	end
end
