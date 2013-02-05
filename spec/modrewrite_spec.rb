require 'modrewrite'

describe Rewriter, "#rewrite" do

  before(:each) do
    docroot = File.dirname(__FILE__) + '/docs'
    @rewriter = Rewriter.new(docroot)
  end

  it "should rewrite url" do
    url = @rewriter.rewrite('http://localhost/lang/python')

    url.should == '/language/python'
  end

  it "should not rewrite when no rewrite pattern matches" do
    url = @rewriter.rewrite('http://localhost/python')

    url.should == '/python'
  end

  it "should rewrite per directory" do
    url = @rewriter.rewrite('http://localhost/ruby/awesome/monkey-patching')

    url.should == '/ruby/fragile/monkey-patching'
  end

  it "should append query string" do
    url = @rewriter.rewrite('http://localhost/lang/python?q=a')

    url.should == '/language/python?q=a'
  end

  it "should terminate matching on last rule" do
    url = @rewriter.rewrite('http://localhost/lang/java')

    url.should == '/blame/oracle'
  end 

  it "should ignore comments" do
    url = @rewriter.rewrite('http://localhost/lang/ruby')

    url.should == '/language/ruby'
  end   
end