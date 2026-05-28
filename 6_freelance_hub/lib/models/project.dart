enum ProjectStatus { open, active, delivered, completed, disputed, closed }

class Project {
  const Project({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.skills,
    required this.category,
    required this.minBudget,
    required this.maxBudget,
    required this.isHourly,
    required this.proposalCount,
    required this.createdAt,
    required this.status,
    required this.clientName,
    this.hasHeroImage = false,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final List<String> skills;
  final String category;
  final double minBudget;
  final double maxBudget;
  final bool isHourly;
  final int proposalCount;
  final DateTime createdAt;
  final ProjectStatus status;
  final String clientName;
  final bool hasHeroImage;

  String formattedBudget() {
    final min = _formatCurrency(minBudget);
    final max = _formatCurrency(maxBudget);
    final suffix = isHourly ? '/h' : '';
    if (minBudget == maxBudget) return '$min$suffix';
    return '$min - $max$suffix';
  }

  String budgetTypeLabel() => isHourly ? 'Por hora' : 'Preço fixo';

  String relativePostedLabel({DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(createdAt);
    if (diff.inDays >= 1) {
      final d = diff.inDays;
      return d == 1 ? 'há 1 dia' : 'há $d dias';
    }
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      return h == 1 ? 'há 1 hora' : 'há $h horas';
    }
    if (diff.inMinutes >= 1) {
      final m = diff.inMinutes;
      return m == 1 ? 'há 1 minuto' : 'há $m minutos';
    }
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

List<Project> get mockProjects {
  final now = DateTime.now();
  return [
    Project(
      id: 'p1',
      ownerId: 'mock-owner-1',
      title: 'Redesign de UI de app mobile',
      skills: const ['UI/UX', 'Figma'],
      category: 'Design',
      minBudget: 2500,
      maxBudget: 4000,
      isHourly: false,
      proposalCount: 12,
      createdAt: now.subtract(const Duration(hours: 2)),
      status: ProjectStatus.open,
      description:
          'Buscamos um designer experiente para liderar a remodelagem completa '
          'da interface do nosso aplicativo de fintech. Precisamos de um visual '
          'moderno, limpo e acessível, com atenção especial à jornada de '
          'onboarding e ao fluxo de pagamentos.\n\nForneceremos guidelines de '
          'marca, personas de usuário e acesso a um design system inicial. O '
          'entregável final são telas em alta fidelidade (Figma) cobrindo todos '
          'os fluxos principais e protótipo navegável.',
      clientName: 'Ana Beltrão',
    ),
    Project(
      id: 'p2',
      ownerId: 'mock-owner-2',
      title: 'Escalar backend de e-commerce',
      skills: const ['Node.js', 'AWS'],
      category: 'Desenvolvimento',
      minBudget: 60,
      maxBudget: 90,
      isHourly: true,
      proposalCount: 5,
      createdAt: now.subtract(const Duration(hours: 4)),
      status: ProjectStatus.open,
      hasHeroImage: true,
      description:
          'Nossa plataforma cresceu 300% em 6 meses e o backend atual (Node.js + '
          'PostgreSQL) está sofrendo gargalos em picos de tráfego. Procuramos um '
          'especialista em AWS para arquitetar uma solução escalável: revisão de '
          'queries, estratégia de cache (Redis/CloudFront), filas de jobs (SQS) '
          'e auto-scaling.\n\nDocumentação detalhada é obrigatória. Pagamento '
          'por hora.',
      clientName: 'Marcelo Vargas',
    ),
    Project(
      id: 'p3',
      ownerId: 'mock-owner-3',
      title: 'Tema WordPress sob medida',
      skills: const ['PHP', 'WordPress'],
      category: 'Desenvolvimento',
      minBudget: 800,
      maxBudget: 1200,
      isHourly: false,
      proposalCount: 28,
      createdAt: now.subtract(const Duration(days: 1)),
      status: ProjectStatus.open,
      description:
          'Estúdio de fotografia precisa de tema WordPress 100% personalizado. '
          'Requisitos: galeria responsiva com lazy-load, área de cliente '
          'protegida por senha (download de fotos), integração com Instagram '
          'API e otimização agressiva de Core Web Vitals.\n\nPerformance é '
          'prioridade máxima — meta de LCP < 1.5s.',
      clientName: 'Júlia Cardoso',
    ),
    Project(
      id: 'p4',
      ownerId: 'mock-owner-4',
      title: 'Renovação de identidade visual',
      skills: const ['Branding', 'Logo Design'],
      category: 'Design',
      minBudget: 1500,
      maxBudget: 1500,
      isHourly: false,
      proposalCount: 42,
      createdAt: now.subtract(const Duration(days: 2)),
      status: ProjectStatus.open,
      description:
          'Marca consolidada há 8 anos buscando atualização completa: logo, '
          'paleta de cores, tipografia, aplicações em mídia digital e impressa. '
          'Mantemos a herança visual original mas com linguagem contemporânea '
          '— evolução, não revolução.\n\nEntregáveis: brand book completo, '
          'arquivos vetoriais em todos os formatos e guia de uso para a equipe '
          'interna.',
      clientName: 'Studio Aurora',
    ),
  ];
}
