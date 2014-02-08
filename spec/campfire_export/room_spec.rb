require 'campfire_export'
require 'campfire_export/timezone'

require 'nokogiri'

module CampfireExport
  describe Room do
    include TimeZone

    before :each do
      doc = Nokogiri::XML "<room><name>Test Room</name><id>666</id>" +
        "<created-at>2009-11-17T19:41:38Z</created-at></room>"
      @room_xml = doc.xpath('/room')
      Account.timezone = find_tzinfo("America/Los_Angeles")
    end

    context "when it is created" do
      let(:room) { Room.new(@room_xml) }

      it "sets up basic properties" do
        room.name.should == "Test Room"
        room.id.should   == "666"
        room.created_at.should == DateTime.parse("2009-11-17T11:41:38Z")
      end
    end
  end
end
