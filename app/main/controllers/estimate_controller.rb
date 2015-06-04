# require 'stdlib/securerandom'
require 'securerandom'

module Main
  class EstimateController < Volt::ModelController
    model :store

    def index
    end

    def enter_session
      session = page._session.to_s.empty? ? generate_random_string : page._session
      user = page._user.to_s.empty? ? "user-#{generate_random_string}" : page._user

      # `redirect_to "/estimate/#{session}/#{user}"` somehow messes up
      # the page state and yields weird task errors.
      `window.location.href = '/estimate/' + session + '/' + user`
    end

    def show
      session = params._session
      user = params._user

      store._estimates.find(user: user).then do |estimates|
        estimates.reverse.each(&:destroy)
      end.then do
        store._estimates << {
          user: user,
          session: session
        }
      end.then do |estimate|
        self.model = estimate
      end
    end

    def available_points
      [1, 3, 5, 8]
    end

    def estimates
      result = nil

      store._estimates.find({
        session: params._session,
      }).then do |estimates|
        result = estimates
      end

      result || []
    end

    def round_finished?
      estimates.all?(&:_point)
    end

    def available_users
      store._estimates.find(session: params._session).then do |estimates|
        estimates.map(&:_user).join(', ')
      end
    end

    def set_point(point)
      self.model._point = point
    end

    # `SecureRandom.urlsafe_base64` is missing from opal
    def generate_random_string
      `Math.random().toString(36).substr(2)`
    end
  end
end
