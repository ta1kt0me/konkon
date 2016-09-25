require 'thor'
require 'capybara/poltergeist'
require 'csv'

module Konkon
  class Attendee < Thor
    Register = Struct.new(:email, :ticket, :free)

    desc 'import GROUP EVENT_ID FILE', 'import user registration("email string","ticket string","free boolean")'
    def import(group, event_id, file)
      logger = Logger.new(STDOUT)
      validate_arguments group, event_id, file
      attendees = CSV.table(file)
      raise 'Mismatch csv header' unless validate_header(attendees.headers)
      attendees.each do |attendee|
        session = visit_first(group, event_id)

        session.check '入場無料' if attendee[:free].to_sym == :true

        if session.has_selector?('#new_admin_event_registration_ticket_type_id')
          session.select(attendee[:ticket], from: 'new_admin_event_registration[ticket_type_id]')
        end

        session.find(:css, '.select2-choice.select2-default').click
        session.find(:css, '#s2id_autogen1_search').click
        session.fill_in('s2id_autogen1_search', with: attendee[:email])
        if (elem = session.find(:css, '#select2-results-1 li')).text != '一致する結果が見つかりませんでした'
          elem.click
        else
          logger.info "#{attendee[:email]}: Fail to search address"
          next
        end

        session.click_button('追加')

        # check
        if session.has_css?('#DataTables_Table_0 tbody') && session.find(:css, '#DataTables_Table_0 tbody').text.match(attendee[:email])
          logger.info "#{attendee[:email]}: Success to purchase"
        else
          logger.info "#{attendee[:email]}: Fail to purchase"
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

    def visit_first(group, event_id)
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(
          app,
          js_errors: false,
          timeout: 5000
        )
      end

      session = Capybara::Session.new(:poltergeist)
      session.driver.headers = {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36'
      }

      session.visit 'https://manage.doorkeeper.jp/'
      session.driver.set_cookie 'remember_user_token', ENV['REMEMBER_USER_TOKEN']
      session.driver.set_cookie 'usdksc', ENV['USDKSC']
      url = "https://manage.doorkeeper.jp/groups/#{group}/events/#{event_id}/tickets/new"
      session.visit(url)
      # NOTE: need to visit twice, mystery
      session.visit(url)
      session
    end
  end
end
