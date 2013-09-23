require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Built in modules", vcr: { record: :new_episodes } do

  before(:all) do
    @cogi = Cogibara::Interface.new
  end

  describe Chatbot do
    it { @cogi.ask_local('hello mr chatbot').should == "How are you today?"}
  end

  describe MemoryDumper do
    before do
      @cogi.ask_local('bla').should == "Crno vino."
    end

    it { @cogi.ask_local('dump memory')[/message_string "bla"/].should_not be nil }
  end

  describe DiceRoller do
    it { @cogi.ask_local('roll 6d6').split("\n").first.to_i.should > 0 }
  end

  describe DBPediaQuery do
    it { @cogi.ask_local('who is the leader of germany')[/Angela Merkel/].should_not be nil }
  end
end