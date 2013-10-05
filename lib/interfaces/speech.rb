module Cogibara
  module Interface
    class Speech
      include Cogibara::Interface

      def record
        # fp = 'spec/resource/audio_test.flac'
        # open(fp,'rb').read
        `AUDIODEV=hw:1 sox -d --norm -t .flac - silence -l 1 0 1% 1 6.0 1% rate 16k`
      end

      def recognize(recording)
        r = RestClient.post 'https://www.google.com/speech-api/v1/recognize?lang=en-US', recording,
                            :content_type => 'audio/x-flac; rate=16000'
        if j = JSON.parse(r)
          j['hypotheses'].first['utterance']
        end
      end

      def cycle
        @active ||= false
        loop do
          if @active
            msg = recognize(record)
            puts "asking #{msg}"
            response = ask(msg)
            puts "from cogi #{response}"
            `AUDIODEV=hw:0 espeak '#{response}'`
          else
            puts "still sleeping..."
            msg = recognize(record)
            puts "got #{msg}"
            # if msg == "at NEC need for international managers will keep rising"
            if msg == "wake up"
              @active = true
              `AUDIODEV=hw:0 espeak 'waking up'`
            end
          end
        end
      end

      # eventually move audio processing to here?
      def ask(str)
        ask_string(str, from: 'local-speech').message
      end
    end
  end
end