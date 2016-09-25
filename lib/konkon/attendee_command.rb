require 'thor'
require 'csv'
require 'konkon/attending_page'

module Konkon
  class AttendeeCommand < Thor
    # CSV.sample
    # ```
    # "email","ticket","free"
    # "bar@example.com","Normal Price", "true"
    # "foo@example.com","Cheap Price", "false"
    # ```
    desc 'import GROUP EVENT_ID FILE', 'import user registration("email string","ticket string","free boolean")'
    def import(group, event_id, file)
      validate_arguments group, event_id, file
      records = CSV.table(file)
      raise 'Mismatch csv header' unless validate_header(records.headers)
      records.each do |record|
        AttendingPage.register(
          group: group,
          event_id: event_id,
          attendee: {
            free: record[:free],
            ticket: record[:ticket],
            email: record[:email]
          }
        )
      end
    end

    private

    def validate_arguments(group, event_id, file)
      raise unless File.exist?(file) || !group.empty? || !event_id.empty?
    end

    def validate_header(headers)
      headers == [:email, :ticket, :free]
    end
  end
end
