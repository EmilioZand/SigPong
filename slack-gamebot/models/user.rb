class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: String
  field :user_name, type: String
  field :wins, type: Integer, default: 0
  field :losses, type: Integer, default: 0
  field :games, type: Integer, default: ->{wins + losses + ties}
  field :losing_streak, type: Integer, default: 0
  field :winning_streak, type: Integer, default: 0
  field :current_streak, type: Integer, default: 0
  field :current_streak_is_win, type: Boolean, default: true
  field :ties, type: Integer, default: 0
  field :elo, type: Integer, default: 0
  field :elo_history, type: Array, default: []
  field :tau, type: Float, default: 0
  field :rank, type: Integer
  field :captain, type: Boolean, default: false
  field :registered, type: Boolean, default: true
  field :retired, type: Boolean, default: false
  field :nickname, type: String
  field :avatar, type: String
  field :favorite_team, type: String
  field :most_played_team, type: String


  belongs_to :team, index: true
  validates_presence_of :team

  index({ user_id: 1, team_id: 1 }, unique: true)
  index(user_name: 1, team_id: 1)
  index(wins: 1, team_id: 1)
  index(losses: 1, team_id: 1)
  index(ties: 1, team_id: 1)
  index(elo: 1, team_id: 1)
  index(games: 1, team_id: 1)
  index(most_played_team: 1, team_id: 1)
  index(current_streak: 1, team_id: 1)
  index(current_streak_is_win: 1, team_id: 1)


  before_save :update_elo_history!
  before_save :update_game_count!
  after_save :rank!

  SORT_ORDERS = ['elo', '-elo', 'created_at', '-created_at', 'wins', '-wins', 'losses', '-losses', 'ties', '-ties', 'user_name', '-user_name', 'rank', '-rank']

  scope :ranked, -> { where(:rank.ne => nil, :retired => false) }
  scope :placed, -> { where(:rank.ne => nil, :games.gte => 8, :retired => false) }
  scope :unplaced, -> { where(:rank.ne => nil, :games.lt => 8, :retired => false) }
  scope :captains, -> { where(captain: true) }
  scope :retired, -> { where(retired: true) }

  def current_matches
    Match.current.where(team: team).or({ winner_ids: _id }, loser_ids: _id)
  end

  def slack_mention
    "<@#{user_id}>"
  end

  def display_name
    registered ? nickname || user_name : '<unregistered>'
  end

  def inspect
    "lemme check my notes here, uh... oh, #{display_name}"
  end

  def self.slack_mention?(user_name)
    Regexp.last_match[1] if user_name =~ /^<@(.*)>$/
  end

  def self.find_by_slack_mention!(team, user_name)
    slack_id = slack_mention?(user_name)
    user = if slack_id
             User.where(user_id: slack_id, team: team).first
           else
             regexp = Regexp.new("^#{user_name}$", 'i')
             User.where(team: team).or({ user_name: regexp }, nickname: regexp).first
           end
    fail SlackGamebot::Error, "I don't know who #{user_name} is! Ask them to _register_." unless user && user.registered?
    user
  end

  def self.find_many_by_slack_mention!(team, user_names)
    user_names.map { |user| find_by_slack_mention!(team, user) }
  end

  def self.find_challenger(user)
     criteria = User.ranked.where(
      :user_name.nin => [user.user_name],
      :rank.gte => user.rank-3,
      :rank.lte => user.rank+3,
      team: user.team
    )
    random_user = criteria.skip(rand(criteria.count)).first
  end

  # Find an existing record, update the username if necessary, otherwise create a user record.
  def self.find_create_or_update_by_slack_id!(client, slack_id)
    instance = User.where(team: client.owner, user_id: slack_id).first
    instance_info = Hashie::Mash.new(client.web_client.users_info(user: slack_id)).user
    instance.update_attributes!(user_name: instance_info.name) if instance && instance.user_name != instance_info.name
    instance ||= User.create!(team: client.owner, user_id: slack_id, user_name: instance_info.name)
    instance.promote! unless instance.captain? || client.owner.captains.count > 0
    instance
  end

  def self.reset_all!(team)
    User.where(team: team).set(
      wins: 0,
      losses: 0,
      ties: 0,
      elo: 0,
      elo_history: [],
      tau: 0,
      rank: nil,
      losing_streak: 0,
      winning_streak: 0
    )
  end

  def to_s
    wins_s = "#{wins} win#{wins != 1 ? 's' : ''}"
    losses_s = "#{losses} loss#{losses != 1 ? 'es' : ''}"
    ties_s = "#{ties} tie#{ties != 1 ? 's' : ''}" if ties && ties > 0
    elo_s = "elo: #{team_elo}"
    lws_s = "lws: #{winning_streak}" if winning_streak >= losing_streak && winning_streak >= 3
    lls_s = "lls: #{losing_streak}" if losing_streak > winning_streak && losing_streak >= 3
    "#{display_name}: #{[wins_s, losses_s, ties_s].compact.join(', ')} (#{[elo_s, lws_s, lls_s].compact.join(', ')})"
  end

  def team_elo
    elo + team.elo
  end

  def promote!
    update_attributes!(captain: true)
  end

  def demote!
    update_attributes!(captain: false)
  end

  def register!
    return if registered?
    update_attributes!(registered: true)
    User.rank!(team)
  end

  def unregister!
    return unless registered?
    update_attributes!(registered: false, rank: nil)
    User.rank!(team)
  end

  def rank!
    return unless elo_changed?
    User.rank!(team)
    reload.rank
  end

  def update_elo_history!
    return unless elo_changed?
    elo_history << elo
  end

  def update_game_count!
    return unless wins_changed? || losses_changed? || ties_changed?
    games = wins + losses + ties
  end

  def self.rank!(team)
    rank = 1
    players = any_of({ :wins.gt => 0 }, { :losses.gt => 0 }, :ties.gt => 0).where(team: team, registered: true, retired: false).desc(:elo).desc(:wins).asc(:losses).desc(:ties)
    players.each_with_index do |player, index|
      if player.registered?
        games = player.wins + player.losses + player.ties
        player.set(games: games) unless games == player.games
        rank += 1 if index > 0 && [:elo, :wins, :losses, :ties].any? { |property| players[index - 1].send(property) != player.send(property) }
        player.set(rank: rank) unless rank == player.rank
      end
    end
  end

  def calculate_streaks!
    longest_winning_streak = 0
    longest_losing_streak = 0
    current_winning_streak = 0
    current_losing_streak = 0
    current_matches.asc(:_id).each do |match|
      if match.tied?
        current_winning_streak = 0
        current_losing_streak = 0
      elsif match.winner_ids.include?(_id)
        current_losing_streak = 0
        current_winning_streak += 1
      else
        current_winning_streak = 0
        current_losing_streak += 1
      end
      longest_losing_streak = current_losing_streak if current_losing_streak > longest_losing_streak
      longest_winning_streak = current_winning_streak if current_winning_streak > longest_winning_streak
    end
    if current_winning_streak > current_losing_streak
      current_streak_value = current_winning_streak
      current_streak_is_win_flag = true
    else
      current_streak_value = current_losing_streak
      current_streak_is_win_flag = false
    end
    return if losing_streak == longest_losing_streak && winning_streak == longest_winning_streak && current_streak == current_streak_value && current_streak_is_win == current_streak_is_win_flag
    update_attributes!(losing_streak: longest_losing_streak, winning_streak: longest_winning_streak, current_streak: current_streak_value, current_streak_is_win: current_streak_is_win_flag)
  end

  def calculate_streak_with_win!
    if current_streak_is_win && (winning_streak <= current_streak)
      update_attributes!(current_streak: (current_streak+1), winning_streak: (current_streak+1))
    elsif current_streak_is_win
      update_attributes!(current_streak: (current_streak+1))
    else
      update_attributes!(current_streak: 1, current_streak_is_win: true)
    end
  end

  def calculate_streak_with_loss!
    if !current_streak_is_win && (losing_streak <= current_streak)
      update_attributes!(current_streak: (current_streak+1), losing_streak: (current_streak+1))
    elsif !current_streak_is_win
      update_attributes!(current_streak: (current_streak+1))
    else
      update_attributes!(current_streak: 1, current_streak_is_win: false)
    end
  end

  def update_teams_played!(team_played, won)
    team = UserTeam.where(user: self, team_name: team_played).first
    if(team.nil?)
      if(won)
        UserTeam.create!(team: self.team, user: self, user_name: self.user_name, team_name: team_played, wins: 1, played: 1)
      else
        UserTeam.create!(team: self.team, user: self, user_name: self.user_name, team_name: team_played, losses: 1, played: 1)
      end
    else
      if(won)
        team.update_attributes!(wins: (team.wins+1), played: (team.played+1))
      else
        team.update_attributes!(losses: (team.losses+1), played: (team.played+1))
      end
    end
    determine_most_played_team!
  end

  def determine_most_played_team!
    team = UserTeam.where(user: self).order_by(played: :desc).limit(1).first
    update_attributes!(most_played_team: team.team_name) unless team.nil?
  end

  def self.rank_section(team, users)
    ranks = users.map(&:rank)
    return users unless ranks.min && ranks.max
    where(team: team, :rank.gte => ranks.min, :rank.lte => ranks.max).asc(:rank).asc(:wins).asc(:ties)
  end
end
