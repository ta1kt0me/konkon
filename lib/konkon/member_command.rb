require 'thor'
require 'konkon/adding_member_page'

module Konkon
  class MemberCommand < Thor
    desc 'import GROUP FILE', 'import user mailaddress(name <email>)'
    option :output, type: :string, aliases: '-o', desc: 'Output file'
    def import(group, file)
      validate_arguments group, file

      members = File.open(file).each_with_object([]) { |line, result| result << line }
      page = AddingMemberPage.new(group: group, members: members)
      page.fill_members
      page.check_members
      page.submit

      output(members.map { |s| s.match(/<(?<email>.*@.*)>/)[:email] }, options[:output]) if options[:output]
    end

    private

    def validate_arguments(group, file)
      raise unless File.exist?(file) || !group.empty?
    end

    def output(emails, file)
      File.write("./tmp/#{file}", emails.join("\n"))
    end
  end
end
