require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara do

  before(:all) do
    @cogi = Cogibara::Interface.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  describe "defaults to chatting" do
      # puts "hello?"
      it { VCR.use_cassette('chatbot') { @cogi.ask_local('hello?').should ==  "How are you?" } }

      it { VCR.use_cassette('chatbot') { @cogi.ask_local('Who are you').should == "How are you?" } }

  end

  it "can return raw question objects" do
    VCR.use_cassette('chatbot') do
      msg = @cogi.ask('hello?',from: "wstrinz@gmail.com")
      msg.to.should == "wstrinz@gmail.com"
      msg.from.should == "cogibara"
      original = msg.response_to
      original.response.subject.should == msg.subject
    end
  end

  it "has a memory" do
    VCR.use_cassette('chatbot') do
      # puts Cogibara.dump_memory
      Cogibara.dump_memory["How are you?"].should_not be nil
    end
  end

  it "can send xmpp response" do
    VCR.use_cassette('chatbot') do
      msg = Blather::Stanza::Message.new
      msg.body = "hello?"
      msg.type = :chat
      msg.id = 1234
      @cogi.ask_xmpp(msg).should == "How are you?"
    end
  end

end
