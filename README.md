本插件可以根据设定的模板快速生成一个项目，可以用于运行一些临时的代码，或者生成一个基础架构。

# 配置

默认配置如下：

```vim
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
```

- `nocmd`

  插件默认绑定一个命令 `:PlayGround`，如果不需要可以设置 `nocmd` 为 `1`。

- `templates_directory`

  模板目录路径，默认未启用。需要设置哪个语言的模板就在模板目录下创建一个对应语言的子目录。比如模板目录为 `~/.vim/templates` ，要设置 C 语言的模板，就创建一个 `~/.vim/templates/c` 目录，在里面创建 `main.c`、`Makefile` 等文件就行了。

- `languages`

  各语言的相关设定都放在这里。默认只设置了 Go 语言。

  - `templates`

    除了在上面的 `templates_directory` 创建模板目录，你也可以直接在配置文件里设置模板内容。这是一个 map 类型的值，key 是文件名，value 是文件内容，列表形式，每一行是一个字符串。

  - `commands`

    如果设置了 `commands`，则本插件会在生成模板文件后按顺序执行 `commands` 里的 vim 命令。比如默认的 Go 语言的设置:

    ```vim
    ['call playground#job_start("go", "mod", "init", "playground")', ':edit main.go']
    ```

    就会执行 `go mod init` 命令来做项目的初始化并自动打开 `main.go` 文件。

    如果没有设置 `commands` ，则插件会查找名称为 `main` 或 `index` 的文件(比如 C 语言的项目就会查找 `main.c`)自动打开，便于使用。

# 用法

`:PlayGround` 命令的格式为：`:PlayGround {language} {directory}`

第一个参数 `language` 是语言名，第二个参数 `directory` 为目标路径。

如果指定的语言不存在会报错。

如果没有给出目标路径，则会使用系统的临时目录作为目标路径。

假如执行 `:PlayGround go ~/codes/golang/foo` ，会生成一个 `~/codes/golang/foo` 的目录。目录下会有 `main.go`、`go.mod` 两个文件，并自动打开 `main.go`。

假如执行 `:PlayGround go` ，由于没有指定目标路径，则会在系统临时文件夹中创建类似于 `/tmp/PlayGround-go-220102150405` 这样的目录，其他操作则相同。
