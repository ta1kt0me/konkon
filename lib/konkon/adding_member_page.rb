require 'konkon/session'

module Konkon
  class AddingMemberPage
    include Session

    attr_reader :url, :members

    def initialize(params)
      @url = "https://manage.doorkeeper.jp/groups/#{params[:group]}/members/new"
      @members = params[:members]
    end

    def self.register(params)
      new(params).register
    end

    def register
      fill_members
      check_members
      submit
      sleep members.size * 1
    end

    private

    def fill_members
      # TODO: if name & emil
      session.fill_in 'new_members_email', with: members.join("\n")
    end

    def check_members
      session.click_button('メールアドレスをチェック')
    end

    def submit
      session.click_button('を追加')
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
