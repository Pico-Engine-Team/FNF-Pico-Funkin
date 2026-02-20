function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Bullet Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'BulletNotes')
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashHue', 0)
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashSat', -20)
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashBrt', 1)
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', 0.0115)
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false)
			end
		end
	end
end

local shootAnims = {'shootLEFT', 'shootDOWN', 'shootUP', 'shootRIGHT'}
local dodgeAnims = {'dodgeLEFT', 'dodgeDOWN', 'dodgeUP', 'dodgeRIGHT'}
function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		playSound('shoot', 0.7)

		characterPlayAnim('dad', shootAnims[direction + 1], true)
		characterPlayAnim('boyfriend', dodgeAnims[direction + 1], true)
		characterPlayAnim('dad', dodgeAnims[direction + 1], false)
		characterPlayAnim('boyfriend', shootAnims[direction + 1], false)

		setProperty('boyfriend.specialAnim', true)
		setProperty('dad.specialAnim', true)
		cameraShake('camGame', 0.01, 0.2)
	end
end
function noteMiss(id, direction, noteType, isSustainNote)
	if noteType == 'Bullet Note' and difficulty == 1 then
		setProperty('health', getProperty('health') - 0.8)
		runTimer('bleed', 0.2, 20)
		playSound('shoot', 1)
		characterPlayAnim('boyfriend', 'hurt', true)
	end
end
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'bleed' and loopsLeft > 0 then
		setProperty('health', getProperty('health') - 0.03)
	end
end