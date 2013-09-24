require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Built in modules", vcr: { record: :new_episodes } do

  before(:all) do
    @cogi = Cogibara::Interface.new
  end

  describe Chatbot do
    it { @cogi.ask_local('hello mr chatbot').should == "Hello. What are you?"}
  end

  describe MemoryDumper do
    before do
      @cogi.ask_local('bla').should == "I don't understand you."
    end

    it { @cogi.ask_local('dump memory')[/message_string "bla"/].should_not be nil }
  end

  describe DiceRoller do
    it { @cogi.ask_local('roll 6d6').split("\n").first.to_i.should > 0 }
  end

  describe DBPediaQuery do
    context "property lookup gdp" do
      it { @cogi.ask_local('what is the GDP PPP per capita of United States').should == "49802.0"}
    end

    context "property lookup gdp 2" do
      it { @cogi.ask_local('what is the GDP PPP per capita of Japan').should == "36179.0"}
    end

    context "property lookup with multi-word property 'leader name'" do
      it { @cogi.ask_local('what is the leader name of germany')[/Angela Merkel/].should_not be nil  }
    end

    context "cached properties" do
      it { @cogi.ask_local('who is the leader of germany')[/Angela Merkel/].should_not be nil }
    end
  end
end