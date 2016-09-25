require 'konkon/attendee'
require 'konkon/session'

module Konkon
  class AttendingPage
    include Session

    attr_reader :attendee, :url, :logger

    def initialize(params)
      @url = "https://manage.doorkeeper.jp/groups/#{params[:group]}/events/#{params[:event_id]}/tickets/new"
      @attendee = Attendee.new(params[:attendee])
      @logger = Logger.new(STDOUT)
    end

    def register
      unless select_attendee
        logger.info "#{attendee.email}: Fail to search address"
        return
      end

      check_free
      select_ticket
      submit

      logger.info "#{attendee.email}: #{registered? ? 'Success' : 'Fail'} to purchase"
    end

    def session
      @session ||= visit_first
    end

    def check_free
      session.check '入場無料' if attendee.free?
    end

    def select_ticket
      if session.has_selector?('#new_admin_event_registration_ticket_type_id')
        session.select(attendee.ticket, from: 'new_admin_event_registration[ticket_type_id]')
      end
    end

    def select_attendee
      session.find(:css, '.select2-choice.select2-default').click
      session.find(:css, '#s2id_autogen1_search').click
      session.fill_in('s2id_autogen1_search', with: attendee.email)
      elem = session.find(:css, '#select2-results-1 li')
      if found_attendee?(elem)
        elem.click
        true
      else
        false
      end
    end

    def submit
      session.click_button('追加')
    end

    def registered?
      session.has_css?('#DataTables_Table_0 tbody') &&
        session.find(:css, '#DataTables_Table_0 tbody').text.match(attendee.email)
    end

    private

    def found_attendee?(elem)
      elem.text != '一致する結果が見つかりませんでした'
    end

    def visit_first
      session = build_session
      session.visit(url)
      # NOTE: need to visit twice, mystery
      session.visit(url)
      session
    end
  end
end
