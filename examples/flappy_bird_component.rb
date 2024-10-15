class FlappyBirdComponent < TurboLive::Component
  GRAVITY = 0.5
  JUMP_STRENGTH = -10.0
  GAME_HEIGHT = 400
  GAME_WIDTH = 300
  BIRD_SIZE = 20
  OBSTACLE_WIDTH = 50
  GAP_HEIGHT = 100
  OBSTACLE_SPEED = 2

  state :bird_y, Float do |value|
    value || 150.0
  end

  state :bird_velocity, Float do |value|
    value || 0.0
  end

  state :obstacles, Array do |value|
    value || []
  end

  state :score, Integer do |value|
    value || 0
  end

  state :game_over, _Boolean

  state :nonce, Integer do |value|
    value || 0
  end

  NONCES = {}

  def initialize(...)
    super
    NONCES[live_id] ||= 0
  end

  def view
    div(class: "flappy-bird-game") do
      render_game
      render_controls
    end
  end

  def render_game
    svg(viewBox: "0 0 #{GAME_WIDTH} #{GAME_HEIGHT}", width: GAME_WIDTH, height: GAME_HEIGHT) do |svg|
      # Render bird
      svg.circle(cx: 50, cy: bird_y, r: BIRD_SIZE / 2, fill: "yellow")

      # Render obstacles
      obstacles.each do |obstacle|
        svg.rect(x: obstacle[:x], y: 0, width: OBSTACLE_WIDTH, height: obstacle[:top], fill: "green")
        svg.rect(x: obstacle[:x], y: obstacle[:bottom], width: OBSTACLE_WIDTH, height: GAME_HEIGHT - obstacle[:bottom], fill: "green")
      end

      # Render score
      svg.text(x: 10, y: 30, fill: "white", "font-size": "20px") { score.to_s }

      # Render game over message
      if game_over
        svg.text(x: GAME_WIDTH / 2, y: GAME_HEIGHT / 2, fill: "red", "font-size": "30px", "text-anchor": "middle") { "Game Over" }
      else
        every(1000 / 30.0, :tick)
      end
    end
  end

  def render_controls
    div(class: "controls") do
      button(**on(click: :jump)) { "Jump / Restart" }
    end
  end

  def update(input)
    case input
    in [:jump]
      if game_over
        reset_game
      else
        self.nonce = NONCES[live_id] = NONCES[live_id] + 1
        self.bird_velocity = JUMP_STRENGTH
      end
    in [:tick]
      norender! if nonce < NONCES[live_id]
      update_game_state
    end
  end

  private

  def update_game_state
    return if game_over

    # Update bird position
    self.bird_velocity += GRAVITY
    self.bird_y += bird_velocity

    # Add new obstacles
    if obstacles.empty? || obstacles.last[:x] < GAME_WIDTH - 200
      add_obstacle
    end

    # Update obstacle positions
    self.obstacles = obstacles.map do |obstacle|
      obstacle[:x] -= OBSTACLE_SPEED
      obstacle
    end.reject { |obstacle| obstacle[:x] < -OBSTACLE_WIDTH }

    # Check collisions
    check_collisions

    # Update score
    self.score += 1 if obstacles.any? { |obstacle| obstacle[:x] == 48 }  # Bird's x position is 50, width is 20
  end

  def add_obstacle
    gap_start = rand(50..(GAME_HEIGHT - GAP_HEIGHT - 50))
    obstacles << {x: GAME_WIDTH, top: gap_start, bottom: gap_start + GAP_HEIGHT}
  end

  def check_collisions
    if bird_y < 0 || bird_y > GAME_HEIGHT
      self.game_over = true
    end

    obstacles.each do |obstacle|
      if (obstacle[:x] < 70 && obstacle[:x] > 30) &&
          (bird_y < obstacle[:top] + BIRD_SIZE / 2 || bird_y > obstacle[:bottom] - BIRD_SIZE / 2)
        self.game_over = true
      end
    end
  end

  def reset_game
    self.bird_y = 150.0
    self.bird_velocity = 0.0
    self.obstacles = []
    self.score = 0
    self.game_over = false
  end
end
