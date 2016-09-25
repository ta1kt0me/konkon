module Konkon
  class Attendee
    attr_reader :ticket, :free, :email

    def initialize(params)
      @ticket = params[:ticket]
      @free = params[:free]
      @email = params[:email]
    end

    def free?
      free.to_sym == :true
    end
  end
end
