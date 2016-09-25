require 'thor'
require 'konkon/adding_member_page'

module Konkon
  class MemberCommand < Thor
    # Email list.sample
    # ```
    # foo@example.com
    # bar@example.com
    # ```
    desc 'import GROUP FILE', 'import user mailaddress(name <email>)'
    def import(group, file)
      validate_arguments group, file

      AddingMemberPage.register(
        group: group,
        members: File.open(file).each_with_object([]) { |line, result| result << line }
      )
    end

    private

    def validate_arguments(group, file)
      raise unless File.exist?(file) || !group.empty?
    end
  end
end
