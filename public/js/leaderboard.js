$(document).ready(function() {
  $.ajax({
    type: "GET",
    url: "api/users?team_id=59408e751865720006b81b9d",
    success: function(data) {
      var users = data._embedded.users;
      var table = $('<table></table>').addClass('table leaderboard');
      table.append( '<thead><tr><th>' + 'Rank' + '</th><th>' + 'Name' + '</th><th>'+ 'ELO' + '</th><th>' + 'Wins' + '</th><th>' + 'Loses' + '</th><th>' + "Streak" + '</th></tr></thead>' );

      for(var i=0; i<users.length; i++){
        var user = users[i];
        if(!user.rank){
          continue;
        }
        if(user.winning_streak != 0) {
          user.streak = 'W' + user.winning_streak;
        } else {
          user.streak = 'L' + user.losing_streak
        }
        table.append( '<tr><td>' + user.rank + '</td><td>' + user.user_name + '</td><td>'+ (user.elo + 1200) + '</td><td>' + user.wins + '</td><td>' + user.losses + '</td><td>' + user.streak + '</td></tr>' );
      }
      $('#leaderboard').append(table);
    },
  });
});
