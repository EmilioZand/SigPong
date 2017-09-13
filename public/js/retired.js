$(document).ready(function() {
  $.ajax({
    type: "GET",
    url: "api/users/retired?team_id=59408e751865720006b81b9d&size=100",
    success: function(data) {
      var users = data._embedded.users;
      var table = $('<table></table>').addClass('table retired-users');
      table.append( '<thead><tr><th>' + 'Rank' + '</th><th>' + 'Name' + '</th><th>'+ 'ELO' + '</th><th>' + 'Wins' + '</th><th>' + 'Losses' + '</th><th>' + "Current Streak" + '</th><th>' + "Longest Winning" + '</th><th>' + "Longest Losing" +'</th></tr></thead>' );

      for(var i=0; i<users.length; i++){
        var user = users[i];
        let user_link =`<a href=/profile?user=${user.user_name}>${user.user_name}</a>`
        var streakText = "";
        if(user.current_streak_is_win === true){
          streakText = "W" + user.current_streak;
        } else if(user.current_streak_is_win === false) {
          streakText = "L" + user.current_streak;
        }
        table.append( '<tr><td>' + (i+1) + '</td><td>' + user_link + '</td><td>'+ (user.elo + 1200) + '</td><td>' + user.wins + '</td><td>' + user.losses + '</td><td>' + streakText + '</td><td>' + "W" + user.winning_streak + '</td><td>' + "L" + user.losing_streak + '</td></tr>' );
      }
      $('#retired-users').append(table);
    },
  });
});
