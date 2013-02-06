require 'uri'
require 'pathname'

class Rewriter
  def initialize(docroot)
    @docroot = docroot
  end

  def rewrite(url)
    uri = URI::parse url
    pn = nil
    dir = Pathname.new(uri.path)
    root_dir_searched = false

    while not root_dir_searched
      pn = Pathname.new("#{@docroot}#{dir}") + Pathname.new(".htaccess")
      break if pn.exist?
      if dir == Pathname.new('/')
        root_dir_searched = true
      else
        dir = dir.parent
      end
    end

    rewritten_url = url


    if pn.exist? and pn.file?
      rule = parse(pn)
      path = uri.path.dup
      path.slice!(dir.to_s)
      path = path.gsub(/^\//, '')
      subsitution = rule.rewrite(path, uri.query)
      rewritten_url = (dir + Pathname.new(subsitution)).to_s                 # add directory back
    end

    rewritten_url
  end

  private
  
  def parse(pathname)
    lines = File.read(pathname)
    conditions = []
    rules = []

    for line in lines.split(/\n/)
      line.strip!
      next if line.empty? or line.start_with?('#')

      if line.start_with?('RewriteCond')
        directive, test_string, pattern = line.split(' ')
        conditions << RewriteCond.new(test_string, pattern)
      elsif line.start_with?('RewriteRule')
        directive, pattern, subsitution, options = line.split(' ')
        rules << RewriteRule.new(pattern, subsitution, options, conditions)
        conditions = []
      end
    end

    RewriteRuleChain.new(pathname.dirname, rules)
  end

end


class RewriteRuleChain
  def initialize(dir, rules)
    @dir = dir
    @rules = rules
  end

  def add(rule)
    @rules << rule
  end

  def rewrite(path, query)
      context = { 'dir' => @dir, 'query' => query }
      rewritten = path
      for rule in @rules
        if not rule.matches?(rewritten, query, context)
          next
        end
        rewritten = rule.rewrite(rewritten, context)
        if rule.is_last?
          break
        end
      end

      context['query'] ? "#{rewritten}?#{context['query']}" : rewritten
  end
end


class RewriteCond
  def initialize(test_string, pattern)
    @test_string = test_string
    @pattern = pattern
  end

  def matches?(path, context)
    request_file = context['dir'] + path
    str = @test_string.gsub('%{REQUEST_FILENAME}', request_file.to_s)
    # breakpoint
    if @pattern == '!-f'
      if not Pathname.new(str).file?
        return true
      end
    end
    if @pattern == '!-d'
      if not Pathname.new(str).directory?
        return true
      end
    end
    return false
  end
end


class RewriteRule
  
  def initialize(pattern, subsitution, options, conditions=[])
    @pattern = Regexp.new(pattern)
    @subsitution = subsitution.gsub('$', '\\')
    @options = options || ''
    @conditions = conditions
  end

  def rewrite(path, context)
    rewritten = path.sub(@pattern, @subsitution)
    uri = URI.parse(rewritten)

    if uri.query
      if context['query']
        context['query'] = uri.query + '&' + context['query']
      else
        context['query'] = uri.query
      end
    end
    
    uri.path
  end

  def matches?(path, query, context)
    for cond in @conditions:
      if not cond.matches?(path, context)
        return false
      end
    end
    @pattern.match(path) ? true : false
  end

  def is_last?
    @options.include?('L')
  end

end