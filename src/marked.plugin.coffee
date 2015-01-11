# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class MarkedPlugin extends BasePlugin
		# Plugin name
		name: 'marked'

		# Plugin configuration
		config:
			markedOptions:
				pedantic: false
				gfm: true
				sanitize: false
				highlight: null
			markedRenderer: {}

		# Render some content
		render: (opts,next) ->
			# Prepare
			config = @config
			{inExtension,outExtension} = opts

			# Check our extensions
			if inExtension in ['md','markdown'] and outExtension in [null,'html']
				# Requires
				marked = require('marked')
				marked.setOptions(config.markedOptions)

				if config.markedRenderer
					renderer = new marked.Renderer()
					for k, v of config.markedRenderer
						if typeof v is 'function'
							renderer[k] = v
				
				# Render
				# use async form of marked in case highlight function requires it
				marked opts.content, { renderer: renderer } ,(err, result) ->
					opts.content = result
					next(err)

			else
				# Done
				next()
