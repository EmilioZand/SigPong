class UserTeam
    include Mongoid::Document

    SORT_ORDERS = ['created_at', '-created_at']

    belongs_to :user
    belongs_to :team
  
    field :user_name, type: String
    field :team_name, type: String
    field :played, type: Integer, default: 0
    field :wins, type: Integer, default: 0
    field :losses, type: Integer, default: 0  
end
