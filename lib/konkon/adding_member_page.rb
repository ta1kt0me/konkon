require 'konkon/session'

module Konkon
  class AddingMemberPage
    include Session

    attr_reader :url, :members

    def initialize(params)
      @url = "https://manage.doorkeeper.jp/groups/#{params[:group]}/members/new"
      @members = params[:members]
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
