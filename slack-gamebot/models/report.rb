class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  index(state: 1, channel: 1)

  SORT_ORDERS = ['created_at', '-created_at', 'updated_at', '-updated_at', 'state', '-state', 'channel', '-channel']

  field :state, type: String, default: ReportState::PROPOSED
  field :channel, type: String

  belongs_to :team, index: true
  belongs_to :season, inverse_of: :reports, index: true
  belongs_to :created_by, class_name: 'User', inverse_of: nil, index: true
  belongs_to :updated_by, class_name: 'User', inverse_of: nil, index: true


  has_and_belongs_to_many :reporters, class_name: 'User', inverse_of: nil
  has_and_belongs_to_many :opponents, class_name: 'User', inverse_of: nil

  field :scores, type: Array
  field :reporter_won, type: Boolean
  field :reporter_team, type: String
  field :opponent_team, type: String
  has_one :match

  validate :validate_playing_against_themselves
  validate :validate_unique_report
  validate :validate_teams

  index({ reporter_ids: 1, state: 1 }, name: 'active_reporter_index')
  index({ opponent_ids: 1, state: 1 }, name: 'active_opponent_index')

  validate :validate_updated_by
  validate :validate_scores
  validates_presence_of :updated_by, if: ->(report) { report.state != ReportState::PROPOSED }
  validates_presence_of :team
  validates_presence_of :reporter_won

  # current reports are not in an archived season
  scope :current, -> { where(season_id: nil) }

  # reports scoped by state
  ReportState.values.each do |state|
    scope state.to_sym, -> { where(state: state) }
  end

  def scores?
    scores && scores.any?
  end

  def proposed?
    state == ReportState::PROPOSED
  end

  def reporter_lost?
    Score.lost?(scores)
  end

  def self.opponent_won?(scores)
    return Score.lost?(scores)
  end

  def self.create_from_teammates_and_opponents!(team, channel, reporter, opponent, scores, reporter_team = nil, opponent_team = nil)
    if Report.opponent_won?(scores)
        won = false
    else
        won = true
    end

    report = Report.create!(
      team: team,
      channel: channel,
      created_by: reporter,
      reporters: [reporter],
      opponents: [opponent],
      reporter_team: reporter_team,
      opponent_team: opponent_team,
      reporter_won: won,
      state: ReportState::PROPOSED,
      scores: scores
    )

    report
  end

  def confirm!(confirmer)
    fail SlackGamebot::Error, "Repprt has already been #{state}." unless state == ReportState::PROPOSED
    if(reporter_lost?)
      match = ::Match.lose!(team: team, winners: opponents, losers: reporters, scores: scores, winner_team: opponent_team, loser_team: reporter_team)
    else
      match = ::Match.lose!(team: team, winners: reporters, losers: opponents, scores: Score.reverse_scores(scores), winner_team: reporter_team, loser_team: opponent_team)
    end
    update_attributes!(updated_by: confirmer, state: ReportState::CONFIRMED)
  end

  def contest!(contester)
    fail SlackGamebot::Error, "Report has already been #{state}." unless state == ReportState::PROPOSED
    update_attributes!(updated_by: contester, state: ReportState::CONTESTED)
  end

  def cancel!(canceller)
    fail SlackGamebot::Error, "Report has already been #{state}." unless state == ReportState::PROPOSED
    update_attributes!(updated_by: canceller, state: ReportState::CANCELLED)
  end 

  def to_s
    if(reporter_team && opponent_team)
      "#{reporters.first.display_name} has claimed they #{score_verb} #{opponents.first.display_name} #{Score.reporter_first_scores_to_string(scores)} with with #{reporter_team} vs. #{opponent_team}. I need #{opponents.first.display_name} to confirm by typing `pp confirm #{created_by.user_name}` or contest with `pp contest #{created_by.user_name}`. Otherwise the report will auto-confirm in 24h."
    else
      "#{reporters.first.display_name} has claimed they #{score_verb} #{opponents.first.display_name} #{Score.match_score_to_string(scores)} with #{Score.reporter_first_scores_to_string(scores)}. I need #{opponents.first.display_name} to confirm by typing `pp confirm #{created_by.user_name}` or contest with `pp contest #{created_by.user_name}`. Otherwise the report will auto-confirm in 24h."
    end
  end

  def self.confirm_outstanding_reports
    num_reports = Report.proposed.count
    Report.proposed.each do |report|
      logger.info "Confirming report #{report._id}"
      report.confirm!(report.opponents.first)
      report.team.inform! "@#{report.opponents.map(&:user_name).and} and @#{report.reporters.map(&:user_name).and}'s reported score was auto-confirmed by the lovely AI brain of SigPong", "robot"
    end
    logger.info "Confirmed #{num_reports} reports."
  end

  def self.find_by_users(team, channel, player1, player2, states = [ReportState::PROPOSED])
    Report.any_of(
      { reporter_ids: player1._id,  opponent_ids: player2._id},
      { reporter_ids: player2._id,  opponent_ids: player1._id}
    ).where(
      team: team,
      channel: channel,
      :state.in => states
    ).first
  end
  
  def self.find_by_opponent(team, channel, player, states = [ReportState::PROPOSED])
    Report.any_of(
      { opponent_ids: player._id }
    ).where(
      team: team,
      channel: channel,
      :state.in => states
    ).first
  end

  def self.find_by_reporter(team, channel, player, states = [ReportState::PROPOSED])
    Report.where(
      created_by: player,
      team: team,
      channel: channel,
      :state.in => states
    ).first
  end

  private

  def score_verb
    if reporter_won
        "beat"
    else
        "lost to"
    end
  end

  def validate_playing_against_themselves
    intersection = reporters & opponents
    errors.add(:challengers, "Player #{intersection.first.user_name} cannot play against themselves.") if intersection.any?
  end

  def validate_teams
    teams = [team]
    teams.concat(reporters.map(&:team))
    teams.concat(opponents.map(&:team))
    teams << match.team if match
    teams << season.team if season
    teams.uniq!
    errors.add(:team, 'Can only play others on the same team.') if teams.count != 1
  end

  def validate_unique_report
    return unless state == ReportState::PROPOSED
    existing_report = ::Report.find_by_users(team, channel, reporters.first, opponents.first)
    return unless existing_report.present?
    return if existing_report == self
    errors.add(:report, "#{reporters.map(&:user_name).and} and #{opponents.map(&:user_name).and} already have an outstanding report.")
  end

  def validate_updated_by
    case state
    when ReportState::CONFIRMED
      return if updated_by && opponents.include?(updated_by)
      errors.add(:confirmed_by, "Only #{opponents.map(&:user_name).and} can confirmed this report.")
    when ReportState::CONTESTED
      return if updated_by && opponents.include?(updated_by)
      errors.add(:declined_by, "Only #{opponents.map(&:user_name).and} can contest this report.")
    when ReportState::CANCELLED
      return if updated_by && (opponents.include?(updated_by) || reporters.include?(updated_by))
      errors.add(:declined_by, "Only #{reporters.map(&:user_name).and} or #{opponents.map(&:user_name).and} can cancel this report.")
    end
  end

  def validate_scores
    return unless scores && scores.any?
    errors.add(:scores, 'Scores must be in the form xx:xx xx:xx xx:xx') unless Score.is_valid?(scores)
  end

end
