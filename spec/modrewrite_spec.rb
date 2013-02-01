# bowling_spec.rb
require 'modrewrite'

describe Rewriter, "#rewrite" do
  it "rewrite url" do
    rewriter = Rewriter.new('RewriteRule ^([^/]+)/?(.*)$ index.php?_p=$1&_=$2 [QSA,L]')

    url = rewriter.rewrite('http://localhost/over/there')

    url.should == 'index.php?_p=over&_=there'
  end
end