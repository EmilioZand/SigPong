module Elo
  DELTA_TAU = 0.94
  MAX_TAU = 20

  def self.team_elo(players)
    (players.sum(&:elo).to_f / players.count).round(2)
  end

  def self.calculate_win_percentage(e1, e2)
    ((1 - 1 / (10 ** ((e1 - e2) / 400) + 1)) * 100).round(2)
  end
  
  def self.team_win_percentage(t1, t2)
    t1_elo = Elo.team_elo(t1)
    t2_elo = Elo.team_elo(t2)
    Elo.calculate_win_percentage(t1_elo, t2_elo)
  end
end
