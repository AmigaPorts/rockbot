function newplatform(plf)
	local name = plf.name
	local description = plf.description

	-- Register new platform
	premake.platforms[name] = {
		cfgsuffix = "_"..name,
		iscrosscompiler = true
	}

	-- Allow use of new platform in --platfroms
	table.insert(premake.option.list["platform"].allowed, { name, description })
	table.insert(premake.fields.platforms.allowed, name)

	-- Add compiler support
	premake.gcc.platforms[name] = plf.gcc
end

function newgcctoolchain(toolchain)
	newplatform {
		name = toolchain.name,
		description = toolchain.description,
		gcc = {
			cc = toolchain.prefix .. "gcc",
			cxx = toolchain.prefix .. "g++",
			ar = toolchain.prefix .. "ar",
			ld = toolchain.prefix .. "ld",
			cppflags = " " .. toolchain.cppflags,
			ldflags = " " .. toolchain.ldflags
		}
	}
end

newgcctoolchain {
	name = "m68k-amigaos",
	description = "m68k-amigaos to cross-compile amiga.68k binaries from linux",
	prefix = "m68k-amigaos-",
	cppflags = "",
	ldflags = ""
}

newgcctoolchain {
	name = "ppc-amigaos",
	description = "ppc-amigaos to cross-compile amiga.ppc binaries from linux",
	prefix = "ppc-amigaos-",
	cppflags = "",
	ldflags = ""
}

newgcctoolchain {
	name = "ppc-morphos",
	description = "ppc-morphos to cross-compile morphos.ppc binaries from linux",
	prefix = "ppc-morphos-",
	cppflags = "",
	ldflags = ""
}

newgcctoolchain {
	name = "x86_64-aros",
	description = "x86_64-aros to cross-compile aros.x86_64 binaries from linux",
	prefix = "x86_64-aros-",
	cppflags = "",
	ldflags = ""
}

newgcctoolchain {
	name = "ppc-macos",
	description = "",
	prefix = "powerpc-apple-macos-",
	cppflags = " ",
	ldflags = ""
}

if _OPTIONS.platform then
	-- overwrite the native platform with the options::platform
	premake.gcc.platforms['Native'] = premake.gcc.platforms[_OPTIONS.platform]
end

