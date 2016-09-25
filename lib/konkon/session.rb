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
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2564.97 Safari/537.36'
      }

      session.visit 'https://manage.doorkeeper.jp/'
      session.driver.set_cookie 'remember_user_token', ENV['REMEMBER_USER_TOKEN']
      session.driver.set_cookie 'usdksc', ENV['USDKSC']
      session
    end
  end
end
