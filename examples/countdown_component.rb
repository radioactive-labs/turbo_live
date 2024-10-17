class CountdownComponent < TurboLive::Component
  state :countdown, Integer

  def view
    div do
      if countdown.nil?
        button(**on(click: :start)) { "Start!" }
      else
        h1 { countdown }
        every(1000, :countdown) if countdown >= 1
      end
    end
  end

  def update(input)
    case input
    in :countdown
      self.countdown -= 1
    in :start
      self.countdown = 1000
    end
  end
end
