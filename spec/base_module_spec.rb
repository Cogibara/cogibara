require File.dirname(__FILE__) + '/spec_helper.rb'

describe Cogibara::Module do

  before(:all) do
    @cogi = Cogibara::Interface.new
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

    it { @cogi.ask_local('hello?').should ==  "?olleh" }
  end

  context "using the dsl" do
    describe "use on keyword and strings or regexps to define behavior" do
      class DiceRoller < Cogibara::Module
        on 'hello you' do
          "hai dere"
        end

        on %r{^I'm (.+)} do |name|
          "hi #{name}"
        end

        on(/roll me (\d+)d(\d+)/) do |number,size|
          number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
        end
      end

      before do
        DiceRoller.register
      end

      it { @cogi.ask_local('hello you').should ==  "hai dere" }
      it { @cogi.ask_local("I'm bill").should ==  "hi bill" }
      it { @cogi.ask_local("roll me 1d150").to_i.should > 0  }
      it { @cogi.ask_local("roll me 4d12").split("\n").size.should == 4 }
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


      it { @cogi.ask_local('hi').should ==  "K1 got your message" }
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

      it { @cogi.ask('hi').response_to.topics.first.should ==  "tests and stuff" }
    end

    describe "can set/get properties manually" do
      it {
        msg = @cogi.ask('hi')
        msg.set_cunkiness 1000
        msg.get_cunkiness.should == 1000
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

      it { @cogi.ask_local('hello you').should ==  "hehe... hello local" }
    end

  end

end