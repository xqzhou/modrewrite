require 'uri'

class Rewriter
  def initialize(rule)
    @rule = parse(rule)
  end

  def rewrite(url)
    uri = URI::parse url
    uri.path
    @rule.rewrite(uri.path[1, uri.path.size()])
  end

  private
  
  def parse(rule)
    puts rule
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