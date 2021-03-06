require 'spec_helper'
require 'stringio'

Merb.logger.set_log(StringIO.new)

describe "ActionArgs" do
  
  it "should not accidently introduce any methods as controller actions" do
    Merb::Controller.callable_actions.should be_empty
  end

  it "should extract explicit one arg" do
    ActionArgs.instance_method(:index).get_args.should == [[[:foo]], []]
  end

  it "should extract explicit multi args" do
    ActionArgs.instance_method(:multi).get_args.should == [[[:foo], [:bar]], []]
  end

  it "should extract optional args" do
    ActionArgs.instance_method(:with_default_nil).get_args.should == [[[:foo], [:bar, nil]], [:bar]]
  end

end

describe Merb::AbstractController do
  
  it "should be able to handle a nested class" do
    dispatch_to(Awesome::ActionArgs, :index, :foo => "bar").body.should == "bar"
  end
  
  it "should be able to handle no arguments" do
    dispatch_to(ActionArgs, :nada).body.should == "NADA"
  end
  
  it "should be able to accept Action Arguments" do
    dispatch_to(ActionArgs, :index, :foo => "bar").body.should == "bar"
  end
  
  it "should be able to accept multiple Action Arguments" do
    dispatch_to(ActionArgs, :multi, :foo => "para_foo", :bar => "para_bar").body.should == "para_foo para_bar"
  end
  
  it "should be able to handle defaults in Action Arguments" do
    dispatch_to(ActionArgs, :defaults, :foo => "para_foo").body.should == "para_foo bar"
  end
  
  it "should be able to handle out of order defaults" do
    dispatch_to(ActionArgs, :defaults_mixed, :foo => "para_foo", :baz => "para_baz").body.should == "para_foo bar para_baz"
  end
  
  it "should throw a BadRequest if the arguments are not provided" do
    lambda { dispatch_to(ActionArgs, :index) }.should raise_error(Merb::ControllerExceptions::BadRequest)
  end
  
  it "should treat define_method actions as equal" do
    dispatch_to(ActionArgs, :dynamic_define_method).body.should == "mos def"
  end
  
  it "should be able to inherit actions for use with Action Arguments" do
    dispatch_to(ActionArgs, :funky_inherited_method, :foo => "bar", :bar => "baz").body.should == "bar baz"
  end
  
  it "should be able to handle nil defaults" do
    dispatch_to(ActionArgs, :with_default_nil, :foo => "bar").body.should == "bar "
  end
  
  it "should be able to handle [] defaults" do
    dispatch_to(ActionArgs, :with_default_array, :foo => "para_foo").body.should == "para_foo []"
  end
  
  it "should print out the missing parameters if all are required" do
    lambda { dispatch_to(ActionArgs, :multi) }.should raise_error(
      Merb::ControllerExceptions::BadRequest, /were missing foo, bar/)
  end
  
  it "should only print out missing parameters" do
    lambda { dispatch_to(ActionArgs, :multi, :foo => "Hello") }.should raise_error(
      Merb::ControllerExceptions::BadRequest, /were missing bar/)
  end
  
end
