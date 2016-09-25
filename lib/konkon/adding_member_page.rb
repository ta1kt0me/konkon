require 'konkon/session'

module Konkon
  class AddingMemberPage
    include Session

    attr_reader :url

    def initialize(group)
      @url = "https://manage.doorkeeper.jp/groups/#{group}/members/new"
    end

    def session
      @session ||= visit_first
    end

    def visit_first
      session = build_session
      session.visit(url)
      session.visit(url)
      session
    end
  end
end
