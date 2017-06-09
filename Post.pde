class Post {

  String title;
  int shares;

  ArrayList<String> persons;
  ArrayList<String> organizations;  
  ArrayList<String> locations;
  Post() {

    title = "";
    shares = 0;
    persons = new ArrayList<String>();
    organizations = new ArrayList<String>();
    locations = new ArrayList<String>();
  }

  void addPerson(String name) {
    persons.add(name);
  }

  void addOrganization(String organization) {
    organizations.add(organization);
  }

  void addLocation(String location) {
    locations.add(location);
  }

  ArrayList<String> getPersons() {
    return persons;
  }

  ArrayList<String> getOrganizations() {
    return organizations;
  }

  ArrayList<String> getLocations() {
    return locations;
  }
}