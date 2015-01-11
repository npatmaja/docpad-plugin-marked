# Export Plugin Tester
module.exports = (testers) ->
	# Define My Tester
	class MyTester extends testers.RendererTester

    docpadConfig:
      enabledPlugins:
        'marked': true
      plugins:
        marked:
          markedRenderer:
            code: (code, lang) ->
              escape = (html, encode) ->
                pattern = if !encode then /&(?!#?\w+;)/g  else /&/g
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