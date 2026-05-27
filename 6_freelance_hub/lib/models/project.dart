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
    required this.description,
    required this.clientName,
    required this.clientRating,
    required this.clientProjectsCount,
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
  final String description;
  final String clientName;
  final double clientRating;
  final int clientProjectsCount;

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
    description:
        'Buscamos um designer experiente para liderar a remodelagem completa '
        'da interface do nosso aplicativo de fintech. Precisamos de um visual '
        'moderno, limpo e acessível, com atenção especial à jornada de '
        'onboarding e ao fluxo de pagamentos.\n\nForneceremos guidelines de '
        'marca, personas de usuário e acesso a um design system inicial. O '
        'entregável final são telas em alta fidelidade (Figma) cobrindo todos '
        'os fluxos principais e protótipo navegável.',
    clientName: 'Ana Beltrão',
    clientRating: 4.8,
    clientProjectsCount: 12,
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
    description:
        'Nossa plataforma cresceu 300% em 6 meses e o backend atual (Node.js + '
        'PostgreSQL) está sofrendo gargalos em picos de tráfego. Procuramos um '
        'especialista em AWS para arquitetar uma solução escalável: revisão de '
        'queries, estratégia de cache (Redis/CloudFront), filas de jobs (SQS) '
        'e auto-scaling.\n\nDocumentação detalhada é obrigatória. Pagamento '
        'por hora.',
    clientName: 'Marcelo Vargas',
    clientRating: 4.6,
    clientProjectsCount: 7,
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
    description:
        'Estúdio de fotografia precisa de tema WordPress 100% personalizado. '
        'Requisitos: galeria responsiva com lazy-load, área de cliente '
        'protegida por senha (download de fotos), integração com Instagram '
        'API e otimização agressiva de Core Web Vitals.\n\nPerformance é '
        'prioridade máxima — meta de LCP < 1.5s.',
    clientName: 'Júlia Cardoso',
    clientRating: 5.0,
    clientProjectsCount: 24,
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
    description:
        'Marca consolidada há 8 anos buscando atualização completa: logo, '
        'paleta de cores, tipografia, aplicações em mídia digital e impressa. '
        'Mantemos a herança visual original mas com linguagem contemporânea '
        '— evolução, não revolução.\n\nEntregáveis: brand book completo, '
        'arquivos vetoriais em todos os formatos e guia de uso para a equipe '
        'interna.',
    clientName: 'Studio Aurora',
    clientRating: 4.7,
    clientProjectsCount: 18,
  ),
];
