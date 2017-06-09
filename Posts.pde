class Posts {

  JSONObject json;
  ArrayList<Post> thePosts;
  String title;
  int shares;
  String query = "http://webhose.io/filterWebContent?token=c7931307-a99c-4af1-8d72-8b913b23de5e&format=json&ts=1496599424042&sort=crawled&q=climate%20change%20social.facebook.likes%3A%3E100";
  boolean dataLoaded;

  Posts() {
  }

  void queryData() {

    thePosts = new ArrayList<Post>();

    try {
      json = loadJSONObject(query);
    } catch (Exception e) {
      println("Connection Error");
    }

    JSONArray posts = json.getJSONArray("posts");

    for (int i = 0; i < posts.size(); i++) {
      JSONObject post = posts.getJSONObject(i);
      Post currentPost = new Post();
      currentPost.title = post.getString("title");
      currentPost.shares = post.getJSONObject("thread").getJSONObject("social").getJSONObject("facebook").getInt("shares");

      JSONArray persons = post.getJSONObject("entities").getJSONArray("persons");
      for (int p = 0; p < persons.size(); p++) {
        String name = persons.getJSONObject(p).getString("name");
        currentPost.addPerson(name);
      }

      JSONArray organizations = post.getJSONObject("entities").getJSONArray("organizations");
      for (int p = 0; p < organizations.size(); p++) {
        String organization = organizations.getJSONObject(p).getString("name");
        currentPost.addOrganization(organization);
      }

      JSONArray locations = post.getJSONObject("entities").getJSONArray("locations");
      for (int p = 0; p < locations.size(); p++) {
        String location = locations.getJSONObject(p).getString("name");
        currentPost.addLocation(location);
      }
      thePosts.add(currentPost);
    }
    dataLoaded = true;
  }
}