class EvNote < Cogibara::Module
  requires 'evernote_oauth'

  requires_key 'evernote'

  def make_remind(message, minutes = 3)
    note = Evernote::EDAM::Type::Note.new
    note.title = "#{message}"
    note.content = '<?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
    <en-note>Hello, World</en-note>'

    now_time = Time.now.to_i * 1000
    then_time = now_time + 60000 * minutes # minutes after `now`

    # init NoteAttributes instance
    note.attributes = Evernote::EDAM::Type::NoteAttributes.new
    note.attributes.reminderOrder = now_time
    note.attributes.reminderTime = then_time

    createdNote = note_store.createNote(note)

    # puts "Note created with GUID: #{createdNote.guid}"

    # Optionally mark the note as "done" by setting reminderDoneTime

    createdNote.attributes.reminderDoneTime = Time.now.to_i
  end

  def note_store
    @token ||= settings["keys"]["evernote"]
    @note_store ||= EvernoteOAuth::Client.new(token: @token).note_store
  end

  on(/^remind me to (.*) at (.*)(am|pm)/i) do |msg, reminder, time, day_night|
    make_remind(reminder)
    t = " tonight" if day_night == "pm"
    "okay, reminding you to #{reminder} at #{time}#{t}"
  end

  register
end