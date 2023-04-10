let g:playground_settings = extend({
	\ 'no_cmd': 0,
	\ 'templates_directory': '',
	\ 'languages': {
		\ 'go':{
			\ 'commands':['call playground#job_start("go", "mod", "init", "playground")', ':edit main.go'],
			\ 'templates': {
				\ 'main.go': ["package main","","import (","\t\"fmt\"",")","","func main() {","\tfmt.Println(\"hello world\")", "}"]
			\ }
		\ }
	\ }
	\ }, get(g:, 'playground_settings', {})

if !g:playground_settings['no_cmd']
	command! -complete=customlist,playground#args_complete -nargs=+ PlayGround call playground#start(<f-args>)
endif

