require 'thor'
require 'capybara/poltergeist'

module Konkon
  class Member < Thor
    desc 'import GROUP FILE', 'import user mailaddress(name <email>)'
    option :output, type: :string, aliases: '-o', desc: 'Output file'
    def import(group, file)
      validate_arguments group, file

      members = File.open(file).each_with_object([]) { |line, result| result << line }
      session = visit_first(group)
      session.fill_in 'new_members_email', with: members.join("\n")
      session.click_button('メールアドレスをチェック')

      session.click_button('を追加')
      output(members.map { |s| s.match(/<(?<email>.*@.*)>/)[:email] }, options[:output]) if options[:output]
    end

    private

    def validate_arguments(group, file)
      raise unless File.exist?(file) || !group.empty?
    end

    def output(emails, file)
      File.write("./tmp/#{file}", emails.join("\n"))
    end

    def visit_first(group)
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

      url = "https://manage.doorkeeper.jp/groups/#{group}/members/new"
      session.visit(url)
      session.visit(url)
      session
    end
  end
end
