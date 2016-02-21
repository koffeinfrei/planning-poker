require 'main/lib/uri'
require 'main/lib/secure_random'

module Main
  class EstimateController < Volt::ModelController
    model :store

    def index
      # the routing doesn't support redirects yet
      redirect_to '/estimate' if url.path == '/'

      random_index = rand(available_card_decks.length)
      set_card_deck(available_card_decks[random_index])

      page._session = params._session
    end

    def show
      page._session_url = url.url_with(user: nil, card_deck: nil)

      # guest user doesn't need more setup
      return if params._user == 'guest'

      session = params._session
      user = URI.unescape(params._user)

      store._estimates.find(user: user, session: session).then do |estimates|
        estimate = estimates.array[0]
        if estimate
          estimate.tap { |e| e._point = false }
        else
          store._estimates << {
            user: user,
            session: session
          }
        end
      end.then do |estimate|
        self.model = estimate
      end
    end

    private

    def enter_session
      session = page._session.to_s.empty? ? SecureRandom.urlsafe_base64 : page._session
      user = page._user.to_s.empty? ? "user-#{SecureRandom.urlsafe_base64(8)}" : page._user
      card_deck = page._card_deck

      redirect_to "/estimate/#{session}/#{card_deck}/#{user}"
    end

    def enter_guest_session
      page._user = 'guest'
      enter_session
    end

    def available_points
      [1, 2, 3, 5, 8]
    end

    def estimates
      store._estimates.find(session: params._session)
    end

    def reset_round
      # we need this for the flip card animation to go smoothly.
      # without this the `model._point` is cleared and the card image is
      # hidden before the flip animation is done.
      page._last_estimate_point = model._point

      store._estimates.find(session: params._session).then do |estimates|
        estimates.each do |estimate|
          # nil won't work as it will be ignored and no update will
          # be triggered (somehow)
          estimate._point = false
        end
      end
    end

    def round_finished?
      estimates_array = estimates.array
      estimates_array.size > 1 && estimates_array.all?(&:_point)
    end

    def set_point(point)
      self.model._point = point
    end

    # TODO replace this by sprockets
    def card_image_url(point)
      "/app/main/assets/images/#{params._card_deck}_#{point}.png"
    end

    # TODO replace this by sprockets
    def card_deck_preview_image_url(deck)
      "/app/main/assets/images/#{deck}_joker.png"
    end

    def available_card_decks
      ('a'..'f').to_a
    end

    def set_card_deck(deck)
      page._card_deck = deck
    end

    def guest_session?
      params._user == 'guest'
    end
  end
end
