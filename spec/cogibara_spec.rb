require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi = Cogibara::Interface.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  describe "defaults to chatting" do
      # puts "hello?"
      it { @cogi.ask_local('hello?').should ==  "How are you?" }

      it { @cogi.ask_local('Who are you').should == "How are you?" }

  end

  it "can return raw question objects" do

      msg = @cogi.ask('hello?',from: "wstrinz@gmail.com")
      msg.to.should == "wstrinz@gmail.com"
      msg.from.should == "cogibara"
      original = msg.response_to
      original.response.subject.should == msg.subject

  end

  it "has a memory" do
      Cogibara.dump_memory["hello?"].should_not be nil
  end

  it "can send xmpp response" do

      msg = Blather::Stanza::Message.new
      msg.body = "hello?"
      msg.type = :chat
      msg.id = 1234
      @cogi.ask_xmpp(msg).should == "Hi."

  end

  it "can save memory" do

      msg = @cogi.ask('hello?',from: "wstrinz@gmail.com")
      Cogibara.export_memory('resource/example_memory.ttl')
      RDF::Repository.load('resource/example_memory.ttl').size.should == Cogibara.base_cogi.memory.repo.size

  end

  it "can load memory" do

      msg = @cogi.ask('hello?',from: "wstrinz@gmail.com")
      Cogibara.import_memory('resource/example_memory.ttl')

  end

  it "can query messages" do
    Cogibara::Message.where(message_string: 'hello?').size.should >= 3
  end

end
