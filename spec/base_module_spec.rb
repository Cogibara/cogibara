require File.dirname(__FILE__) + '/spec_helper.rb'

describe Cogibara::Module, vcr: { record: :new_episodes } do

  before(:all) do
    @cogi_l = Cogibara::Interface::Local.new
    @cogi_x = Cogibara::Interface::XMPP.new
    @cogi_p = Class.new { include Cogibara::Interface }.new
  end

  context "overriding ask method" do
    class Reverser < Cogibara::Module
      def ask(msg)
        msg.message.reverse
      end
    end

    before do
      Reverser.register
    end

    it { @cogi_l.ask('hello?').should ==  "?olleh" }
  end

  context "using the dsl", vcr: { record: :new_episodes } do
    describe "use on keyword and strings or regexps to define behavior" do
      class DiceRoller < Cogibara::Module
        on 'hello you' do
          "hai dere"
        end

        on %r{^I'm (.+)} do |message, name|
          "hi #{name}"
        end

        on(/roll me (\d+)d(\d+)/) do |message, number, size|
          number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
        end
      end

      before do
        DiceRoller.register
      end

      it { @cogi_l.ask('hello you').should ==  "hai dere" }
      it { @cogi_l.ask("I'm bill").should ==  "hi bill" }
      it { @cogi_l.ask("roll me 1d150").to_i.should > 0  }
      it { @cogi_l.ask("roll me 4d12").split("\n").size.should == 4 }
    end



    describe "specify order with categories" do


      class K1 < Cogibara::Module
        on 'hi' do
          "K1 got your message"
        end
      end

      class K2 < Cogibara::Module
        on 'hi' do
          "K2 got your message"
        end
      end

      before do
        K1.register
        K2.register :last
      end


      it { @cogi_l.ask('hi').should ==  "K1 got your message" }
    end

    describe "add topics" do
      class Topicizer < Cogibara::Module
        on(/.*/) do
          current_message.topics << 'tests and stuff'
        end
      end

      before do
        Topicizer.register :classify
      end

      it { @cogi_p.ask('hi').response_to.topics.first.should ==  "tests and stuff" }
    end

    describe "can set/get properties manually" do
        before do
          @msg = @cogi_p.ask('hi')
        end

        it {
          @msg.set_cunkiness 1000
          @msg.get_cunkiness.should == 1000
        }
    end

    describe "can still access the raw message" do
      class CreepyGreeter < Cogibara::Module
        on(/.*/) do
          "hehe... hello #{current_message.from}"
        end
      end

      before do
        CreepyGreeter.register
      end

      it { @cogi_l.ask('hello you').should ==  "hehe... hello local" }
    end

    describe "can order response handlers" do
      class OrderKlass < Cogibara::Module
        on do
          "do say this"
        end

        on do
          "don't say this"
        end
      end

      before do
        OrderKlass.register
      end

      it { @cogi_l.ask('testing').should == "do say this"}
    end

    describe "can restrict on arbitrary properties" do
      class AlarmSetter < Cogibara::Module
        on(/.*/, maluuba_action: "ALARM_SET") do
          "set an alarm"
        end

        on(/.*/, maluuba_action: "ALARM_CANCEL") do
          "cancel an alarm"
        end

        on do
          "not an alarm"
        end
      end

      before do
        AlarmSetter.register
      end

      it { @cogi_l.ask('testing').should == "not an alarm" }
      it { @cogi_l.ask('set me an alarm for 8am tomorrow').should == "set an alarm"}
      it { @cogi_l.ask('cancel my 8am alarm').should == "cancel an alarm" }
    end

    describe "use filter helper for more complex filtering" do
      class PersonLookup < Cogibara::Module
        on(/.*/, maluuba_action: "CONTACT_SEARCH") do
          filter do |msg|
            msg.message["who"]
          end

          "looking up a person"
        end

        on do
          # puts current_message.get_maluuba_action
          "you have to say 'who'"
        end
      end

      before do
        PersonLookup.register
      end

      it {@cogi_l.ask('who is Johnny Habu?').should == "looking up a person" }
      it {@cogi_l.ask('show me Johnny Habus contact info').should == "you have to say 'who'" }
    end

    describe "can interact with user" do
      class Namer < Cogibara::Module
        on(/hello/) do
          name = request_input "what's your name?"
          "hi #{name}! :D"
        end

        on(/hi/) do
          say "hey, this is a intermediate response"
          "and this is the final one"
        end

      end

      before do
        Namer.register
        @cogi_l.stub(:gets).and_return('bob')
        @cogi_l.stub(:puts)
      end

      it {@cogi_l.ask('hello').should == "hi bob! :D"}
      it {@cogi_l.ask('hi').should == "and this is the final one"}
    end

  end

end