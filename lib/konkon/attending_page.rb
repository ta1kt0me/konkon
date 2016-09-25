require 'konkon/attendee'
require 'konkon/session'

module Konkon
  class AttendingPage
    include Session

    attr_reader :attendee, :url

    def initialize(params)
      @url = "https://manage.doorkeeper.jp/groups/#{params[:group]}/events/#{params[:event_id]}/tickets/new"
      @attendee = Attendee.new(params[:attendee])
    end

    def visit_first
      session = build_session
      session.visit(url)
      # NOTE: need to visit twice, mystery
      session.visit(url)
      session
    end
  end
end
