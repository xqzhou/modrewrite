# bowling_spec.rb
require 'modrewrite'

describe Rewriter, "#rewrite" do

  before(:each) do
    @rewriter = Rewriter.new(File.dirname(__FILE__) + '/docs')
  end

  it "should rewrite url" do
    url = @rewriter.rewrite('http://localhost/localpath/pathinfo')

    url.should == '/otherpath/pathinfo'
  end

  it "should not rewrite when no rewrite pattern matches" do
    url = @rewriter.rewrite('http://localhost/file')

    url.should == '/file'
  end

  it "should rewrite per directory" do
    url = @rewriter.rewrite('http://localhost/dir1/localpath/pathinfo')

    url.should == '/dir1/dir1path/pathinfo'
  end

  it "should append query string" do
    url = @rewriter.rewrite('http://localhost/localpath/pathinfo?q=a')

    url.should == '/otherpath/pathinfo?q=a'
  end
end