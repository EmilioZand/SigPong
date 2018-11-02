class UserTeam
    include Mongoid::Document
  
    belongs_to :user
  
    field :user_name, type: String
    field :team_name, type: String
    field :played, type: Integer, default: 0
    field :wins, type: Integer, default: 0
    field :losses, type: Integer, default: 0  
end
