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
    describe "property lookup gdp" do
      it { @cogi.ask_local('what is the GDP PPP per capita of United States').should == "49802.0"}
    end

    describe "property lookup gdp 2" do
      it { @cogi.ask_local('what is the GDP PPP per capita of Japan').should == "36179.0"}
    end

    describe "doesn't mind question marks" do
      it { @cogi.ask_local('who is the leader of France?').should == "Jean-Marc Ayrault, François Hollande"}
    end

    describe "property lookup with multi-word property 'leader name'" do
      it { @cogi.ask_local('what is the leader name of germany')[/Angela Merkel/].should_not be nil  }
    end

    describe "cached properties" do
      it { @cogi.ask_local('who is the leader of germany')[/Angela Merkel/].should_not be nil }
    end
  end

  describe DBPediaSpotlight do
    it "resolves entities using spotlight" do
      @cogi.ask_local('What does President Obama think of the Bacon Crisis?')
      # puts Cogibara.dump_memory
      Cogibara.dump_memory["structured_properties"].should_not be nil
    end

    it "creates structured properties" do
      msg = @cogi.ask('I live in Madison Wisconsin')
      original = msg.response_to
      prop = original.property_for(original.structured_properties[1])
      prop.values["spotlight_entity_uri"].should == "http://dbpedia.org/resource/Madison,_Wisconsin"
      prop.values["spotlight_types"]["DBpedia:City"].should_not be nil
    end

    describe "debug keywords" do
      it "can print all entities" do
        msg = @cogi.ask_local('spotlight entities for "I live in Madison Wisconsin"')
        msg['"spotlight_entity_uri"=>"http://dbpedia.org/resource/Madison,_Wisconsin"'].should_not be nil
      end

      it "can return just URIs" do
        msg = @cogi.ask_local('spotlight URIs for "I live in Madison Wisconsin"')
        eval(msg)["Madison Wisconsin"].should == "http://dbpedia.org/resource/Madison,_Wisconsin"
      end
    end
  end
end