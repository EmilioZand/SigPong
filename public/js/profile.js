$(document).ready(function() {
  var user_id =  window.location.href.substring(url.lastIndexOf('/') + 1);
  var elo_history = [];
  $.ajax({
    type: "GET",
    url: `https://sigpong.herokuapp.com/api/users/#{user_id}`,
    success: function(user) {
      elo_history = user.elo_history;
      matches = user.matches;
      $('#user-name').append(user.user_name);
      $('#wins').append(user.wins + "W");
      $('#losses').append(user.losses + "L");
      $('#elo').append(user.elo + " ELO");
      $('#win-streak').append(user.winning_streak + "W");
      $('#lose-streak').append(user.losing_streak + "L");

      var table = $('<table></table>').addClass('table recent-matches');
      table.append( '<thead><tr><th>' + 'Winner' + '</th><th>' + 'Loser' + '</th><th>'+ 'Score' + '</th><th>' + "ELO Change" + '</th></tr></thead>' );
      for(var i=0;i<matches.length;i++){
        var match = matches[i];
        match.elo_change = elo_history.pop();
        var games = match.scores;
        var loserScore = 0;
        var winnerScore = 0;
        for(var j=0;j<games.length;j++){
          games[j][0] > games[j][1] ? loserScore++ : winnerScore++;
        }
        var overallScore = winnerScore + ' : ' + loserScore
        table.append( '<tr><td>' + match.winners[0].user_name + '</td><td>' + match.losers[0].user_name + '</td><td>'+ overallScore + '</td><td>' + (match.elo_change || '') + '</td></tr>' );
      }
      $('#recent-matches').append(table);
    },
  });
});
