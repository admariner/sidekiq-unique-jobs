# frozen_string_literal: true

module SidekiqUniqueJobs
  #
  # Class NotificationCollection provides a collection with known notifications
  #
  # @author Mikael Henriksson <mikael@mhenrixon.com>
  #
  class NotificationCollection
    #
    # @return [Array<Symbol>] list of notifications
    NOTIFICATIONS = [:unlock_failed, :execution_failed, :error, :timeout, :duplicate].freeze

    #
    # @return [Hash<Symbol, String>] a hash with deprecated notifications
    DEPRECATIONS = {}.freeze

    NOTIFICATIONS.each do |notification|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{notification}(*args, &block)                          # def unlock_failed(*args, &block)
          raise NoBlockGiven, "block required" unless block_given?  #   raise NoBlockGiven, "block required" unless block_given?
          @notifications[:#{notification}] = block                  #   @notifications[:unlock_failed] = block
        end                                                         # end
      RUBY
    end

    def initialize
      @notifications = {}
    end

    def dispatch(notification, *args)
      block = @notifications[notification]

      if block
        block.call(*args)

        if DEPRECATIONS.key?(notification)
          replacement, removal_version = DEPRECATIONS[notification]
          SidekiqUniqueJobs::Deprecation.warn(
            "#{notification} is deprecated and will be removed in version #{removal_version}. Use #{replacement} instead.",
          )
        end
      elsif !NOTIFICATIONS.include?(notification)
        raise NoSuchNotificationError, notification
      end
    end
  end
end
