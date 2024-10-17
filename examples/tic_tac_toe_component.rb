class TicTacToeComponent < TurboLive::Component
  state :board, Array do |value|
    value || Array.new(9, nil)
  end

  state :current_player, String do |value|
    value || "X"
  end

  state :winner, String do |value|
    value || nil
  end

  def view
    div(class: "tic-tac-toe-container") do
      render_board
      render_status
      render_reset_button
    end
  end

  def render_board
    div(class: "board") do
      board.each_with_index do |cell, index|
        button(
          class: "cell",
          **on(click: [:make_move, index]),
          disabled: cell || winner,
          "data-value": cell
        ) { cell || "&nbsp;".html_safe }
      end
    end
  end

  def render_status
    div(class: "status") do
      if winner
        "Winner: #{winner}"
      elsif board.compact.length == 9
        "It's a draw!"
      else
        "Current player: #{current_player}"
      end
    end
  end

  def render_reset_button
    button(**on(click: :reset_game)) { "Reset Game" }
  end

  def update(input)
    case input
    in [:make_move, index]
      make_move(index)
    in :reset_game
      reset_game
    end
  end

  private

  def make_move(index)
    return if board[index] || winner

    new_board = board.dup
    new_board[index] = current_player
    self.board = new_board
    self.winner = check_winner
    self.current_player = (current_player == "X") ? "O" : "X" unless winner
  end

  def check_winner
    winning_combinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], # Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], # Columns
      [0, 4, 8], [2, 4, 6]             # Diagonals
    ]

    winning_combinations.each do |combo|
      if board[combo[0]] && board[combo[0]] == board[combo[1]] && board[combo[0]] == board[combo[2]]
        return board[combo[0]]
      end
    end

    nil
  end

  def reset_game
    self.board = Array.new(9, nil)
    self.current_player = "X"
    self.winner = nil
  end
end
