class CounterComponent < TurboLive::Component
  state :count, Integer do |value|
    value || 0
  end

  def view
    div do
      button(**on(click: :increment)) { "+" }
      span { " Clicked: #{count} " }
      button(**on(click: :decrement)) { "-" }
      plain " "
      button(**on(click: :reset)) { "Reset" }
    end
  end

  def update(input)
    case input
    in [:decrement]
      self.count -= 1
    in [:increment]
      self.count += 1
    in [:reset]
      self.count = 0
    end
  end
end
