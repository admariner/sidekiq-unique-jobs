# frozen_string_literal: true

module SidekiqUniqueJobs
  #
  # Module Notifiable provides a method to notify subscribers
  #
  # @author Mikael Henriksson <mikael@mhenrixon.com>
  #
  module Notifiable
    def notify(name, *args)
      SidekiqUniqueJobs.notification_stack.dispatch(name, *args)
      nil
    rescue StandardError => ex
      SidekiqUniqueJobs.logger.error(ex)
    end
  end
end
