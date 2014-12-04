require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi_l = Cogibara::Interface::Local.new
    @cogi_x = Cogibara::Interface::XMPP.new
    @cogi_p = Class.new { include Cogibara::Interface }.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  describe "defaults to chatting" do
    # puts "hello?"
    it { expect(@cogi_l.ask('hello?')).to eq("Do you have time to talk?") }

    it { expect(@cogi_l.ask('Who are you')).to eq("Do you have time to talk?") }
  end

  it "can return raw question objects" do

    msg = @cogi_p.ask('hello?',from: "wstrinz@gmail.com")
    expect(msg.to.to_s).to eq("http://cogi.strinz.me/users/wstrinz%40gmail.com")
    # msg.from.should == "cogibara"
    expect(msg.from).to eq("http://cogi.strinz.me/users/cogibara")

    original = msg.response_to
    expect(original.response.subject).to eq(msg.subject)

  end

  it "has a memory" do
    expect(Cogibara.dump_memory["hello?"]).not_to be nil
  end

  it "can send xmpp response" do
    msg = Blather::Stanza::Message.new
    msg.body = "hello?"
    msg.type = :chat
    msg.id = 1234
    expect(@cogi_x.ask(msg)).to eq("What are you doing?")
  end

  it "can save memory" do
    @cogi_p.ask('hello?',from: "wstrinz@gmail.com")
    Cogibara.export_memory('resource/example_memory.ttl')
    expect(RDF::Repository.load('resource/example_memory.ttl').size).to eq(Cogibara.base_cogi.memory.repo.size)
  end

  it "can load memory" do
    @cogi_p.ask('hello?',from: "wstrinz@gmail.com")
    Cogibara.import_memory('resource/example_memory.ttl')
  end

  it "can query messages" do
    expect(Cogibara::Message.where(message_string: 'hello?').size).to be >= 3
  end
end
