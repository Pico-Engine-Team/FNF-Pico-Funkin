local neneComboAnim = 'none' -- Altere para 'psych' ou 'vanilla' se quiser ativar por padrão
local animOptions = {Disabled = 'none', Psych = 'psych', Vanilla = 'vanilla'}

function onCreate()
    -- Lógica de getModSetting removida para evitar dependências de menu externo.
    -- A variável neneComboAnim agora usa o valor padrão definido acima.
end

function onCreatePost()
    -- This is to make sure that the hardcoded WeekEnd 1 stages don't have a duplicate.
    if curStage == 'phillyStreets' or curStage == 'phillyBlazin' then
        if gfName == 'nene' then
            setCharacterX('gf', getCharacterX('gf') - 60)
            setCharacterY('gf', getCharacterY('gf') + 200)
            callMethod('stages[0].abot.destroy')
        end
    elseif curStage == 'tankErect' then
        -- Temporary fix to make Nene centered in this stage.
        if gfName == 'nene' then
            setCharacterX('gf', getCharacterX('gf') + 115)
        end
    end
    
    addLuaScript('characters/abot-speaker')
    callScript('characters/abot-speaker', 'createSpeaker', {'nene', 0, 0}) -- {characterName, offsetX, offsetY}

    -- Some extra code to set up the speaker's shader in the 'tankErect' stage.
    if curStage == 'tankErect' then
        setVar('trackShader', false)
        if shadersEnabled == true then
            initLuaShader('adjustColor')
            for _, object in ipairs({'AbotSpeaker', 'AbotSpeakerBG', 'AbotPupils', 'AbotEyes'}) do
                setSpriteShader(object, 'adjustColor')
                setShaderFloat(object, 'hue', -10)
                setShaderFloat(object, 'saturation', -20)
                setShaderFloat(object, 'contrast', -25)
                setShaderFloat(object, 'brightness', -30)
            end

            for bar = 1, 7 do
                setSpriteShader('AbotSpeakerVisualizer'..bar, 'adjustColor')
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'hue', -30)
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'saturation', -10)
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'contrast', 0)
                setShaderFloat('AbotSpeakerVisualizer'..bar, 'brightness', -12)
            end
        end
	end
end

local comboAnimActive = true
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if neneComboAnim ~= 'none' and comboAnimActive == true then
        if neneComboAnim == 'vanilla' then
            if combo == 50 then
                playAnim('gf', 'combo50')
                setProperty('gf.specialAnim', true)
            end
            if combo == 200 then
                playAnim('gf', 'combo200')
                setProperty('gf.specialAnim', true)
            end
        end
        lastCombo = combo
    end
end

function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    if neneComboAnim ~= 'none' and comboAnimActive == true then
        if neneComboAnim == 'vanilla' then
            if lastCombo >= 70 then
                playAnim('gf', 'drop70')
                setProperty('gf.specialAnim', true)
            end
        end
        if neneComboAnim == 'psych' then
            if lastCombo > 5 then
                playAnim('gf', 'drop70')
                setProperty('gf.specialAnim', true)
            end
        end
        lastCombo = 0
    end
end

function noteMissPress(direction)
    if neneComboAnim ~= 'none' and comboAnimActive == true then
        if neneComboAnim == 'vanilla' then
            if lastCombo >= 70 then
                playAnim('gf', 'drop70')
                setProperty('gf.specialAnim', true)
            end
        end
        if neneComboAnim == 'psych' then
            if lastCombo > 5 then
                playAnim('gf', 'drop70')
                setProperty('gf.specialAnim', true)
            end
        end
        lastCombo = 0
    end
end

function onUpdatePost(elapsed)
    if songName ~= "Blazin'" then
        transitionAnim()
    end
end

local animTrans = 0
local blinkDelay = 3
local trainStartedMoving = nil
function transitionAnim()
    checkHairBlowState()
    if animTrans == 0 then
        if getHealth() <= 0.5 then
            animTrans = 1
        else
            animTrans = 0
        end
    elseif animTrans == 1 then
        if getHealth() > 0.5 then
            animTrans = 0
        elseif getProperty('gf.animation.name') == 'danceLeft' then
            comboAnimActive = false
            setProperty('gf.specialAnim', true)
            if getProperty('gf.animation.finished') then
                animTrans = 2
                playAnim('gf', 'raiseKnife')
                setProperty('gf.specialAnim', true)
                changedBeat = curBeat
            end
        end
    elseif animTrans == 2 then
        if getHealth() > 0.5 then
            animTrans = 3
            playAnim('gf', 'lowerKnife')
            setProperty('gf.specialAnim', true)
        elseif getProperty('gf.animation.finished') then
            if getProperty('gf.animation.name') ~= 'idleKnife' or curBeat - changedBeat == blinkDelay then
                blinkDelay = getRandomInt(3, 7)
                changedBeat = curBeat
                playAnim('gf', 'idleKnife')
                setProperty('gf.specialAnim', true)
            else
                lastFrame = getProperty('gf.animation.numFrames')
                playAnim('gf', 'idleKnife', false, false, lastFrame)
                setProperty('gf.specialAnim', true)
            end
        end
    elseif animTrans == 3 then
        if getProperty('gf.animation.finished') then
            animTrans = 0
            comboAnimActive = true
            setProperty('gf.danced', false)
            characterDance('gf')
        end   
    elseif animTrans == 4 then
        if trainStartedMoving == false then
            animTrans = 0
            playAnim('gf', 'hairFallNormal')
            setProperty('gf.specialAnim', true)
        else
            playAnim('gf', 'hairBlowNormal')
            setProperty('gf.specialAnim', true)
        end
    elseif animTrans == 5 then
        if trainStartedMoving == false then
            animTrans = 2
            playAnim('gf', 'hairFallKnife')
            setProperty('gf.specialAnim', true)
        else
            playAnim('gf', 'hairBlowKnife')
            setProperty('gf.specialAnim', true)
        end
    end
end

function checkHairBlowState()
    if curStage == 'philly' then
        trainStartedMoving = getProperty('stages[0].phillyTrain.startedMoving')
    elseif curStage == 'phillyErect' then
        trainStartedMoving = getVar('startedMoving')
    else
        return
    end

    if trainStartedMoving == true and animTrans < 4 then
        if animTrans == 2 then
            animTrans = 5
        else
            animTrans = 4
        end
    end