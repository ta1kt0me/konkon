require 'capybara/poltergeist'

module Konkon
  module Session
    def build_session
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(
          app,
          js_errors: false,
          timeout: 5000
        )
      end

      session = Capybara::Session.new(:poltergeist)
      session.driver.headers = {
        'User-Agent' => ENV['UA']
      }
      session.visit 'https://manage.doorkeeper.jp/'
      session.driver.set_cookie 'remember_user_token', ENV['REMEMBER_USER_TOKEN']
      session.driver.set_cookie 'usdksc', ENV['USDKSC']
      session
    end
  end
end
