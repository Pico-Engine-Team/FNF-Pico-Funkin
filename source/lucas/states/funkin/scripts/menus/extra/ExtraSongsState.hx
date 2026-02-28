package lucas.states.funkin.scripts.menus.extra;

import objects.HealthIcon;
import backend.Song;
import backend.WeekData;
import backend.Highscore;
import backend.Difficulty;
import options.GameplayChangersSubstate;
import states.editors.ChartingState;
import flixel.sound.FlxSound;

using StringTools;

class ExtraSongsState extends MusicBeatState
{
    private var songs:Array<ExtraSongMetadata> = [];
    private static var curSelected:Int = 0;
    var curDifficulty:Int = -1;

    var scoreBG:FlxSprite;
    var scoreText:FlxText;
    var diffText:FlxText;
    
    var lerpScore:Int = 0;
    var lerpRating:Float = 0;
    var intendedScore:Int = 0;
    var intendedRating:Float = 0;

    private var grpSongs:FlxTypedGroup<Alphabet>;
    private var iconArray:Array<HealthIcon> = [];

    var bg:FlxSprite;
    var intendedColor:Int;
    var colorTween:FlxTween;

    override function create()
    {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        
        persistentUpdate = true;
        PlayState.isStoryMode = false;

        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In The Extra Songs Menu", "Selecting An Extra Song");
        #end

        addSong('lo-fight', 1, 'whitty', 0xFF1D1E35, 'Pico');
        addSong('endless', 2, 'exe/majin-encore', 0xFF0000D7, 'Pico');
        addSong('sky', 3, 'face', 0xFFB80000, 'Pico', 'Pico-Remix');

        bg = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);
        bg.screenCenter();

        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);

        for (i in 0...songs.length)
        {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpSongs.add(songText);

            var maxWidth:Float = 980;
            if (songText.width > maxWidth)
                songText.scaleX = maxWidth / songText.width;

            Mods.currentModDirectory = songs[i].folder;
            var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
            icon.sprTracker = songText;
            iconArray.push(icon);
            add(icon);
        }

        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
        scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
        
        scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
        scoreBG.alpha = 0.6;
        add(scoreBG);

        diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
        diffText.font = scoreText.font;
        add(diffText);
        add(scoreText);

        changeSelection();
        super.create();
    }

    // Função addSong atualizada para aceitar 5 argumentos
    public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, ?diff:String = "Pico", ?display:String = "Pico")
    {
        songs.push(new ExtraSongMetadata(songName, weekNum, songCharacter, color, diff, display));
    }

    override function update(elapsed:Float)
    {
        lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
        lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));
        scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
        positionHighscore();

        if (controls.UI_UP_P) changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new lucas.states.funkin.scripts.menus.FreeplayMenuState());
        }

        if (controls.ACCEPT)
        {
            var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
            
            // Pasta definida como 'extras' conforme solicitado
            var customFolder:String = 'extras/' + songLowercase;

            // Carrega o JSON forçando a dificuldade Pico para evitar o erro de 'asset not found'
            PlayState.SONG = Song.loadFromJson(songLowercase + '-' + songs[curSelected].forcedDiff.toLowerCase(), customFolder);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = curDifficulty;

            if (FlxG.keys.pressed.SHIFT) LoadingState.loadAndSwitchState(new ChartingState());
            else LoadingState.loadAndSwitchState(new PlayState());

            FlxG.sound.music.volume = 0;
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
            
        intendedColor = songs[curSelected].color;
        if(colorTween != null) colorTween.cancel();
        colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {onComplete: function(twn:FlxTween) { colorTween = null; }});

        // Define a dificuldade baseada no Metadata da música
        var diffFile:String = songs[curSelected].forcedDiff;
        curDifficulty = Difficulty.list.indexOf(diffFile);
        if(curDifficulty == -1) curDifficulty = 0;

        intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
        intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

        diffText.text = '< ' + songs[curSelected] + ' >';

        for (i in 0...iconArray.length) iconArray[i].alpha = 0.6;
        iconArray[curSelected].alpha = 1;

        var bullShit:Int = 0;
        for (item in grpSongs.members) {
            item.targetY = bullShit - curSelected;
            bullShit++;
            item.alpha = 0.6;
            if (item.targetY == 0) item.alpha = 1;
        }
        Mods.currentModDirectory = songs[curSelected].folder;
    }

    private function positionHighscore() {
        scoreText.x = FlxG.width - scoreText.width - 6;
        scoreBG.scale.x = FlxG.width - scoreText.x + 6;
        scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
        diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
        diffText.x -= diffText.width / 2;
    }
}

class ExtraSongMetadata
{
    public var songName:String = "";
    public var week:Int = 0;
    public var songCharacter:String = "";
    public var color:Int = -1;
    public var folder:String = "";
    public var forcedDiff:String = "Pico";

    public function new(song:String, week:Int, songCharacter:String, color:Int, ?diff:String = "Pico", ?display:String = "Pico")
    {
        this.songName = song;
        this.week = week;
        this.songCharacter = songCharacter;
        this.color = color;
        this.forcedDiff = diff;
        this.folder = Mods.currentModDirectory;
        if(this.folder == null) this.folder = '';
    }
}