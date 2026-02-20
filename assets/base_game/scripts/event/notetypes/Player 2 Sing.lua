function onCreate()
    for notes = 0,getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes',notes,'noteType') == 'Player 2 Sing' then
            setPropertyFromGroup('unspawnNotes',notes,'ignoreNote',true)
            setPropertyFromGroup('unspawnNotes',notes,'active',false)
            if version <= '0.6.3' or version >= '0.7' and getPropertyFromClass('states.PlayState','SONG.disableNoteRGB') then
                setPropertyFromGroup('unspawnNotes',notes,'texture','ExtraNote')
            elseif version >= '0.7' then
                setPropertyFromGroup('unspawnNotes',notes,'rgbShader.r',getColorFromHex('EEEEEE'))
                setPropertyFromGroup('unspawnNotes',notes,'rgbShader.g',getColorFromHex('FFFFFF'))
                setPropertyFromGroup('unspawnNotes',notes,'rgbShader.b',getColorFromHex('808080'))
                setPropertyFromGroup('unspawnNotes',notes,'multAlpha',0.5)
            end
        end
    end
end