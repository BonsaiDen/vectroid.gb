# Build
debug:
	@mkdir -p build
	@../../gbasm/bin/gbasm -O -d -o build/game.gb -m stdout -s build/game.sym src/main.gb.s
	@cp build/game.gb ~/.wine_old/drive_c/Program\ Files/bgb/game.gb
	@cp build/game.sym ~/.wine_old/drive_c/Program\ Files/bgb/game.sym

release:
	@mkdir -p build
	@../../gbasm/bin/gbasm -O -o build/game.gb -m stdout -s build/game.sym src/main.gb.s

# Emulation
run: release
	gngb -a --sound build/game.gb

gambatte: release
	gambatte_sdl -s 2 build/game.gb

bgb: debug
	wine ~/.wine_old/drive_c/Program\ Files/bgb/bgb.exe ~/.wine_old/drive_c/Program\ Files/bgb/game.gb

# Others
clean:
	rm -rf build
	find . -name "*.bin" -print0 | xargs -0 rm -rf
	
tiled:
	~/dev/tiled/bin/tiled src/data/scroll.map.json &


# Video
record:
	rm -f game_raw.mov
	mednafen -sound.driver sdl -qtrecord "game_raw.mov" -qtrecord.vcodec png -qtrecord.h_double_threshold 144 -qtrecord.w_double_threshold 160 build/game.gb

webm:
	ffmpeg -i game_raw.mov -vf scale=320:288 -sws_flags neighbor -c:v libvpx -crf 20 -b:v 1M -c:a libvorbis game.webm

render:
	ffmpeg -i game_raw.mov -vf scale=480:432 -sws_flags neighbor -acodec libmp3lame -ac 1 -ab 64000 -ar 22050 -vcodec mpeg4 -flags +mv4+gmc -mbd bits -trellis 2 -b 8000k game.avi
