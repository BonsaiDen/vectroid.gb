# Build
debug: convert
	@mkdir -p build
	@../../gbasm/bin/gbasm -O -d -o build/vectroid.gbc -m stdout -s build/game.sym src/main.gb.s
	@cp build/vectroid.gbc ~/.wine_old/drive_c/Program\ Files/bgb/vectroid.gbc
	@cp build/game.sym ~/.wine_old/drive_c/Program\ Files/bgb/game.sym

release: convert
	@mkdir -p build
	@../../gbasm/bin/gbasm -O -o build/vectroid.gbc -m stdout -s build/game.sym src/main.gb.s

convert:
	@mkdir -p src/data/bin
	node tools/convert src/data src/data/bin

# Emulation
run: release
	gngb -Y --res=640x576 -a --sound build/vectroid.gbc

gambatte: release
	gambatte_sdl -s 2 build/vectroid.gbc

bgb: debug
	wine ~/.wine_old/drive_c/Program\ Files/bgb/bgb.exe ~/.wine_old/drive_c/Program\ Files/bgb/vectroid.gbc

# Others
clean:
	rm -rf build
	find . -name "*.bin" -print0 | xargs -0 rm -rf
	
tiled:
	~/dev/tiled/bin/tiled src/data/scroll.map.json &


# Video
record:
	rm -f game_raw.mov
	mednafen -sound.driver sdl -qtrecord "game_raw.mov" -qtrecord.vcodec png -qtrecord.h_double_threshold 144 -qtrecord.w_double_threshold 160 build/vectroid.gbc

webm:
	ffmpeg -i game_raw.mov -vf scale=320:288 -sws_flags neighbor -c:v libvpx -crf 20 -b:v 1M -c:a libvorbis game.webm

render:
	ffmpeg -i game_raw.mov -vf scale=480:432 -sws_flags neighbor -acodec libmp3lame -ac 1 -ab 64000 -ar 22050 -vcodec mpeg4 -flags +mv4+gmc -mbd bits -trellis 2 -b 8000k game.avi

