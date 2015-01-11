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

				renderer = new marked.Renderer()

				renderer.code = (code, lang) ->
					escape = (html, encode) ->
						pattern = if !encode then /&(?!#?\w+;)/g	else /&/g
						return html
							.replace(pattern, '&amp;')
					    .replace(/</g, '&lt;')
					    .replace(/>/g, '&gt;')
					    .replace(/"/g, '&quot;')
					    .replace(/'/g, '&#39;')

					if code.match(/^sequenceDiagram/)|| code.match(/^graph/)
						return "<div class=\"mermaid\">\n#{code}\n</div>\n"
					else
						if @options.highlight
							out = @options.highlight code, lang
							if out != null && out != code
								escaped = true
								code = out

						if !lang
							return '<pre><code>' +
				      	(if escaped then code else escape(code, true)) +
				      	'\n</code></pre>'
						
						return '<pre><code class="' +
					    this.options.langPrefix +
					    escape(lang, true) +
					    '">' +
					    (if escaped then code else escape(code, true)) +
					    '\n</code></pre>\n'
					

				# Render
				# use async form of marked in case highlight function requires it
				marked opts.content, { renderer: renderer } ,(err, result) ->
					opts.content = result
					next(err)

			else
				# Done
				next()
