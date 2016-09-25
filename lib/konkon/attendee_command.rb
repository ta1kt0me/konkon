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

        session = page.visit_first

        session.check '入場無料' if attendee.free?

        if session.has_selector?('#new_admin_event_registration_ticket_type_id')
          session.select(attendee.ticket, from: 'new_admin_event_registration[ticket_type_id]')
        end

        session.find(:css, '.select2-choice.select2-default').click
        session.find(:css, '#s2id_autogen1_search').click
        session.fill_in('s2id_autogen1_search', with: attendee.email)
        if (elem = session.find(:css, '#select2-results-1 li')).text != '一致する結果が見つかりませんでした'
          elem.click
        else
          logger.info "#{attendee.email}: Fail to search address"
          next
        end

        session.click_button('追加')

        # check
        if session.has_css?('#DataTables_Table_0 tbody') && session.find(:css, '#DataTables_Table_0 tbody').text.match(attendee.email)
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
