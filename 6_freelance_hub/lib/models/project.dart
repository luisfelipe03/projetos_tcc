class Project {
  const Project({
    required this.id,
    required this.title,
    required this.skills,
    required this.minBudget,
    required this.maxBudget,
    required this.isHourly,
    required this.proposalCount,
    required this.postedAgo,
    this.hasHeroImage = false,
  });

  final String id;
  final String title;
  final List<String> skills;
  final double minBudget;
  final double maxBudget;
  final bool isHourly;
  final int proposalCount;
  final Duration postedAgo;
  final bool hasHeroImage;

  String formattedBudget() {
    final min = _formatCurrency(minBudget);
    final max = _formatCurrency(maxBudget);
    final suffix = isHourly ? '/h' : '';
    if (minBudget == maxBudget) return '$min$suffix';
    return '$min - $max$suffix';
  }

  String budgetTypeLabel() => isHourly ? 'Por hora' : 'Preço fixo';

  String relativePostedLabel() {
    final h = postedAgo.inHours;
    final d = postedAgo.inDays;
    if (d >= 1) return d == 1 ? 'há 1 dia' : 'há $d dias';
    if (h >= 1) return h == 1 ? 'há 1 hora' : 'há $h horas';
    return 'agora';
  }

  static String _formatCurrency(double value) {
    final intPart = value.truncate();
    final buf = StringBuffer('R\$ ');
    final str = intPart.toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

const mockProjects = <Project>[
  Project(
    id: 'p1',
    title: 'Redesign de UI de app mobile',
    skills: ['UI/UX', 'Figma'],
    minBudget: 2500,
    maxBudget: 4000,
    isHourly: false,
    proposalCount: 12,
    postedAgo: Duration(hours: 2),
  ),
  Project(
    id: 'p2',
    title: 'Escalar backend de e-commerce',
    skills: ['Node.js', 'AWS'],
    minBudget: 60,
    maxBudget: 90,
    isHourly: true,
    proposalCount: 5,
    postedAgo: Duration(hours: 4),
    hasHeroImage: true,
  ),
  Project(
    id: 'p3',
    title: 'Tema WordPress sob medida',
    skills: ['PHP', 'WordPress'],
    minBudget: 800,
    maxBudget: 1200,
    isHourly: false,
    proposalCount: 28,
    postedAgo: Duration(days: 1),
  ),
  Project(
    id: 'p4',
    title: 'Renovação de identidade visual',
    skills: ['Branding', 'Logo Design'],
    minBudget: 1500,
    maxBudget: 1500,
    isHourly: false,
    proposalCount: 42,
    postedAgo: Duration(days: 2),
  ),
];
