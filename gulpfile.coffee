# include gulp
gulp         = require("gulp")

# include our plugins
sass         = require("gulp-sass")
plumber      = require("gulp-plumber")
notify       = require("gulp-notify")
minifycss    = require("gulp-minify-css")
autoprefixer = require("gulp-autoprefixer")
concat       = require("gulp-concat")
rename       = require("gulp-rename")
uglify       = require("gulp-uglify")
coffee       = require("gulp-coffee")
jade         = require("gulp-jade")
clean        = require("gulp-clean")
connect      = require("gulp-connect")
lr           = require("tiny-lr")
livereload   = require("gulp-livereload")
server       = lr()

# paths
src          = "src"
dist         = "dist"

#
#	 gulp tasks
#	 ==========================================================================

# clean
gulp.task "clean", ->
	gulp.src dist
	.pipe clean()

# jade
gulp.task "jade", ->
	gulp.src src + "/templates/pages/*.jade"
	.pipe plumber()
	.pipe jade
		pretty: true
	.on "error", notify.onError()
	.on "error", (err) ->
		console.log "Error:", err
	.pipe gulp.dest "./dist"
	.pipe livereload(server)

# jade-dist
gulp.task "jade-dist", ->
	gulp.src src + "/templates/pages/*.jade"
	.pipe plumber()
	.pipe jade()
	.on "error", notify.onError()
	.on "error", (err) ->
		console.log "Error:", err
	.pipe gulp.dest "./dist"

# copy
gulp.task "copy", ->
	gulp.src src + "/vendor/scripts/jquery/jquery.min.js"
	.pipe gulp.dest dist + "/scripts"

# vendor scripts
gulp.task "vendor-scripts", ->
	gulp.src src + "/vendor/scripts/bootstrap/bootstrap.js"
	.pipe rename "vendor.js"
	.pipe gulp.dest dist + "/scripts"

# scripts
gulp.task "scripts", ->
	gulp.src src + "/scripts/**/*.coffee"
	.pipe coffee
		bare: true
	.pipe concat("scripts.js")
	.pipe gulp.dest dist + "/scripts"
	.pipe connect.reload()

# scripts-dist
gulp.task "scripts-dist", ->
	gulp.src src + "/scripts/**/*.coffee"
	.pipe coffee
		bare: true
	.pipe concat("scripts.js")
	.pipe uglify()
	.pipe gulp.dest dist + "/scripts"

# styles
gulp.task "styles", ->
	gulp.src src + "/styles/styles.scss"
	.pipe plumber()
	.pipe sass
		errLogToConsole: false
		onError: (err) -> notify().write(err)
	.pipe gulp.dest dist + "/styles"
	.pipe livereload(server)

# styles-dist
gulp.task "styles-dist", ->
	gulp.src src + "/styles/styles.scss"
	.pipe plumber()
	.pipe sass()
	.on "error", notify.onError()
	.on "error", (err) ->
		console.log "Error:", err
	.pipe autoprefixer("last 15 version")
	.pipe minifycss
		keepSpecialComments: 0
	.pipe gulp.dest dist + "/styles"

gulp.task "connect", connect.server
	root: [__dirname + "/" + dist]
	port: 9000
	livereload: true

gulp.task 'watch', ->
	server.listen 35729, (err) ->
		return console.error(err)  if err

		gulp.watch ['./src/scripts/**/*.coffee'], ['scripts']
		gulp.watch ['./src/styles/**/*.scss'], ['styles']
		gulp.watch ['./src/templates/**/*.jade'], ['jade']

#
#  main tasks
#	 ==========================================================================

# default task
gulp.task 'default', [
	"copy"
	"jade"
	"styles"
	"scripts"
	"vendor-scripts"
	"connect"
	"watch"
]

# build task
gulp.task 'dist', [
	"clean"
	"copy"
	"vendor-scripts"
	"scripts-dist"
	"jade-dist"
	"styles-dist"
]


