$(document).ready(function() {

  $.ajax({
    type: "GET",
    url: "api/season?team_id=59408e751865720006b81b9d",
    success: function(data) {
      for (var user in data.users_ranks) {
        if(user.winning_streak != 0) {
          user.streak = 'W' + user.winning_streak;
        } else {
          user.streak = 'L' + user.losing_streak
        }
        if(user.rank) {
          ranked_users.append(user);
        }
      }

      var users_count = ranked_users.count;

      var table = $('<table></table>').addClass('leaderboard');
      $table.append( '<th><td>' + 'Rank' + '</td><td>' + 'Name' + '</td><td>'+ 'ELO' + '</td><td>' + 'Wins' + '</td><td>' + 'Loses' + '</td><td>' + "Streak" + '</td></th>' );
      for(var user in ranked_users){
         $table.append( '<tr><td>' + user.rank + '</td><td>' + user.user_name + '</td><td>'+ (user.elo + 1200) + '</td><td>' + user.wins + '</td><td>' + user.loses + '</td><td>' + user.streak + '</td></tr>' );
      }

      $('#leaderboard').append(table);
    },
  });
});
