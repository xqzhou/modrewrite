require 'uri'
require 'pathname'

class Rewriter
  def initialize(docroot)
    @docroot = docroot
  end

  def rewrite(url)
    uri = URI::parse url
    pn = nil
    path_parts = uri.path.split('/')

    begin
      pn = Pathname.new("#{@docroot}#{path_parts.join('/')}/.htaccess")
      break if pn.exist?
      path_parts = path_parts[0...-1]
    end while not path_parts.empty?

    rewritten_url = url

    if pn.exist? and pn.file?
      dir = path_parts.join('/') + '/'
      path = uri.path[dir.size()...uri.path.size()]      # per-directory

      rule = parse(File.read(pn))
      subsitution = rule.rewrite(path, uri.query)
      rewritten_url = dir + subsitution                  # add directory back
    end

    rewritten_url
  end

  private
  
  def parse(rules)
    chain = RewriteRuleChain.new()

    for line in rules.split(/\n/)
      line.strip!
      next if line.empty? or not line.include?('RewriteRule') or line.start_with?('#')
      directive, pattern, subsitution, options = line.split(' ')
      rule = RewriteRule.new(pattern, subsitution, options)
      chain.add(rule)
    end

    chain
  end

end

class RewriteRuleChain
  def initialize()
    @rules = []
  end

  def add(rule)
    @rules << rule
  end

  def rewrite(path, query)
    invocation = ChainInvocation.new(@rules)
    invocation.rewrite(path, query)
  end

  class ChainInvocation
    def initialize(rules)
      @rules = rules
      @current = 0
      @rewritten = nil
    end

    def rewrite(path, query)
      return path if @current >= @rules.size()
      rule = @rules[@current]
      @current += 1
      rule.rewrite(path, query, self)
    end
  end
end

class RewriteRule
  
  def initialize(pattern, subsitution, options)
    @pattern = Regexp.new(pattern)
    @subsitution = subsitution.gsub('$', '\\')
    @options = options || ''
  end

  def rewrite(path, query, chain)
    if not @pattern.match(path)
      return chain.rewrite(path, query)
    end
    
    rewritten = path.gsub(@pattern, @subsitution)

    if not @options.include?('L')
      rewritten = chain.rewrite(rewritten, query)
    end

    if @options.include?('QSA') and query
      rewritten += '?' + query
    end
    
    rewritten
  end
end