require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Built in modules", vcr: { record: :new_episodes } do

  before(:all) do
    @cogi_l = Cogibara::Interface::Local.new
    @cogi_x = Cogibara::Interface::XMPP.new
    @cogi_p = Class.new { include Cogibara::Interface }.new
  end

  describe Chatbot do
    it { @cogi_l.ask('hello mr chatbot').should == "Hello, my Earthling friend."}
  end

  describe MemoryDumper do
    before do
      @cogi_l.ask('bla').should == "Bla bla."
    end

    it { @cogi_l.ask('dump memory')[/message_string "bla"/].should_not be nil }
  end

  describe DiceRoller do
    it { @cogi_l.ask('roll 6d6').split("\n").first.to_i.should > 0 }
  end

  describe DBPediaQuery do
    describe "property lookup gdp" do
      it { @cogi_l.ask('what is the GDP PPP per capita of United States').should == "49802.0"}
    end

    describe "property lookup gdp 2" do
      it { @cogi_l.ask('What is the gdp PPP per capita of Japan').should == "36179.0"}
    end

    describe "doesn't mind question marks" do
      it { @cogi_l.ask('who is the leader of France?').should == "Jean-Marc Ayrault, François Hollande"}
    end

    describe "also looks up owl properties" do
      it { @cogi_l.ask('what is the record label of Arashi').should == "J Storm, Pony Canyon"}
    end

    describe "returns uris when no labels are available" do
      it { @cogi_l.ask('what is the website of Community (TV series)').should == "http://www.nbc.com/community/"}
    end

    describe "property lookup with multi-word property 'leader name'" do
      it { @cogi_l.ask('what is the leader name of germany')[/Angela Merkel/].should_not be nil  }
    end

    describe "cached properties" do
      it { @cogi_l.ask('who is the leader of germany')[/Angela Merkel/].should_not be nil }
    end

    describe "use it to refer to current object" do
      it { @cogi_l.ask('what is the capital of it').should == "Berlin" }
    end

    describe "can fetch abstracts" do
      it { @cogi_l.ask('what is Tardigrade')[0..119].should == "Tardigrades (commonly known as waterbears or moss piglets) are small, water-dwelling, segmented animals with eight legs." }
    end

    # describe "uses ActiveSupport to singularize" do
    #   it { @cogi_l.ask('what are Tardigrades?')[0..119].should == "Tardigrades (commonly known as waterbears or moss piglets) are small, water-dwelling, segmented animals with eight legs." }
    # end

    describe "can help disambiguate abstracts" do
      it { @cogi_l.ask('what is pitch?')[0..43].should == "Pitch Pine, Pitch (card game), Pitch (film)," }
    end


    describe "lists known predicates" do
      it { @cogi_l.ask('what can you tell me about Germany')['Capital, Caption, cctld, color, common name, conventional long name, currency'].should_not be nil }
    end

    context "experimental wit integration" do
      describe "property enumeration" do
        it { @cogi_l.ask('what you know about balloon?')[0..43].should == "sameAs, label, depiction, comment, is primar" }
      end

      describe "fact questions" do
        it { @cogi_l.ask('what\'s the capital of Cuba?')[0..43].should == "Havana" }
      end
    end
  end

  describe DBPediaSpotlight do
    pending("spotlight disabled for now")
    # it "resolves entities using spotlight" do
    #   @cogi_l.ask('What does President Obama think of the Bacon Crisis?')
    #   # puts Cogibara.dump_memory
    #   Cogibara.dump_memory["structured_properties"].should_not be nil
    # end

    # it "creates structured properties" do
    #   msg = @cogi.ask('I live in Madison Wisconsin')
    #   original = msg.response_to
    #   prop = original.property_for(original.structured_properties[1])
    #   prop.values["spotlight_entity_uri"].should == "http://dbpedia.org/resource/Madison,_Wisconsin"
    #   prop.values["spotlight_types"]["DBpedia:City"].should_not be nil
    # end

    # describe "debug keywords" do
    #   it "can print all entities" do
    #     msg = @cogi_l.ask('spotlight entities for "I live in Madison Wisconsin"')
    #     msg['"spotlight_entity_uri"=>"http://dbpedia.org/resource/Madison,_Wisconsin"'].should_not be nil
    #   end

    #   it "can return just URIs" do
    #     msg = @cogi_l.ask('spotlight URIs for "I live in Madison Wisconsin"')
    #     eval(msg)["Madison Wisconsin"].should == "http://dbpedia.org/resource/Madison,_Wisconsin"
    #     # puts Cogibara.dump_memory
    #   end
    # end
  end

  describe Wit, :no_travis do
    # before do
    #   Wit.register(:pre)
    # end

    describe "raw output" do
      it {
        JSON.parse(@cogi_l.ask('wit debug "heyo hows it going"'))["outcome"]["intent"].should == "hello"
      }
    end

    describe "sets wit_intent properties" do
      it {
        @cogi_p.ask("heyo hows it going").response_to.get_wit_intent.should == "hello"
      }
    end
  end

  describe Gcal, :no_travis do
    describe "sets reminders" do
      it {
        @cogi_l.ask("remind me to feed the cat at 7:00pm").should == "okay, reminding you to feed the cat at 7:00 tonight"
      }
    end

    describe "select reminder method" do
      it {
        @cogi_l.ask("remind me via sms to feed the cat at 7:00pm").should == "okay, reminding you to feed the cat at 7:00 tonight"
      }
    end

    describe "wit integration" do
      it {
        @cogi_l.ask("can you remind me via sms to eat pudding at 8:00pm").should == "okay, reminding you to eat pudding at 8:00"
      }
    end
  end
end