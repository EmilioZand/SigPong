class UserTeam
    include Mongoid::Document

    SORT_ORDERS = ['created_at', '-created_at']

    belongs_to :user, index: true
    belongs_to :team, index: true
  
    field :user_name, type: String
    field :team_name, type: String
    field :played, type: Integer, default: 0
    field :wins, type: Integer, default: 0
    field :losses, type: Integer, default: 0  
end
