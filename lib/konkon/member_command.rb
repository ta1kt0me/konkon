require 'thor'
require 'konkon/adding_member_page'

module Konkon
  class MemberCommand < Thor
    desc 'import GROUP FILE', 'import user mailaddress(name <email>)'
    option :output, type: :string, aliases: '-o', desc: 'Output file'
    def import(group, file)
      validate_arguments group, file

      page = AddingMemberPage.new(
        group: group,
        members: File.open(file).each_with_object([]) { |line, result| result << line }
      )
      page.fill_members
      page.check_members
      page.submit

      output(page.members, options[:output]) if options[:output]
    end

    private

    def validate_arguments(group, file)
      raise unless File.exist?(file) || !group.empty?
    end

    def output(members, file)
      emails = members.map { |s| s.match(/<(?<email>.*@.*)>/)[:email] }
      File.write("./tmp/#{file}", emails.join("\n"))
    end
  end
end
