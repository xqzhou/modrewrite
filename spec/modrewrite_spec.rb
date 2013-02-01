# bowling_spec.rb
require 'modrewrite'

describe Rewriter, "#rewrite" do
  it "rewrite url" do
    rewriter = Rewriter.new

    url = rewriter.rewrite('http://localhost/')

    url.should == url
  end
end