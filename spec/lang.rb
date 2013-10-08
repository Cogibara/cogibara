require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara::Lang, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi = Cogibara::Interface::Local.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  describe "more generalized Language interface" do
    before do
      @msg = Cogibara::Memory.new_message("remind me via sms to fetch the mail tonight")
    end

    it "does NER with wit" do
      Cogibara::Lang::NER.for(:wit).get_entities(@msg).first.should_not be nil
    end

    it "iterates through registered recognizers" do
      Cogibara::Lang::NER.get_entities(@msg).first.should_not be nil
    end
  end
end
