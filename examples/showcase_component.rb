class ShowcaseComponent < TurboLive::Component
  state :component, Symbol do |value|
    value || :counter
  end

  def view
    div class: "container" do
      div class: "left-column" do
        h2 { "Components" }
        ul do
          li { button(**on(click: [:change_component, :counter])) { "Counter" } }
          li { button(**on(click: [:change_component, :countdown])) { "Countdown" } }
          li { button(**on(click: [:change_component, :tic_tac_toe])) { "TicTacToe" } }
          li { button(**on(click: [:change_component, :flappy_bird])) { "Flappy Bird" } }
        end
      end
      div class: "right-column" do
        div class: "card" do
          render selected_component.new
        end
      end
    end
  end

  def update(input)
    case input
    in [[:change_component, component]]
      self.component = component
    end
  end

  private

  def selected_component
    case component
    when :counter
      CounterComponent
    when :countdown
      CountdownComponent
    when :tic_tac_toe
      TicTacToeComponent
    when :flappy_bird
      FlappyBirdComponent
    end
  end
end
