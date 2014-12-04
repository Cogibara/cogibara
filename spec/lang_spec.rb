require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara::Lang, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi = Cogibara::Interface::Local.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  describe Cogibara::Lang::NER do
    before do
      @msg = Cogibara::Memory.new_message("remind me via sms to fetch the mail tonight")
      @ner = Cogibara::Lang::NER
    end

    it "does NER with wit", :no_travis do
      expect(@ner.for(:wit).get_entities(@msg).first).not_to be nil
    end

    it "iterates through registered recognizers" do
      expect(@ner.get_entities(@msg).first).not_to be nil
    end
  end

  describe Cogibara::Lang::Normalize do
    before do
      @maluuba = Cogibara::Lang::Normalize.for(:maluuba)
    end

    describe "normalizes time" do
      it { expect(Time.parse(@maluuba.get_normalized("Remind me to go the shop in 5 hours"))).not_to be nil }
    end
  end
end
