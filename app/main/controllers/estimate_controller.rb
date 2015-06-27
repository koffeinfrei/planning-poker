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
      user = unescape(params._user)

      store._estimates.find(user: user, session: session).then do |estimates|
        if estimates[0]
          estimates[0].tap { |estimate| estimate._point = false }
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
      session = page._session.to_s.empty? ? generate_random_string : page._session
      user = page._user.to_s.empty? ? "user-#{generate_random_string}" : page._user
      card_deck = page._card_deck

      # `redirect_to "/estimate/#{session}/#{user}"` somehow messes up
      # the page state and yields weird task errors.
      `window.location.href = '/estimate/' + session + '/' + card_deck + '/' + user`
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
      estimates.count > 1 && estimates.all?(&:_point)
    end

    def set_point(point)
      self.model._point = point
    end

    # `SecureRandom.urlsafe_base64` is missing from opal
    def generate_random_string
      `Math.random().toString(36).substr(2)`
    end

    # `URI.unescape` is missing from opal
    def unescape(value)
      `decodeURI(value)`
    end

    def card_image_url(point)
      "/assets/images/#{params._card_deck}_#{point}.png"
    end

    def card_deck_preview_image_url(deck)
      "/assets/images/#{deck}_joker.png"
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
