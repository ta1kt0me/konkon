require 'thor'
require 'capybara/poltergeist'
require 'csv'
require 'konkon/session'
require 'konkon/attending_page'
require 'konkon/attendee'

module Konkon
  class AttendeeCommand < Thor
    desc 'import GROUP EVENT_ID FILE', 'import user registration("email string","ticket string","free boolean")'
    def import(group, event_id, file)
      logger = Logger.new(STDOUT)
      validate_arguments group, event_id, file
      records = CSV.table(file)
      raise 'Mismatch csv header' unless validate_header(records.headers)
      records.each do |record|
        page = AttendingPage.new(
          group: group,
          event_id: event_id,
          attendee: {
            free: record[:free],
            ticket: record[:ticket],
            email: record[:email]
          }
        )
        attendee = page.attendee

        page.check_free
        page.select_ticket

        unless page.select_attendee
          logger.info "#{attendee.email}: Fail to search address"
          next
        end

        page.submit

        # check
        if page.registered?
          logger.info "#{attendee.email}: Success to purchase"
        else
          logger.info "#{attendee.email}: Fail to purchase"
        end
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
