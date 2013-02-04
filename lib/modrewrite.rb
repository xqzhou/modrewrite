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

    if pn.exist?
      dir = path_parts.join('/') + '/'
      path = uri.path[dir.size()...uri.path.size()]      # per-directory

      rule = parse(File.read(pn))
      subsitution = rule.rewrite(path)
      rewritten_url = dir + subsitution                  # add directory back

      if rule.options and rule.options.include?('QSA') and uri.query
        rewritten_url += '?' + uri.query
      end
    end

    rewritten_url
  end

  private
  
  def parse(rule)
    directive, pattern, subsitution, options = rule.split(' ')
    RewriteRule.new(pattern, subsitution, options)
  end

end

class RewriteRule
  
  def initialize(pattern, subsitution, options)
    @pattern = Regexp.new(pattern)
    @subsitution = subsitution.gsub('$', '\\')
    @options = options
  end

  attr_reader :options

  def rewrite(path)
    path.gsub(@pattern, @subsitution)
  end
end