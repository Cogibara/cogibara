# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )

end

DaemonKit::XMPP.run do
  # when_ready { DaemonKit.logger.info "Connected as #{jid}" }

  ## Enables file transfer (when_ready appears to be broken...)
    # set_caps(
    #   "arthur@wonderland.lit",
    #   [{:type => "bot", :category => "client", :name => "arthur"}],
    #   [
    #   # In-band bytestreams: http://xmpp.org/extensions/xep-0047.html
    #   "http://jabber.org/protocol/ibb",

    #   # SOCKS5 Bytestreams: http://xmpp.org/extensions/xep-0065.html
    #   "http://jabber.org/protocol/bytestreams",

    #   # SI File Transfer: http://xmpp.org/extensions/xep-0096.html
    #   "http://jabber.org/protocol/si",

    #   # Namespace of stream initiation profile (specified in 0096)
    #   "http://jabber.org/protocol/si/profile/file-transfer",
    #   ]
    # )
    # DaemonKit.logger.info "Connected to #{client.jid}. Sent capabilities:"
    # Thread.new do
    #   sleep(3)
    #   send_caps
    #   set_status(state = nil, msg = 'I dream of electric sheep')

    #   DaemonKit.logger.info "Connected as #{jid}"
    # end

  client.register_handler :file_transfer do |iq|
      transfer = Blather::FileTransfer.new(client, iq)

      fname = BASE_DIR + "/dl_files/#{iq.si.file['name']}"
      transfer.accept(
        Blather::FileTransfer::SimpleFileReceiver,
        fname,  # destination path
        iq.si.file["size"].to_i,
      )


      DaemonKit.logger.info "Receiving file from #{iq.from}"
      Thread.new do
        sleep(5)
        DaemonKit.logger.info IO.read(fname)
      end
  end

  # Auto approve subscription requests
  subscription :request? do |s|
    write_to_stream s.approve!
  end

  message :chat?, :body do |m|
    repl = m.reply
    repl.body = Cogibara::Interface::XMPP.new.ask(m)
    write_to_stream repl
  end
end