solution "rockbot"
	configurations { "Release", "Release-noFPU", "Debug" }
	platforms { "m68k-amigaos", "ppc-amigaos", "ppc-morphos", "x86_64-aros", "ppc-macos" }
	includedirs { "./", }
	defines { "HAVE_CONFIG_H", "MILKYTRACKER", "__THREADTIMER__", "DRIVER_UNIX", "__FORCE_SDL_AUDIO__" }

	configuration "m68k-amigaos"
		buildoptions "-m68040 -mhard-float -O3 -fomit-frame-pointer -fno-exceptions -s -noixemul "
		linkoptions { "-noixemul", "-lnix -Xlinker --allow-multiple-definition " }
		includedirs { "/opt/m68k-amigaos/m68k-amigaos/sys-include", "/opt/m68k-amigaos/include", "/opt/m68k-amigaos/include/SDL" }
		libdirs { "/opt/m68k-amigaos/lib", "/opt/m68k-amigaos/m68k-amigaos/lib", "/opt/m68k-amigaos/m68k-amigaos/libnix/lib/libnix" }
		defines { "AMIGA", "__AMIGA__", "PC" }

	configuration "ppc-morphos"
		buildoptions "-O3 -fomit-frame-pointer -fno-exceptions -s -noixemul"
		linkoptions { "-noixemul", "-ldebug" }
		includedirs { "/opt/ppc-morphos/os-include", "/opt/ppc-morphos/include", "/opt/ppc-morphos/include/SDL" }
		libdirs { "/opt/ppc-morphos/lib" }
		defines { "AMIGA", "__AMIGA__", "MORPHOS", "__MORPHOS__", "morphos", "__morphos__" }

	configuration "ppc-amigaos"
		buildoptions "-O3 -mcrt=newlib -fomit-frame-pointer -fno-exceptions"
		linkoptions { "-mcrt=newlib", "-lauto", "-lunix" }
		includedirs { "/opt/ppc-amigaos/ppc-amigaos/sys-include", "/opt/ppc-amigaos/include", "/opt/ppc-amigaos/include/SDL", "./src/ppui/osinterface/amiga", "./src/ppui/osinterface/sdl-1.2", "./src/ppui/osinterface/posix" }
		libdirs { "/opt/ppc-amigaos/lib", "/opt/ppc-amigaos/ppc-amigaos/lib" }
		defines { "AMIGA", "__AMIGA__", "__amigaos4__" }

	configuration "x86_64-aros"
		buildoptions "-O3 -fomit-frame-pointer -fno-exceptions"
		linkoptions { "-noixemul" }
		includedirs { "/opt/aros/sdk/x86_64-aros/sys-include", "/opt/aros/sdk/include", "/opt/aros/sdk/include/SDL", "./src/ppui/osinterface/amiga", "./src/ppui/osinterface/sdl-1.2", "./src/ppui/osinterface/posix" }
		libdirs { "/opt/aros/sdk/lib", "/opt/aros/sdk/x86_64-aros/lib" }
		defines { "AMIGA", "__AMIGA__", "AROS", "aros", "__AROS__", "__aros__" }

	configuration "ppc-macos"
		buildoptions "-fomit-frame-pointer -fno-exceptions"
		linkoptions { "" }
		includedirs { "/opt/m68k-ppc-macos/toolchain/powerpc-apple-macos/include", "/opt/m68k-ppc-macos/toolchain/powerpc-apple-macos/RIncludes", "/opt/m68k-ppc-macos/toolchain/powerpc-apple-macos/include/SDL", "./include/mac", "./src/ppui/osinterface/sdl-1.2", "./src/ppui/osinterface/posix" }
		libdirs { "/opt/m68k-ppc-macos/toolchain/powerpc-apple-macos/lib" }
		defines { "__macos__" }

	project "zlib"
		kind "StaticLib"
		language "C"
		location "projects"
		targetdir("lib/")
		files { "../milkytracker-68k-master/src/submodules/zlib/*.c" }
		includedirs { "../milkytracker-68k-master/submodules/zlib" }
		targetname "z"

		configuration "debug"
			defines { "DEBUG" }
			flags { "Symbols" }
			targetsuffix "_d"

		configuration "release"
			defines { "NDEBUG" }
			buildoptions ""

		configuration "release-nofpu"
			defines { "NDEBUG" }
			buildoptions "-mhard-float"

	project "rockbot"
		kind "WindowedApp"
		language "C++"
		location "projects"
		targetdir "./bin"
		targetname "rockbot"
		libdirs { "./lib" }
		files { "./main.cpp", "./options/key_map.cpp", "./inputlib.cpp", "./timerlib.cpp", "./soundlib.cpp", "./file/file_io.cpp", "./collision_detection.cpp", "./graphicslib.cpp", "./sceneslib.cpp", "./stage_select.cpp", "./graphic/option_picker.cpp", "./classmap.cpp", "./objects/object.cpp", "./character/character.cpp", "./projectilelib.cpp", "./graphic/animation.cpp", "./stage.cpp", "./stage_select.cpp", "./class_config.cpp", "./scenes/dialogs.cpp", "./scenes/game_menu.cpp", "./game.cpp", "./character/classplayer.cpp", "./character/classnpc.cpp", "./character/artificial_inteligence.cpp", "./aux_tools/trajectory_parabola.cpp", "./file/convert.cpp", "./graphic/draw.cpp", "./graphic/gfx_sin_wave.cpp", "./character/movement/jump.cpp", "./character/movement/inertia.cpp", "./scenes/sceneshow.cpp", "./game_mediator.cpp", "./strings_map.cpp", "./file/fio_strings.cpp", "./file/fio_common.cpp", "./file/fio_scenes.cpp", "./aux_tools/stringutils.cpp", "./aux_tools/fps_control.cpp", "./docs/game_manual.cpp", "./aux_tools/exception_manager.cpp", "./character/character_animation.cpp" }
		links { "xmp", "SDL_image", "SDL_mixer", "mad", "SDL_ttf", "SDL_rotozoom", "jpeg", "png", "freetype", "z", "SDL", "stdc++", "debug", "m", "nix" }
		flags { "Symbols" }
		buildoptions "-fno-rtti"

		configuration "m68k-amigaos"
			targetextension ".68k"
		configuration "ppc-morphos"
			targetextension ".mos"
			links { "debug" }
		configuration "ppc-amigaos"
			targetextension ".os4"
		configuration "ppc-macos"
			targetextension ".app"
		--	links { "SDLmain" }
		
		-- Debug options.
		configuration "Debug"
			defines { "DEBUG" }
			targetsuffix "_d"
			flags { "NoEditAndContinue" }
		
		-- Release options.
		configuration "Release"
			buildoptions "-fpermissive"

		configuration "Release-noFPU"
            defines { "NDEBUG" }
            buildoptions "-mhard-float"
			targetsuffix "-nofpu"
