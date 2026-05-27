enum UserRole {
  client(
    displayName: 'Cliente',
    tagline: 'Contrate freelancers e\npublique projetos.',
  ),
  freelancer(
    displayName: 'Freelancer',
    tagline: 'Receba projetos e\ngerencie entregas.',
  );

  const UserRole({required this.displayName, required this.tagline});

  final String displayName;
  final String tagline;
}
