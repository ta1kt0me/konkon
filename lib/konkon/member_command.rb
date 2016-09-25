require 'thor'
require 'capybara/poltergeist'
require 'konkon/session'

module Konkon
  class MemberCommand < Thor
    include Session

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
      session = build_session
      url = "https://manage.doorkeeper.jp/groups/#{group}/members/new"
      session.visit(url)
      session.visit(url)
      session
    end
  end
end
