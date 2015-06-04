module Main
  class EstimateController < Volt::ModelController
    model :store

    def index
      session_id = params._session_id
      user_id = params._user_id

      store._estimates.find(user_id: user_id).then do |estimates|
        estimates.reverse.each(&:destroy)
      end.then do
        store._estimates << {
          user_id: user_id,
          session_id: session_id
        }
      end.then do |estimate|
        self.model = estimate
      end
    end

    def available_points
      [1, 3, 5, 8]
    end

    def result
      store._estimates.find({
        session_id: params._session_id,
      }).then do |estimates|
        if estimates.all? { |x| x._point }
          estimates.map(&:_point).join(', ')
        else
          "not yet"
        end
      end
    end

    def set_estimate(point)
      self.model._point = point
    end
  end
end
