$(document).ready(function() {
  let url = new URL(window.location.href)
  let searchParams = new URLSearchParams(url.search);
  let user_name = searchParams.get('user');
let ajaxUrl = "api/matches/user?user_name=" + user_name;
  $.ajax({
    type: "GET",
    url: ajaxUrl,
    success: function(data) {
      var table = $('<table></table>').addClass('table recent-matches');
      var matches = data._embedded.matches
      table.append( '<thead><tr><th>' + 'Winner' + '</th><th>' + 'Loser' + '</th><th>'+ 'Score' + '</th><th>' + "ELO Gain/Loss" + '</th></tr></thead>' );
      for(var i=0;i<matches.length;i++){
        var match = matches[i];
        var games = match.scores;
        var loserScore = 0;
        var winnerScore = 0;
        var overallScore = "";
        let winner_user_name = match.winners[0].user_name;
        let loser_user_name = match.losers[0].user_name
        let winner_link =`<a class="winner" href=/profile?user=${winner_user_name}>${winner_user_name}</a>`
        let loser_link =`<a class="loser" href=/profile?user=${loser_user_name}>${loser_user_name}</a>`
        if (games){
          for(var j=0;j<games.length;j++){
            games[j][0] > games[j][1] ? loserScore++ : winnerScore++;
          }
          overallScore = winnerScore + ' : ' + loserScore
        }
        table.append( '<tr><td>' + winner_link + '</td><td>' + loser_link + '</td><td>'+ overallScore + '</td><td>+' + (match.elo_gain || '') + ' / -' + (match.elo_loss || '') + '</td></tr>' );
      }
      $('#recent-matches').append(table);
    },
  });
});
