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
      [1, 2, 3, 5, 8]
    end

    def estimates
      store._estimates.find(session: params._session)
    end

    def reset_round
      store._estimates.find(session: params._session).then do |estimates|
        estimates.each do |estimate|
          # nil won't work as it will be ignored and no update will
          # be triggered (somehow)
          estimate._point = false
        end
      end
    end

    def round_finished?
      estimates.all?(&:_point)
    end

    def set_point(point)
      self.model._point = point
    end

    # `SecureRandom.urlsafe_base64` is missing from opal
    def generate_random_string
      `Math.random().toString(36).substr(2)`
    end

    def card_image_url(point)
      "/assets/images/b_#{point}.jpg"
    end
  end
end
