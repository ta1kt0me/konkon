require 'konkon/attendee'

module Konkon
  class AttendingPage
    attr_reader :attendee, :url

    def initialize(params)
      @url = "https://manage.doorkeeper.jp/groups/#{params[:group]}/events/#{params[:event_id]}/tickets/new"
      @attendee = Attendee.new(params[:attendee])
    end
  end
end
