(function(){
  var index;
  
  $(document).ready(function() {

    // load searchIndex.json
    $.getJSON('searchIndex.json', function(indexData) {
      index = lunr.Index.load(indexData);
    });

    // load searchData.json
    $.getJSON('searchData.json', function(searchData) {

    });

    var search = function(term) {
      index.search(term);
    }

    // callback on key up inside of the search box that performs a search
    $('input').bind('keyup', function() {
      if ($(this).val() < 2) return;
      var searchQuery = $this.val();
      var searchResults = index.search(searchQuery).map(function(result) {
        // todo: match against loaded data
      });
    });

    // callback to clear search results 
    $('a.all').bind('click', function() {
      clearSearchResults();
      $('input').val('');
    });

  });

})()

