if !exists('g:playground_settings')
	let g:playground_settings = {
		\ 'nocmd': 0,
		\ 'templates_directory': '',
		\ 'languages': {
			\ 'go':{
				\ 'commands':['call playground#job_start("go", "mod", "init", "playground")', ':edit main.go'],
				\ 'templates': {
					\ 'main.go': ["package main","","import (","\t\"fmt\"",")","","func main() {","\tfmt.Println(\"hello world\")", "}"]
				\ }
			\ }
		\ }
	\ }
endif

if !g:playground_settings['nocmd']
	command! -complete=customlist,playground#args_complete -nargs=+ PlayGround call playground#start(<f-args>)
endif

