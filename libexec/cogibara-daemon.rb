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