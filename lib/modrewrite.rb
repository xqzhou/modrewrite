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
      rule = parse(File.read(pn))
      path = uri.path[dir.size()...uri.path.size()]      # per-directory
      subsitution = rule.rewrite(path)
      rewritten_url = dir + subsitution                  # add directory back
    end

    rewritten_url
  end

  private
  
  def parse(rule)
    parts = rule.split(' ')
    RewriteRule.new(parts[1], parts[2])
  end

end

class RewriteRule
  
  def initialize(from, to)
    @pattern = Regexp.new(from)
    @to = to.gsub('$', '\\')
  end

  def rewrite(path)
    path.gsub(@pattern, @to)
  end
end