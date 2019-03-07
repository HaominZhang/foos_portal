module MeetingRoom
  class ResponseRetriever
    FLOOR_MAP_URL = 'https://wpsvc5.com/ESASSO026/'.freeze
    private_constant :FLOOR_MAP_URL

    def self.retrieve(original_request_text)
      request = original_request_text.gsub(' ', '').downcase

      case request
      when 'map'
        return FLOOR_MAP_URL
      when 'list'
        rooms = MeetingRoomDirection.all.map do |room|
          "#{room.id}. #{room.room_name}"
        end.join("\n")

        response = <<-list
        ```
          #{rooms}
        ```
        list

        return response
      when 'help'
        response = <<-help
        ```
          /meetingroom Camino --> direction how to go to meeting room Camino
          /meetingroom map    --> show floor plan map
          /meetingroom list   --> show all meeting rooms name
        ```
        help

        return response
      else
        data = MeetingRoomDirection.where(room_name: request).first
        if data.present?
          notes = data.notes.present? ? " *Notes:* #{data.notes}" : ''
          response = "#{original_request_text} - #{data.direction}#{notes} #{data.image}"
          return response
        else
          return 'Sorry, room not found.'
        end
      end
    end
  end
end