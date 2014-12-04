require File.dirname(__FILE__) + '/spec_helper.rb'

describe Cogibara, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi_l = Cogibara::Interface::Local.new
    @cogi_x = Cogibara::Interface::XMPP.new
    @cogi_p = Class.new { include Cogibara::Interface }.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end


  describe "encodes email addresses" do
      # puts "hello?"
    it {
      u = Cogibara::User.new('wstrinz@gmail.com')
      expect(u.subject.to_s).to eq("http://cogi.strinz.me/users/wstrinz%40gmail.com")
    }
  end

  describe "can modify attributes" do
    before do
      @user = Cogibara::User.new('wstrinz@gmail.com')
    end

    it {
      @user.name = "Will Strinz"
      @user.save
      expect(Cogibara::User.new('wstrinz@gmail.com').name).to eq("Will Strinz")
    }
  end

end
