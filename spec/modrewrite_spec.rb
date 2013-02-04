# bowling_spec.rb
require 'modrewrite'

describe Rewriter, "#rewrite" do

  it "rewrite url" do
    rewriter = Rewriter.new(File.dirname(__FILE__) + '/docs')

    url = rewriter.rewrite('http://localhost/localpath/pathinfo')

    url.should == '/otherpath/pathinfo'
  end

  it "should not rewrite when no rewrite rules" do
    rewriter = Rewriter.new(File.dirname(__FILE__) + '/docs')

    url = rewriter.rewrite('http://localhost/file')

    url.should == '/file'
  end

end