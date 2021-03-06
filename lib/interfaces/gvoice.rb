module Cogibara
  module Interface
    class GVoice
      include Cogibara::Interface


        def fetch_messages
          api = @api
          json_data = api.messages_json()
          js = JSON.parse(json_data)
        end

        def poll
          msgs = fetch_messages
          childs =  msgs["messageList"].map{|m| m["children"]}.flatten
          to_me = childs.select{|m| m["type"] != 11 and m["phoneNumber"] != ""}

          if @read.size == 0
            to_me.each{|m| @read << m["id"]}
            []
          else
            unread = to_me.reject{|m| @read.include?(m["id"])}
            unread.each{|m| @read << m["id"]}
            unread
          end
        end

        def initialize
          @api = GoogleVoice::Api.new(Cogibara::Module.settings["keys"]["google_name"], Cogibara::Module.settings["keys"]["google_pass"])
          @read = []
          @start = Time.now
        end

        def cycle(sleeptime=60)
          loop do
            poll

            imap = Net::IMAP.new 'imap.gmail.com', ssl: true unless imap

            imap.login Cogibara::Module.settings["keys"]["google_name"], Cogibara::Module.settings["keys"]["google_pass"]
            imap.select "[Gmail]/All Mail"

            Thread.new do
              puts "Starting timer"
              sleep 29 * 60
              imap.idle_done
            end


            imap.idle do |resp|
              if resp.kind_of?(Net::IMAP::ContinuationRequest) and resp.data.text == 'idling'
                puts "Starting idle loop over"
              elsif resp.kind_of?(Net::IMAP::UntaggedResponse) and resp.name == 'EXISTS'
                msgs = poll

                puts "[#{Time.now.to_s}] got #{msgs.size}"
                msgs.each do |m|
                  reply = ask(m)
                  puts "(#{m["phoneNumber"]}) asked #{m["message"]}\n got #{reply.message}"
                  u = Cogibara::User.for(reply.to.to_s)
                  @api.sms(u.identifier, reply.message)
                end
              end
            end
          end
        end
      # end


      def ask(msg_json)
        response = ask_string(msg_json["message"], from: msg_json["phoneNumber"])
        response
      end

      def reply(msg)
        u = Cogibara::User.for(msg.to.to_s)
        @api.sms(u.identifier, reply.message)
      end
    end
  end
end