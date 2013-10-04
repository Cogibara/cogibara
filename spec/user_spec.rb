require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi_l = Cogibara::Interface::Local.new
    @cogi_x = Cogibara::Interface::XMPP.new
    @cogi_p = Class.new { include Cogibara::Interface }.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  # describe "defaults to chatting" do
  #     # puts "hello?"
  #     it { @cogi_l.ask('hello?').should ==  "How are you?" }

  #     it { @cogi_l.ask('Who are you').should == "How are you?" }
  # end

  describe "encodes email addresses" do
      # puts "hello?"
    it {
      u = Cogibara::User.new('wstrinz@gmail.com')
      u.subject.to_s.should == "http://cogi.strinz.me/users/wstrinz%40gmail.com"
    }
  end

  describe "can modify attributes" do
    before do
      @user = Cogibara::User.new('wstrinz@gmail.com')
    end

    it {
      @user.name = "Will Strinz"
      @user.save
      Cogibara::User.new('wstrinz@gmail.com').name.should == "Will Strinz"
    }
  end

end
