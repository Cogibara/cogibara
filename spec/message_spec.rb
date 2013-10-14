require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe Cogibara::Message, vcr: {record: :new_episodes} do

  before(:all) do
    @cogi = Cogibara::Interface::Local.new
    Cogibara::ModuleStack.clear
    Cogibara.load_base_modules
  end

  context "#structured_properties" do

    describe "dynamic methods for rdf predicates" do
      before do
        @msg = Cogibara::Memory.new_message("remind me via sms to fetch the mail tonight")
        @msg.entities()
      end

      it { @msg.structured_properties.first.rdf_type.should_not be nil}
    end

    describe "retrieve by rdf class" do
      before do
        @msg = Cogibara::Memory.new_message("remind me via sms to fetch the mail tonight")
        @msg.entities()
      end

      it { @msg.structured_properties("NamedEntity").first.should_not be nil}
    end

  end
end
