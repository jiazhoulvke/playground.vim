if has('win32')
	let s:sep = '\'
else
	let s:sep = '/'
endif

function playground#temp_dir() abort
	if has('win32')
		if exists('$TMP')
			return $TMP
		elseif exists('$TEMP')
			return $TEMP
		else
			return 'C:\temp'
		endif
	else
		if exists('$TMPDIR')
			return $TMPDIR
		elseif exists('TMP')
			return $TMP
		else
			return '/tmp'
		endif
	endif
endfunction

function playground#project_dir(dir, prefix) abort
	if exists("*strftime")
		return a:dir.s:sep.a:prefix.strftime('%y%m%d%H%M%S')
	endif
	return a:dir.s:sep.a:prefix.localtime()
endfunction

function playground#start(language, ...) abort
	let has_templates_dir = 0
	if strlen(g:playground_settings['templates_directory']) > 0
		let templates_dir = expand(g:playground_settings['templates_directory']).s:sep.a:language
		if isdirectory(templates_dir)
			let has_templates_dir = 1
		endif
	endif
	let has_settings = 0
	if has_key(g:playground_settings['languages'], a:language)
		let has_settings = 1
	endif
	if has_settings == 0 && has_templates_dir == 0
		echomsg 'language '.a:language.' no templates'
		return
	endif
	if a:0 > 0
		let project_dir = a:1
	else
		let project_dir = playground#project_dir(playground#temp_dir(), 'PlayGround-'.a:language.'-')
	endif
	call mkdir(project_dir, 'p')
	call chdir(project_dir)
	if has_templates_dir
		call playground#copy_template_files(templates_dir, project_dir)
	endif
	let has_commands = 0
	if has_settings
		let settings = g:playground_settings['languages'][a:language]
		if has_key(settings, 'templates')
			for [key, value] in items(settings['templates'])
				if type(value) == v:t_list
					call writefile(value, key, 's')
				endif
			endfor
		endif
		if has_key(settings, 'commands')
			let has_commands = 1
			for cmd in settings['commands']
				exec cmd
			endfor
		endif
	endif
	" 默认打开 main.c 、index.js 这类文件
	if has_commands == 0
		for file in playground#readdirex(project_dir)
			if file['name'] == 'main.'.a:language || file['name'] == 'index.'.a:language
				exec ':edit '.file['name']
			endif
		endfor
	endif
endfunction

function playground#job_start(...) abort
	if exists('*jobstart')
		call jobstart(a:000 , { 'detach': v:true })
	elseif exists('*job_start')
		call job_start(a:000, {"stoponexit": ""})
	else
		call system(join(a:000, ' '))
	endif
endfunction

function playground#copy_template_files(src, dest) abort
	if !isdirectory(a:dest)
		call mkdir(a:dest, 'p')
	endif
	for file in playground#readdirex(a:src)
		if file['type'] == 'file'
			if file['size'] == 0
				continue
			endif
			let sfile = a:src.s:sep.file['name']
			let content = readfile(sfile)
			if len(content) == 0
				echomsg 'read file '.sfile.' failed'
				continue
			endif
			let dfile = a:dest.s:sep.file['name']
			if writefile(content, dfile, 's') == -1
				echomsg 'write file '.dfile.' failed'
			endif
		elseif file['type'] == 'dir'
			call playground#copy_template_files(a:src.s:sep.file['name'], a:dest.s:sep.file['name'])
		endif
	endfor
endfunction

" 目前 neovim 没有 readdirex 函数, 只能自己实现
function playground#readdirex(directory) abort
	if exists('*readdirex')
		return readdirex(a:directory)
	endif
	let flist = readdir(a:directory)
	let result = []
	for f in flist
		let item = {'name': f}
		let filepath = a:directory.s:sep.f
		let item['perm'] = getfperm(filepath)
		let item['size'] = getfsize(filepath)
		let item['time'] = getftime(filepath)
		let item['type'] = getftype(filepath)
		call add(result, item)
	endfor
	return result
endfunction

function playground#args_complete_languages(A) abort
	let result = []
	let languages = {}
	for language in keys(g:playground_settings['languages'])
		let languages[language] = 1
	endfor
	if len(g:playground_settings['templates_directory']) > 0
		for file in playground#readdirex(expand(g:playground_settings['templates_directory']))
			if file['type'] == 'dir'
				let languages[file['name']] = 1
			endif
		endfor
	endif
	for [language, value] in items(languages)
		if len(a:A) > 0
			if strpart(language, 0, len(a:A)) != a:A
				continue
			endif
		endif
		call add(result, language)
	endfor
	return result
endfunction

function playground#args_complete(ArgLead,CmdLine,CursorPos) abort
	let s = trim(strpart(a:CmdLine, stridx(a:CmdLine,' ')), " \t", 1)
	let s = substitute(s, "\t", ' ', 'g')
	if stridx(s, ' ') == -1
		return playground#args_complete_languages(a:ArgLead)
	endif
	let pathA = trim(strpart(s, stridx(s, ' ')))
	return map(getcompletion(a:ArgLead, 'dir'), { -> escape(v:val, ' ') })
endfunction
